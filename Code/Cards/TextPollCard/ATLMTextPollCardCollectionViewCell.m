//
//  ATLMTextPollCardCollectionViewCell.m
//  Atlas Messenger
//
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import "ATLMTextPollCardCollectionViewCell.h"
#import "ATLMTextPollCard.h"
#import "ATLMLayerController.h"

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark - Constants
#endif

static const CGFloat ATLMTextPollCardCollectionViewCellTopPadding = 10.0;
static const CGFloat ATLMTextPollCardCollectionViewCellBottomPadding = 17.0;
static const CGFloat ATLMTextPollCardCollectionViewCellHorizontalPadding = 13.0;
static const CGFloat ATLMTextPollCardCollectionViewCellIconSize = 18.0;
static const CGFloat ATLMTextPollCardCollectionViewCellIconHorizontalGap = 11.0;
static const CGFloat ATLMTextPollCardCollectionViewCellIconVerticalGap = 11.0;
static const CGFloat ATLMTextPollCardCollectionViewCellSeparatorVerticalGap = 10.0;
static const CGFloat ATLMTextPollCardCollectionViewCellSeparatorHeight = 1.0;
static const CGFloat ATLMTextPollCardCollectionViewCellChoiceHeight = 48.0;
static const CGFloat ATLMTextPollCardCollectionViewCellChoiceButtonHeight = 35.0;
static const CGFloat ATLMTextPollCardCollectionViewCellChoiceSpacing = ATLMTextPollCardCollectionViewCellChoiceHeight - ATLMTextPollCardCollectionViewCellChoiceButtonHeight;
static const CGFloat ATLMTextPollCardCollectionViewCellChoiceBottomPadding = 39.0;
static const CGFloat ATLMTextPollCardCollectionViewCellDirectionHeight = 18.0;
static const CGFloat ATLMTextPollCardCollectionViewCellQuestionFontSize = 15.0;
static const CGFloat ATLMTextPollCardCollectionViewCellChoiceFontSize = 15.0;
static const CGFloat ATLMTextPollCardCollectionViewCellDirectionFontSize = 13.0;


#if 0
#pragma mark -
#endif

@interface ATLMTextPollCardChoiceViewCell : UITableViewCell
@property (nonatomic, strong, readwrite) UIButton *choice;
@property (nonatomic, weak, readwrite, nullable) id target;
@property (nonatomic, assign, readwrite, nullable) SEL action;

- (void)performSelection:(id)sender;

@end


#if 0
#pragma mark - Functions
#endif

static inline UIColor *
ATLMTextPollCardCollectionViewCellBackgroundColor(ATLCellType type) {
    return ((ATLOutgoingCellType == type) ? ATLBlueColor() : ATLLightGrayColor());
}

static inline UIColor *
ATLMTextPollCardCollectionViewCellForegroundColor(ATLCellType type) {
    if (ATLOutgoingCellType == type) {
        return [UIColor whiteColor];
    }
    return [UIColor colorWithRed:49.0/255.0 green:63.0/255.0 blue:72.0/255.0 alpha:1.0];
}

static inline UIColor *
ATLMTextPollCardCollectionViewCellSeparatorColor(ATLCellType type) {
    if (ATLOutgoingCellType == type) {
        return [UIColor whiteColor];
    }
    return [UIColor colorWithWhite:222.0/255.0 alpha:1.0];
}

static inline UIColor *
ATLMTextPollCardCollectionViewCellChoiceButtonBackgroundColor(ATLCellType type) {
    if (ATLOutgoingCellType == type) {
        return [UIColor colorWithWhite:1.0 alpha:0.7];
    }
    return [UIColor colorWithRed:25.0f/255.0 green:165.0/255.0 blue:228.0/255.0 alpha:0.1];
}

static inline UIFont *
ATLMTextPollCardCollectionViewCellQuestionFont(void) {
    return [UIFont systemFontOfSize:ATLMTextPollCardCollectionViewCellQuestionFontSize weight:UIFontWeightSemibold];
}

static inline UIFont *
ATLMTextPollCardCollectionViewCellChoiceFont(void) {
    return [UIFont systemFontOfSize:ATLMTextPollCardCollectionViewCellChoiceFontSize weight:UIFontWeightSemibold];
}

static inline UIFont *
ATLMTextPollCardCollectionViewCellDirectionFont(void) {
    return [UIFont systemFontOfSize:ATLMTextPollCardCollectionViewCellDirectionFontSize weight:UIFontWeightSemibold];
}


#if 0
#pragma mark -
#endif

@interface ATLMTextPollCardCollectionViewCell () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong, readwrite, nullable) ATLMTextPollCard *card;
@property (nonatomic, strong, readonly) UIImageView *icon;
@property (nonatomic, strong, readonly) UILabel *question;
@property (nonatomic, strong, readonly) UIView *separator;
@property (nonatomic, strong, readonly) UITableView *choices;
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

@implementation ATLMTextPollCardCollectionViewCell
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
    
    _icon = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"TextPollIcon"] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)]];
    [_icon setTranslatesAutoresizingMaskIntoConstraints:NO];
    [content addSubview:_icon];
    [content sendSubviewToBack:_icon];
    
    _question = [[UILabel alloc] init];
    [_question setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_question setFont:ATLMTextPollCardCollectionViewCellQuestionFont()];
    [_question setNumberOfLines:2];
    [content addSubview:_question];
    [content sendSubviewToBack:_question];
    
    _separator = [[UIView alloc] init];
    [_separator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [content addSubview:_separator];
    [content sendSubviewToBack:_separator];
    
    _choices = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_choices setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_choices setDataSource:self];
    [_choices setDelegate:self];
    [_choices setRowHeight:ATLMTextPollCardCollectionViewCellChoiceHeight];
    [_choices setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
    [_choices setAllowsSelection:NO];
    [content addSubview:_choices];
    [content sendSubviewToBack:_choices];

    _direction = [[UILabel alloc] init];
    [_direction setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_direction setFont:ATLMTextPollCardCollectionViewCellDirectionFont()];
    [_direction setTextAlignment:(NSTextAlignmentCenter)];
    [_direction setAlpha:0.3f];
    [content addSubview:_direction];
    [content sendSubviewToBack:_direction];

    NSDictionary *views = NSDictionaryOfVariableBindings(_icon, _question, _separator, _choices, _direction);
    NSDictionary *metrics = @{@"ATLMTextPollCardCollectionViewCellTopPadding": @(ATLMTextPollCardCollectionViewCellTopPadding),
                              @"ATLMTextPollCardCollectionViewCellHorizontalPadding": @(ATLMTextPollCardCollectionViewCellHorizontalPadding),
                              @"ATLMTextPollCardCollectionViewCellIconSize":@(ATLMTextPollCardCollectionViewCellIconSize),
                              @"ATLMTextPollCardCollectionViewCellIconHorizontalGap":@(ATLMTextPollCardCollectionViewCellIconHorizontalGap),
                              @"ATLMTextPollCardCollectionViewCellIconVerticalGap":@(ATLMTextPollCardCollectionViewCellIconVerticalGap),
                              @"ATLMTextPollCardCollectionViewCellSeparatorHeight": @(ATLMTextPollCardCollectionViewCellSeparatorHeight),
                              @"ATLMTextPollCardCollectionViewCellSeparatorVerticalGap": @(ATLMTextPollCardCollectionViewCellSeparatorVerticalGap),
                              @"ATLMTextPollCardCollectionViewCellChoiceBottomPadding": @(ATLMTextPollCardCollectionViewCellChoiceBottomPadding),
                              @"ATLMTextPollCardCollectionViewCellBottomPadding": @(ATLMTextPollCardCollectionViewCellBottomPadding),
                              @"ATLMTextPollCardCollectionViewCellDirectionHeight": @(ATLMTextPollCardCollectionViewCellDirectionHeight)};
    [content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-ATLMTextPollCardCollectionViewCellHorizontalPadding-[_icon(ATLMTextPollCardCollectionViewCellIconSize)]-ATLMTextPollCardCollectionViewCellIconHorizontalGap-[_question]-ATLMTextPollCardCollectionViewCellHorizontalPadding-|" options:0 metrics:metrics views:views]];
    [content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0.0-[_separator]-0.0-|" options:0 metrics:metrics views:views]];
    [content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-ATLMTextPollCardCollectionViewCellHorizontalPadding-[_choices]-ATLMTextPollCardCollectionViewCellHorizontalPadding-|" options:0 metrics:metrics views:views]];
    [content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-ATLMTextPollCardCollectionViewCellHorizontalPadding-[_direction]-ATLMTextPollCardCollectionViewCellHorizontalPadding-|" options:0 metrics:metrics views:views]];
    [content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-ATLMTextPollCardCollectionViewCellIconVerticalGap-[_icon(ATLMTextPollCardCollectionViewCellIconSize)]" options:0 metrics:metrics views:views]];
    [content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-ATLMTextPollCardCollectionViewCellTopPadding-[_question]-ATLMTextPollCardCollectionViewCellSeparatorVerticalGap-[_separator(ATLMTextPollCardCollectionViewCellSeparatorHeight)]-0-[_choices]-ATLMTextPollCardCollectionViewCellChoiceBottomPadding-|" options:0 metrics:metrics views:views]];
    [content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_direction(ATLMTextPollCardCollectionViewCellDirectionHeight)]-ATLMTextPollCardCollectionViewCellBottomPadding-|" options:0 metrics:metrics views:views]];
}

- (void)dealloc {
    
    LYRMessage *current = [self message];
    
    if (nil != current) {
        for (LYRMessagePart *part in [current parts]) {
            [part removeObserver:self forKeyPath:@"transferStatus"];
        }
    }
}

- (nullable ATLMTextPollCard *)card {

    if (nil == _card) {
        LYRMessage *message = [self message];
        if (nil != message) {
            _card = [ATLMTextPollCard cardWithMessage:message];
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
        [self synchronize];
        
        for (LYRMessagePart *part in [message parts]) {
            
            [part addObserver:self forKeyPath:@"transferStatus" options:NSKeyValueObservingOptionNew context:NULL];
            
            // Start downloading the parts if any are outstanding
            LYRContentTransferStatus status = [part transferStatus];
            if ([part transferStatus] == LYRContentTransferReadyForDownload) {
                (void)[part downloadContent:NULL];
                [[self bubbleView] updateProgressIndicatorWithProgress:0.0 visible:YES animated:NO];
            }
            else {
                [[self bubbleView] updateProgressIndicatorWithProgress:0.0 visible:(LYRContentTransferComplete != status) animated:NO];
            }
        }
        
        ATLMTextPollCard *card = [self card];
        if (nil != card) {

            UILabel *label = [self question];
            NSString *question = [card question];
            [label setText:question];
            [label setHidden:(0 == [question length])];
            
            UITableView *table = [self choices];
            [table reloadData];
            [table setHidden:NO];
        }
        else {
            [[self question] setHidden:YES];
            [[self choices] setHidden:YES];
        }
        
        [self updateBubbleWidth:[[self class] cellSizeForMessage:message withCellWidth:CGRectGetWidth([self bounds])].width];
    }
}

- (void)setType:(ATLCellType)type {
    
    _type = type;
    
    UIColor *bgColor = ATLMTextPollCardCollectionViewCellBackgroundColor(type);
    UIColor *fgColor = ATLMTextPollCardCollectionViewCellForegroundColor(type);
    
    [self setBubbleViewColor:bgColor];
    
    [[self icon] setTintColor:fgColor];
    
    UILabel *question = [self question];
    [question setBackgroundColor:bgColor];
    [question setTextColor:fgColor];
    
    [[self separator] setBackgroundColor:ATLMTextPollCardCollectionViewCellSeparatorColor(type)];
    
    UITableView *choices = [self choices];
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
        
        UITableView *choices = [self choices];
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
            [[self question] setText:[[self card] question]];
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
    
    ATLMTextPollCard *card = [ATLMTextPollCard cardWithMessage:message];
    NSString *question = [card question];
    
    CGSize sz = CGSizeMake(cellWidth, CGFLOAT_MAX);
    sz.width -= (ATLMTextPollCardCollectionViewCellIconSize + ATLMTextPollCardCollectionViewCellIconHorizontalGap);
    CGRect result = CGRectIntegral([question boundingRectWithSize:sz
                                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                       attributes:@{NSFontAttributeName:ATLMTextPollCardCollectionViewCellQuestionFont()}
                                                          context:nil]);
    
    result.size.height += (ATLMTextPollCardCollectionViewCellTopPadding +
                           ATLMTextPollCardCollectionViewCellSeparatorVerticalGap +
                           ATLMTextPollCardCollectionViewCellSeparatorHeight +
                           ATLMTextPollCardCollectionViewCellChoiceSpacing +
                           (ATLMTextPollCardCollectionViewCellChoiceHeight * [[card choices] count]) +
                           ATLMTextPollCardCollectionViewCellChoiceBottomPadding);
    result.size.width += ((2.0 * ATLMTextPollCardCollectionViewCellHorizontalPadding) +
                          ATLMTextPollCardCollectionViewCellIconSize +
                          ATLMTextPollCardCollectionViewCellIconHorizontalGap);

    return result.size;
}

#if 0
#pragma mark - UITableViewDataSource
#endif

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self card] choices] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ATLMTextPollCardChoiceViewCell *result = [[ATLMTextPollCardChoiceViewCell alloc] init];
    
    NSUInteger row = [indexPath row];
    NSNumber *vote = [self vote];
    BOOL selected = ((nil != vote) && ([vote unsignedIntegerValue] == row));
    
    NSString *choice = [[[self card] choices] objectAtIndex:[indexPath row]];
    
    ATLCellType type = [self type];
    UIButton *button = [result choice];
    [button setAttributedTitle:[[NSAttributedString alloc] initWithString:choice
                                                               attributes:@{NSFontAttributeName:ATLMTextPollCardCollectionViewCellChoiceFont(),
                                                                            NSForegroundColorAttributeName:ATLBlueColor()}]
                      forState:(UIControlStateNormal)];
    [button setBackgroundColor:ATLMTextPollCardCollectionViewCellChoiceButtonBackgroundColor(type)];
    [button setAlpha:(((nil == vote) || selected) ? 1.0 : 0.2)];
    
    [result setBackgroundColor:((ATLOutgoingCellType == type) ? ATLBlueColor() : ATLLightGrayColor())];
    
    [result setSelectionStyle:(UITableViewCellSelectionStyleNone)];
    
    [result setTarget:self];
    [result setAction:@selector(sendResponse:)];
    [result setTag:row];
    
    return result;
}

- (void)sendResponse:(id)sender {
    
    if (nil == [self task]) {
        ATLMCard *card = [self card];
        ATLMLayerController *controller = [self layerController];
        LYRClient *client = [controller layerClient];
        if ((nil != card) && (nil != controller) && (nil != client)) {
            
            id<ATLMRESTEndpoint> endpoint = [controller RESTEndpoint];
            NSURLSession *session = [endpoint URLSession];
            NSURL *baseURL = [endpoint baseURL];
            if ((nil != session) && (nil != baseURL)) {
                
                NSNumber *choice = @([sender tag]);
                NSArray *payload = @[@{@"operation":@"set",
                                       @"property":[NSString stringWithFormat:@"votes.%@", [[client authenticatedUser] userID]],
                                       @"value":choice}];
                NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:0 error:NULL];
                
                [self setVote:choice];
                
                __weak typeof(self) wSelf = self;
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"/message/%@", [[[card message] identifier] lastPathComponent]]
                                    relativeToURL:baseURL];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                [request setHTTPMethod:@"PATCH"];
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
#pragma mark - UITableViewDelegate
#endif

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ATLMTextPollCardCollectionViewCellChoiceSpacing;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

@end


#if 0
#pragma mark -
#endif

@implementation ATLMTextPollCardChoiceViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
        
        UIView *content = [self contentView];
        
        _choice = [UIButton buttonWithType:(UIButtonTypeSystem)];
        [_choice setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_choice setClipsToBounds:YES];
        [[_choice layer] setCornerRadius:4.0];
        [_choice addTarget:self action:@selector(performSelection:) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:_choice];
        
        [[NSLayoutConstraint constraintWithItem:_choice attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:content attribute:(NSLayoutAttributeLeft) multiplier:1.0 constant:0.0] setActive:YES];
        [[NSLayoutConstraint constraintWithItem:_choice attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationEqual) toItem:content attribute:(NSLayoutAttributeRight) multiplier:1.0 constant:0.0] setActive:YES];
        [[NSLayoutConstraint constraintWithItem:_choice attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ATLMTextPollCardCollectionViewCellChoiceButtonHeight] setActive:YES];
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
