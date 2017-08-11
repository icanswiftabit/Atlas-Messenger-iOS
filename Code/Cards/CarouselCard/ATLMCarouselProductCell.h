//
//  ATLMCarouselProductCell.h
//  Atlas Messenger
//
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark -
#endif

@class ATLMCarouselProduct;

@interface ATLMCarouselProductCell : UICollectionViewCell
@property (nonatomic, strong, readwrite) ATLMCarouselProduct *product;
@property (nonatomic, strong, readonly) UILabel *title;
@property (nonatomic, strong, readonly) UILabel *subtitle;
@property (nonatomic, strong, readonly) UILabel *price;

+ (void)registerWithCollectionView:(UICollectionView *)collection forCellWithReuseIdentifier:(NSString *)identifier;

+ (instancetype)dequeueFromCollectionView:(UICollectionView *)collection withReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

+ (CGSize)intrinsicSizeForProduct:(ATLMCarouselProduct *)product width:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END       // }
