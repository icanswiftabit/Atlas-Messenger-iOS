//
//  ATLMSchedulingCard.m
//  Atlas Messenger
//
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import "ATLMSchedulingCard.h"
#import "ATLMCardSubclass.h"
#import <LayerKit/LayerKit.h>
#import "ATLMSchedulingCardCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark - Constants
#endif

static NSString * const ATLMATLMSchedulingCardJSONDTitleKey = @"title";
static NSString * const ATLMSchedulingCardJSONDatesKey = @"dates";   // Array of available choices
static NSString * const ATLMSchedulingCardJSONDateRangeStartKey = @"start";
static NSString * const ATLMSchedulingCardJSONDateRangeEndKey = @"end";


#if 0
#pragma mark -
#endif

@interface ATLMSchedulingCard ()
@property (nonatomic, copy, readonly, nullable) NSDictionary *payloadJSON;  // Dehydrated form of the payload
+ (NSString*)MIMEType;
+ (NSArray<ATLMSchedulingCardDateRange *> *)defaultDates;
@end


#if 0
#pragma mark -
#endif

@implementation ATLMSchedulingCardDateRange

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    
    if (NSOrderedAscending == [endDate compare:startDate]) {
        [NSException raise:NSInvalidArgumentException format:@"%@ must be after %@!", endDate, startDate];
    }
    
    if ((self = [super init])) {
        _startDate = startDate;
        _endDate = endDate;
    }
    
    return self;
}

@end


#if 0
#pragma mark - Functions
#endif

/* extern */ NSDateFormatter*
ATLMSchedulingCardISODateFormatter(void) {
    
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

@implementation ATLMSchedulingCard
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
            if ((nil == _payloadJSON) || ![_payloadJSON isKindOfClass:[NSDictionary class]] || ![[self dates] isKindOfClass:[NSArray class]]) {
                _payloadJSON = @{ATLMSchedulingCardJSONDatesKey:[[self class] defaultDates]};
            }
        }
    }
    
    return _payloadJSON;
}

- (nullable NSString *)title {
    return [[self payloadJSON] objectForKey:ATLMATLMSchedulingCardJSONDTitleKey];
}

- (nullable NSArray<ATLMSchedulingCardDateRange*> *)dates {
    
    NSArray<ATLMSchedulingCardDateRange *> *result = nil;
    NSArray<NSDictionary<NSString *, NSString *> *> *ranges = [[self payloadJSON] objectForKey:ATLMSchedulingCardJSONDatesKey];
    
    NSDateFormatter *formatter = ATLMSchedulingCardISODateFormatter();
    for (NSDictionary *range in ranges) {
        NSString *date = [range objectForKey:ATLMSchedulingCardJSONDateRangeStartKey];
        if (0 == [date length]) continue;
        NSDate *start = [formatter dateFromString:date];
        if (nil == start) continue;
        date = [range objectForKey:ATLMSchedulingCardJSONDateRangeEndKey];
        if (0 == [date length]) continue;
        NSDate *end = [formatter dateFromString:date];
        if (nil == end) continue;
        ATLMSchedulingCardDateRange *add = [[ATLMSchedulingCardDateRange alloc] initWithStartDate:start endDate:end];
        if (nil != result) {
            result = [result arrayByAddingObject:add];
        }
        else {
            result = [NSArray arrayWithObject:add];
        }
    }
    
    return result;
}

+ (NSArray<ATLMSchedulingCardDateRange *> *)defaultDates {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *start = [calendar startOfDayForDate:now];
    ATLMSchedulingCardDateRange *first = [[ATLMSchedulingCardDateRange alloc] initWithStartDate:start
                                                                                        endDate:[calendar dateByAddingUnit:NSCalendarUnitHour
                                                                                                                     value:1
                                                                                                                    toDate:start
                                                                                                                   options:NSCalendarWrapComponents]];
    
    start = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:start options:NSCalendarWrapComponents];
    ATLMSchedulingCardDateRange *second = [[ATLMSchedulingCardDateRange alloc] initWithStartDate:start
                                                                                         endDate:[calendar dateByAddingUnit:NSCalendarUnitHour
                                                                                                                      value:1
                                                                                                                     toDate:start
                                                                                                                    options:NSCalendarWrapComponents]];
    
    return @[first, second];
}

+ (NSString*)MIMEType {
    // Use the "x." tree for unregisterd type being used exclusively private right now.
    return @"application/x.card.scheduling+json";
}

+ (BOOL)isSupportedMessage:(LYRMessage *)message {
    
    LYRMessagePart *payload = [[message parts] firstObject];
    return (NSOrderedSame == [[payload MIMEType] compare:[self MIMEType] options:NSCaseInsensitiveSearch]);
}

+ (nullable LYRMessage *)newMessageWithClient:(LYRClient *)client
                                        title:(nullable NSString *)title
                                        dates:(NSArray<ATLMSchedulingCardDateRange *> *)dates
                                      options:(nullable LYRMessageOptions *)options
                                        error:(NSError * _Nullable * _Nullable)error
{
    
    if (0 == [dates count]) {
        dates = [self defaultDates];
    }
    
    NSMutableArray *items = [dates mutableCopy];
    NSDateFormatter *formatter = ATLMSchedulingCardISODateFormatter();
    [dates enumerateObjectsUsingBlock:^(ATLMSchedulingCardDateRange * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [items replaceObjectAtIndex:idx withObject:@{ATLMSchedulingCardJSONDateRangeStartKey:[formatter stringFromDate:[obj startDate]],
                                                     ATLMSchedulingCardJSONDateRangeEndKey:[formatter stringFromDate:[obj endDate]]}];
    }];
    
    NSDictionary *payload;
    if (0 != [title length]) {
        payload = @{ATLMATLMSchedulingCardJSONDTitleKey:title,
                    ATLMSchedulingCardJSONDatesKey:items};
    }
    else {
        payload = @{ATLMSchedulingCardJSONDatesKey:items};
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
    return [ATLMSchedulingCardCollectionViewCell class];
}

@end

NS_ASSUME_NONNULL_END       // }
