//
//  ATLMCard.m
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import "ATLMCard.h"
#import "ATLMCardSubclass.h"
#import <LayerKit/LayerKit.h>

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark -
#endif

@interface ATLMCard ()

@end


#if 0
#pragma mark -
#endif

@implementation ATLMCard

+ (nullable instancetype)cardWithMessage:(LYRMessage *)message {
    return ([self isSupportedMessage:message] ? [[self alloc] initWithMessage:message] : nil);
}

- (nonnull instancetype)initWithMessage:(nonnull LYRMessage *)message {

    if ((self = [super init])) {
        _message = message;
    }
    
    return self;
}

- (LYRMessagePart *)initialPayloadPart {
    return [[[self message] parts] firstObject];
}

- (nullable NSArray<LYRMessagePart *> *)supplementalParts {
    
    NSArray<LYRMessagePart *> *parts = [[self message] parts];
    NSUInteger count = [parts count];
    
    return ((1 < count) ? [parts subarrayWithRange:NSMakeRange(1, (count - 1))] : nil);
}

+ (BOOL)isSupportedMessage:(LYRMessage *)message {
    return YES;
}

+ (nullable LYRMessage *)newMessageWithClient:(LYRClient *)client
                           initialPayloadPart:(LYRMessagePart *)initialPayloadPart
                            supplementalParts:(nullable NSArray<LYRMessagePart *> *)supplementalParts
                                      options:(nullable LYRMessageOptions *)options
                                        error:(NSError * _Nullable * _Nullable)error
{
    NSArray<LYRMessagePart *> *parts = @[initialPayloadPart];
    
    if (0 != [supplementalParts count]) {
        parts = [parts arrayByAddingObjectsFromArray:supplementalParts];
    }
    
    return [client newMessageWithParts:parts options:options error:error];
}

@end

NS_ASSUME_NONNULL_END       // }
