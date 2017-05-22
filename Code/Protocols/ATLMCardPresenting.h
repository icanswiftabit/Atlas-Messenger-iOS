//
//  ATLMCardPresenting.h
//  Atlas Messenger
//
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark -
#endif

// Forward declarations
@class ATLMCard;
@protocol ATLMessagePresenting;

/**
 @abstract The `ATLMCardPresenting` protocol must be adopted by objects wishing to present cards via
 a user interface.
 @see ATLMessagePresenting
 */
@protocol ATLMCardPresenting <ATLMessagePresenting>
@required

/**
 @abstract Card which is represented by this `ATLMCardPresenting` protocol instance.
 */
@property (nonatomic, strong, readonly, nullable) ATLMCard *card;

/**
 @abstract Performs the calculations to determine the cell's height.
 @param message The `LYRMessage` object that will be displayed in the cell.
 @param cellWidth The width of the message's cell.
 @return The height for the cell.
 */
+ (CGSize)cellSizeForMessage:(LYRMessage *)message withCellWidth:(CGFloat)cellWidth;

@end

NS_ASSUME_NONNULL_END       // }
