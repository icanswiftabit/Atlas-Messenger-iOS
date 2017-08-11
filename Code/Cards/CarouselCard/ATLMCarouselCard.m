//
//  ATLMCarouselCard.m
//  Atlas Messenger
//
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import "ATLMCarouselCard.h"
#import "ATLMCardSubclass.h"
#import <LayerKit/LayerKit.h>
#import "ATLMCarouselCardCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark - Constants
#endif

static NSString * const ATLMCarouselCardJSONTitleKey = @"title";
static NSString * const ATLMCarouselCardJSONSubtitleKey = @"subtitle";
static NSString * const ATLMCarouselCardJSONSelectionModeKey = @"selection_mode";
static NSString * const ATLMCarouselCardJSONItemsKey = @"items";
static NSString * const ATLMCarouselCardJSONPriceKey = @"price";
static NSString * const ATLMCarouselCardJSONDetailURLKey = @"detail_url";
static NSString * const ATLMCarouselCardJSONImageURLKey = @"image_url";

static NSString * const ATLMCarouselCardJSONSelectionModeNone = @"none";
static NSString * const ATLMCarouselCardJSONSelectionModeOne = @"one";
static NSString * const ATLMCarouselCardJSONSelectionModeUnlimited = @"unlimited";


#if 0
#pragma mark -
#endif

@interface ATLMCarouselCard ()
@property (nonatomic, copy, readonly, nullable) NSDictionary *payloadJSON;  // Dehydrated form of the payload

+ (NSString*)MIMEType;

@end


#if 0
#pragma mark -
#endif

@implementation ATLMCarouselProduct

- (instancetype)initWithTitle:(NSString *)title {
    
    if ((self = [super init])) {
        _title = [title copy];
    }
    
    return self;
}

- (nullable instancetype)initWithJSONRepresentation:(NSDictionary *)json {
    
    NSString *title = [json objectForKey:ATLMCarouselCardJSONTitleKey];
    if ([title isKindOfClass:[NSString class]] && (0 != [title length]) && (self = [self initWithTitle:title])) {
        _subtitle = [[json objectForKey:ATLMCarouselCardJSONSubtitleKey] copy];
        if (![_subtitle isKindOfClass:[NSString class]]) _subtitle = nil;
        _price = [[json objectForKey:ATLMCarouselCardJSONPriceKey] copy];
        if (![_price isKindOfClass:[NSNumber class]]) _price = nil;
        
        NSString *str = [json objectForKey:ATLMCarouselCardJSONDetailURLKey];
        if ([str isKindOfClass:[NSString class]]) {
            _detailURL = [NSURL URLWithString:str];
        }
        
        str = [json objectForKey:ATLMCarouselCardJSONImageURLKey];
        if ([str isKindOfClass:[NSString class]]) {
            _imageURL = [NSURL URLWithString:str];
        }
    }
    else {
        self = nil;
    }
    
    return self;
}

- (NSDictionary*)JSONRepresentation {
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:5];
    
    [result setObject:[self title] forKey:ATLMCarouselCardJSONTitleKey];
    
    id value = [self subtitle];
    if (0 != [value length]) {
        [result setObject:value forKey:ATLMCarouselCardJSONSubtitleKey];
    }
    
    value = [self price];
    if (nil != value) {
        [result setObject:value forKey:ATLMCarouselCardJSONPriceKey];
    }
    
    value = [self detailURL];
    if (nil != value) {
        [result setObject:[value absoluteString] forKey:ATLMCarouselCardJSONDetailURLKey];
    }
    
    value = [self imageURL];
    if (nil != value) {
        [result setObject:[value absoluteString] forKey:ATLMCarouselCardJSONImageURLKey];
    }
    
    return [result copy];
}

@end


#if 0
#pragma mark -
#endif

@implementation ATLMCarouselCard
@synthesize payloadJSON = _payloadJSON;
@synthesize items = _items;

- (nullable NSDictionary *)payloadJSON {
    
    if (nil == _payloadJSON) {
        
        LYRMessagePart *part = [self initialPayloadPart];
        
        NSData *data = [part data];
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
        }
        else {
            NSURL *url = [part fileURL];
            if (nil != url) {
                NSInputStream *stream = [NSInputStream inputStreamWithURL:url];
                
                NSError *error = nil;
                
                @try {
                    _payloadJSON = [NSJSONSerialization JSONObjectWithStream:stream options:0 error:&error];
                    if (nil != error) {
                        _payloadJSON = nil;
                    }
                }
                @finally { /* Do nothing */ }
            }
        }
        
        // This is simply defense against bad data which shouldn't happen if the convenience method
        // was used for creating the message for the card.
        if ((nil == _payloadJSON) || ![_payloadJSON isKindOfClass:[NSDictionary class]] ||
            ![[self title] isKindOfClass:[NSString class]] || ![[self items] isKindOfClass:[NSArray class]])
        {
            _payloadJSON = @{ /* Empty payload. */ };
        }
    }
    
    return _payloadJSON;
}

- (nullable NSString *)title {
    return [[self payloadJSON] objectForKey:ATLMCarouselCardJSONTitleKey];
}

- (nullable NSString *)subtitle {
    NSString *result = [[self payloadJSON] objectForKey:ATLMCarouselCardJSONSubtitleKey];
    if (![result isKindOfClass:[NSString class]]) {
        result = nil;
    }
    return result;
}

- (ATLMCarouselCardSelectionMode)selectionMode {
    
    ATLMCarouselCardSelectionMode result = ATLMCarouselCardSelectionModeNone;
    NSString *value = [[self payloadJSON] objectForKey:ATLMCarouselCardJSONSelectionModeKey];
    
    if ([value isEqualToString:ATLMCarouselCardJSONSelectionModeOne]) {
        result = ATLMCarouselCardSelectionModeOne;
    }
    else if ([value isEqualToString:ATLMCarouselCardJSONSelectionModeUnlimited]) {
        result = ATLMCarouselCardSelectionModeUnlimited;
    }
    
    return result;
}

- (nullable NSArray<ATLMCarouselProduct *> *)items {
    
    if (nil == _items) {
        
        NSArray<NSDictionary *> *json = [[self payloadJSON] objectForKey:ATLMCarouselCardJSONItemsKey];

        if (nil == _items) {
            for (NSDictionary *object in json) {
                ATLMCarouselProduct *product = [[ATLMCarouselProduct alloc] initWithJSONRepresentation:object];
                if (nil != product) {
                    if (nil != _items) {
                        _items = [_items arrayByAddingObject:product];
                    }
                    else {
                        _items = [NSArray arrayWithObject:product];
                    }
                }
            }
        }
    }
    
    return _items;
}

+ (NSString*)MIMEType {
    return @"application/x.card.carousel+json";
}

+ (BOOL)isSupportedMessage:(LYRMessage *)message {
    LYRMessagePart *payload = [[message parts] firstObject];
    return (NSOrderedSame == [[payload MIMEType] compare:[self MIMEType]
                                                 options:NSCaseInsensitiveSearch
                                                   range:NSMakeRange(0, [[self MIMEType] length])]);
}

+ (Class<ATLMessagePresenting>)collectionViewCellClass {
    return [ATLMCarouselCardCollectionViewCell class];
}

+ (nullable LYRMessage *)newMessageWithClient:(LYRClient *)client
                                        title:(NSString *)title
                                     subtitle:(nullable NSString *)subtitle
                                selectionMode:(ATLMCarouselCardSelectionMode)selectionMode
                                        items:(NSArray<ATLMCarouselProduct *> *)items
                                      options:(nullable LYRMessageOptions *)options
                                        error:(NSError * _Nullable * _Nullable)error
{
    if (0 == [title length]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"+[%@ %@] requires a valid title!", NSStringFromClass(self), NSStringFromSelector(_cmd)]
                                     userInfo:nil];
    }
    
    NSUInteger count = [items count];
    if (0 == count) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"+[%@ %@] requires a valid list of items!", NSStringFromClass(self), NSStringFromSelector(_cmd)]
                                     userInfo:nil];
    }
    
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithCapacity:4];
    [payload setObject:title forKey:ATLMCarouselCardJSONTitleKey];
    if (0 != [subtitle length]) {
        [payload setObject:title forKey:ATLMCarouselCardJSONSubtitleKey];
    }
    
    NSString *mode = ATLMCarouselCardJSONSelectionModeNone;
    switch (selectionMode) {
        case ATLMCarouselCardSelectionModeOne:
            mode = ATLMCarouselCardJSONSelectionModeOne;
            break;
        case ATLMCarouselCardSelectionModeUnlimited:
            mode = ATLMCarouselCardJSONSelectionModeUnlimited;
            break;
        default:
            break;
    }
    [payload setObject:mode forKey:ATLMCarouselCardJSONSelectionModeKey];
    
    NSMutableArray<NSDictionary *> *products = [NSMutableArray arrayWithCapacity:count];
    for (ATLMCarouselProduct *item in items) {
        [products addObject:[item JSONRepresentation]];
    }
    
    [payload setObject:products forKey:ATLMCarouselCardJSONItemsKey];
    
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

@end

NS_ASSUME_NONNULL_END       // }
