//
//  ATLMAuthenticationProvider.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 5/26/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import "ATLMAuthenticationProvider.h"
#import "ATLMHTTPResponseSerializer.h"
#import "ATLMConstants.h"
#import "ATLMConfiguration.h"
#import "ATLMUtilities.h"
#import "ATLMErrors.h"

NSString *const ATLMEmailKey = @"ATLMEmailKey";
NSString *const ATLMPasswordKey = @"ATLMPasswordKey";
NSString *const ATLMCredentialsKey = @"ATLMCredentialsKey";
static NSString *const ATLMAtlasIdentityTokenKey = @"identity_token";

NSString *const ATLMAuthenticatedEndpoint = @"/login";
NSString *const ATLMListUsersEndpoint = @"/users.json";

@interface ATLMAuthenticationProvider ();

@property (nonatomic) NSURL *baseURL;
@property (nonatomic) NSURLSession *URLSession;

@property (nonatomic, copy, readwrite, nullable) NSString *authorization;

- (void)authenticateToken:(NSString*)token nonce:(NSString *)nonce completion:(void (^)(NSString *identityToken, NSError *error))completion;

@end

@implementation ATLMAuthenticationProvider

+ (nonnull instancetype)providerWithBaseURL:(nonnull NSURL *)baseURL layerAppID:(NSURL *)layerAppID
{
    return  [[self alloc] initWithBaseURL:baseURL layerAppID:layerAppID];
}

- (instancetype)initWithConfiguration:(ATLMConfiguration *)configuration
{
    NSURL *appIDURL = configuration.appID;
    NSURL *identityProviderURL = (configuration.identityProviderURL ?: ATLMRailsBaseURL(ATLMEnvironmentProduction));
    
    self = [self initWithBaseURL:identityProviderURL layerAppID:appIDURL];
    return self;
}

- (instancetype)initWithBaseURL:(nonnull NSURL *)baseURL layerAppID:(NSURL *)layerAppID;
{
    if (baseURL == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Cannot initialize %@ with `baseURL` argument being nil", self.class];
    }
    if (layerAppID == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Cannot initialize %@ with `layerAppID` argument being nil", self.class];
    }
    
    self = [super init];
    if (self) {
        _baseURL = baseURL;
        _layerAppID = layerAppID;
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Failed to call designated initializer. Call the designated initializer on the subclass instead."
                                 userInfo:nil];
}

- (nullable NSURLSession*)URLSession {
    
    if (nil == _URLSession) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        NSMutableArray *components = [[NSLocale preferredLanguages] mutableCopy];
        NSUInteger count = [components count];
        
        static const NSUInteger limit = 6;
        if (limit < count) {
            [components removeObjectsInRange:NSMakeRange(limit, count - limit)];
            count = limit;
        }
        
        for (NSUInteger i = 1; i < count; i++) {
            [components replaceObjectAtIndex:i withObject:[[components objectAtIndex:i] stringByAppendingFormat:@";q=%0.1g", (1.0 - (0.1 * i))]];
        }
        
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        UIDevice *device = [UIDevice currentDevice];
        
        NSString *agent = [NSString stringWithFormat:@"%@; %@; %@ %@", info[@"CFBundleName"], device.model, device.systemName, device.systemVersion];

        NSDictionary *headers = @{@"Accept": @"application/json",
                                  @"X_LAYER_APP_ID": self.layerAppID.absoluteString,
                                  @"User-Agent": agent,
                                  @"Accept-Language": [components componentsJoinedByString:@","]};
        
        NSString *authorization = [self authorization];
        if (0 != [authorization length]) {
            NSMutableDictionary *cp = [headers mutableCopy];
            [cp setObject:authorization forKey:@"Authorization"];
            headers = cp;
        }
        
        [configuration setHTTPAdditionalHeaders:headers];
        _URLSession = [NSURLSession sessionWithConfiguration:configuration];
    }
    
    return _URLSession;
}

- (void)setAuthorization:(nullable NSString *)authorization {
    
    if (![authorization isEqualToString:[self authorization]]) {
        _authorization = [authorization copy];
        [self setURLSession:nil];
    }
}

- (void)authenticateToken:(NSString*)token nonce:(NSString *)nonce completion:(void (^)(NSString *identityToken, NSError *error))completion {
    
    NSURL *url = [NSURL URLWithString:@"layer_authenticate" relativeToURL:[self baseURL]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                            timeoutInterval:DBL_MAX];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *body = @{@"session_token":token, @"nonce":nonce};
    
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:0 error:NULL]];
    
    NSURLSessionDataTask *task;
    __weak typeof(self) wSelf = self;
    task = [[self URLSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (nil != sSelf) {
            
            NSString *authorization = nil;
            
            if (nil == error) {
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                NSInteger code = 0;
                if ([result isKindOfClass:[NSDictionary class]]) {
                    
                    authorization = [result objectForKey:ATLMAtlasIdentityTokenKey];
                    
                    if ([authorization isKindOfClass:[NSString class]] && (0 < [authorization length])) {
                        
                        if (200 == [(NSHTTPURLResponse*)response statusCode]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [sSelf setAuthorization:authorization];
                            });
                        }
                        else {
                            code = NSURLErrorUnknown;
                        }
                    }
                    else {
                        authorization = nil;
                        code = NSURLErrorBadServerResponse;
                    }
                }
                
                else {
                    code = NSURLErrorBadServerResponse;
                }
                
                if (0 != code) {
                    error = [NSError errorWithDomain:NSURLErrorDomain
                                                code:code
                                            userInfo:@{NSURLErrorFailingURLErrorKey:url,
                                                       NSURLErrorFailingURLStringErrorKey:[url absoluteString]}];
                }
            }
            
            if (NULL != completion) {
                
                if ((nil == token) && (nil == error)) {
                    error = [NSError errorWithDomain:NSURLErrorDomain
                                                code:NSURLErrorBadServerResponse
                                            userInfo:@{NSURLErrorFailingURLErrorKey:url,
                                                       NSURLErrorFailingURLStringErrorKey:[url absoluteString]}];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(((nil == error) ? authorization : nil), error);
                });
            }
        }
    }];
    
    [task resume];
}

- (void)authenticateWithCredentials:(NSDictionary *)credentials nonce:(NSString *)nonce completion:(void (^)(NSString *identityToken, NSError *error))completion
{
    NSURL *authenticateURL = [NSURL URLWithString:ATLMAuthenticatedEndpoint relativeToURL:self.baseURL];
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:credentials];
    [payload setObject:nonce forKey:@"nonce"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:authenticateURL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        
        if (!data) {
            NSError *error = [NSError errorWithDomain:ATLMErrorDomain code:ATLMAuthenticationErrorNoDataTransmitted userInfo:@{NSLocalizedDescriptionKey: @"Expected identity information in the response from the server, but none was received."}];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setValue:credentials forKey:ATLMCredentialsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // TODO: Basic response and content checks — status and length
        NSError *serializationError;
        NSDictionary *rawResponse = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
        if (serializationError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, serializationError);
            });
            return;
        }
        
        NSString *token = rawResponse[@"token"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self authenticateToken:token nonce:nonce completion:completion];
        });
    }] resume];
}

- (void)refreshAuthenticationWithNonce:(NSString *)nonce completion:(void (^)(NSString *identityToken, NSError *error))completion
{
    NSDictionary *credentials = [[NSUserDefaults standardUserDefaults] objectForKey:ATLMCredentialsKey];
    [self authenticateWithCredentials:credentials nonce:nonce completion:^(NSString * _Nonnull identityToken, NSError * _Nonnull error) {
        completion(identityToken, error);
    }];
}

@end
