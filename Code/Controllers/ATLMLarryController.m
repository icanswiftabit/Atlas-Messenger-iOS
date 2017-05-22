//
//  ATLMLarryController.m
//  Atlas Messenger
//
//  Created by Daniel Maness on 5/10/17.
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#import <ApiAI/ApiAI.h>

#import "ATLMLarryController.h"
#import "ATLMConfiguration.h"

@interface ATLMLarryController ()

@property (nonatomic, readonly) LYRClient *layerClient;
@property (nonatomic, strong) ApiAI *apiAI;
@property (nonatomic) NSURL *larryUserID;

@end

@implementation ATLMLarryController

+ (nonnull instancetype)larryControllerWithLayerClient:(nonnull LYRClient *)layerClient
{
    return [[self alloc] initWithLayerClient:layerClient];
}

- (id)initWithLayerClient:(nonnull LYRClient *)layerClient
{
    self = [super init];
    if (self) {
        _layerClient = layerClient;
        
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"LayerConfiguration.json" withExtension:nil];
        ATLMConfiguration *configuration = [[ATLMConfiguration alloc] initWithFileURL:fileURL];
        
        self.larryUserID = configuration.larryUserID;
        
        self.apiAI = [[ApiAI alloc] init];
        id <AIConfiguration> aiConfiguration = [[AIDefaultConfiguration alloc] init];
        aiConfiguration.clientAccessToken = configuration.apiAIToken;
        self.apiAI.configuration = aiConfiguration;
    }
    return self;
}

- (LYRIdentity *)larryIdentity
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRIdentity class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"userID" predicateOperator:LYRPredicateOperatorIsEqualTo value:self.larryUserID];
    
    NSError *error;
    NSOrderedSet *results = [self.layerClient executeQuery:query error:&error];
    return results.firstObject;
}

- (void)getResponseFromLarry:(NSString *)messageText completion:(void (^)(NSString *responseText, NSError *error))completion
{
    
}

- (void)sendMessageAsLarry:(NSString *)messageText
{
    
}

@end
