//
//  ATLMCardResponder.h
//  Atlas Messenger
//
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
@class ATLMCardResponse;
@class ATLMLayerController;
@protocol ATLMRESTEndpoint;

@protocol ATLMCardResponder <NSObject>
@optional
@property (nonatomic, weak, readwrite, nullable) ATLMLayerController *layerController;

@end

NS_ASSUME_NONNULL_END       // }
