//
//  ATLMCardResponseCollectionViewCell.h
//  Atlas Messenger
//
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import <Atlas/Atlas.h>

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark -
#endif

// Forward declarations
@class ATLMCardResponse;
@class ATLMLayerController;

@interface ATLMCardResponseCollectionViewCell : UICollectionViewCell <ATLMessagePresenting>
@property (nonatomic, strong, readonly, nullable) ATLMCardResponse *response;
@property (nonatomic, weak, readwrite, nullable) ATLMLayerController *layerController;

+ (CGSize)cellSizeForCardResponse:(ATLMCardResponse *)response
              fromLayerController:(ATLMLayerController *)layerController
                    withCellWidth:(CGFloat)cellWidth;

@end

NS_ASSUME_NONNULL_END       // }
