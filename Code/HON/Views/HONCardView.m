//
//  HONCardView.m
//  Atlas Messenger
//
//  Created by Daniel Maness on 8/3/17.
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#import "HONCardView.h"

@interface HONCardView ()
@property (nonatomic) NSURL *url;
@end

@implementation HONCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _cornerRadius = 5.0;
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self configureCorners];
}

- (void)configureCorners
{
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.bounds byRoundingCorners: UIRectCornerAllCorners cornerRadii: (CGSize){self.cornerRadius, self.cornerRadius}].CGPath;
    
    self.layer.mask = maskLayer;
}

@end
