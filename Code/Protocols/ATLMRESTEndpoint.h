//
//  ATLMRESTEndpoint.h
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

@protocol ATLMRESTEndpoint <NSObject>
@property (nonatomic, strong, readonly, nullable) NSURLSession *URLSession;
@property (nonatomic, strong, readonly, nullable) NSURL *baseURL;
@end

NS_ASSUME_NONNULL_END       // }
