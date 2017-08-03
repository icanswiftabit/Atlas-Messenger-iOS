////
////  ATLMTranslationCard.m
////  Larry Messenger
////
////  Created by Daniel Maness on 5/31/17.
////  Copyright © 2017 Layer, Inc. All rights reserved.
////
//
//#if 0
//#pragma mark Imports
//#endif
//
//#import "ATLMTranslationCard.h"
//#import "ATLMCardSubclass.h"
//#import <LayerKit/LayerKit.h>
//#import "ATLMTranslationCardCollectionViewCell.h"
//
//NS_ASSUME_NONNULL_BEGIN
//
//
//#if 0
//#pragma mark - Constants
//#endif
//
//static NSString * const ATLMTranslationCardJSONTextKey = @"text";
//static NSString * const ATLMTranslationCardJSONMetadataKey = @"metadata";   // Locale information
//
//
//#if 0
//#pragma mark -
//#endif
//
//@interface ATLMTranslationCard ()
//@property (nonatomic, copy, readonly, nullable) NSDictionary *payloadJSON;  // Dehydrated form of the payload
//+ (NSString*)MIMEType;
//@end
//
//
//#if 0
//#pragma mark -
//#endif
//
//@implementation ATLMTranslationCard
//@synthesize payloadJSON = _payloadJSON;
//
//- (nullable NSDictionary *)payloadJSON {
//    
//    if (nil == _payloadJSON) {
//
//        NSData *data = [[self initialPayloadPart] data];
//        if (nil != data) {
//            if (0 != [data length]) {
//                
//                NSError *error = nil;
//                
//                @try {
//                    _payloadJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//                    if (nil != error) {
//                        _payloadJSON = nil;
//                    }
//                }
//                @finally { /* Do nothing */ }
//            }
//            
//            // This is simply defense against bad data which shouldn't happen if the convenience method
//            // was used for creating the message for the card.
//            if ((nil == _payloadJSON) || ![_payloadJSON isKindOfClass:[NSDictionary class]] || ![[self metadata] isKindOfClass:[NSArray class]]) {
//                _payloadJSON = @{ATLMTranslationCardJSONMetadataKey:@[@"Yes", @"No"]};
//            }
//        }
//    }
//    
//    return _payloadJSON;
//}
//
//- (nullable NSString *)text {
//    return [[self payloadJSON] objectForKey:ATLMTranslationCardJSONTextKey];
//}
//
//- (nullable NSArray<NSString*> *)metadata {
//    return [[self payloadJSON] objectForKey:ATLMTranslationCardJSONMetadataKey];
//}
//
//+ (NSString*)MIMEType {
//    // Use the "x." tree for unregisterd type being used exclusively private right now.
//    return @"application/x.card.translation+json";
//}
//
//+ (BOOL)isSupportedMessage:(LYRMessage *)message {
//    
//    LYRMessagePart *payload = [[message parts] firstObject];
//    return (NSOrderedSame == [[payload MIMEType] compare:[self MIMEType] options:NSCaseInsensitiveSearch]);
//}
//
//+ (nullable LYRMessage *)newMessageWithClient:(LYRClient *)layerClient text:(NSString *)text metadata:(NSArray<NSString *> *)metadata
//{
////    if (0 == [choices count]) {
////        choices = @[@"Yes", @"No"];
////    }
////    
////    NSDictionary *payload;
////    if (0 != [question length]) {
////        payload = @{ATLMTextPollCardJSONQuestionKey:question,
////                    ATLMTextPollCardJSONChoicesKey:choices};
////    }
////    else {
////        payload = @{ATLMTextPollCardJSONChoicesKey:choices};
////    }
////    NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:0 error:error];
//    
//    LYRMessage *result = nil;
////    if (nil != data) {
////        result = [super newMessageWithClient:client
////                          initialPayloadPart:[LYRMessagePart messagePartWithMIMEType:[self MIMEType] data:data]
////                           supplementalParts:nil
////                                     options:options
////                                       error:error];
////    }
//    
//    return result;
//}
//
//+ (Class<ATLMCardPresenting>)collectionViewCellClass {
//    return [ATLMTranslationCardCollectionViewCell class];
//}
//
//@end
//
//NS_ASSUME_NONNULL_END
