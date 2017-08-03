//
//  LYRTextTranslationOperation.m
//  LayerKit
//
//  Created by Blake Watters on 12/28/16.
//  Copyright (c) 2016 Layer Inc. All rights reserved.
//

#import "LYRTextTranslationOperation.h"

NSString *const LYRTextTranslationErrorDomain = @"com.microsofttranslator.api";
static NSString *LYRStringByStrippingXMLTagsFromString(NSString *string)
{
    static NSRegularExpression *regexp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regexp = [NSRegularExpression regularExpressionWithPattern:@"<[^>]+>" options:kNilOptions error:nil];
    });
        
    return [regexp stringByReplacingMatchesInString:string
                                            options:kNilOptions
                                              range:NSMakeRange(0, string.length)
                                       withTemplate:@""];
}

@interface LYRTextTranslationOperation ()

@property (nonatomic, nonnull) NSURLSession *URLSession;

@end

@implementation LYRTextTranslationOperation

+ (nonnull id)translationOperationWithSubscriptionKey:(nonnull NSString *)subscriptionKey
                                          accessToken:(nullable NSString *)accessToken
                                   forTranslatingText:(nonnull NSString *)text
                                     fromLanguageCode:(nullable NSString *)inputLanguageCode
                                       toLanguageCode:(nonnull NSString *)outputLanguageCode;
{
    return [[self alloc] initWithSubscriptionKey:subscriptionKey accessToken:accessToken text:text inputLanguageCode:inputLanguageCode outputLanguageCode:outputLanguageCode];
}

- (id)initWithSubscriptionKey:(nonnull NSString *)subscriptionKey
                  accessToken:(nullable NSString *)accessToken
                         text:(nonnull NSString *)text
            inputLanguageCode:(nonnull NSString *)inputLanguageCode
           outputLanguageCode:(nonnull NSString *)outputLanguageCode;
{
    self = [super init];
    if (self) {
        _subscriptionKey = subscriptionKey;
        _accessToken = accessToken;
        _text = text;
        _inputLanguageCode = inputLanguageCode;
        _outputLanguageCode = outputLanguageCode;
        _URLSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Failed to call designated initializer: Call `%@` instead.",
                                           NSStringFromSelector(@selector(initWithSubscriptionKey:accessToken:text:inputLanguageCode:outputLanguageCode:))]
                                 userInfo:nil];
}

- (void)obtainAccessTokenWithCompletion:(void (^)(NSString *accessToken, NSError *error))completion
{
    NSURL *URL = [NSURL URLWithString:@"https://api.cognitive.microsoft.com/sts/v1.0/issueToken"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    [request setValue:self.subscriptionKey forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completion(nil, error);
        } else {
            if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                NSString *accessToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                completion(accessToken, nil);
            } else {
                NSError *parseError;
                NSDictionary *errorObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                NSString *errorMessage = errorObject[@"message"];
                NSError *error = [NSError errorWithDomain:LYRTextTranslationErrorDomain code:LYRTextTranslationErrorAccessCodeFailure userInfo:@{ NSLocalizedDescriptionKey: @"The translation operation failed because an access token could not be obtained.", NSLocalizedFailureReasonErrorKey: errorMessage }];
                completion(nil, error);
            }
        }
    }] resume];
}

- (void)performTranslationWithCompletion:(void (^)(NSString *translatedText, NSError *error))completion
{
    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://api.microsofttranslator.com/v2/http.svc/Translate"];
    NSMutableArray *queryItems = [NSMutableArray new];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"text" value:self.text]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"to" value:self.outputLanguageCode]];
    if (self.inputLanguageCode) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"from" value:self.inputLanguageCode]];
    }
    components.queryItems = queryItems;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken] forHTTPHeaderField:@"Authorization"];
    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completion(nil, error);
        } else {
            if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                NSString *XML = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                completion(LYRStringByStrippingXMLTagsFromString(XML), nil);
            } else {
                NSString *errorHTML = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSError *error = [NSError errorWithDomain:LYRTextTranslationErrorDomain code:LYRTextTranslationErrorTranslationFailure userInfo:@{ NSLocalizedDescriptionKey: @"The translation operation failed because of invalid translation input.", NSLocalizedFailureReasonErrorKey: errorHTML }];
                completion(nil, error);
            }
        }
    }] resume];
}

- (void)execute
{
    if (self.accessToken == nil) {
        [self obtainAccessTokenWithCompletion:^(NSString *accessToken, NSError *error) {
            if (accessToken) {
                _accessToken = accessToken;
                _accessTokenExpiresAt = [NSDate dateWithTimeIntervalSinceNow:8 * 60]; // 8 minutes from now
                [self performTranslationWithCompletion:^(NSString *translatedText, NSError *error) {
                    _translatedText = translatedText;
                    _error = error;
                    [self finish];
                }];
            } else if (error) {
                _error = error;
                [self finish];
            }
        }];
    } else {
        [self performTranslationWithCompletion:^(NSString *translatedText, NSError *error) {
            _translatedText = translatedText;
            _error = error;
            [self finish];
        }];
    }
}

- (void)setCompletionBlockWithBlock:(void (^)(NSString *translatedText, NSError *error))completion
{
    __weak typeof(self) weakSelf = self;
    [self setCompletionBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(strongSelf.translatedText, strongSelf.error);
            });
        }
        strongSelf.completionBlock = nil;
    }];
}

@end
