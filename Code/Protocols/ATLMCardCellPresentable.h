//
//  ATLMCardCellPresentable.h
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
@class LYRMessage;
@protocol ATLMCardPresenting;

/**
 @abstract The `ATLMCardCellPesentable` protocol is implemented by cards which are presentable for
 display in a conversation.
 */
@protocol ATLMCardCellPesentable <NSObject>
@required

/**
 @abstract Verifies the provided message can be used for the creation of an instance of this
 `ATLMCard` subclass.  See 
 @param message A `LYRMessage` to be verified
 @return Returns `YES` if the message is supported. Default implementation returns `YES`.
 @see ATLMCard (Subclassing) in ATLMCardSubclass.h
 */
+ (BOOL)isSupportedMessage:(LYRMessage *)message;

/**
 @abstract Provides the class to be used for presenting the card in the conversation.
 @return Returns a class conforming to `ATLMCardPresenting` which is suitable for instantiation
 and display in a conversation view.
 */
+ (Class<ATLMCardPresenting>)collectionViewCellClass;

@end

NS_ASSUME_NONNULL_END       // }
