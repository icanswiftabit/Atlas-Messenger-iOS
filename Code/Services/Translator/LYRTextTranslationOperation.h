//
//  LYRTextTranslationOperation.h
//  LayerKit
//
//  Created by Blake Watters on 12/28/16.
//  Copyright (c) 2016 Layer Inc. All rights reserved.
//

#import "WEFLYRConcurrentOperation.h"

extern NSString *_Nonnull const LYRTextTranslationErrorDomain;
typedef NS_ENUM(NSUInteger, LYRTextTranslationError) {
    LYRTextTranslationErrorAccessCodeFailure,
    LYRTextTranslationErrorTranslationFailure
};

/**
 @abstract The `LYRTextTranslationOperation` provides an asynchronous interface to the Microsoft Translator API provided as part of Azure Cognitive Services. It is capable of obtaining an access token and performing a translation of text between two given language codes.
 */
@interface LYRTextTranslationOperation : WEFLYRConcurrentOperation

///-------------------------------------------
/// @name Initializing a Translation Operation
///-------------------------------------------

/**
 @abstract Initializes and returns a new operation for translating text between two languages.
 @param subscriptionKey The Subscription Key for Microsoft's Azure Cognitive Services. Used to obtain a valid access token.
 @param accessToken An optional access token for accessing the Translator API. Must be valid.
 @param text The text to be translated.
 @param inputLanguageCode A language code identifying the language of the input text to be translated.
 @param outputLanguageCode A language code identifying the desired language of the translated output text.
 @see http:docs.microsofttranslator.com/oauth-token.html
 @see http:docs.microsofttranslator.com/text-translate.html#!/default/get_Translate
 */
+ (nonnull id)translationOperationWithSubscriptionKey:(nonnull NSString *)subscriptionKey
                                          accessToken:(nullable NSString *)accessToken
                                   forTranslatingText:(nonnull NSString *)text
                                     fromLanguageCode:(nullable NSString *)inputLanguageCode
                                       toLanguageCode:(nonnull NSString *)outputLanguageCode;

///----------------------------------
/// @name Accessing Translation Input
///----------------------------------

/**
 @abstract The Microsoft Cognitive Services subscription key used for obtaining an access token.
 */
@property (nonatomic, nonnull, readonly) NSString *subscriptionKey;

/**
 @abstract The text to be translated via the Translation API.
 */
@property (nonatomic, nonnull, readonly) NSString *text;

/**
 @abstract The source language of the text input as a language code (i.e. en, de, etc).
 */
@property (nonatomic, nullable, readonly) NSString *inputLanguageCode;

/**
 @abstract The destination language of the translated text output as a language code (i.e. en, de, etc).
 */
@property (nonatomic, nonnull, readonly) NSString *outputLanguageCode;

///----------------------------
/// @name Managing Access Token
///----------------------------

/**
 @abstract The access token used to interact with the Microsoft Translation API.
 */
@property (nonatomic, nullable, readonly) NSString *accessToken;

/**
 @abstract An advisory time at which the access token should no longer be used.
 @discussion Only populated if the translation operation obtains a new token.
 */
@property (nonatomic, nullable, readonly) NSDate *accessTokenExpiresAt;

///---------------------------------
/// @name Accessing Operation Output
///---------------------------------

/**
 @abstract The translated text as a UTF-8 string or `nil` if the operation failed.
 */
@property (nonatomic, nullable, readonly) NSString *translatedText;

/**
 @abstract An error describing why the operation failed or `nil` if the operation was successful.
 */
@property (nonatomic, nullable, readonly) NSError *error;

/**
 @abstract Sets a convenience completion block that will yield the results of the operation.
 @param completion The block to invoke when the operation completes.
 */
- (void)setCompletionBlockWithBlock:(nullable void (^)(NSString  * _Nullable translatedText, NSError * _Nullable error))completion;

@end
