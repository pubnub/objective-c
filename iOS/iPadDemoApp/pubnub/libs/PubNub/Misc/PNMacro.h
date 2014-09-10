//
//  PNMacro.h
//  pubnub
//
//  This helper header stores useful C functions
//  and small amount of macro for variaty of tasks.
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//

#import <Foundation/Foundation.h>
#import "NSDate+PNAdditions.h"
#import "PNLogger+Protected.h"
#import "PNStructures.h"


#ifndef PNMacro_h
#define PNMacro_h 1


#pragma mark - Weaks

#ifndef pn_desired_weak
    #if __has_feature(objc_arc_weak)
        #define pn_desired_weak weak
        #define __pn_desired_weak __weak
    #else
        #define pn_desired_weak unsafe_unretained
        #define __pn_desired_weak __unsafe_unretained
    #endif // __has_feature(objc_arc_weak)
#endif // pn_desired_weak


#pragma mark - Logging

#if COCOAPODS == 1
	#define PNLOG_LOGGING_ENABLED 0
	#define PNLOG_STORE_LOG_TO_FILE 0
#else
	#define PNLOG_LOGGING_ENABLED 1
	#define PNLOG_STORE_LOG_TO_FILE 1
#endif

#define PNLOG_GENERAL_LOGGING_ENABLED 1
#define PNLOG_REACHABILITY_LOGGING_ENABLED 1
#define PNLOG_DESERIALIZER_INFO_LOGGING_ENABLED 1
#define PNLOG_DESERIALIZER_ERROR_LOGGING_ENABLED 1
#define PNLOG_COMMUNICATION_CHANNEL_LAYER_ERROR_LOGGING_ENABLED 1
#define PNLOG_COMMUNICATION_CHANNEL_LAYER_INFO_LOGGING_ENABLED 1
#define PNLOG_COMMUNICATION_CHANNEL_LAYER_WARN_LOGGING_ENABLED 1
#define PNLOG_CONNECTION_LAYER_ERROR_LOGGING_ENABLED 1
#define PNLOG_CONNECTION_LAYER_INFO_LOGGING_ENABLED 1
#define PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_LOGGING_ENABLED 0
#define PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_STORING_ENABLED 0

#ifdef PN_TESTING
    #undef PNLOG_LOGGING_ENABLED
    #define PNLOG_LOGGING_ENABLED 1
    #undef PNLOG_STORE_LOG_TO_FILE
    #define PNLOG_STORE_LOG_TO_FILE 1
    #undef PNLOG_GENERAL_LOGGING_ENABLED
    #define PNLOG_GENERAL_LOGGING_ENABLED 1
    #undef PNLOG_REACHABILITY_LOGGING_ENABLED
    #define PNLOG_REACHABILITY_LOGGING_ENABLED 1
    #undef PNLOG_DESERIALIZER_INFO_LOGGING_ENABLED
    #define PNLOG_DESERIALIZER_INFO_LOGGING_ENABLED 1
    #undef PNLOG_DESERIALIZER_ERROR_LOGGING_ENABLED
    #define PNLOG_DESERIALIZER_ERROR_LOGGING_ENABLED 1
    #undef PNLOG_COMMUNICATION_CHANNEL_LAYER_ERROR_LOGGING_ENABLED
    #define PNLOG_COMMUNICATION_CHANNEL_LAYER_ERROR_LOGGING_ENABLED 1
    #undef PNLOG_COMMUNICATION_CHANNEL_LAYER_INFO_LOGGING_ENABLED
    #define PNLOG_COMMUNICATION_CHANNEL_LAYER_INFO_LOGGING_ENABLED 1
    #undef PNLOG_COMMUNICATION_CHANNEL_LAYER_WARN_LOGGING_ENABLED
    #define PNLOG_COMMUNICATION_CHANNEL_LAYER_WARN_LOGGING_ENABLED 1
    #undef PNLOG_CONNECTION_LAYER_ERROR_LOGGING_ENABLED
    #define PNLOG_CONNECTION_LAYER_ERROR_LOGGING_ENABLED 1
    #undef PNLOG_CONNECTION_LAYER_INFO_LOGGING_ENABLED
    #define PNLOG_CONNECTION_LAYER_INFO_LOGGING_ENABLED 1
    #undef PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_LOGGING_ENABLED
    #define PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_LOGGING_ENABLED 1
    #undef PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_STORING_ENABLED
    #define PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_STORING_ENABLED 1
#endif


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"


static void PNLog(PNLogLevel level, id sender, ...);
void PNLog(PNLogLevel level, id sender, ...) {

    va_list args;
    va_start(args, sender);
    NSString *logFormatString = va_arg(args, NSString*);
    NSString *formattedLogString = [[NSString alloc] initWithFormat:logFormatString arguments:args];
    va_end(args);
    
    [PNLogger logFrom:sender forLevel:level withParametersFromBlock:^NSArray *{
        
        return @[(formattedLogString ? formattedLogString : @"nothing to say")];
    }];
}


#pragma mark - Misc functions

static NSNumber* PNTimeTokenFromDate(NSDate *date);
NSNumber* PNTimeTokenFromDate(NSDate *date) {

    unsigned long long int longLongValue = ((unsigned long long int)[date timeIntervalSince1970])*10000000;


    return [NSNumber numberWithUnsignedLongLong:longLongValue];
}

static NSNumber* PNNumberFromUnsignedLongLongString(id timeToken);
NSNumber* PNNumberFromUnsignedLongLongString(id timeToken) {

    if ([timeToken isKindOfClass:[NSString class]]) {

        unsigned long long longLongToken = strtoull([timeToken UTF8String], NULL, 0);
        timeToken = [[NSNumber alloc] initWithUnsignedLongLong:longLongToken];
    }


    return timeToken;
}

static NSString* PNStringFromUnsignedLongLongNumber(id timeToken);
NSString* PNStringFromUnsignedLongLongNumber(id timeToken) {

    if ([timeToken isKindOfClass:[NSNumber class]]) {

        timeToken = [NSString stringWithFormat:@"%llu", [timeToken unsignedLongLongValue]];
    }


    return timeToken;
}

static NSTimeInterval PNUnixTimeStampFromTimeToken(NSNumber *timeToken);
NSTimeInterval PNUnixTimeStampFromTimeToken(NSNumber *timeToken) {

    unsigned long long int longLongValue = [timeToken unsignedLongLongValue];
    NSTimeInterval timeStamp = longLongValue;
    if (longLongValue > INT32_MAX) {

        timeStamp = ((NSTimeInterval)longLongValue)/10000000.0f;
    }


    return timeStamp;
}

static NSString* PNObfuscateString(NSString *string);
NSString *PNObfuscateString(NSString *string) {

    NSString *obfuscatedString = string;
    NSUInteger minimumWidth = 3;
    NSUInteger stringWidth = (NSUInteger)([string length]/2);
    if (stringWidth >= minimumWidth) {

        obfuscatedString = [NSString stringWithFormat:@"%@*****%@", [string substringToIndex:minimumWidth],
                            [string substringFromIndex:([string length] - minimumWidth)]];
    }
    else if([obfuscatedString length]) {

        obfuscatedString = [obfuscatedString substringToIndex:stringWidth];
    }


    return (obfuscatedString ? obfuscatedString : @"");
}

#pragma clang diagnostic pop


#pragma mark Debug options

#ifdef DEBUG
    #define PN_SOCKET_PROXY_ENABLED 0
#endif // DEBUG

#ifdef PN_SOCKET_PROXY_ENABLED
    #if PN_SOCKET_PROXY_ENABLED == 1
        #define PN_SOCKET_PROXY_HOST @"0.0.0.0"
        #define PN_SOCKET_PROXY_PORT @(0)
    #endif // PN_SOCKET_PROXY_ENABLED
#endif // PN_SOCKET_PROXY_ENABLED

#endif
