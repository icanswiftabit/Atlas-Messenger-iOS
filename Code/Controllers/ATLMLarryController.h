//
//  ATLMLarryController.h
//  Atlas Messenger
//
//  Created by Daniel Maness on 5/10/17.
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LYRClient.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATLMLarryController : NSObject

- (instancetype)initWithLayerClient:(nonnull LYRClient *)layerClient;
- (instancetype)init NS_UNAVAILABLE;

- (LYRIdentity *)larryIdentity;
- (void)getResponseFromLarry:(NSString *)messageText completion:(void (^)(NSString *responseText, NSError *error))completion;
- (void)sendMessageAsLarry:(NSString *)messageText;


@end

NS_ASSUME_NONNULL_END
