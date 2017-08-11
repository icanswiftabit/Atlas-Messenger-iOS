//
//  ATLMCarouselCard.h
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
#pragma mark - Types
#endif

typedef NS_ENUM(NSUInteger, ATLMCarouselCardSelectionMode) {
    ATLMCarouselCardSelectionModeNone,
    ATLMCarouselCardSelectionModeOne,
    ATLMCarouselCardSelectionModeUnlimited = NSUIntegerMax
};


#if 0
#pragma mark -
#endif

@interface ATLMCarouselProduct : NSObject
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite, nullable) NSString *subtitle;
@property (nonatomic, strong, readwrite) NSNumber *price;
@property (nonatomic, strong, readwrite) NSURL *detailURL;
@property (nonatomic, strong, readwrite) NSURL *imageURL;

- (instancetype)initWithTitle:(NSString *)title NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithJSONRepresentation:(NSDictionary *)json;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (NSDictionary*)JSONRepresentation;

@end


#if 0
#pragma mark -
#endif

@interface ATLMCarouselCard : ATLMCard <ATLMCardCellPesentable>

@property (nonatomic, copy, readonly, nullable) NSString *title;
@property (nonatomic, copy, readonly, nullable) NSString *subtitle;
@property (nonatomic, assign, readonly) ATLMCarouselCardSelectionMode selectionMode;

@property (nonatomic, copy, readonly, nullable) NSArray<ATLMCarouselProduct *> *items;

+ (nullable LYRMessage *)newMessageWithClient:(LYRClient *)client
                                        title:(NSString *)title
                                     subtitle:(nullable NSString *)subtitle
                                selectionMode:(ATLMCarouselCardSelectionMode)selectionMode
                                        items:(NSArray<ATLMCarouselProduct *> *)items
                                      options:(nullable LYRMessageOptions *)options
                                        error:(NSError * _Nullable * _Nullable)error;

+ (nullable LYRMessage *)newMessageWithClient:(LYRClient *)client
                           initialPayloadPart:(LYRMessagePart *)initialPayloadPart
                            supplementalParts:(nullable NSArray<LYRMessagePart *> *)supplementalParts
                                      options:(nullable LYRMessageOptions *)options
                                        error:(NSError * _Nullable * _Nullable)error NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END       // }
