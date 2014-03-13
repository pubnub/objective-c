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


#pragma mark - Logging

// Stores maximum file syze which should be stored on file system.
// As soon as limit will be reached, beginning of the file will be truncated.
// Default file size is 5Mb
#define kPNLogMaximumLogFileSize (10 * 1024 * 1024)

#if COCOAPODS == 1
	#define PNLOG_LOGGING_ENABLED 0
	#define PNLOG_STORE_LOG_TO_FILE 0
#else
	#define PNLOG_LOGGING_ENABLED 1
	#define PNLOG_STORE_LOG_TO_FILE 1
#endif

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
#define PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_LOGGING_ENABLED 0
#define PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_STORING_ENABLED 0

#ifdef PN_TESTING
#undef PNLOG_LOGGING_ENABLED
#define PNLOG_LOGGING_ENABLED 1
#undef PNLOG_STORE_LOG_TO_FILE
#define PNLOG_STORE_LOG_TO_FILE 1
#undef PNLOG_GENERAL_LOGGING_ENABLED
#define PNLOG_GENERAL_LOGGING_ENABLED 1
#undef PNLOG_DELEGATE_LOGGING_ENABLED
#define PNLOG_DELEGATE_LOGGING_ENABLED 1
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

static void PNLogDumpFileTruncate();
void PNLogDumpFileTruncate() {


    if (PNLOG_STORE_LOG_TO_FILE) {

        // Retrieve path to the 'Documents' folder
        NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *consoleDumpFilePath = [documentsFolder stringByAppendingPathComponent:@"pubnub-console-dump.txt"];
        NSString *oldConsoleDumpFilePath = [documentsFolder stringByAppendingPathComponent:@"pubnub-console-dump.1.txt"];


        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:consoleDumpFilePath]) {

            NSError *attributesFetchError = nil;
            NSDictionary *fileInformation = [fileManager attributesOfItemAtPath:consoleDumpFilePath
                                                                          error:&attributesFetchError];
            if (attributesFetchError == nil) {

                unsigned long long consoleDumpFileSize = [(NSNumber *)[fileInformation valueForKey:NSFileSize] unsignedLongLongValue];


                NSLog(@"PNLog: Current console dump file size is %lld bytes (maximum allowed: %d bytes)",
                      consoleDumpFileSize, kPNLogMaximumLogFileSize);

                if (consoleDumpFileSize > kPNLogMaximumLogFileSize) {

                    NSError *oldLogDeleteError = nil;
                    if ([fileManager fileExistsAtPath:oldConsoleDumpFilePath]) {

                        [fileManager removeItemAtPath:oldConsoleDumpFilePath error:&oldLogDeleteError];
                    }

                    if (oldLogDeleteError == nil) {

                        NSError *fileCopyError;
                        [fileManager copyItemAtPath:consoleDumpFilePath toPath:oldConsoleDumpFilePath error:&fileCopyError];

                        if (fileCopyError == nil) {

                            if ([fileManager fileExistsAtPath:consoleDumpFilePath]) {

                                NSError *currentLogDeleteError = nil;
                                [fileManager removeItemAtPath:consoleDumpFilePath error:&currentLogDeleteError];

                                if (currentLogDeleteError != nil) {

                                    NSLog(@"PNLog: Can't remove current console dump log (%@) because of error: %@",
                                          consoleDumpFilePath, currentLogDeleteError);
                                }
                            }
                        }
                        else {

                            NSLog(@"PNLog: Can't copy current log (%@) to new location (%@) because of error: %@",
                                  consoleDumpFilePath, oldConsoleDumpFilePath, fileCopyError);
                        }
                    }
                    else {

                        NSLog(@"PNLog: Can't remove old console dump log (%@) because of error: %@",
                              oldConsoleDumpFilePath, oldLogDeleteError);
                    }
                }
            }
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


#pragma mark - Misc functions

static void PNDebugPrepare();
void PNDebugPrepare() {

    PNLogDumpFileTruncate();
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
    else {

        obfuscatedString = [obfuscatedString substringToIndex:stringWidth];
    }


    return obfuscatedString;
}

#pragma clang diagnostic pop

#endif
