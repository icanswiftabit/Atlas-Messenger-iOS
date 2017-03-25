//
//  ATLMCard.h
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark -
#endif

// Forward declarations
@class LYRClient;
@class LYRMessage;
@class LYRMessagePart;
@class LYRMessageOptions;

/**
 @abstract The `ATLMCard` class is the base class implementation for rich, interactive cards.
 @discussion The `ATLMCard` class provides an API for rich, interactive cards via the Layer
 platform. This class is designed to be flexible enough to support various card "types" and
 behaviors but still enforces a strict compliance to a specific structure which `ATLMCard` expects
 and requires. Although `ATLMCard` can be used as a standalone, the expectation is that subclassing
 is used to create these other types of cards. E.g. a Poll card would be implemented as a subclass
 of `ATLMCard` with its own specialized implementation.
 */
@interface ATLMCard : NSObject

#if 0
#pragma mark - Properties
#endif

/**
 @abstract Message which is represented by this `ATLMCard` instance.
 */
@property (nonatomic, strong, readonly) LYRMessage *message;

/**
 @abstract Initial payload which was used to create this `ATLMCard` instance.
 */
@property (nonatomic, strong, readonly) LYRMessagePart *initialPayloadPart;

/**
 @abstract Supplemental parts which were used to create this `ATLMCard` instance.
 */
@property (nonatomic, copy, readonly, nullable) NSArray<LYRMessagePart *> *supplementalParts;


#if 0
#pragma mark - Initializers
#endif

/**
 @abstract Creates and returns a new `ATLMCard` instance using the provided `LYRMessage` instance as
 the model.  If the provided message is not suitable for instantiating a card, `nil` is returned.
 @param message A `LYRMessage` to be used as the model
 @return Returns a newly created `ATLMCard` instance
 */
+ (nullable instancetype)cardWithMessage:(LYRMessage *)message;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END       // }
