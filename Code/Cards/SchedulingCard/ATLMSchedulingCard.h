//
//  ATLMSchedulingCard.h
//  Atlas Messenger
//
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

@interface ATLMSchedulingCardDateRange : NSObject
@property (nonatomic, strong, readonly) NSDate *startDate;
@property (nonatomic, strong, readonly) NSDate *endDate;

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end


#if 0
#pragma mark -
#endif

@interface ATLMSchedulingCard : ATLMCard <ATLMCardCellPesentable>
@property (nonatomic, copy, readonly, nullable) NSString *title;
@property (nonatomic, copy, readonly, nullable) NSArray<ATLMSchedulingCardDateRange *> *dates;

+ (nullable LYRMessage *)newMessageWithClient:(LYRClient *)client
                                        title:(nullable NSString *)title
                                      dates:(NSArray<ATLMSchedulingCardDateRange *> *)choices
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
