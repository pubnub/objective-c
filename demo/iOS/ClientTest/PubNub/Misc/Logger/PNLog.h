#import <CocoaLumberjack/CocoaLumberjack.h>
#import "PNStructures.h"


#pragma mark Log macro declaration

#define DDLogReachability(frmt, ...) LOG_MAYBE(YES, ddLogLevel, PNReachabilityLogLevel,  0, nil, \
                                               __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogRequest(frmt, ...) LOG_MAYBE(YES, ddLogLevel, PNRequestLogLevel,  0, nil, \
                                          __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogResult(frmt, ...) LOG_MAYBE(YES, ddLogLevel, PNResultLogLevel,  0, nil, \
                                         __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogStatus(frmt, ...) LOG_MAYBE(YES, ddLogLevel, PNStatusLogLevel,  0, nil, \
                                         __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogFailureStatus(frmt, ...) LOG_MAYBE(YES, ddLogLevel, PNFailureStatusLogLevel,  0, nil, \
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
 @brief  Update logging level for \b PubNub client and it's categories.
 
 @param logLevel Bit field with target logging level which should be set and used by Cocoa
                 Lumberjack.
 
 @since 4.0
 */
+ (void)setClientLogLevel:(PNLogLevel)logLevel;

/**
 @brief  Specify whether logger should store output to log files or not.
 
 @param shouldDumpToFile If set to \c YES then logger will store all output (for levels which has 
                         been enabled) into file which is stored at path returned by 
                         \c +dumpFilePath method.
 
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
