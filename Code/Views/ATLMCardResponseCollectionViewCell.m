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
#import "ATLMLayerController.h"

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark -
#endif

@interface ATLMCardResponseCollectionViewCell ()
@property (nonatomic, strong, readwrite, nullable) ATLMCardResponse *response;
@property (nonatomic, strong, readonly) UILabel *label;

- (void)lyr_CommonInit;

+ (NSString*)labelForCardResponse:(ATLMCardResponse *)response fromLayerController:(ATLMLayerController *)layerController;

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
        _response = response;
        [[self label] setText:[[self class] labelForCardResponse:_response fromLayerController:[self layerController]]];
    }
}

- (void)setLayerController:(nullable ATLMLayerController *)layerController {
    
    ATLMLayerController *existing = [self layerController];
    if ((layerController != existing) && ![existing isEqual:layerController]) {
        _layerController = layerController;
        [[self label] setText:[[self class] labelForCardResponse:[self response] fromLayerController:_layerController]];
    }
}

+ (NSString*)labelForCardResponse:(ATLMCardResponse *)response fromLayerController:(ATLMLayerController *)layerController {
    
    LYRIdentity *me = [[layerController layerClient] authenticatedUser];
    
    NSString *args[2];
    LYRIdentity *senders[2] = {
        [[[response payloadPart] message] sender],
        [[layerController messageForIdentifier:[response cardIdentifier]] sender]
    };
    
    for (size_t i = 0; i < (sizeof(senders) / sizeof(senders[0])); i++) {
        if ([senders[i] isEqual:me]) {
            args[i] = ((0 == i) ? @"You" : @"you");
        }
        else {
            args[i] = [senders[i] displayName];
            if (0 == [args[i] length]) {
                args[i] = ((0 == i) ? @"Someone" : @"someone");
            }
        }
    }
    
    return [NSString stringWithFormat:@"%@ responded to a message from %@.", args[0], args[1]];
}

+ (CGSize)cellSizeForCardResponse:(ATLMCardResponse *)response
              fromLayerController:(ATLMLayerController *)layerController
                    withCellWidth:(CGFloat)cellWidth
{
    CGSize sz = CGSizeMake(cellWidth, CGFLOAT_MAX);
    sz.width -= 40.0;
    
    NSString *label = [self labelForCardResponse:response fromLayerController:layerController];
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
