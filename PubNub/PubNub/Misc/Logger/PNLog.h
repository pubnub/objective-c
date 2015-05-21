#import <CocoaLumberjack/CocoaLumberjack.h>
#import "PNStructures.h"


#pragma mark Log macro declaration


#define DDLogClientInfo(frmt, ...) LOG_MAYBE(NO, ddLogLevel, (DDLogFlag)PNInfoLogLevel,  0, nil, \
                                             __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogReachability(frmt, ...) LOG_MAYBE(NO, ddLogLevel, (DDLogFlag)PNReachabilityLogLevel, \
                                               0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogRequest(frmt, ...) LOG_MAYBE(NO, ddLogLevel, (DDLogFlag)PNRequestLogLevel,  0, nil, \
                                          __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogResult(frmt, ...) LOG_MAYBE(NO, ddLogLevel, (DDLogFlag)PNResultLogLevel,  0, nil, \
                                         __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogStatus(frmt, ...) LOG_MAYBE(NO, ddLogLevel, (DDLogFlag)PNStatusLogLevel,  0, nil, \
                                         __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogFailureStatus(frmt, ...) LOG_MAYBE(NO, ddLogLevel, (DDLogFlag)PNFailureStatusLogLevel, \
                                                0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogAESError(frmt, ...) LOG_MAYBE(NO, ddLogLevel, (DDLogFlag)PNAESErrorLogLevel,  0, nil, \
                                           __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogAPICall(frmt, ...) LOG_MAYBE(NO, ddLogLevel, (DDLogFlag)PNAESErrorLogLevel,  0, nil, \
                                          __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)



/**
 @brief      Cocoa Lumberjack helper class to manage logging levels for \b PubNub client.
 @discussion Declares available logging level and allow to manage them at run-time.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNLog : NSObject


///------------------------------------------------
/// @name Initialization and configuration
///------------------------------------------------

+ (void)prepare;

/**
 @brief  Enable particular logging level.
 
 @param logLevel Level which should be enabled and used by Cocoa Lumberjack macro.
 
 @since 4.0
 */
+ (void)enableLogLevel:(PNLogLevel)logLevel;

/**
 @brief  Disable particular logging level.
 
 @param logLevel Level which should be enabled and used by Cocoa Lumberjack macro.
 
 @since 4.0
 */
+ (void)disableLogLevel:(PNLogLevel)logLevel;

/**
 @brief  Update logging level for \b PubNub client and it's categories.
 
 @param logLevel Bit field with target logging level which should be set and used by Cocoa
                 Lumberjack.
 
 @since 4.0
 */
+ (void)setLogLevel:(PNLogLevel)logLevel;

/**
 @brief  Specify whether logger should store output to log files or not.
 
 @param shouldDumpToFile If set to \c YES then logger will store all output (for levels which has 
                         been enabled) into file.
 
 @since 4.0
 */
+ (void)dumpToFile:(BOOL)shouldDumpToFile;

/**
 @brief  Check whether logger allowed to store console output into file or not.
 @defult By default this flag is set to \c YES.
 
 @return \c YES if logger is able to store console output into file.
 */
+ (BOOL)isDumpingToFile;

#pragma mark -


@end
