//
//  WEFLYRConcurrentOperation.h
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WEFLYRConcurrentOperationStateMachine.h"

@interface WEFLYRConcurrentOperation : NSOperation

@property (nonatomic, strong, readonly) WEFLYRConcurrentOperationStateMachine *stateMachine;
@property (nonatomic, readonly) dispatch_queue_t dispatchQueue;

// Entry point for operation. Must be implemented by subclass.
- (void)execute;
- (void)finish;

@end
