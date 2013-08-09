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
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSData+PNAdditions.h"
#include <stdlib.h>


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
    #endif
#endif


#pragma mark - Logging

#if !PNLOG_VERBOSE_LOGGING_ENABLED

#define PNLOG_GENERAL_LOGGING_ENABLED 0
#define PNLOG_REACHABILITY_LOGGING_ENABLED 0
#define PNLOG_DESERIALIZER_INFO_LOGGING_ENABLED 0
#define PNLOG_COMMUNICATION_CHANNEL_LAYER_INFO_LOGGING_ENABLED 0
#define PNLOG_CONNECTION_LAYER_INFO_LOGGING_ENABLED 0

#else

#define PNLOG_GENERAL_LOGGING_ENABLED 1
#define PNLOG_REACHABILITY_LOGGING_ENABLED 1
#define PNLOG_DESERIALIZER_INFO_LOGGING_ENABLED 1
#define PNLOG_COMMUNICATION_CHANNEL_LAYER_INFO_LOGGING_ENABLED 1
#define PNLOG_CONNECTION_LAYER_INFO_LOGGING_ENABLED 1

#endif

#define PNLOG_DESERIALIZER_ERROR_LOGGING_ENABLED 1
#define PNLOG_COMMUNICATION_CHANNEL_LAYER_ERROR_LOGGING_ENABLED 1
#define PNLOG_CONNECTION_LAYER_ERROR_LOGGING_ENABLED 1
#define PNLOG_COMMUNICATION_CHANNEL_LAYER_WARN_LOGGING_ENABLED 1

typedef enum _PNLogLevels {
    PNLogGeneralLevel,
    PNLogReachabilityLevel,
    PNLogDeserializerInfoLevel,
    PNLogDeserializerErrorLevel,
    PNLogConnectionLayerErrorLevel,
    PNLogConnectionLayerInfoLevel,
    PNLogCommunicationChannelLayerErrorLevel,
    PNLogCommunicationChannelLayerWarnLevel,
    PNLogCommunicationChannelLayerInfoLevel
} PNLogLevels;


static BOOL PNLoggingEnabledForLevel(PNLogLevels level);
BOOL PNLoggingEnabledForLevel(PNLogLevels level) {

    BOOL isLoggingEnabledForLevel = NO;

    switch (level) {

        case PNLogGeneralLevel:

                isLoggingEnabledForLevel = PNLOG_GENERAL_LOGGING_ENABLED == 1;
            break;

        case PNLogReachabilityLevel:

                isLoggingEnabledForLevel = PNLOG_REACHABILITY_LOGGING_ENABLED == 1;
            break;

        case PNLogDeserializerInfoLevel:

                isLoggingEnabledForLevel = PNLOG_DESERIALIZER_INFO_LOGGING_ENABLED == 1;
            break;

        case PNLogDeserializerErrorLevel:

                isLoggingEnabledForLevel = PNLOG_DESERIALIZER_ERROR_LOGGING_ENABLED == 1;
            break;

        case PNLogConnectionLayerErrorLevel:

                isLoggingEnabledForLevel = PNLOG_CONNECTION_LAYER_ERROR_LOGGING_ENABLED == 1;
            break;

        case PNLogConnectionLayerInfoLevel:

                isLoggingEnabledForLevel = PNLOG_CONNECTION_LAYER_INFO_LOGGING_ENABLED == 1;
            break;

        case PNLogCommunicationChannelLayerErrorLevel:

                isLoggingEnabledForLevel = PNLOG_COMMUNICATION_CHANNEL_LAYER_ERROR_LOGGING_ENABLED == 1;
            break;

        case PNLogCommunicationChannelLayerWarnLevel:

                isLoggingEnabledForLevel = PNLOG_COMMUNICATION_CHANNEL_LAYER_WARN_LOGGING_ENABLED == 1;
            break;

        case PNLogCommunicationChannelLayerInfoLevel:

                isLoggingEnabledForLevel = PNLOG_COMMUNICATION_CHANNEL_LAYER_INFO_LOGGING_ENABLED == 1;
            break;
    }


    return isLoggingEnabledForLevel;
}

static void PNLog(PNLogLevels level, id sender, ...);
void PNLog(PNLogLevels level, id sender, ...) {

    __block __unsafe_unretained id weakSender = sender;
    NSString *formattedLog = nil;

    va_list args;
    va_start(args, sender);
    NSString *logFormatString = va_arg(args, NSString*);
    NSString *formattedLogString = [[NSString alloc] initWithFormat:logFormatString arguments:args];
    va_end(args);

    formattedLog = [NSString stringWithFormat:@"%@ (%p) %%@", NSStringFromClass([weakSender class]), weakSender];
    NSString *additionalData = nil;


    switch (level) {

        case PNLogGeneralLevel:
        case PNLogReachabilityLevel:

            if (PNLoggingEnabledForLevel(level)) {

                additionalData = @"";
            }
            break;
        case PNLogDeserializerInfoLevel:
        case PNLogConnectionLayerInfoLevel:
        case PNLogCommunicationChannelLayerInfoLevel:

            if (PNLoggingEnabledForLevel(level)) {

                additionalData = @"{INFO}";
            }
            break;
        case PNLogDeserializerErrorLevel:
        case PNLogConnectionLayerErrorLevel:
        case PNLogCommunicationChannelLayerErrorLevel:

            if (PNLoggingEnabledForLevel(level)) {

                additionalData = @"{ERROR}";
            }
            break;
        case PNLogCommunicationChannelLayerWarnLevel:

            if (PNLoggingEnabledForLevel(level)) {

                additionalData = @"{WARN}";
            }
            break;
    }


    if(formattedLog != nil && additionalData != nil) {

        NSLog(@"%@%@", [NSString stringWithFormat:formattedLog, additionalData], formattedLogString);
    }
}

static void PNCFRelease(CF_RELEASES_ARGUMENT void *CFObject);
void PNCFRelease(CF_RELEASES_ARGUMENT void *CFObject) {
    if (CFObject != NULL) {

        if (*((CFTypeRef*)CFObject) != NULL) {
            
            CFRelease(*((CFTypeRef*)CFObject));
        }
        
        *((CFTypeRef*)CFObject) = NULL;
    }
}

static NSNull* PNNillIfNotSet(id object);
NSNull* PNNillIfNotSet(id object) {

    return (object ? object : [NSNull null]);
}

static NSUInteger PNRandomValueInRange(NSRange valuesRange);
NSUInteger PNRandomValueInRange(NSRange valuesRange) {
    
    return valuesRange.location + (random() % (valuesRange.length - valuesRange.location));
}

static NSString* PNUniqueIdentifier();
NSString* PNUniqueIdentifier() {

    // Generating new unique identifier
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfUUID = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    // release the UUID
    CFRelease(uuid);

    
    return [(NSString *)CFBridgingRelease(cfUUID) lowercaseString];
}

static NSString* PNShortenedIdentifierFromUUID(NSString *uuid);
NSString* PNShortenedIdentifierFromUUID(NSString *uuid) {
    
    NSMutableString *shortenedUUID = [NSMutableString string];
    
    NSArray *components = [uuid componentsSeparatedByString:@"-"];
    [components enumerateObjectsUsingBlock:^(NSString *group, NSUInteger groupIdx, BOOL *groupEnumeratorStop) {
        
        NSRange randomValueRange = NSMakeRange(PNRandomValueInRange(NSMakeRange(0, [group length])), 1);
        [shortenedUUID appendString:[group substringWithRange:randomValueRange]];
    }];
    
    
    return shortenedUUID;
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

static NSNumber* PNTimeTokenFromDate(NSDate *date);
NSNumber* PNTimeTokenFromDate(NSDate *date) {

    unsigned long long int longLongValue = ((NSTimeInterval)[date timeIntervalSince1970])*10000000;


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

static NSString *PNHMACSHA256String(NSString *key, NSString *signedData);
NSString *PNHMACSHA256String(NSString *key, NSString *signedData) {

    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cSignedData = [signedData cStringUsingEncoding:NSUTF8StringEncoding];

    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cSignedData, strlen(cSignedData), cHMAC);
    NSData *HMACData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];


    return [HMACData HEXString];
}

static BOOL PNIsUserGeneratedUUID(NSString *uuid);
BOOL PNIsUserGeneratedUUID(NSString *uuid) {

    NSString *uuidSearchRegex = @"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}";
    NSPredicate *generatedUUIDCheckPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", uuidSearchRegex];


    return ![generatedUUIDCheckPredicate evaluateWithObject:uuid];
}

static NSInteger PNRandomInteger();
NSInteger PNRandomInteger() {

    return (arc4random() %(INT32_MAX)-1);
}


#endif
