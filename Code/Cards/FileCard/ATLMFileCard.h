//
//  ATLMFileCard.h
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

@interface ATLMFileCard : ATLMCard <ATLMCardCellPesentable>
@property (nonatomic, strong, readonly) LYRMessagePart *filePart;
@property (nonatomic, copy, readonly, nullable) NSString *fileName;
@property (nonatomic, copy, readonly, nullable) NSString *fileMIMEType;

@property (nonatomic, copy, readonly, nullable) NSString *comment;
@property (nonatomic, copy, readonly, nullable) NSDate *creationDate;
@property (nonatomic, copy, readonly, nullable) NSDate *modificationDate;

+ (nullable LYRMessage *)newMessageWithClient:(LYRClient *)client
                                      fileURL:(NSURL *)url
                                      comment:(nullable NSString *)comment
                                      options:(nullable LYRMessageOptions *)options
                                        error:(NSError * _Nullable * _Nullable)error;

+ (nullable LYRMessage *)newMessageWithClient:(LYRClient *)client
                           initialPayloadPart:(LYRMessagePart *)initialPayloadPart
                            supplementalParts:(nullable NSArray<LYRMessagePart *> *)supplementalParts
                                      options:(nullable LYRMessageOptions *)options
                                        error:(NSError * _Nullable * _Nullable)error NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END       // }
