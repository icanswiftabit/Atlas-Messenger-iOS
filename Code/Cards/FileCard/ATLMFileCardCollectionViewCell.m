//
//  ATLMFileCardCollectionViewCell.m
//  Atlas Messenger
//
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import "ATLMFileCardCollectionViewCell.h"
#import "ATLMFileCard.h"
#import <MobileCoreServices/MobileCoreServices.h>

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark - Constants
#endif

static const CGFloat ATLMFileCardCollectionViewVerticalPadding = 20.0;
static const CGFloat ATLMFileCardCollectionViewHorizontalPadding = 10.0;
static const CGFloat ATLMFileCardCollectionViewIconSize = 48.0;
static const CGFloat ATLMFileCardCollectionViewIconSpacing = 5.0;
static const CGFloat ATLMFileCardCollectionViewNameFontSize = 11.0;


#if 0
#pragma mark - Functions
#endif

static inline UIColor *
ATLMFileCardCollectionViewBackgroundColor(ATLCellType type) {
    return ((ATLOutgoingCellType == type) ? ATLBlueColor() : ATLLightGrayColor());
}

static inline UIColor *
ATLMFileCardCollectionViewForegroundColor(ATLCellType type) {
    if (ATLOutgoingCellType == type) {
        return [UIColor whiteColor];
    }
    return [UIColor colorWithRed:49.0/255.0 green:63.0/255.0 blue:72.0/255.0 alpha:1.0];
}

static inline UIFont *
ATLMFileCardCollectionViewCellNameFont(void) {
    return [UIFont systemFontOfSize:ATLMFileCardCollectionViewNameFontSize];
}


#if 0
#pragma mark -
#endif

@interface ATLMFileCardCollectionViewCell () <UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong, readwrite, nullable) ATLMFileCard *card;
@property (nonatomic, strong, readwrite) UIDocumentInteractionController *interaction;
@property (nonatomic, strong, readonly) UIImageView *icon;
@property (nonatomic, strong, readonly) UILabel *name;
@property (nonatomic, assign, readwrite) ATLCellType type;
@property (nonatomic, strong, readwrite) UIGestureRecognizer *download;

- (void)lyr_CommonInit;

- (void)updateDocumentInteraction;
- (void)toggleDownload:(UITapGestureRecognizer*)tap;

@end


#if 0
#pragma mark -
#endif

@implementation ATLMFileCardCollectionViewCell

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
    
    _interaction = [[UIDocumentInteractionController alloc] init];
    [_interaction setUTI:(__bridge NSString*)kUTTypeFileURL];
    NSArray<UIImage *> *icons = [_interaction icons];
    
    _icon = [[UIImageView alloc] initWithImage:[icons firstObject]];
    [_icon setContentMode:(UIViewContentModeScaleAspectFit)];
    [_icon setTranslatesAutoresizingMaskIntoConstraints:NO];
    [content addSubview:_icon];
    [content sendSubviewToBack:_icon];
    
    _name = [[UILabel alloc] init];
    [_name setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_name setFont:ATLMFileCardCollectionViewCellNameFont()];
    [_name setTextAlignment:(NSTextAlignmentCenter)];
    [content addSubview:_name];
    [content sendSubviewToBack:_name];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_icon, _name);
    NSDictionary *metrics = @{@"ATLMFileCardCollectionViewVerticalPadding": @(ATLMFileCardCollectionViewVerticalPadding),
                              @"ATLMFileCardCollectionViewHorizontalPadding": @(ATLMFileCardCollectionViewHorizontalPadding),
                              @"ATLMFileCardCollectionViewIconSize":@(ATLMFileCardCollectionViewIconSize),
                              @"ATLMFileCardCollectionViewIconSpacing":@(ATLMFileCardCollectionViewIconSpacing)};
    [content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-ATLMFileCardCollectionViewHorizontalPadding-[_name(>=ATLMFileCardCollectionViewIconSize)]-ATLMFileCardCollectionViewHorizontalPadding-|" options:0 metrics:metrics views:views]];
    [content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=ATLMFileCardCollectionViewHorizontalPadding)-[_icon(ATLMFileCardCollectionViewIconSize)]-(>=ATLMFileCardCollectionViewHorizontalPadding)-|" options:0 metrics:metrics views:views]];
    [content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-ATLMFileCardCollectionViewVerticalPadding-[_icon(ATLMFileCardCollectionViewIconSize)]-ATLMFileCardCollectionViewIconSpacing-[_name]-ATLMFileCardCollectionViewVerticalPadding-|" options:0 metrics:metrics views:views]];
    [[NSLayoutConstraint constraintWithItem:_icon attribute:(NSLayoutAttributeCenterX) relatedBy:(NSLayoutRelationEqual) toItem:content attribute:(NSLayoutAttributeCenterX) multiplier:1.0 constant:0.0] setActive:YES];
    
    _download = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleDownload:)];
    [content addGestureRecognizer:_download];
}

- (void)dealloc {
    
    LYRMessage *current = [self message];
    
    if (nil != current) {
        for (LYRMessagePart *part in [current parts]) {
            [part removeObserver:self forKeyPath:@"transferStatus"];
        }
    }
}

- (void)updateDocumentInteraction {
    
    ATLMFileCard *card = [self card];
    UIDocumentInteractionController *interaction;
    if (nil != card) {
        
        NSString *name = [card fileName];
        LYRMessagePart *part = [card filePart];
        NSURL *url = [part fileURL];
        if (nil == url) {
            NSData *data = [part data];
            if (nil != data) {
                NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
                cache = [cache stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
                cache = [cache stringByAppendingPathComponent:[[[card message] identifier] lastPathComponent]];
                (void)[[NSFileManager defaultManager] createDirectoryAtPath:cache withIntermediateDirectories:YES attributes:nil error:nil];
                cache = [cache stringByAppendingPathComponent:(name?:[[part identifier] lastPathComponent])];
                (void)[data writeToFile:cache atomically:YES];
                url = [NSURL fileURLWithPath:cache];
            }
        }
        
        if (nil != url) {
            interaction = [UIDocumentInteractionController interactionControllerWithURL:[url absoluteURL]];
        }
        else {
            interaction = [[UIDocumentInteractionController alloc] init];
        }
        
        [interaction setName:name];
        
        NSString *mime = [card fileMIMEType];
        if (0 != [mime length]) {
            CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)mime, NULL);
            if (NULL != uti) {
                [interaction setUTI:(__bridge NSString*)uti];
                CFRelease(uti);
            }
        }
        
        if (0 == [[interaction UTI] length]) {
            [interaction setUTI:(__bridge NSString*)kUTTypeFileURL];
        }
    }
    else {
        interaction = [[UIDocumentInteractionController alloc] init];
        [interaction setUTI:(__bridge NSString*)kUTTypeFileURL];
    }
    
    [self setInteraction:interaction];
}

- (void)toggleDownload:(UITapGestureRecognizer*)tap {
    
    ATLMFileCard *card = [self card];
    LYRMessagePart *file = [card filePart];
    LYRContentTransferStatus status = [file transferStatus];
    
    switch (status) {
            
        case LYRContentTransferDownloading: {
            LYRProgress *progess = [file progress];
            if ([progess isPaused]) {
                (void)[file downloadContent:NULL];
            }
            else {
                [progess pause];
            }
            break;
        }
            
        case LYRContentTransferReadyForDownload:
            (void)[file downloadContent:NULL];
            break;
            
        default:
            /* Do nothing for complete or uploading. */
            break;
    }
}

- (nullable ATLMFileCard *)card {
    
    if (nil == _card) {
        LYRMessage *message = [self message];
        if (nil != message) {
            _card = [ATLMFileCard cardWithMessage:message];
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
        
        // Clear the old cached card prior to pulling the new one.
        [self setCard:nil];
        
        LYRMessagePart *part;
        
        for (part in [message parts]) {
            [part addObserver:self forKeyPath:@"transferStatus" options:NSKeyValueObservingOptionNew context:NULL];
        }
        
        part = [[self card] initialPayloadPart];
        
        // Start downloading the initial part if its outstanding
        LYRContentTransferStatus status = [part transferStatus];
        if ([part transferStatus] == LYRContentTransferReadyForDownload) {
            (void)[part downloadContent:NULL];
            [[self bubbleView] updateProgressIndicatorWithProgress:0.0 visible:YES animated:NO];
            [[self download] setEnabled:NO];
        }
        else {
            BOOL complete = (LYRContentTransferComplete == status);
            [[self bubbleView] updateProgressIndicatorWithProgress:0.0 visible:!complete animated:NO];
            [[self download] setEnabled:complete];
        }

        [self updateDocumentInteraction];
        
        [self updateBubbleWidth:[[self class] cellSizeForMessage:message withCellWidth:CGRectGetWidth([self bounds])].width];
    }
}

- (void)setInteraction:(UIDocumentInteractionController *)interaction {
    
    UIDocumentInteractionController *existing = [self interaction];
    if (![existing isEqual:interaction]) {
        
        [existing setDelegate:nil];
        
        UIView *bubble = [self bubbleView];
        NSArray<UIGestureRecognizer *> *gestures = [existing gestureRecognizers];
        for (UIGestureRecognizer *gesture in gestures) {
            [bubble removeGestureRecognizer:gesture];
        }
        
        _interaction = interaction;
        
        [interaction setDelegate:self];
        
        NSArray<UIImage *> *icons = [_interaction icons];
        
        // Search for the largest icon that will fit in the allocated size.
        UIImage *icon = [icons lastObject];
        for (UIImage *image in [icons reverseObjectEnumerator]) {
            CGSize sz = [image size];
            if ((sz.width >= ATLMFileCardCollectionViewIconSize) || (sz.height >= ATLMFileCardCollectionViewIconSize)) {
                icon = image;
            }
            else break;
        }
        
        [[self icon] setImage:icon];
        
        [[self name] setText:[interaction name]];
        
        if (LYRContentTransferComplete == [[[self card] filePart] transferStatus]) {
            gestures = [interaction gestureRecognizers];
            for (UIGestureRecognizer *gesture in gestures) {
                [bubble addGestureRecognizer:gesture];
            }
        }
    }
}

- (void)setType:(ATLCellType)type {
    
    _type = type;
    
    UIColor *bgColor = ATLMFileCardCollectionViewBackgroundColor(type);
    UIColor *fgColor = ATLMFileCardCollectionViewForegroundColor(type);
    
    [self setBubbleViewColor:bgColor];
    
    UILabel *name = [self name];
    [name setBackgroundColor:bgColor];
    [name setTextColor:fgColor];
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
        
        ATLMFileCard *card = [self card];
        LYRMessagePart *initial = [card initialPayloadPart];

        // If the main part has not completed download/upload, show that progress.
        if (LYRContentTransferComplete != [initial transferStatus]) {
            [[self bubbleView] updateProgressIndicatorWithProgress:[[initial progress] fractionCompleted] visible:YES animated:YES];
            [[self download] setEnabled:NO];
        }
        
        else {
            
            // When the initial part is the one updating, this will capture when it flips to complete.
            // When it does flip, this will update the UIDocumentInteractionController with all the info.
            if ([object isEqual:initial]) {
                [self updateDocumentInteraction];
            }
            
            // If the main part has been transfered, this needs to show the progress of the file part.
            // If the transfer of the file is either complete or isn't actively being transfered,
            // treat it as a "steady state" in which no progress is displayed at all.
            
            BOOL visible = NO;
            BOOL enabled = NO;
            float progress = 1.0;
            LYRMessagePart *file = [card filePart];
            LYRContentTransferStatus status = [file transferStatus];
            switch (status) {
                    
                case LYRContentTransferReadyForDownload:
                    enabled = YES;
                    break;
                    
                case LYRContentTransferComplete:
                    if ([object isEqual:file]) {
                        UIView *bubble = [self bubbleView];
                        NSArray<UIGestureRecognizer *> *gestures = [[self interaction] gestureRecognizers];
                        for (UIGestureRecognizer *gesture in gestures) {
                            [bubble addGestureRecognizer:gesture];
                        }
                    }
                    break;
                    
                case LYRContentTransferDownloading:
                    visible = YES;
                    enabled = YES;
                    break;
                    
                default:
                    visible = YES;
                    progress = [[file progress] fractionCompleted];
                    break;
            }
            
            [[self download] setEnabled:enabled];
            [[self bubbleView] updateProgressIndicatorWithProgress:progress visible:visible animated:YES];
        }
    }
}

- (void)configureCellForType:(ATLCellType)cellType {
    [super configureCellForType:cellType];
    [self setType:cellType];
}

+ (CGSize)cellSizeForMessage:(LYRMessage *)message withCellWidth:(CGFloat)cellWidth {
    
    ATLMFileCard *card = [ATLMFileCard cardWithMessage:message];
    NSString *name = [card fileName];
    
    CGRect result = CGRectIntegral([name boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 0.0)
                                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                   attributes:@{NSFontAttributeName:ATLMFileCardCollectionViewCellNameFont()}
                                                      context:nil]);
    
    result.size.width = MAX(MIN((MIN(cellWidth, ATLMaxCellWidth()) - (2.0 * ATLMFileCardCollectionViewHorizontalPadding)), result.size.width), ATLMFileCardCollectionViewIconSize);
    result.size.width += (2.0 * ATLMFileCardCollectionViewHorizontalPadding);
    result.size.height += ((2.0 * ATLMFileCardCollectionViewVerticalPadding) + ATLMFileCardCollectionViewIconSize + ATLMFileCardCollectionViewIconSpacing);
    
    if (result.size.width < result.size.height) {
        result.size.width = result.size.height;
    }
    
    return result.size;
}

#if 0
#pragma mark - UIDocumentInteractionControllerDelegate
#endif

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    
    UIViewController *result = [[self window] rootViewController];
    UIViewController *next;
    do {
        next = [result presentedViewController];
        if (nil != next) {
            result = next;
            continue;
        }
        
        if ([result isKindOfClass:[UINavigationController class]]) {
            result = next = [(UINavigationController*)result topViewController];
            continue;
        }
        
        else if ([result isKindOfClass:[UITabBarController class]]) {
            result = next = [(UITabBarController*)result selectedViewController];
        }

    } while (nil != next);
    
    return result;
}

@end

NS_ASSUME_NONNULL_END       // }
