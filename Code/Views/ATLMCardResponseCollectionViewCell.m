//
//  ATLMCardResponseCollectionViewCell.m
//  Atlas Messenger
//
//  Created by Jeremy Wyld on 3/25/17.
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import "ATLMCardResponseCollectionViewCell.h"
#import "ATLMCardResponse.h"

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark -
#endif

@interface ATLMCardResponseCollectionViewCell ()
@property (nonatomic, strong, readwrite, nullable) ATLMCardResponse *response;
@property (nonatomic, strong, readonly) UILabel *label;

- (void)lyr_CommonInit;

@end


#if 0
#pragma mark -
#endif

@implementation ATLMCardResponseCollectionViewCell

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
    
    _label = [[UILabel alloc] initWithFrame:CGRectInset([content bounds], 20.0, 0.0)];
    [_label setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [_label setFont:[UIFont systemFontOfSize:11.0]];
    [_label setTextAlignment:(NSTextAlignmentCenter)];
    [_label setTextColor:[UIColor grayColor]];
    [content addSubview:_label];
}

- (void)setResponse:(nullable ATLMCardResponse *)response {
    
    ATLMCardResponse *existing = [self response];
    if ((response != existing) && ![existing isEqualToCardResponse:response]) {
        [[self label] setText:@"Someone responded to a message from someone else."];
        
        // **FIXME** Remove debugging code
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            (void)[[[response payloadPart] message] delete:(LYRDeletionModeAllParticipants) error:NULL];
//        });
    }
}

+ (CGSize)cellSizeForMessage:(LYRMessage *)message withCellWidth:(CGFloat)cellWidth {
    
    CGSize sz = CGSizeMake(cellWidth, CGFLOAT_MAX);
    sz.width -= 40.0;
    
    NSString *label = @"Someone responded to a message from someone else.";
    CGRect result = CGRectIntegral([label boundingRectWithSize:sz
                                                       options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0]}
                                                       context:nil]);
    result.size.width += 40.0;
    
    return result.size;
}

- (void)presentMessage:(LYRMessage *)message {
    
    NSArray<LYRMessagePart *> *parts = [message parts];
    
    NSUInteger count = [parts count];
    LYRMessagePart *initial = [parts firstObject];
    parts = ((1 == count) ? nil : [parts subarrayWithRange:NSMakeRange(1, count - 1)]);
    
    [self setResponse:[ATLMCardResponse cardResponseWithMessagePart:initial supplementalParts:parts]];
}

- (void)updateWithSender:(nullable id<ATLParticipant>)sender {
     /* Do nothing */
}

- (void)shouldDisplayAvatarItem:(BOOL)shouldDisplayAvatarItem {
    /* Do nothing */
}

@end

NS_ASSUME_NONNULL_END       // }
