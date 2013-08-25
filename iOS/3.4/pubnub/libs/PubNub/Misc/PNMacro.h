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
#import "NSDate+PNAdditions.h"
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
    #endif // __has_feature(objc_arc_weak)
#endif // pn_desired_weak


#pragma mark - GCD helper macro

#ifndef PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS
    #define PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS 0

    #if __IPHONE_OS_VERSION_MIN_REQUIRED
        // Only starting from iOS 6.x GCD structures treated as objects and handled by ARC
        #if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
            #undef PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS
            #define PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS 1
        #endif // __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
    #else
        // Only starting from Mac OS X 10.8.x GCD structures treated as objects and handled by ARC
        #if MAC_OS_X_VERSION_MIN_REQUIRED >= 1080
            #undef PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS
            #define PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS 1
        #endif // MAC_OS_X_VERSION_MIN_REQUIRED >= 1080
    #endif // __IPHONE_OS_VERSION_MIN_REQUIRED
#endif // PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS

#ifndef pn_dispatch_property_ownership
    #define pn_dispatch_property_ownership assign

    #if PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS
        #undef pn_dispatch_property_ownership
        #define pn_dispatch_property_ownership strong
    #endif // PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS
#endif // pn_dispatch_property_ownership

#ifndef pn_dispatch_object_memory_management
    #define pn_dispatch_object_memory_management

    #if PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS
        #define pn_dispatch_object_retain(__OBJECT__)
        #define pn_dispatch_object_release(__OBJECT__)
    #else
        #define pn_dispatch_object_retain(__OBJECT__) dispatch_retain(__OBJECT__)
        #define pn_dispatch_object_release(__OBJECT__) dispatch_release(__OBJECT__)
    #endif // PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS
#endif // pn_dispatch_object_memory_management


#pragma mark - Logging

#define PNLOG_LOGGING_ENABLED 1
#define PNLOG_STORE_LOG_TO_FILE 1
#define PNLOG_GENERAL_LOGGING_ENABLED 1
#define PNLOG_DELEGATE_LOGGING_ENABLED 1
#define PNLOG_REACHABILITY_LOGGING_ENABLED 1
#define PNLOG_DESERIALIZER_INFO_LOGGING_ENABLED 1
#define PNLOG_DESERIALIZER_ERROR_LOGGING_ENABLED 1
#define PNLOG_COMMUNICATION_CHANNEL_LAYER_ERROR_LOGGING_ENABLED 1
#define PNLOG_COMMUNICATION_CHANNEL_LAYER_INFO_LOGGING_ENABLED 1
#define PNLOG_COMMUNICATION_CHANNEL_LAYER_WARN_LOGGING_ENABLED 1
#define PNLOG_CONNECTION_LAYER_ERROR_LOGGING_ENABLED 1
#define PNLOG_CONNECTION_LAYER_INFO_LOGGING_ENABLED 1
#define PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_LOGGING_ENABLED 1
#define PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_STORING_ENABLED 1

typedef enum _PNLogLevels {
    PNLogGeneralLevel,
    PNLogDelegateLevel,
    PNLogReachabilityLevel,
    PNLogDeserializerInfoLevel,
    PNLogDeserializerErrorLevel,
    PNLogConnectionLayerErrorLevel,
    PNLogConnectionLayerInfoLevel,
    PNLogConnectionLayerHTTPLoggingLevel,
    PNLogCommunicationChannelLayerErrorLevel,
    PNLogCommunicationChannelLayerWarnLevel,
    PNLogCommunicationChannelLayerInfoLevel
} PNLogLevels;


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
static BOOL PNLoggingEnabledForLevel(PNLogLevels level);
BOOL PNLoggingEnabledForLevel(PNLogLevels level) {

    BOOL isLoggingEnabledForLevel = NO;

    switch (level) {

        case PNLogGeneralLevel:

                isLoggingEnabledForLevel = PNLOG_GENERAL_LOGGING_ENABLED == 1;
            break;

        case PNLogDelegateLevel:

                isLoggingEnabledForLevel = PNLOG_DELEGATE_LOGGING_ENABLED == 1;
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

        case PNLogConnectionLayerHTTPLoggingLevel:

                isLoggingEnabledForLevel = PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_LOGGING_ENABLED == 1;
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

static BOOL PNHTTPDumpOutputToFileEnabled();
BOOL PNHTTPDumpOutputToFileEnabled() {

    return PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_STORING_ENABLED == 1;
}

static NSString* PNHTTPDumpOutputFolderPath();
NSString* PNHTTPDumpOutputFolderPath() {

    // Retrieve path to the 'Documents' folder
    NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];


    return [documentsFolder stringByAppendingPathComponent:@"http-response-dump"];
}

static NSString* PNHTTPDumpOutputFilePath();
NSString* PNHTTPDumpOutputFilePath() {

    return [PNHTTPDumpOutputFolderPath() stringByAppendingFormat:@"/response-%@.dmp", [[NSDate date] consoleOutputTimestamp]];
}

static void PNHTTPDumpOutputToFile(NSData *data);
void PNHTTPDumpOutputToFile(NSData *data) {

    if (PNHTTPDumpOutputToFileEnabled()) {

        if(![data writeToFile:PNHTTPDumpOutputFilePath() atomically:YES]){

            NSLog(@"CAN'T SAVE DUMP: %@", data);
        }
    }
}

static void PNLogDumpOutputToFile(NSString *output);
void PNLogDumpOutputToFile(NSString *output) {

    if (PNLOG_STORE_LOG_TO_FILE) {

        // Retrieve path to the 'Documents' folder
        NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *consoleDumpFilePath = [documentsFolder stringByAppendingPathComponent:@"pubnub-console-dump.txt"];

        output = [[[NSDate date] consoleOutputTimestamp] stringByAppendingFormat:@"> %@\n", output];



        FILE *consoleDumpFilePointer = fopen([consoleDumpFilePath UTF8String], "a+");
        if (consoleDumpFilePointer == NULL) {

            NSLog(@"PNLog: Can't open console dump file (%@)", consoleDumpFilePath);
        }
        else {

            const char *cOutput = [output UTF8String];
            fwrite(cOutput, strlen(cOutput), 1, consoleDumpFilePointer);
            fclose(consoleDumpFilePointer);
        }
    }
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


    if (PNLoggingEnabledForLevel(level)) {

        switch (level) {

            case PNLogDelegateLevel:

                additionalData = @"{DELEGATE}";
                break;
            case PNLogDeserializerInfoLevel:
            case PNLogConnectionLayerInfoLevel:
	        case PNLogConnectionLayerHTTPLoggingLevel:
            case PNLogCommunicationChannelLayerInfoLevel:

                additionalData = @"{INFO}";
                break;
            case PNLogDeserializerErrorLevel:
            case PNLogConnectionLayerErrorLevel:
            case PNLogCommunicationChannelLayerErrorLevel:

                additionalData = @"{ERROR}";
                break;
            case PNLogCommunicationChannelLayerWarnLevel:

                additionalData = @"{WARN}";
                break;
            default:

                additionalData = @"";
                break;
        }
    }


    if(formattedLog != nil && additionalData != nil) {

        NSString *consoleString = [NSString stringWithFormat:@"%@%@", [NSString stringWithFormat:formattedLog, additionalData], formattedLogString];
#if PNLOG_LOGGING_ENABLED == 1
        NSLog(@"%@", consoleString);
#endif
        PNLogDumpOutputToFile(consoleString);
    }
}


#pragma mark - GCD helper functions

static void PNDispatchRetain(dispatch_object_t object);
void PNDispatchRetain(dispatch_object_t object) {

    pn_dispatch_object_retain(object);
}

static void PNDispatchRelease(dispatch_object_t object);
void PNDispatchRelease(dispatch_object_t object) {

    pn_dispatch_object_release(object);
}


#pragma mark - Bitwise helper functions

#define BITS_LIST_TERMINATOR ((NSUInteger)0)


static NSUInteger PNBitCompound(va_list masksList);
NSUInteger PNBitCompound(va_list masksList) {

    NSUInteger compoundMask = 0;
    NSUInteger mask = va_arg(masksList, NSUInteger);
    while (mask != BITS_LIST_TERMINATOR) {

        compoundMask |= mask;
        mask = va_arg(masksList, NSUInteger);
    }
    va_end(masksList);


    return compoundMask;
}

static void PNBitClear(NSUInteger *flag);
void PNBitClear(NSUInteger *flag) {

    *flag = 0;
}

static BOOL PNBitStrictIsOn(NSUInteger flag, NSUInteger mask);
BOOL PNBitStrictIsOn(NSUInteger flag, NSUInteger mask) {

    return (flag & mask) == mask;
}


static BOOL PNBitIsOn(NSUInteger flag, NSUInteger mask);
BOOL PNBitIsOn(NSUInteger flag, NSUInteger mask) {

    return (flag & mask) != 0;
}

static BOOL PNBitsIsOn(NSUInteger flag, BOOL allMasksRequired, ...);
BOOL PNBitsIsOn(NSUInteger flag, BOOL allMasksRequired, ...) {

    va_list bits;
    va_start(bits, allMasksRequired);
    NSUInteger compoundMask = PNBitCompound(bits);


    return allMasksRequired ? (flag & compoundMask) == compoundMask : (flag & compoundMask) != 0;
}

static void PNBitOn(NSUInteger *flag, NSUInteger mask);
void PNBitOn(NSUInteger *flag, NSUInteger mask) {

    *flag |= mask;
}

static void PNBitsOn(NSUInteger *flag, ...);
void PNBitsOn(NSUInteger *flag, ...) {

    va_list bits;
    va_start(bits, flag);
    NSUInteger compoundMask = PNBitCompound(bits);

    PNBitOn(flag, compoundMask);
}

static void PNBitOff(NSUInteger *flag, NSUInteger mask);
void PNBitOff(NSUInteger *flag, NSUInteger mask) {

    *flag &= ~mask;
}

static void PNBitsOff(NSUInteger *flag, ...);
void PNBitsOff(NSUInteger *flag, ...) {

    va_list bits;
    va_start(bits, flag);
    NSUInteger compoundMask = PNBitCompound(bits);

    PNBitOff(flag, compoundMask);
}


#pragma mark - CoreFoundation helper functions

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


#pragma mark - Misc functions

static void PNDebugPrepare();
void PNDebugPrepare() {

    if (PNHTTPDumpOutputToFileEnabled()) {

        NSFileManager *fileManager = [NSFileManager defaultManager];

        // Check whether HTTP responses dump folder exists or not
        NSString *dumpsFolderPath = PNHTTPDumpOutputFolderPath();
        if (![fileManager fileExistsAtPath:dumpsFolderPath isDirectory:NULL]) {

            [fileManager createDirectoryAtPath:dumpsFolderPath withIntermediateDirectories:YES
                                    attributes:nil error:NULL];
        }
    }
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

#pragma clang diagnostic pop

#endif