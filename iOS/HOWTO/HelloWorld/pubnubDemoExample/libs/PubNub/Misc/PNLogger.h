//
//  PNLogger.h
//  pubnub
//
//  Created by Sergey Mamontov on 4/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Types

/**
 Enum represent available logger levels which can be used.
 */
typedef NS_OPTIONS(unsigned long, PNLogLevel) {

    // This level can be used for any information output. PubNub client itself use this level a lot for own needs.
    PNLogGeneralLevel = 1 << 0,
    
    // This method allow to log out when certain delegate method is about to be called.
    PNLogDelegateLevel = 1 << 1,
    
    // Level which allow to observe for events related to network reachability.
    PNLogReachabilityLevel = 1 << 2,
    
    // Response deserializer level which allow to analyze possible issues with received data.
    PNLogDeserializerInfoLevel = 1 << 3,
    
    // Underlaying layer which is responsible for connection with PubNub servers.
    PNLogDeserializerErrorLevel = 1 << 4,
    PNLogConnectionLayerErrorLevel = 1 << 5,
    PNLogConnectionLayerInfoLevel = 1 << 6,
    
    // Additional level for connection which allow to print out raw HTTP packet content.
    PNLogConnectionLayerHTTPLoggingLevel = 1 << 7,
    
    // Underlaying layer which is responsible requests-response processing.
    PNLogCommunicationChannelLayerErrorLevel = 1 << 8,
    PNLogCommunicationChannelLayerWarnLevel = 1 << 9,
    PNLogCommunicationChannelLayerInfoLevel = 1 << 10
};


#pragma mark - Public interface declaration

@interface PNLogger : NSObject


#pragma mark - Class methods

/**
 Complete logger initialization process.
 */
+ (void)prepare;

/**
 Log out message for specified level using data returned from \c messageBlock block.

 @param sender
 Reference on instance from the name of which message will be logged.

 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logFrom:(id)sender forLevel:(PNLogLevel)level message:(NSString *(^)(void))messageBlock;

/**
 Log out \c 'general' level log message using data returned from \c messageBlock block.

 @param sender
 Reference on instance from the name of which message will be logged.

 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logGeneralMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock;

/**
 Log out \c 'delegate' level log message using data returned from \c messageBlock block.

 @param sender
 Reference on instance from the name of which message will be logged.

 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logDelegateMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock;

/**
 Log out \c 'reachability' level log message using data returned from \c messageBlock block.

 @param sender
 Reference on instance from the name of which message will be logged.

 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logReachabilityMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock;

/**
 Log out \c 'deserializer info' level log message using data returned from \c messageBlock block.

 @param sender
 Reference on instance from the name of which message will be logged.

 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logDeserializerInfoMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock;

/**
 Log out \c 'deserializer error' level log message using data returned from \c messageBlock block.

 @param sender
 Reference on instance from the name of which message will be logged.

 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logDeserializerErrorMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock;

/**
 Log out \c 'connection error' level log message using data returned from \c messageBlock block.

 @param sender
 Reference on instance from the name of which message will be logged.

 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logConnectionErrorMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock;

/**
 Log out \c 'connection info' level log message using data returned from \c messageBlock block.

 @param sender
 Reference on instance from the name of which message will be logged.

 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logConnectionInfoMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock;

/**
 Log out \c 'communication channel error' level log message using data returned from \c messageBlock block.

 @param sender
 Reference on instance from the name of which message will be logged.

 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logCommunicationChannelErrorMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock;

/**
 Log out \c 'communication channel warn' level log message using data returned from \c messageBlock block.

 @param sender
 Reference on instance from the name of which message will be logged.

 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logCommunicationChannelWarnMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock;

/**
 Log out \c 'communication channel info' level log message using data returned from \c messageBlock block.

 @param sender
 Reference on instance from the name of which message will be logged.

 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logCommunicationChannelInfoMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock;

/**
 Store data passed through \c httpPacketBlock block into separate file which will represent single HTTP packet.

 @param httpPacketBlock
 Block which is used by logger to receive \b NSData instance which contains all payload which has been received from server.
 */
+ (void)storeHTTPPacketData:(NSData *(^)(void))httpPacketBlock;


#pragma mark - General logger state manipulation

/**
 Specify whether logger should print out passed values into Xcode console and device log or not.

 @param isLoggerEnabled
 \c YES in case if logger should print out provided input.

 @note This method allow to enable / disable only console / log output. Console dump operation can be changed with
 \c +dumpToFile: method.
 */
+ (void)loggerEnabled:(BOOL)isLoggerEnabled;

/**
 Check whether logger allowed to print out user input or not.

 @return \c YES if logger allowed to print provided data into Xcode console and device log.
 */
+ (BOOL)isLoggerEnabled;

/**
 Specify whether logger should store provided data into file or not.

 @param shouldDumpToFile
 If set to \c YES then logger will store all output (for levels which has been enabled) into file which is stored at
 path returned by \c +dumpFilePath method.
 */
+ (void)dumpToFile:(BOOL)shouldDumpToFile;

/**
 Check whether logger allowed to store console output into file or not.

 @return \c YES if logger is able to store console output into file.
 */
+ (BOOL)isDumpingToFile;

/**
 Retrieve path on log file into which all console output is stored.

 @note Because of log rotation only actual file's path will be returned.

 @return Full path to log file.
 */
+ (NSString *)dumpFilePath;


#pragma mark - File dump manipulation methods

/**
 Allow to configure size of the log file which should be used by log rotation logic to switch with new one if size is
 exceeded.

 @param fileSize
 New size which should be used for files.

 @note Current file immediately will be recalculated and if required log rotation will be performed.
 */
+ (void)setMaximumDumpFileSize:(NSUInteger)fileSize;


#pragma mark - HTTP response dump methods

/**
 Specify whether logger should store provided HTTP payload data into separate file or not.

 @param shouldDumpHTTPResponseToFile
 If set to \c YES then logger will store every single provided packet to be stored in special folder
 ('http-response-dump') inside 'Documents' folder.
 */
+ (void)dumpHTTPResponseToFile:(BOOL)shouldDumpHTTPResponseToFile;

/**
 Check whether logger allowed to store HTTP packets into separarte files or not.

 @return \c YES in case if logger is able to store HTTP responses into file.
 */
+ (BOOL)isDumpingHTTPResponse;


#pragma mark - Levels manipulation methods

/**
 Configure logger and allow it to handle messages for specified logging level.

 @param level
 One of \b PNLogLevel enum entries which specify exact level for which logging should be enabled.
 */
+ (void)enableFor:(PNLogLevel)level;

/**
 Configure logger to suppress log messages from specified logging level.

 @param level
 One of \b PNLogLevel enum entries which should be ignored by logger from now on.
 */
+ (void)disableFor:(PNLogLevel)level;

#pragma mark -


@end
