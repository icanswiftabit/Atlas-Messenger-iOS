//
//  ATLMFileCard.m
//  Atlas Messenger
//
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import "ATLMFileCard.h"
#import "ATLMCardSubclass.h"
#import <LayerKit/LayerKit.h>
#import "ATLMFileCardCollectionViewCell.h"
#import <MobileCoreServices/MobileCoreServices.h>

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark - Constants
#endif

static NSString * const ATLMFileCardJSONNameKey = @"title";
static NSString * const ATLMFileCardJSONCommentKey = @"comment";
static NSString * const ATLMFileCardJSONMIMETypeKey = @"mime_type";
static NSString * const ATLMFileCardJSONSizeKey = @"size";
static NSString * const ATLMFileCardJSONCreationDateKey = @"created_at";
static NSString * const ATLMFileCardJSONModificationDateKey = @"updated_at";
static NSString * const ATLMFileCardBinaryDataMIMEType = @"application/octet-stream";


#if 0
#pragma mark - Functions
#endif

static NSDateFormatter*
ATLMFileCardISODateFormatter(void) {
    
    // NOTE this date formatter never needs to be reset.  It is fixed at GMT
    // and on en/US in order to remain ISO compliant.
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken; dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    return formatter;
}


#if 0
#pragma mark -
#endif

@interface ATLMFileCard ()
@property (nonatomic, copy, readonly, nullable) NSDictionary *payloadJSON;  // Dehydrated form of the payload
- (nullable NSDate *)dateForKey:(NSString *)key;
+ (NSString*)MIMEType;
@end


#if 0
#pragma mark -
#endif

@implementation ATLMFileCard
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
            if ((nil == _payloadJSON) || ![_payloadJSON isKindOfClass:[NSDictionary class]] ||
                ![[self fileName] isKindOfClass:[NSString class]] || ![[self fileMIMEType] isKindOfClass:[NSString class]])
            {
                _payloadJSON = @{ATLMFileCardJSONNameKey:@"File", ATLMFileCardJSONMIMETypeKey:ATLMFileCardBinaryDataMIMEType};
            }
        }
    }
    
    return _payloadJSON;
}

- (LYRMessagePart *)filePart {
    return [[self supplementalParts] firstObject];
}

- (nullable NSString *)fileName {
    return [[self payloadJSON] objectForKey:ATLMFileCardJSONNameKey];
}

- (nullable NSArray<NSString*> *)fileMIMEType {
    return [[self payloadJSON] objectForKey:ATLMFileCardJSONMIMETypeKey];
}

- (nullable NSString *)comment {
    return [[self payloadJSON] objectForKey:ATLMFileCardJSONCommentKey];
}

- (nullable NSDate *)creationDate {
    return [self dateForKey:ATLMFileCardJSONCreationDateKey];
}

- (nullable NSDate *)modificationDate {
    return [self dateForKey:ATLMFileCardJSONModificationDateKey];
}

- (nullable NSDate *)dateForKey:(NSString *)key {
    
    NSDate *result = nil;
    
    NSString *iso = [[self payloadJSON] objectForKey:key];
    if ([iso isKindOfClass:[NSString class]] && (0 != [iso length])) {
        NSDateFormatter *formatter = ATLMFileCardISODateFormatter();
        result = [formatter dateFromString:iso];
    }
    
    return result;
}

+ (NSString*)MIMEType {
    return @"application/x.card.file+json";
}

+ (BOOL)isSupportedMessage:(LYRMessage *)message {
    LYRMessagePart *payload = [[message parts] firstObject];
    return (NSOrderedSame == [[payload MIMEType] compare:[self MIMEType]
                                                 options:NSCaseInsensitiveSearch
                                                   range:NSMakeRange(0, [[self MIMEType] length])]);
}

+ (Class<ATLMessagePresenting>)collectionViewCellClass {
    return [ATLMFileCardCollectionViewCell class];
}

+ (nullable LYRMessage *)newMessageWithClient:(LYRClient *)client
                                      fileURL:(NSURL *)url
                                      comment:(nullable NSString *)comment
                                      options:(nullable LYRMessageOptions *)options
                                        error:(NSError * _Nullable * _Nullable)error
{
    if (![url isFileURL]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"+[%@ %@] requires a file URL!", NSStringFromClass(self), NSStringFromSelector(_cmd)]
                                     userInfo:nil];
    }
    
    LYRMessage *result = nil;

    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error:error];
    if (nil != attributes) {
        
        NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithCapacity:5];
        
        [payload setObject:[attributes objectForKey:NSFileSize] forKey:ATLMFileCardJSONSizeKey];
        
        NSDateFormatter *formatter = ATLMFileCardISODateFormatter();
        [payload setObject:[formatter stringFromDate:[attributes objectForKey:NSFileCreationDate]] forKey:ATLMFileCardJSONCreationDateKey];
        [payload setObject:[formatter stringFromDate:[attributes objectForKey:NSFileModificationDate]] forKey:ATLMFileCardJSONModificationDateKey];

        NSString *mime = nil;
        NSString *name = [url lastPathComponent];
        
        CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[name pathExtension], NULL);
        if (NULL != uti) {
            mime = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
            CFRelease(uti);
        }

        [payload setObject:name forKey:ATLMFileCardJSONNameKey];
        [payload setObject:(mime?:ATLMFileCardBinaryDataMIMEType) forKey:ATLMFileCardJSONMIMETypeKey];
        
        if (0 != [comment length]) {
            [payload setObject:comment forKey:ATLMFileCardJSONCommentKey];
        }

        NSInputStream *stream = [NSInputStream inputStreamWithURL:url];
        if (nil != stream) {
            NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:0 error:error];
            
            if (nil != data) {

                result = [super newMessageWithClient:client
                                  initialPayloadPart:[LYRMessagePart messagePartWithMIMEType:[self MIMEType] data:data]
                                   supplementalParts:@[[LYRMessagePart messagePartWithMIMEType:[payload objectForKey:ATLMFileCardJSONMIMETypeKey] stream:stream]]
                                             options:options
                                               error:error];
            }
            
        }
    }
    
    return result;
}

@end

NS_ASSUME_NONNULL_END       // }
