//
//  ATLMSchedulingCardCollectionViewCell.m
//  Atlas Messenger
//
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import "ATLMSchedulingCardCollectionViewCell.h"
#import "ATLMSchedulingCard.h"
#import "ATLMLayerController.h"
#import "ATLMCardResponse.h"

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark - Constants
#endif

static const CGFloat ATLMSchedulingCardCollectionViewCellTopPadding = 10.0;
static const CGFloat ATLMSchedulingCardCollectionViewCellBottomPadding = 17.0;
static const CGFloat ATLMSchedulingCardCollectionViewCellHorizontalPadding = 13.0;
static const CGFloat ATLMSchedulingCardCollectionViewCellIconSize = 18.0;
static const CGFloat ATLMSchedulingCardCollectionViewCellIconHorizontalGap = 11.0;
static const CGFloat ATLMSchedulingCardCollectionViewCellIconVerticalGap = 11.0;
static const CGFloat ATLMSchedulingCardCollectionViewCellSeparatorVerticalGap = 10.0;
static const CGFloat ATLMSchedulingCardCollectionViewCellSeparatorHeight = 1.0;
static const CGFloat ATLMSchedulingCardCollectionViewCellChoiceButtonHeight = 47.0;
static const CGFloat ATLMSchedulingCardCollectionViewCellChoiceButtonWidth = 130.0;
static const CGFloat ATLMSchedulingCardCollectionViewCellChoiceHorizontalSpacing = 12.0;
static const CGFloat ATLMSchedulingCardCollectionViewCellChoiceVerticalSpacing = 13.0;
static const CGFloat ATLMSchedulingCardCollectionViewCellChoiceBottomPadding = 39.0;
static const CGFloat ATLMSchedulingCardCollectionViewCellDirectionHeight = 18.0;
static const CGFloat ATLMSchedulingCardCollectionViewCellTitleFontSize = 15.0;
static const CGFloat ATLMSchedulingCardCollectionViewCellChoiceFontSize = 11.0;
static const CGFloat ATLMSchedulingCardCollectionViewCellDirectionFontSize = 13.0;


#if 0
#pragma mark -
#endif

@interface ATLMSchedulingCardChoiceViewCell : UICollectionViewCell
@property (nonatomic, strong, readwrite) UIButton *choice;
@property (nonatomic, weak, readwrite, nullable) id target;
@property (nonatomic, assign, readwrite, nullable) SEL action;

+ (NSString*)reuseIdentifier;

- (void)performSelection:(id)sender;

@end


#if 0
#pragma mark - Functions
#endif

static inline UIColor *
ATLMSchedulingCardCollectionViewCellBackgroundColor(ATLCellType type) {
    return ((ATLOutgoingCellType == type) ? ATLBlueColor() : ATLLightGrayColor());
}

static inline UIColor *
ATLMSchedulingCardCollectionViewCellForegroundColor(ATLCellType type) {
    if (ATLOutgoingCellType == type) {
        return [UIColor whiteColor];
    }
    return [UIColor colorWithRed:49.0/255.0 green:63.0/255.0 blue:72.0/255.0 alpha:1.0];
}

static inline UIColor *
ATLMSchedulingCardCollectionViewCellSeparatorColor(ATLCellType type) {
    if (ATLOutgoingCellType == type) {
        return [UIColor whiteColor];
    }
    return [UIColor colorWithWhite:222.0/255.0 alpha:1.0];
}

static inline UIColor *
ATLMSchedulingCardCollectionViewCellChoiceButtonBackgroundColor(ATLCellType type) {
    if (ATLOutgoingCellType == type) {
        return [UIColor colorWithWhite:1.0 alpha:0.7];
    }
    return [UIColor colorWithRed:25.0f/255.0 green:165.0/255.0 blue:228.0/255.0 alpha:0.1];
}

static inline UIFont *
ATLMSchedulingCardCollectionViewCellTitleFont(void) {
    return [UIFont systemFontOfSize:ATLMSchedulingCardCollectionViewCellTitleFontSize weight:UIFontWeightSemibold];
}

static inline UIFont *
ATLMSchedulingCardCollectionViewCellChoiceFont(void) {
    return [UIFont systemFontOfSize:ATLMSchedulingCardCollectionViewCellChoiceFontSize weight:UIFontWeightSemibold];
}

static inline UIFont *
ATLMSchedulingCardCollectionViewCellDirectionFont(void) {
    return [UIFont systemFontOfSize:ATLMSchedulingCardCollectionViewCellDirectionFontSize weight:UIFontWeightSemibold];
}


#if 0
#pragma mark -
#endif

@interface ATLMSchedulingCardCollectionViewCell () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong, readwrite, nullable) ATLMSchedulingCard *card;
@property (nonatomic, strong, readonly) UIImageView *icon;
@property (nonatomic, strong, readonly) UILabel *title;
@property (nonatomic, strong, readonly) UIView *separator;
@property (nonatomic, strong, readonly) UICollectionView *choices;
@property (nonatomic, strong, readonly) UILabel *direction;
@property (nonatomic, assign, readwrite) ATLCellType type;
@property (nonatomic, strong, readwrite, nullable) NSURLSessionDataTask *task;
@property (nonatomic, strong, readwrite, nullable) NSNumber *vote;

- (void)lyr_CommonInit;

- (void)sendResponse:(id)sender;

@end


#if 0
#pragma mark -
#endif

@implementation ATLMSchedulingCardCollectionViewCell
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
    
    UIView *content = [self bubbleView];
    
    _icon = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SchedulingIcon"] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)]];
    [_icon setTranslatesAutoresizingMaskIntoConstraints:NO];
    [content addSubview:_icon];
    [content sendSubviewToBack:_icon];
    
    _title = [[UILabel alloc] init];
    [_title setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_title setFont:ATLMSchedulingCardCollectionViewCellTitleFont()];
    [_title setText:@"Calendar"];
    [content addSubview:_title];
    [content sendSubviewToBack:_title];
    
    _separator = [[UIView alloc] init];
    [_separator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [content addSubview:_separator];
    [content sendSubviewToBack:_separator];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    _choices = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_choices setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_choices setDataSource:self];
    [_choices setDelegate:self];
    [_choices registerClass:[ATLMSchedulingCardChoiceViewCell class] forCellWithReuseIdentifier:[ATLMSchedulingCardChoiceViewCell reuseIdentifier]];
    [content addSubview:_choices];
    [content sendSubviewToBack:_choices];
    
    _direction = [[UILabel alloc] init];
    [_direction setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_direction setFont:ATLMSchedulingCardCollectionViewCellDirectionFont()];
    [_direction setTextAlignment:(NSTextAlignmentCenter)];
    [_direction setAlpha:0.3f];
    [content addSubview:_direction];
    [content sendSubviewToBack:_direction];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_icon, _title, _separator, _choices, _direction);
    NSDictionary *metrics = @{@"ATLMSchedulingCardCollectionViewCellTopPadding": @(ATLMSchedulingCardCollectionViewCellTopPadding),
                              @"ATLMSchedulingCardCollectionViewCellHorizontalPadding": @(ATLMSchedulingCardCollectionViewCellHorizontalPadding),
                              @"ATLMSchedulingCardCollectionViewCellIconSize":@(ATLMSchedulingCardCollectionViewCellIconSize),
                              @"ATLMSchedulingCardCollectionViewCellIconHorizontalGap":@(ATLMSchedulingCardCollectionViewCellIconHorizontalGap),
                              @"ATLMSchedulingCardCollectionViewCellIconVerticalGap":@(ATLMSchedulingCardCollectionViewCellIconVerticalGap),
                              @"ATLMSchedulingCardCollectionViewCellSeparatorHeight": @(ATLMSchedulingCardCollectionViewCellSeparatorHeight),
                              @"ATLMSchedulingCardCollectionViewCellSeparatorVerticalGap": @(ATLMSchedulingCardCollectionViewCellSeparatorVerticalGap),
                              @"ATLMSchedulingCardCollectionViewCellChoiceVerticalSpacing": @(ATLMSchedulingCardCollectionViewCellChoiceVerticalSpacing),
                              @"ATLMSchedulingCardCollectionViewCellChoiceBottomPadding": @(ATLMSchedulingCardCollectionViewCellChoiceBottomPadding),
                              @"ATLMSchedulingCardCollectionViewCellBottomPadding": @(ATLMSchedulingCardCollectionViewCellBottomPadding),
                              @"ATLMSchedulingCardCollectionViewCellDirectionHeight": @(ATLMSchedulingCardCollectionViewCellDirectionHeight)};
    [content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-ATLMSchedulingCardCollectionViewCellHorizontalPadding-[_icon(ATLMSchedulingCardCollectionViewCellIconSize)]-ATLMSchedulingCardCollectionViewCellIconHorizontalGap-[_title]-ATLMSchedulingCardCollectionViewCellHorizontalPadding-|" options:0 metrics:metrics views:views]];
    [content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0.0-[_separator]-0.0-|" options:0 metrics:metrics views:views]];
    [content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-ATLMSchedulingCardCollectionViewCellHorizontalPadding-[_choices]-ATLMSchedulingCardCollectionViewCellHorizontalPadding-|" options:0 metrics:metrics views:views]];
    [content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-ATLMSchedulingCardCollectionViewCellHorizontalPadding-[_direction]-ATLMSchedulingCardCollectionViewCellHorizontalPadding-|" options:0 metrics:metrics views:views]];
    [content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-ATLMSchedulingCardCollectionViewCellIconVerticalGap-[_icon(ATLMSchedulingCardCollectionViewCellIconSize)]" options:0 metrics:metrics views:views]];
    [content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-ATLMSchedulingCardCollectionViewCellTopPadding-[_title]-ATLMSchedulingCardCollectionViewCellSeparatorVerticalGap-[_separator(ATLMSchedulingCardCollectionViewCellSeparatorHeight)]-ATLMSchedulingCardCollectionViewCellChoiceVerticalSpacing-[_choices]-ATLMSchedulingCardCollectionViewCellChoiceBottomPadding-|" options:0 metrics:metrics views:views]];
    [content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_direction(ATLMSchedulingCardCollectionViewCellDirectionHeight)]-ATLMSchedulingCardCollectionViewCellBottomPadding-|" options:0 metrics:metrics views:views]];
}

- (void)dealloc {
    
    LYRMessage *current = [self message];
    
    if (nil != current) {
        for (LYRMessagePart *part in [current parts]) {
            [part removeObserver:self forKeyPath:@"transferStatus"];
        }
    }
}

- (nullable ATLMSchedulingCard *)card {
    
    if (nil == _card) {
        LYRMessage *message = [self message];
        if (nil != message) {
            _card = [ATLMSchedulingCard cardWithMessage:message];
        }
    }
    
    return _card;
}

- (void)setMessage:(LYRMessage *)message {
    
    if (![[self message] isEqual:message]) {
        
        for (LYRMessagePart *part in [[self message] parts]) {
            [part removeObserver:self forKeyPath:@"transferStatus"];
        }
        
        [super setMessage:message];
        
        [self setCard:nil];
        
        [self setTask:nil];
        [self synchronize];
        
        for (LYRMessagePart *part in [message parts]) {
            
            [part addObserver:self forKeyPath:@"transferStatus" options:NSKeyValueObservingOptionNew context:NULL];
            
            // Start downloading the parts if any are outstanding
            LYRContentTransferStatus status = [part transferStatus];
            if (LYRContentTransferReadyForDownload == status) {
                (void)[part downloadContent:NULL];
                [[self bubbleView] updateProgressIndicatorWithProgress:0.0 visible:YES animated:NO];
            }
            else {
                [[self bubbleView] updateProgressIndicatorWithProgress:0.0 visible:(LYRContentTransferComplete != status) animated:NO];
            }
        }
        
        [self updateBubbleWidth:[[self class] cellSizeForMessage:message withCellWidth:CGRectGetWidth([self bounds])].width];
        
        ATLMSchedulingCard *card = [self card];
        if (nil != card) {
            
            UILabel *label = [self title];
            NSString *title = [card title];
            [label setText:((0 != [title length]) ? title : @"When Can We Meet")];
            
            UICollectionView *choices = [self choices];
            [choices reloadData];
            [choices setHidden:NO];
        }
        else {
            [[self choices] setHidden:YES];
        }
    }
}

- (void)setType:(ATLCellType)type {
    
    _type = type;
    
    UIColor *bgColor = ATLMSchedulingCardCollectionViewCellBackgroundColor(type);
    UIColor *fgColor = ATLMSchedulingCardCollectionViewCellForegroundColor(type);
    
    [self setBubbleViewColor:bgColor];
    
    [[self icon] setTintColor:fgColor];
    
    UILabel *title = [self title];
    [title setBackgroundColor:bgColor];
    [title setTextColor:fgColor];
    
    [[self separator] setBackgroundColor:ATLMSchedulingCardCollectionViewCellSeparatorColor(type)];

    UICollectionView *choices = [self choices];
    [choices setBackgroundColor:bgColor];
    [choices reloadData];
    
    [[self direction] setTextColor:fgColor];
}

- (void)setLayerController:(nullable ATLMLayerController *)layerController {
    
    if ([self layerController] != layerController) {
        _layerController = layerController;
        [self setTask:nil];
        [self synchronize];
    }
}

- (void)setTask:(nullable NSURLSessionDataTask *)task {
    
    if ([self task] != task) {
        _task = task;
        
        BOOL enabled = NO;
        ATLMessageBubbleView *bv = [self bubbleView];
        if (nil != task) {
            [bv updateProgressIndicatorWithProgress:0.0 visible:YES animated:NO];
            [bv updateProgressIndicatorWithProgress:80.0 visible:YES animated:YES];
        }
        else {
            enabled = (nil == [self vote]);
            [bv updateProgressIndicatorWithProgress:100.0 visible:NO animated:YES];
        }
        [[self choices] setUserInteractionEnabled:enabled];
    }
}

- (void)setVote:(nullable NSNumber *)vote {
    
    if (![[self vote] isEqual:vote]) {
        
        _vote = vote;
        
        BOOL voted = (nil == vote);
        
        UICollectionView *choices = [self choices];
        [choices reloadData];
        [choices setUserInteractionEnabled:!voted];
        
        [[self direction] setText:(voted ? @"You can only submit once." : @"Thanks for submitting!")];\
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
                
                [self setVote:nil];
                
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
                                            [sSelf setVote:choice];
                                        }
                                    }
                                }
                            }
                            else {
                                [sSelf setVote:nil];
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
            [[self bubbleView] updateProgressIndicatorWithProgress:1.0 visible:NO animated:YES];
            [[self choices] reloadData];
        }
        else {
            [[self bubbleView] updateProgressIndicatorWithProgress:[[(LYRMessagePart*)object progress] fractionCompleted] visible:YES animated:YES];
        }
    }
}

- (void)configureCellForType:(ATLCellType)cellType {
    [super configureCellForType:cellType];
    [self setType:cellType];
}

+ (CGSize)cellSizeForMessage:(LYRMessage *)message withCellWidth:(CGFloat)cellWidth {
    
    ATLMSchedulingCard *card = [ATLMSchedulingCard cardWithMessage:message];
    NSString *title = [card title];
    if (0 == [title length]) {
        title = @"When Can We Meet";
    }
    
    static const CGFloat SingleColumnWidth = ((2.0 * ATLMSchedulingCardCollectionViewCellHorizontalPadding) +
                                              ATLMSchedulingCardCollectionViewCellChoiceButtonWidth);
    static const CGFloat DoubleColumnWidth = ((2.0 * ATLMSchedulingCardCollectionViewCellHorizontalPadding) +
                                              (2.0 * ATLMSchedulingCardCollectionViewCellChoiceButtonWidth) +
                                              ATLMSchedulingCardCollectionViewCellChoiceHorizontalSpacing);
    
    NSUInteger count = [[card dates] count];
    NSUInteger lines = 1;
    if (1 < count) {
        if (DoubleColumnWidth <= cellWidth) {
            cellWidth = DoubleColumnWidth;
            lines = ((count + 1) / 2);
        }
        else {
            cellWidth = SingleColumnWidth;
            lines = count;
        }
    }
    else {
        cellWidth = SingleColumnWidth;
    }
    
    CGSize sz = CGSizeMake(cellWidth - (ATLMSchedulingCardCollectionViewCellIconSize + ATLMSchedulingCardCollectionViewCellIconHorizontalGap), CGFLOAT_MAX);
    CGRect result = CGRectIntegral([title boundingRectWithSize:sz
                                                       options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                    attributes:@{NSFontAttributeName:ATLMSchedulingCardCollectionViewCellTitleFont()}
                                                       context:nil]);
    
    result.size.width = cellWidth;
    result.size.height += (ATLMSchedulingCardCollectionViewCellTopPadding +
                           ATLMSchedulingCardCollectionViewCellSeparatorVerticalGap +
                           ATLMSchedulingCardCollectionViewCellSeparatorHeight +
                           (ATLMSchedulingCardCollectionViewCellChoiceButtonHeight * lines) +
                           ((lines + 1) * ATLMSchedulingCardCollectionViewCellChoiceVerticalSpacing) +
                           ATLMSchedulingCardCollectionViewCellChoiceBottomPadding);
    
    return result.size;
}

#if 0
#pragma mark - UICollectionViewDataSource
#endif

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[self card] dates] count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ATLMSchedulingCardChoiceViewCell *result = [collectionView dequeueReusableCellWithReuseIdentifier:[ATLMSchedulingCardChoiceViewCell reuseIdentifier]
                                                                                         forIndexPath:indexPath];
    
    NSUInteger row = [indexPath row];
    NSNumber *vote = [self vote];
    BOOL selected = ((nil != vote) && ([vote unsignedIntegerValue] == row));
    
    ATLMSchedulingCardDateRange *range = [[[self card] dates] objectAtIndex:[indexPath row]];
    NSDate *start = [range startDate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocalizedDateFormatFromTemplate:@"E MMdd"];
    NSString *day = [formatter stringFromDate:start];
    NSString *time = [NSDateFormatter localizedStringFromDate:start dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    NSString *end = [NSDateFormatter localizedStringFromDate:[range endDate] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    
    ATLCellType type = [self type];
    UIButton *button = [result choice];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:(NSTextAlignmentCenter)];
    [button setAttributedTitle:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@ - %@", day, time, end]
                                                               attributes:@{NSFontAttributeName:ATLMSchedulingCardCollectionViewCellChoiceFont(),
                                                                            NSForegroundColorAttributeName:ATLBlueColor(),
                                                                            NSParagraphStyleAttributeName:style}]
                      forState:(UIControlStateNormal)];
    
    [button setNeedsLayout];
    
    [button setBackgroundColor:ATLMSchedulingCardCollectionViewCellChoiceButtonBackgroundColor(type)];
    [button setAlpha:(((nil == vote) || selected) ? 1.0 : 0.2)];

    [result setBackgroundColor:((ATLOutgoingCellType == type) ? ATLBlueColor() : ATLLightGrayColor())];
    
    [result setTarget:self];
    [result setAction:@selector(sendResponse:)];
    [result setTag:[indexPath row]];
    
    return result;
}

- (void)sendResponse:(id)sender {
    
    if (nil == [self task]) {
        ATLMSchedulingCard *card = [self card];
        ATLMLayerController *controller = [self layerController];
        LYRClient *client = [controller layerClient];
        if ((nil != card) && (nil != controller) && (nil != client)) {
            
            id<ATLMRESTEndpoint> endpoint = [controller RESTEndpoint];
            NSURLSession *session = [endpoint URLSession];
            NSURL *baseURL = [endpoint baseURL];
            if ((nil != session) && (nil != baseURL)) {
                
                NSInteger tag = [sender tag];
                NSNumber *choice = @([sender tag]);
                ATLMSchedulingCardDateRange *range = [[card dates] objectAtIndex:tag];
                
                NSDateFormatter *formatter = ATLMSchedulingCardISODateFormatter();
                NSDictionary *payload = @{@"messageID":[[[self message] identifier] absoluteString],
                                          @"selectedIndex":choice,
                                          @"title":[card title],
                                          @"start":[formatter stringFromDate:[range startDate]],
                                          @"end":[formatter stringFromDate:[range endDate]]};
                
                NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:0 error:NULL];
                
                [self setVote:choice];
                
                __weak typeof(self) wSelf = self;
                NSURL *url = [NSURL URLWithString:@"/scheduleEvent" relativeToURL:baseURL];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                [request setHTTPMethod:@"POST"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:data];
                
                NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        typeof(wSelf) sSelf = wSelf;
                        if ((nil != sSelf) && [card isEqualToCard:[sSelf card]]) {
                            
                            BOOL succeeded = NO;
                            if ((nil == error) && (0 != [data length])) {
                                NSError *err = nil;
                                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
                                if ([json isKindOfClass:[NSDictionary class]]) {
                                    succeeded = [[json objectForKey:@"ok"] boolValue];
                                    if (succeeded) {
                                        
                                        succeeded = [ATLMCardResponse sendCardResponseWithPayloadData:[NSJSONSerialization dataWithJSONObject:[json objectForKey:@"patch"] options:0 error:NULL]
                                                                                    supplementalParts:nil
                                                                                              forCard:card
                                                                                               client:client
                                                                                              options:nil
                                                                                                error:&err];
                                        
                                        // **FIXME** This should realy inform the user of any failure
                                        if (nil != err) {
                                            NSLog(@"Sending poll response failed (%@)!", err);
                                        }
                                        else if (!succeeded) {
                                            NSLog(@"Unable to send poll response!");
                                        }
                                    }
                                }
                            }
                            
                            if (!succeeded) {
                                [sSelf setVote:nil];
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

#if 0
#pragma mark - UICollectionViewDelegateFlowLayout
#endif

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(ATLMSchedulingCardCollectionViewCellChoiceButtonWidth, ATLMSchedulingCardCollectionViewCellChoiceButtonHeight);
}

@end


#if 0
#pragma mark -
#endif

@implementation ATLMSchedulingCardChoiceViewCell

+ (NSString*)reuseIdentifier {
    return NSStringFromClass(self);
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
        
        UIView *content = [self contentView];
        
        _choice = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_choice setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_choice setClipsToBounds:YES];
        [[_choice layer] setCornerRadius:4.0];
        
        [[_choice titleLabel] setNumberOfLines:2];

        [_choice addTarget:self action:@selector(performSelection:) forControlEvents:UIControlEventTouchUpInside];

        [content addSubview:_choice];
        
        [[NSLayoutConstraint constraintWithItem:_choice attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:content attribute:(NSLayoutAttributeLeft) multiplier:1.0 constant:0.0] setActive:YES];
        [[NSLayoutConstraint constraintWithItem:_choice attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationEqual) toItem:content attribute:(NSLayoutAttributeRight) multiplier:1.0 constant:0.0] setActive:YES];
        [[NSLayoutConstraint constraintWithItem:_choice attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ATLMSchedulingCardCollectionViewCellChoiceButtonHeight] setActive:YES];
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self setTarget:nil];
    [self setAction:nil];
}

- (void)performSelection:(id)sender {
    
    id target = [self target];
    SEL action = [self action];
    
    if ((nil != target) && (NULL != action)) {
        sender = self;
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        [invocation setTarget:target];
        [invocation setSelector:action];
        [invocation setArgument:&sender atIndex:2];
        [invocation invoke];
    }
}

@end

NS_ASSUME_NONNULL_END       // }
