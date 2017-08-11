//
//  ATLMCarouselCardCollectionViewCell.m
//  Atlas Messenger
//
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import "ATLMCarouselCardCollectionViewCell.h"
#import "ATLMCarouselCard.h"
#import "ATLMLayerController.h"
#import "ATLMCarouselProductCell.h"
#import <SafariServices/SafariServices.h>

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark - Constants
#endif

static const CGFloat ATLMCarouselCardCollectionViewProgressSize = 64.0;
static const CGFloat ATLMCarouselCardCollectionViewAvatarLeadPadding = 12.0;
static const CGFloat ATLMCarouselCardCollectionViewAvatarTailPadding = 4.0;


#if 0
#pragma mark - Functions
#endif

static inline UIColor *
ATLMCarouselCardCollectionViewCellBackgroundColor(ATLCellType type) {
    return ((ATLOutgoingCellType == type) ? ATLBlueColor() : ATLLightGrayColor());
}

static inline UIColor *
ATLMCarouselCardCollectionViewCellForegroundColor(ATLCellType type) {
    if (ATLOutgoingCellType == type) {
        return [UIColor whiteColor];
    }
    return [UIColor colorWithRed:49.0/255.0 green:63.0/255.0 blue:72.0/255.0 alpha:1.0];
}


#if 0
#pragma mark -
#endif

@interface ATLMCarouselCardAvatarCell : UICollectionViewCell
@property (nonatomic, strong, readonly) ATLAvatarView *avatar;
@end


#if 0
#pragma mark -
#endif

@interface ATLMCarouselCardCollectionViewCell () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong, readwrite, nullable) ATLMCarouselCard *card;
@property (nonatomic, assign, readwrite) ATLCellType type;
@property (nonatomic, strong, readwrite, nullable) NSURLSessionDataTask *task;
@property (nonatomic, strong, readonly) UICollectionView *carousel;
@property (nonatomic, strong, readonly) ATLProgressView *progress;

@property (nonatomic, strong, readwrite, nullable, setter=updateWithSender:) id<ATLParticipant> sender;
@property (nonatomic, assign, readwrite, setter=shouldDisplayAvatarItem:) BOOL displayAvatarItem;

- (void)lyr_CommonInit;

- (void)updateProgressIndicatorWithProgress:(float)progress visible:(BOOL)visible animated:(BOOL)animated;

@end


#if 0
#pragma mark -
#endif

@implementation ATLMCarouselCardCollectionViewCell
@synthesize layerController = _layerController;

- (instancetype)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
        [self lyr_CommonInit];
    }
    
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super initWithCoder:aDecoder])) {
        [self lyr_CommonInit];
    }
    
    return self;
}

- (void)lyr_CommonInit {
    
    UIView *content = [self contentView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:(UICollectionViewScrollDirectionHorizontal)];
    [layout setItemSize:CGSizeMake(200, 200)];
    [layout setMinimumLineSpacing:6.0];
    
    _carousel = [[UICollectionView alloc] initWithFrame:[content bounds] collectionViewLayout:layout];
    [_carousel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_carousel setBackgroundColor:[UIColor clearColor]];
    [_carousel setShowsHorizontalScrollIndicator:NO];
    [_carousel setDataSource:self];
    [_carousel setDelegate:self];
    [content addSubview:_carousel];
    
    [ATLMCarouselProductCell registerWithCollectionView:_carousel forCellWithReuseIdentifier:NSStringFromClass([ATLMCarouselProductCell class])];
    
    Class clss = [ATLMCarouselCardAvatarCell class];
    NSString *identifier = NSStringFromClass(clss);
    [_carousel registerClass:clss forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:identifier];
    [_carousel registerClass:clss forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:identifier];
    
    _progress = [[ATLProgressView alloc] init];
    [_progress setTranslatesAutoresizingMaskIntoConstraints:NO];
    [content addSubview:_progress];
    
    [[NSLayoutConstraint constraintWithItem:_carousel attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:content attribute:(NSLayoutAttributeBottom) multiplier:1.0 constant:0.0] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:_carousel attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:content attribute:(NSLayoutAttributeTop) multiplier:1.0 constant:0.0] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:_carousel attribute:(NSLayoutAttributeLeading) relatedBy:(NSLayoutRelationEqual) toItem:content attribute:(NSLayoutAttributeLeading) multiplier:1.0 constant:0.0] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:_carousel attribute:(NSLayoutAttributeTrailing) relatedBy:(NSLayoutRelationEqual) toItem:content attribute:(NSLayoutAttributeTrailing) multiplier:1.0 constant:0.0] setActive:YES];
    
    [[NSLayoutConstraint constraintWithItem:_progress attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationEqual) toItem:nil attribute:(NSLayoutAttributeNotAnAttribute) multiplier:1.0 constant:ATLMCarouselCardCollectionViewProgressSize] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:_progress attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:nil attribute:(NSLayoutAttributeNotAnAttribute) multiplier:1.0 constant:ATLMCarouselCardCollectionViewProgressSize] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:_progress attribute:(NSLayoutAttributeCenterX) relatedBy:(NSLayoutRelationEqual) toItem:content attribute:(NSLayoutAttributeCenterX) multiplier:1.0 constant:0.0] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:_progress attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:content attribute:(NSLayoutAttributeCenterY) multiplier:1.0 constant:0.0] setActive:YES];
}

- (void)dealloc {
    
    LYRMessage *current = [self message];
    
    if (nil != current) {
        for (LYRMessagePart *part in [current parts]) {
            [part removeObserver:self forKeyPath:@"transferStatus"];
        }
    }
}

- (void)layoutSubviews {

    [super layoutSubviews];
    
    UICollectionView *carousel = [self carousel];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[carousel collectionViewLayout];
    
    [layout setItemSize:CGSizeMake(ATLMaxCellWidth(), CGRectGetHeight([carousel bounds]))];
}

- (nullable ATLMCarouselCard *)card {
    
    if (nil == _card) {
        LYRMessage *message = [self message];
        if (nil != message) {
            _card = [ATLMCarouselCard cardWithMessage:message];
        }
    }
    
    return _card;
}

- (void)presentMessage:(LYRMessage *)message {
    [self setMessage:message];
}

- (void)updateWithSender:(nullable id<ATLParticipant>)sender {
    
    if (![sender isEqual:[self sender]]) {
        _sender = sender;
        [[self carousel] reloadData];
    }
}

- (void)shouldDisplayAvatarItem:(BOOL)shouldDisplayAvatarItem {
    
    if (shouldDisplayAvatarItem != _displayAvatarItem) {
        _displayAvatarItem = shouldDisplayAvatarItem;
        [[self carousel] reloadData];
    }
}

- (void)updateProgressIndicatorWithProgress:(float)progress visible:(BOOL)visible animated:(BOOL)animated {
    ATLProgressView *pv = [self progress];
    [pv setProgress:progress animated:animated];
    [UIView animateWithDuration:(animated ? 0.25 : 0.0) animations:^{
        [pv setAlpha:(visible ? 1.0 : 0.0)];
    }];
}

- (void)setMessage:(nullable LYRMessage *)message {
    
    if (![[self message] isEqual:message]) {
        
        for (LYRMessagePart *part in [[self message] parts]) {
            [part removeObserver:self forKeyPath:@"transferStatus"];
        }
        
        _message = message;
        
        [self setCard:nil];
        [self synchronize];
        
        for (LYRMessagePart *part in [message parts]) {
            
            [part addObserver:self forKeyPath:@"transferStatus" options:NSKeyValueObservingOptionNew context:NULL];
            
            // Start downloading the parts if any are outstanding
            LYRContentTransferStatus status = [part transferStatus];
            if ([part transferStatus] == LYRContentTransferReadyForDownload) {
                (void)[part downloadContent:NULL];
                [self updateProgressIndicatorWithProgress:0.0 visible:YES animated:NO];
            }
            else {
                [self updateProgressIndicatorWithProgress:0.0 visible:(LYRContentTransferComplete != status) animated:NO];
            }
        }
        
        ATLMCarouselCard *card = [self card];
        if (nil != card) {
            [self setType:([[[[self layerController] layerClient] authenticatedUser] isEqual:[message sender]] ? ATLOutgoingCellType : ATLIncomingCellType)];
        }
        else {
        }
    }
}

- (void)setType:(ATLCellType)type {
   
    if (type != _type) {
        _type = type;
    
        [[self carousel] reloadData];
    }
}

- (void)setLayerController:(nullable ATLMLayerController *)layerController {
    
    if ([self layerController] != layerController) {
        _layerController = layerController;
        [self setTask:nil];
        [self synchronize];
        [self setType:([[[layerController layerClient] authenticatedUser] isEqual:[[self message] sender]] ? ATLOutgoingCellType : ATLIncomingCellType)];
    }
}

- (void)synchronize {
    
    if (nil == [self task]) {
        ATLMCard *card = [self card];
        ATLMLayerController *controller = [self layerController];
        if ((nil != card) && (nil != controller)) {
            
            id<ATLMRESTEndpoint> endpoint = [controller RESTEndpoint];
            NSURLSession *session = [endpoint URLSession];
            NSURL *baseURL = [endpoint baseURL];
            if ((nil != session) && (nil != baseURL)) {
                
//                [self setVote:nil];
                
                __weak typeof(self) wSelf = self;
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"/message/%@", [[[card message] identifier] lastPathComponent]]
                                    relativeToURL:baseURL];
                NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        typeof(wSelf) sSelf = wSelf;
                        if ((nil != sSelf) && [card isEqualToCard:[sSelf card]]) {
                            
                            if ((nil == error) && (0 != [data length])) {
                                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                                if ([json isKindOfClass:[NSDictionary class]]) {
                                    NSString *participant = [[[controller layerClient] authenticatedUser] userID];
                                    NSDictionary *votes = [json objectForKey:@"votes"];
                                    if ((nil != participant) && [votes isKindOfClass:[NSDictionary class]]) {
                                        NSNumber *choice = [votes objectForKey:participant];
                                        if ([choice isKindOfClass:[NSNumber class]]) {
//                                            [sSelf setVote:choice];
                                        }
                                    }
                                }
                            }
                            else {
//                                [sSelf setVote:nil];
                            }
                            
                            [sSelf setTask:nil];
                        }
                    });
                }];
                [self setTask:task];
                [task resume];
            }
        }
    }
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSString*, id> *)change
                       context:(nullable void *)context
{
    // Re-dispatch this call to the main thread if it's not.
    if (![[NSThread currentThread] isMainThread]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }];
        return;
    }
    
    LYRMessage *message = [self message];
    LYRMessage *other = [(LYRMessagePart*)object message];
    
    if ([message isEqual:other]) {
        if (LYRContentTransferComplete == [object transferStatus]) {
            [self updateProgressIndicatorWithProgress:1.0 visible:NO animated:YES];
        }
        else {
            [self updateProgressIndicatorWithProgress:[[(LYRMessagePart*)object progress] fractionCompleted] visible:YES animated:YES];
        }
    }
}

+ (CGSize)cellSizeForMessage:(LYRMessage *)message withCellWidth:(CGFloat)cellWidth {
    
    CGSize result = CGSizeMake(cellWidth, 0.0);
    CGFloat width = ATLMaxCellWidth();

    ATLMCarouselCard *card = [ATLMCarouselCard cardWithMessage:message];
    NSArray<ATLMCarouselProduct *> *items = [card items];
    for (ATLMCarouselProduct *product in items) {
        CGSize sz = [ATLMCarouselProductCell intrinsicSizeForProduct:product width:width];
        if (sz.height > result.height) {
            result.height = sz.height;
        }
    }
    
    return result;
}

#if 0
#pragma mark - UICollectionViewDataSource
#endif

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[self card] items] count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ATLMCarouselProductCell *result = [ATLMCarouselProductCell dequeueFromCollectionView:[self carousel]
                                                                     withReuseIdentifier:NSStringFromClass([ATLMCarouselProductCell class])
                                                                            forIndexPath:indexPath];
    [result setProduct:[[[self card] items] objectAtIndex:[indexPath row]]];

    ATLCellType type = [self type];
    UIColor *bgColor = ATLMCarouselCardCollectionViewCellBackgroundColor(type);
    UIColor *fgColor = ATLMCarouselCardCollectionViewCellForegroundColor(type);

    [result setBackgroundColor:bgColor];

    [[result title] setTextColor:fgColor];
    [[result subtitle] setTextColor:fgColor];
    [[result price] setTextColor:fgColor];
    
    return result;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collection viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    UICollectionReusableView *result;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] || [kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        ATLMCarouselCardAvatarCell *cell = [collection dequeueReusableSupplementaryViewOfKind:kind
                                                                          withReuseIdentifier:NSStringFromClass([ATLMCarouselCardAvatarCell class])
                                                                                 forIndexPath:indexPath];

        ATLAvatarView *avatar = [cell avatar];
        [avatar setAvatarItem:[self sender]];
        [avatar setHidden:![self displayAvatarItem]];
        
        result = cell;
    }
    else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"-[%@ %@] does not expect requests for \"%@\"!", NSStringFromClass([self class]), NSStringFromSelector(_cmd), kind]
                                     userInfo:nil];
    }
    
    return result;
}

#if 0
#pragma mark - UICollectionViewDelegateFlowLayout
#endif

- (CGSize)collectionView:(UICollectionView *)collection layout:(UICollectionViewLayout*)layout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize result = ([self displayAvatarItem] ? [[[ATLAvatarView alloc] init] intrinsicContentSize] : CGSizeZero);
    result.width += (ATLMCarouselCardCollectionViewAvatarLeadPadding + ATLMCarouselCardCollectionViewAvatarTailPadding);
    return result;
}

- (CGSize)collectionView:(UICollectionView *)collection layout:(UICollectionViewLayout*)layout referenceSizeForFooterInSection:(NSInteger)section {
    CGSize result = ([self displayAvatarItem] ? [[[ATLAvatarView alloc] init] intrinsicContentSize] : CGSizeZero);
    result.width += (ATLMCarouselCardCollectionViewAvatarLeadPadding + ATLMCarouselCardCollectionViewAvatarTailPadding);
    return result;
}

- (void)collectionView:(UICollectionView *)collection didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ATLMCarouselProduct *product = [[[self card] items] objectAtIndex:[indexPath row]];
    NSURL *details = [product detailURL];
    
    if (nil != details) {
        UIViewController *presentation = [[self window] rootViewController];
        UIViewController *next;
        do {
            next = [presentation presentedViewController];
            if (nil != next) {
                presentation = next;
                continue;
            }
            
            if ([presentation isKindOfClass:[UINavigationController class]]) {
                presentation = next = [(UINavigationController*)presentation topViewController];
                continue;
            }
            
            else if ([presentation isKindOfClass:[UITabBarController class]]) {
                presentation = next = [(UITabBarController*)presentation selectedViewController];
            }
            
        } while (nil != next);
        
        SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:details];
        [presentation presentViewController:safari animated:YES completion:NULL];
    }
}

@end


#if 0
#pragma mark -
#endif

@implementation ATLMCarouselCardAvatarCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
        
        UIView *content = [self contentView];
        
        _avatar = [[ATLAvatarView alloc] init];
        [_avatar setTranslatesAutoresizingMaskIntoConstraints:NO];
        [content addSubview:_avatar];

        [[NSLayoutConstraint constraintWithItem:_avatar attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:content attribute:(NSLayoutAttributeBottom) multiplier:1.0 constant:0.0] setActive:YES];
        [[NSLayoutConstraint constraintWithItem:_avatar attribute:(NSLayoutAttributeLeading) relatedBy:(NSLayoutRelationEqual) toItem:content attribute:(NSLayoutAttributeLeading) multiplier:1.0 constant:ATLMCarouselCardCollectionViewAvatarLeadPadding] setActive:YES];
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END       // }
