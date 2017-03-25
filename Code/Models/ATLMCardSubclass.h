//
//  ATLMCardSubclass.h
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import "ATLMCard.h"

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark -
#endif

// Forward declarations
@class LYRMessage;

/**
 @abstract Additional `ATLMCard` methods available for override or execution when creating a
 subclass of `ATLMCard`.
 */
@interface ATLMCard (/* Subclassing */)

/**
 @abstract Creates and returns a new `ATLMCard` instance using the provided `LYRMessage` instance as
 the model.  Overrides MUST call `[super initWithMessage:message]`.
 @param message A `LYRMessage` to be used as the model
 @return Returns a newly created `ATLMCard` instance
 */
- (instancetype)initWithMessage:(LYRMessage *)message NS_DESIGNATED_INITIALIZER;

/**
 @abstract Verifies the provided message can be used for the creation of an instance of this
 subclass.
 @param message A `LYRMessage` to be verified
 @return Returns `YES` if the message is supported. Default implementation returns `YES`.
 */
+ (BOOL)isSupportedMessage:(LYRMessage *)message;

/**
 @abstract Create and return a `LYRMessage` instance suitable for sending via `LYRConversation`.
 @discussion Creates a `LYRMessage` representation of a card. This message will be used by
 recipients in order to create `ATLMCard` instances to which they may respond. The contents of
 `initialPayloadPart` and `supplementalParts` will be bundled into the result of this method call.
 @param client The `LYRClient` instance to be used for creating the message
 @param initialPayloadPart `LYRMessagePart` to be used as the initial payload for the card
 @param supplementalParts Optional array of `LYRMessagePart` instances to be bundled with the card
 @param options An instance of `LYRMessageOptions` containing options to apply to the newly
 initialized `LYRMessage` instance.
 @param error An error object describing a failure if one has occured.
 @return Returns a newly created `LYRMessage` instance or `nil` in the case of failure.
 @see LYRClientOptions
 */
+ (nullable LYRMessage *)newMessageWithClient:(LYRClient *)client
                           initialPayloadPart:(LYRMessagePart *)initialPayloadPart
                            supplementalParts:(nullable NSArray<LYRMessagePart *> *)supplementalParts
                                      options:(nullable LYRMessageOptions *)options
                                        error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END       // }
