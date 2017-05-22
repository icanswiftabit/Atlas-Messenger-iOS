//
//  ATLMTextPollCard.h
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import "ATLMCard.h"
#import "ATLMCardCellPresentable.h"

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark -
#endif

@interface ATLMTextPollCard : ATLMCard <ATLMCardCellPesentable>
@property (nonatomic, copy, readonly, nullable) NSString *question;
@property (nonatomic, copy, readonly, nullable) NSArray<NSString *> *choices;

+ (nullable LYRMessage *)newMessageWithClient:(LYRClient *)client
                                     question:(nullable NSString *)question
                                      choices:(NSArray<NSString *> *)choices
                                      options:(nullable LYRMessageOptions *)options
                                        error:(NSError * _Nullable * _Nullable)error;

// Unavailable for use; use the convenience methods.
+ (nullable LYRMessage *)newMessageWithClient:(LYRClient *)client
                           initialPayloadPart:(LYRMessagePart *)initialPayloadPart
                            supplementalParts:(nullable NSArray<LYRMessagePart *> *)supplementalParts
                                      options:(nullable LYRMessageOptions *)options
                                        error:(NSError * _Nullable * _Nullable)error NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END       // }
