//
//  ATLMCardResponse.h
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
@class ATLMCard;
@class LYRClient;
@class LYRMessagePart;
@class LYRMessageOptions;

/**
 @abstract The `ATLMCardResponse` class represents the response portion of a ATLMCard interaction.
 @discussion The `ATLMCardResponse` class is not intended to be subclassed.  Composition should
 be preferred over inheritance.  A `ATLMCardResponse`, much like a `ATLMCard` is a combination of a
 payload `LYRMessagePart` and a set of supplemental `LYRMessagePart` instances.  `ATLMCardResponse`
 does not allow for the creation of a standalone `LYRMessage`.  It only offers the ability to send
 in response to a particular `ATLMCard`. This guarantees the `ATLMCardResponse` is sent to the same
 conversation as the `ATLMCard` instance.
 */
@interface ATLMCardResponse : NSObject

#if 0
#pragma mark - Properties
#endif

/**
 @abstract Message part which is represented by this `ATLMCardResponse` instance.
 */
@property (nonatomic, strong, readonly, nonnull) LYRMessagePart *payloadPart;

/**
 @abstract Supplemental parts which were sent with this `ATLMCardResponse` instance.
 */
@property (nonatomic, copy, readonly, nullable) NSArray<LYRMessagePart *> *supplementalParts;

/**
 @abstract Identifier for the card to which this is a response.
 */
@property (nonatomic, strong, readonly) NSURL *cardIdentifier;


#if 0
#pragma mark - Initializers
#endif

/**
 @abstract Creates and returns a new `ATLMCardResponse` instance using the provided `LYRMessagePart`
 instance as the model.  If the part is not suitable for use as a card response, `nil` is returned.
 @param part A `LYRMessagePart` to be used as the model
 @param supplementalParts A list of `LYRMessageParts` which are supplemental to the main part
 @return Returns a newly created `ATLMCardResponse` instance.
 */
+ (nullable instancetype)cardResponseWithMessagePart:(LYRMessagePart *)part
                                   supplementalParts:(nullable NSArray<LYRMessagePart *> *)supplementalParts;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

#if 0
#pragma mark - Instance Methods
#endif

- (BOOL)isEqualToCardResponse:(ATLMCardResponse *)other;

#if 0
#pragma mark - Class Methods
#endif

/**
 @abstract Sends a response to this card.
 @discussion This method sends a response for a given card.  Responses can have their own payload
 data and parts in order to produce an additive effect or in order to alter the experience for a
 card.
 @param payload Data to be sent as the main content of the response.
 @param supplementalParts Optional list of extra `LYRMessagePart` instance to be sent as part of the
 response.
 @param options An instance of `LYRMessageOptions` containing options to apply to the sent response.
 @param error An error object describing a failure if one has occured.
 @return Returns YES if the send was successful, otherwise NO.
 */
+ (BOOL)sendCardResponseWithPayloadData:(NSData *)payload
                      supplementalParts:(nullable NSArray<LYRMessagePart *> *)supplementalParts
                                forCard:(ATLMCard *)card
                                 client:(LYRClient *)client
                                options:(nullable LYRMessageOptions *)options
                                  error:(NSError * _Nullable * _Nullable)error;

/**
 @abstract Sends a response to this card.
 @discussion This method sends a response for a given card.  Responses can have their own payload
 data and parts in order to produce an additive effect or in order to alter the experience for a
 card.
 @param payload Stream to be sent as the main content of the response.
 @param supplementalParts Optional list of extra `LYRMessagePart` instance to be sent as part of the
 response.
 @param options An instance of `LYRMessageOptions` containing options to apply to the sent response.
 @param error An error object describing a failure if one has occured.
 @return Returns YES if the send was successful, otherwise NO.
 */
+ (BOOL)sendCardResponseWithPayloadStream:(NSInputStream *)payload
                        supplementalParts:(nullable NSArray<LYRMessagePart *> *)supplementalParts
                                  forCard:(ATLMCard *)card
                                   client:(LYRClient *)client
                                  options:(nullable LYRMessageOptions *)options
                                    error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END       // }
