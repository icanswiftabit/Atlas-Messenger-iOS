//
//  WEFLYRConcurrentOperationStateMachine.m
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <TransitionKit/TransitionKit.h>
#import "WEFLYRConcurrentOperationStateMachine.h"

NSString *const LYRConcurrentOperationFailureException = @"LYRConcurrentOperationFailureException";

static NSString *const LYRConcurrentOperationStateReady = @"Ready";
static NSString *const LYRConcurrentOperationStateExecuting = @"Executing";
static NSString *const LYRConcurrentOperationStateFinished = @"Finished";

static NSString *const LYRConcurrentOperationEventStart = @"start";
static NSString *const LYRConcurrentOperationEventFinish = @"finish";

static NSString *const LYRConcurrentOperationLockName = @"org.restkit.operation.lock";

@interface WEFLYRConcurrentOperationStateMachine ()

@property (nonatomic, strong) TKStateMachine *stateMachine;
@property (nonatomic, weak, readwrite) NSOperation *operation;
@property (nonatomic, strong, readwrite) dispatch_queue_t dispatchQueue;
@property (nonatomic, copy) void (^cancellationBlock)(void);

@property (nonatomic, readonly) BOOL isConfigurable;
@property (nonatomic, assign, getter = isReady) BOOL ready;
@property (nonatomic, assign, getter = isExecuting) BOOL executing;
@property (nonatomic, assign, getter = isFinished) BOOL finished;
@property (nonatomic, assign, getter = isCancelled) BOOL cancelled;

@end

@implementation WEFLYRConcurrentOperationStateMachine

- (id)initWithOperation:(NSOperation *)operation dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    if (! operation) [NSException raise:NSInvalidArgumentException format:@"Invalid argument: `operation` cannot be nil."];
    if (! dispatchQueue) [NSException raise:NSInvalidArgumentException format:@"Invalid argument: `dispatchQueue` cannot be nil."];
    self = [super init];
    if (self) {
        _operation = operation;
        _dispatchQueue = dispatchQueue;
        _stateMachine = [TKStateMachine new];
        
        // NOTE: State transitions are guarded by a lock via start/finish/cancel action methods
        TKState *readyState = [TKState stateWithName:LYRConcurrentOperationStateReady];
        __weak __typeof(&*self)weakSelf = self;
        [readyState setWillEnterStateBlock:^(TKState *state, TKTransition *transition) {
            [weakSelf.operation willChangeValueForKey:@"isReady"];
        }];
        [readyState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
            weakSelf.ready = YES;
            [weakSelf.operation didChangeValueForKey:@"isReady"];
        }];
        [readyState setWillExitStateBlock:^(TKState *state, TKTransition *transition) {
            [weakSelf.operation willChangeValueForKey:@"isReady"];
        }];
        [readyState setDidExitStateBlock:^(TKState *state, TKTransition *transition) {
            weakSelf.ready = NO;
            [weakSelf.operation didChangeValueForKey:@"isReady"];
        }];
        
        TKState *executingState = [TKState stateWithName:LYRConcurrentOperationStateExecuting];
        [executingState setWillEnterStateBlock:^(TKState *state, TKTransition *transition) {
            [weakSelf.operation willChangeValueForKey:@"isExecuting"];
        }];
        [executingState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
            [NSException raise:NSInternalInconsistencyException format:@"You must configure an execution block via `setExecutionBlock:`."];
        }];
        // NOTE: isExecuting KVO for `setDidEnterStateBlock:` configured below in `setExecutionBlock`
        [executingState setWillExitStateBlock:^(TKState *state, TKTransition *transition) {
            [weakSelf.operation willChangeValueForKey:@"isExecuting"];
        }];
        [executingState setDidExitStateBlock:^(TKState *state, TKTransition *transition) {
            weakSelf.executing = NO;
            [weakSelf.operation didChangeValueForKey:@"isExecuting"];
        }];
        
        TKState *finishedState = [TKState stateWithName:LYRConcurrentOperationStateFinished];
        [finishedState setWillEnterStateBlock:^(TKState *state, TKTransition *transition) {
            [weakSelf.operation willChangeValueForKey:@"isFinished"];
        }];
        [finishedState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
            weakSelf.finished = YES;
            [weakSelf.operation didChangeValueForKey:@"isFinished"];
        }];
        
        [self.stateMachine addStates:@[ readyState, executingState, finishedState ]];
        
        TKEvent *startEvent = [TKEvent eventWithName:LYRConcurrentOperationEventStart transitioningFromStates:@[ readyState ] toState:executingState];
        TKEvent *finishEvent = [TKEvent eventWithName:LYRConcurrentOperationEventFinish transitioningFromStates:@[ executingState ] toState:finishedState];
        [self.stateMachine addEvents:@[ startEvent, finishEvent ]];
        
        self.stateMachine.initialState = readyState;
        [self.stateMachine activate];
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke initWithOperation: instead.",
                                           NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (void)start
{
    if (! self.dispatchQueue) [NSException raise:NSInternalInconsistencyException format:@"You must configure an `operationQueue`."];
    dispatch_barrier_async(self.dispatchQueue, ^{
        NSError *error = nil;
        BOOL success = [self.stateMachine fireEvent:LYRConcurrentOperationEventStart userInfo:nil error:&error];
        if (! success) [NSException raise:LYRConcurrentOperationFailureException format:@"The operation: %@ unexpectedly failed to start due to an error: %@", self.operation, error];
    });
}

- (void)finish
{
    // Ensure that we are finished from the operation queue
    dispatch_barrier_async(self.dispatchQueue, ^{
        if ([self.stateMachine isInState:LYRConcurrentOperationStateFinished]) {
            return;
        }
        NSError *error = nil;
        BOOL success = [self.stateMachine fireEvent:LYRConcurrentOperationEventFinish userInfo:nil error:&error];
        if (! success) {
            [NSException raise:LYRConcurrentOperationFailureException format:@"The operation: %@ unexpectedly failed to finish due to an error: %@", self.operation, error];   
        }
    });
}

- (void)cancel
{
    if ([self isCancelled] || [self isFinished]) return;
    dispatch_barrier_async(self.dispatchQueue, ^{
        self.cancelled = YES;
        if (self.cancellationBlock) {
            self.cancellationBlock();
        }
    });
}

- (BOOL)isConfigurable
{
    return (_cancelled == NO && _executing == NO && _finished == NO);
}

- (void)setExecutionBlock:(void (^)(void))block
{
    if (!self.isConfigurable) {
        return;
    }
    dispatch_barrier_sync(self.dispatchQueue, ^{
        __weak __typeof(&*self)weakSelf = self;
        TKState *executingState = [self.stateMachine stateNamed:LYRConcurrentOperationStateExecuting];
        [executingState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
            weakSelf.executing = YES;
            [weakSelf.operation didChangeValueForKey:@"isExecuting"];
            dispatch_async(weakSelf.dispatchQueue, ^{
                block();
            });
        }];
    });
}

- (void)setFinalizationBlock:(void (^)(void))block
{
    if (!self.isConfigurable) {
        return;
    }
    dispatch_barrier_sync(self.dispatchQueue, ^{
        __weak __typeof(&*self)weakSelf = self;
        TKState *finishedState = [self.stateMachine stateNamed:LYRConcurrentOperationStateFinished];
        [finishedState setWillEnterStateBlock:^(TKState *state, TKTransition *transition) {
            // Must emit KVO as we are replacing the block configured in `initWithOperation:queue:`
            [weakSelf.operation willChangeValueForKey:@"isFinished"];
            block();
        }];
    });
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p (for %@:%p), state: %@, cancelled: %@>",
            [self class], self,
            [self.operation class], self.operation,
            self.stateMachine.currentState.name,
            (_cancelled ? @"YES" : @"NO")];
}

@end
