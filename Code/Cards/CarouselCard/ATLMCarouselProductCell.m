//
//  ATLMCarouselProductCell.m
//  Atlas Messenger
//
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import "ATLMCarouselProductCell.h"
#import "ATLMCarouselCard.h"

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark -
#endif

@interface ATLMCarouselProductFrameView : UIView

@end


#if 0
#pragma mark -
#endif

@interface ATLMCarouselProductCell ()
@property (nonatomic, strong, readwrite) IBOutlet UIView *clip;
@property (nonatomic, strong, readwrite) IBOutlet UIImageView *image;
@property (nonatomic, strong, readwrite) IBOutlet UILabel *title;
@property (nonatomic, strong, readwrite) IBOutlet UILabel *subtitle;
@property (nonatomic, strong, readwrite) IBOutlet UILabel *price;

@property (nonatomic, strong, readwrite) IBOutlet NSLayoutConstraint *imageAspectRatio;

@property (nonatomic, strong, readwrite, nullable) NSURLSessionTask *download;

@end


#if 0
#pragma mark -
#endif

@implementation ATLMCarouselProductCell

+ (void)registerWithCollectionView:(UICollectionView *)collection forCellWithReuseIdentifier:(NSString *)identifier {
    UINib *nib = [UINib nibWithNibName:@"ATLMCarouselProductCell" bundle:[NSBundle bundleForClass:self]];
    [collection registerNib:nib forCellWithReuseIdentifier:identifier];
}

+ (instancetype)dequeueFromCollectionView:(UICollectionView *)collection withReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    ATLMCarouselProductCell *result = [collection dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (![result isKindOfClass:[ATLMCarouselProductCell class]]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"+[%@ %@] expected to get an instance type as a return!", NSStringFromClass([self class]), NSStringFromSelector(_cmd)]
                                     userInfo:nil];
    }
    return result;
}

+ (CGSize)intrinsicSizeForProduct:(ATLMCarouselProduct *)product width:(CGFloat)width {
    
    UINib *nib = [UINib nibWithNibName:@"ATLMCarouselProductCell" bundle:[NSBundle bundleForClass:self]];
    ATLMCarouselProductCell *cell = [[nib instantiateWithOwner:nil options:nil] firstObject];
    [cell setProduct:product];
    CGRect bounds = [cell bounds];
    bounds.size.width = width;
    [cell setBounds:bounds];
    
    [cell setNeedsUpdateConstraints];
    [cell layoutIfNeeded];
    
    return CGSizeMake(width, CGRectGetMaxY(CGRectIntegral([[cell price] frame])) + 8.0);
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    UIView *clip = [self clip];
    CGRect bounds = [clip bounds];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:10.0];
    CAShapeLayer *mask = [CAShapeLayer layer];
    [mask setPath:[path CGPath]];
    [[clip layer] setMask:mask];
}

- (void)setBackgroundColor:(nullable UIColor *)backgroundColor {
    [[self clip] setBackgroundColor:backgroundColor];
}

- (nullable UIColor*)backgroundColor {
    return [[self clip] backgroundColor];
}

- (void)setDownload:(nullable NSURLSessionTask *)download {

    if (![download isEqual:[self download]]) {
        [_download cancel];
        _download = download;
        [download resume];
    }
}

- (void)setProduct:(ATLMCarouselProduct *)product {
    
    if (![product isEqual:[self product]]) {
    
        _product = product;
        
        UILabel *label = [self title];
        [label setText:[product title]];
        [label sizeToFit];
        
        label = [self subtitle];
        [label setText:[product subtitle]];
        [label sizeToFit];
        
        label = [self price];
        [label setText:[NSNumberFormatter localizedStringFromNumber:[product price] numberStyle:(NSNumberFormatterCurrencyStyle)]];
        [label sizeToFit];
        
        [self setNeedsUpdateConstraints];
        [self layoutIfNeeded];
        
        __weak typeof(self) wSelf = self;
        [self setDownload:[[NSURLSession sharedSession] dataTaskWithURL:[product imageURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(wSelf) sSelf = wSelf;
                if ((nil != sSelf) && [product isEqual:[sSelf product]]) {
                    UIImage *image = [UIImage imageWithData:data];
                    [[sSelf image] setImage:image];
                }
            });
        }]];
    }
}

@end


#if 0
#pragma mark -
#endif

@implementation ATLMCarouselProductFrameView

- (void)drawRect:(CGRect)rect {

    [super drawRect:rect];
    
    [[UIColor clearColor] setFill];
    UIRectFill(rect);
    
    [[[self superview] backgroundColor] setStroke];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset([self bounds], 1.0, 1.0) cornerRadius:10.0];
    
    [path stroke];
}

@end

NS_ASSUME_NONNULL_END       // }
