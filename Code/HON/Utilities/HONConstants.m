//
//  HONConstants.m
//  Atlas Messenger
//
//  Created by Daniel Maness on 8/4/17.
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

@import GoogleFontsiOS;
#import "HONConstants.h"

UIColor *HONRedColor()
{
    return [UIColor colorWithRed:237/255.0f green:48.0f/255.0f blue:43.0f/255.0f alpha:1.0];
}

UIColor *HONGreenColor()
{
    return [UIColor colorWithRed:48.0f/255.0f green:182.0f/255.0f blue:69.0f/255.0f alpha:1.0];
}

UIColor *HONPurpleColor()
{
    return [UIColor colorWithRed:69.0f/255.0f green:28.0f/255.0f blue:80.0f/255.0f alpha:1.0];
}

UIColor *HONGrayColor()
{
    return [UIColor colorWithRed:155.0f/255.0f green:155.0f/255.0f blue:155.0f/255.0f alpha:1.0];
}

UIColor *HONLightGrayColor()
{
    return [UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:1.0];
}

UIFont *HONFontRegular(CGFloat size)
{
    return [UIFont sourceSansProRegularFontOfSize:size];
}

UIFont *HONFontSemibold(CGFloat size)
{
    return [UIFont sourceSansProSemiboldFontOfSize:size];
}

UIFont *HONFontBold(CGFloat size)
{
    return [UIFont sourceSansProBoldFontOfSize:size];
}
