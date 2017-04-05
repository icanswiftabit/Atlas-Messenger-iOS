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
@class LYRClient;
@class ATLMCardResponse;

@interface ATLMCardResponseCollectionViewCell : UICollectionViewCell <ATLMessagePresenting>
@property (nonatomic, strong, readonly, nullable) ATLMCardResponse *response;

+ (CGSize)cellSizeForMessage:(LYRMessage *)message withCellWidth:(CGFloat)cellWidth;

@end

NS_ASSUME_NONNULL_END       // }
