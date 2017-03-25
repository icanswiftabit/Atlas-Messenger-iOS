//
//  ATLMTextPollCard.m
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import "ATLMTextPollCard.h"
#import "ATLMCardSubclass.h"
#import <LayerKit/LayerKit.h>
#import "ATLMTextPollCardCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark - Constants
#endif

static NSString * const ATLMTextPollCardJSONQuestionKey = @"question";
static NSString * const ATLMTextPollCardJSONChoicesKey = @"choices";   // Array of available choices


#if 0
#pragma mark -
#endif

@interface ATLMTextPollCard ()
@property (nonatomic, copy, readonly, nullable) NSDictionary *payloadJSON;  // Dehydrated form of the payload
+ (NSString*)MIMEType;
@end


#if 0
#pragma mark -
#endif

@implementation ATLMTextPollCard
@synthesize payloadJSON = _payloadJSON;

- (nullable NSDictionary *)payloadJSON {
    
    if (nil == _payloadJSON) {
        
        NSData *data = [[self initialPayloadPart] data];
        if (nil != data) {
            if (0 != [data length]) {
                
                NSError *error = nil;
                
                @try {
                    _payloadJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                    if (nil != error) {
                        _payloadJSON = nil;
                    }
                }
                @finally { /* Do nothing */ }
            }
            
            // This is simply defense against bad data which shouldn't happen if the convenience method
            // was used for creating the message for the card.
            if ((nil == _payloadJSON) || ![_payloadJSON isKindOfClass:[NSDictionary class]] || ![[self choices] isKindOfClass:[NSArray class]]) {
                _payloadJSON = @{ATLMTextPollCardJSONChoicesKey:@[@"Yes", @"No"]};
            }
        }
    }
    
    return _payloadJSON;
}

- (nullable NSString *)question {
    return [[self payloadJSON] objectForKey:ATLMTextPollCardJSONQuestionKey];
}

- (nullable NSArray<NSString*> *)choices {
    return [[self payloadJSON] objectForKey:ATLMTextPollCardJSONChoicesKey];
}

+ (NSString*)MIMEType {
    // Use the "x." tree for unregisterd type being used exclusively private right now. 
    return @"application/x.card.text-poll+json";
}

+ (BOOL)isSupportedMessage:(LYRMessage *)message {
    
    LYRMessagePart *payload = [[message parts] firstObject];
    return (NSOrderedSame == [[payload MIMEType] compare:[self MIMEType] options:NSCaseInsensitiveSearch]);
}

+ (nullable LYRMessage *)newMessageWithClient:(LYRClient *)client
                                     question:(nullable NSString *)question
                                      choices:(NSArray<NSString *> *)choices
                                      options:(nullable LYRMessageOptions *)options
                                        error:(NSError * _Nullable * _Nullable)error
{
    if (0 == [choices count]) {
        choices = @[@"Yes", @"No"];
    }
    
    NSDictionary *payload;
    if (0 != [question length]) {
        payload = @{ATLMTextPollCardJSONQuestionKey:question,
                    ATLMTextPollCardJSONChoicesKey:choices};
    }
    else {
        payload = @{ATLMTextPollCardJSONChoicesKey:choices};
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:0 error:error];
    
    LYRMessage *result = nil;
    if (nil != data) {
        result = [super newMessageWithClient:client
                          initialPayloadPart:[LYRMessagePart messagePartWithMIMEType:[self MIMEType] data:data]
                           supplementalParts:nil
                                     options:options
                                       error:error];
    }
    
    return result;
}

+ (Class<ATLMessagePresenting>)collectionViewCellClass {
    return [ATLMTextPollCardCollectionViewCell class];
}

@end

NS_ASSUME_NONNULL_END       // }
