//
//  ATLMCardResponse.m
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import "ATLMCardResponse.h"
#import <LayerKit/LayerKit.h>
#import "ATLMCard.h"

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark - Constants
#endif

static NSString * const ATLMCardResponseMIMETypeParameterAttributeCard = @"card";


#if 0
#pragma mark -
#endif

@interface ATLMCardResponse ()

@property (nonatomic, copy, readwrite) NSDictionary<NSString *, NSString *> *parameters;

- (nonnull instancetype)initWithMessagePart:(LYRMessagePart*)part
                          supplementalParts:(nullable NSArray<LYRMessagePart *> *)supplementalParts;

+ (NSString*)MIMEType;
+ (BOOL)isSuitableMessagePart:(LYRMessagePart *)part;
+ (NSDictionary<NSString *, NSString *> *)parametersToMIMEType:(NSString *)mime;

+ (NSString*)MIMETypeForResponseToCard:(ATLMCard *)card;

+ (nullable LYRMessage *)newMessageWithClient:(LYRClient *)client
                                  payloadPart:(LYRMessagePart *)payloadPart
                            supplementalParts:(nullable NSArray<LYRMessagePart *> *)supplementalParts
                                      options:(nullable LYRMessageOptions *)options
                                        error:(NSError * _Nullable * _Nullable)error;

+ (BOOL)sendCardResponsePayloadPart:(LYRMessagePart *)payloadPart
                  supplementalParts:(nullable NSArray<LYRMessagePart *> *)supplementalParts
                            forCard:(ATLMCard *)card
                             client:(LYRClient *)client
                            options:(nullable LYRMessageOptions *)options
                              error:(NSError * _Nullable * _Nullable)error;

@end


#if 0
#pragma mark -
#endif

@implementation ATLMCardResponse

+ (nullable instancetype)cardResponseWithMessagePart:(LYRMessagePart *)part
                                   supplementalParts:(nullable NSArray<LYRMessagePart *> *)supplementalParts
{
    ATLMCardResponse *result = nil;
    
    if ([self isSuitableMessagePart:part]) {
        result = [[self alloc] initWithMessagePart:part supplementalParts:supplementalParts];
    }
    
    return result;
}

- (nonnull instancetype)initWithMessagePart:(LYRMessagePart*)part
                          supplementalParts:(nullable NSArray<LYRMessagePart *> *)supplementalParts
{
    if ((self = [super init])) {
        _payloadPart = part;
        _supplementalParts = [supplementalParts copy];
        _parameters = [[self class] parametersToMIMEType:[part MIMEType]];
    }
    
    return self;
}

- (NSURL*)cardIdentifier {
    NSString *encoded = [[self parameters] objectForKey:ATLMCardResponseMIMETypeParameterAttributeCard];
    NSString *identifier = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:encoded options:0]
                                                 encoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:identifier];
}

- (BOOL)isEqual:(id)other {
    return ([other isKindOfClass:[self class]] && [self isEqualToCardResponse:other]);
}

- (BOOL)isEqualToCardResponse:(ATLMCardResponse *)other {
    
    BOOL result = [super isEqual:other];
    if (!result && (nil != other) && [[self payloadPart] isEqual:[other payloadPart]]) {
        NSArray<LYRMessagePart *> *parts = [self supplementalParts];
        NSArray<LYRMessagePart *> *otherParts = [other supplementalParts];
        result = ((parts == otherParts) || [parts isEqualToArray:otherParts]);
    }
    
    return result;
}

+ (NSString*)MIMEType {
    return @"application/x.card-response.1+json";
}

+ (BOOL)isSuitableMessagePart:(LYRMessagePart *)part {
    
    NSString *mime = [[part MIMEType] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Card responses MUST have the card response type as well as the reference to the card.
    return ((0 == [mime rangeOfString:[self MIMEType] options:NSCaseInsensitiveSearch].location) &&
            (0 != [mime rangeOfString:[NSString stringWithFormat:@";%@=", ATLMCardResponseMIMETypeParameterAttributeCard]
                              options:NSCaseInsensitiveSearch].length));
}

+ (NSDictionary<NSString *, NSString *> *)parametersToMIMEType:(NSString *)mime {
    
    // This method assumes the MIME string has already been validated to be a Card Response type.
    
    // Assume it will have all 3 parameters specified
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:3];
    
    NSString *parameters = [mime substringFromIndex:[[self MIMEType] length]];
    
    // **FIXME** This function is easy to fool.  It doesn't support quoted values properly.
    // It also doesn't handle bare attributes (i.e. attributes with no value).
    NSArray<NSString *> *pairs = [parameters componentsSeparatedByString:@";"];
    
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSCharacterSet *quotes = [NSCharacterSet characterSetWithCharactersInString:@"\""];

    for (NSString *pair in pairs) {
        
        NSArray<NSString *> *kv = [pair componentsSeparatedByString:@"="];
        
        if (2 == [kv count]) {
            
            NSString *key = [[kv firstObject] stringByTrimmingCharactersInSet:ws];
            NSString *value = [[kv lastObject] stringByTrimmingCharactersInSet:ws];
            
            NSUInteger length = [value length];
            
            if ((0 != [key length]) && (0 != length)) {
                
                // Perform a cheap hack to trim quoted values down
                value = [value stringByTrimmingCharactersInSet:quotes];
                
                [result setObject:value forKey:key];
            }
        }
    }
    
    return [result copy];
}

+ (NSString*)MIMETypeForResponseToCard:(ATLMCard *)card {
    LYRMessage *message = [card message];
    NSURL *identifier = [message identifier];
    NSString *escaped = [[[identifier absoluteString] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    return [[self MIMEType] stringByAppendingFormat:@";%@=\"%@\"", ATLMCardResponseMIMETypeParameterAttributeCard, escaped];
}

+ (nullable LYRMessage *)newMessageWithClient:(LYRClient *)client
                                  payloadPart:(LYRMessagePart *)payloadPart
                            supplementalParts:(nullable NSArray<LYRMessagePart *> *)supplementalParts
                                      options:(nullable LYRMessageOptions *)options
                                        error:(NSError * _Nullable * _Nullable)error
{
    NSArray<LYRMessagePart *> *parts = @[payloadPart];
    
    if (0 != [supplementalParts count]) {
        parts = [parts arrayByAddingObjectsFromArray:supplementalParts];
    }
    
    return [client newMessageWithParts:parts options:options error:error];
}

+ (BOOL)sendCardResponsePayloadPart:(LYRMessagePart *)payloadPart
                  supplementalParts:(nullable NSArray<LYRMessagePart *> *)supplementalParts
                            forCard:(ATLMCard *)card
                             client:(LYRClient *)client
                            options:(nullable LYRMessageOptions *)options
                              error:(NSError * _Nullable * _Nullable)error
{    
    LYRMessage *message = [self newMessageWithClient:client
                                         payloadPart:payloadPart
                                   supplementalParts:supplementalParts
                                             options:options
                                               error:error];
    
    BOOL result = NO;
    if (nil != message) {
        result = [[[card message] conversation] sendMessage:message error:error];
    }
    
    return result;
}

+ (BOOL)sendCardResponseWithPayloadData:(NSData *)payload
                      supplementalParts:(nullable NSArray<LYRMessagePart *> *)supplementalParts
                                forCard:(ATLMCard *)card
                                 client:(LYRClient *)client
                                options:(nullable LYRMessageOptions *)options
                                  error:(NSError * _Nullable * _Nullable)error
{
    NSString *mime = [self MIMETypeForResponseToCard:card];
    return [self sendCardResponsePayloadPart:[LYRMessagePart messagePartWithMIMEType:mime data:payload]
                           supplementalParts:supplementalParts
                                     forCard:card
                                      client:client
                                     options:options
                                       error:error];
}

+ (BOOL)sendCardResponseWithPayloadStream:(NSInputStream *)payload
                        supplementalParts:(nullable NSArray<LYRMessagePart *> *)supplementalParts
                                  forCard:(ATLMCard *)card
                                   client:(LYRClient *)client
                                  options:(nullable LYRMessageOptions *)options
                                    error:(NSError * _Nullable * _Nullable)error
{
    NSString *mime = [self MIMETypeForResponseToCard:card];
    return [self sendCardResponsePayloadPart:[LYRMessagePart messagePartWithMIMEType:mime stream:payload]
                           supplementalParts:supplementalParts
                                     forCard:card
                                      client:client
                                     options:options
                                       error:error];
}

@end

NS_ASSUME_NONNULL_END       // }
