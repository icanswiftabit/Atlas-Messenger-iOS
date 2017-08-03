//
//  WEFLYRConcurrentOperation.m
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "WEFLYRConcurrentOperation.h"

@implementation WEFLYRConcurrentOperation

- (id)init
{
    self = [super init];
    if (self) {
        __weak __typeof(&*self)weakSelf = self;
        _dispatchQueue = dispatch_queue_create([[NSString stringWithFormat:@"com.layer.synchronization.%@", NSStringFromClass(self.class)] UTF8String], DISPATCH_QUEUE_CONCURRENT);
        _stateMachine = [[WEFLYRConcurrentOperationStateMachine alloc] initWithOperation:self dispatchQueue:_dispatchQueue];
        [self.stateMachine setExecutionBlock:^{
            // See APPS-2555: Remove dependencies when we start to avoid dealloc crashes
            for (NSOperation *dependentOperation in weakSelf.dependencies) {
                [weakSelf removeDependency:dependentOperation];
            }
         
            if (weakSelf.isCancelled) {
                [weakSelf.stateMachine finish];
            } else {
                [weakSelf execute];
            }
        }];
    }
    return self;
}

#pragma mark - NSOperation

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isReady
{
    return [self.stateMachine isReady] && [super isReady];
}

- (BOOL)isExecuting
{
    return [self.stateMachine isExecuting];
}

- (BOOL)isFinished
{
    return [self.stateMachine isFinished];
}

- (void)start
{
    [self.stateMachine start];
}

- (void)cancel
{
    [super cancel];
    [self.stateMachine cancel];
}

#pragma mark - Subclass Hooks

- (void)finish
{
    [self.stateMachine finish];
}

- (void)execute
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Subclass must implement `%@`", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end
