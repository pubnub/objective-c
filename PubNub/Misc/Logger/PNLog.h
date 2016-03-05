#import "PNStructures.h"


/**
 @brief      Cocoa Lumberjack helper class to manage logging levels for \b PubNub client.
 @discussion Declares available logging level and allow to manage them at run-time.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNLog : NSObject


///------------------------------------------------
/// @name Initialization and configuration
///------------------------------------------------

/**
 @brief  Shortcut to \c +setLogLevel: method and allow to enable/disable logging using bool switch.
 
 @param isLoggingEnabled \c YES in case if logger should allow output from DDLog. Verbose level will
                         be used.
 
 @since 4.0
 */
+ (void)enabled:(BOOL)isLoggingEnabled;

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


///------------------------------------------------
/// @name File logging
///------------------------------------------------

/**
 @brief      Specify maximum file size for single log dup file.
 @discussion As soon as file will exceed specified \c size it will be reotated and depending on 
             configuration can be removed.
 
 @param size Maximum single log dump file size in bytes.
 
 @since 4.0
 */
+ (void)setMaximumLogFileSize:(NSUInteger)size;

/**
 @brief      Manage clean up logic and will keep on file system only last \c count log dump files.
 @discussion If in case of logs rotation new file will be created and overall count of files will
             exceed \c count older files will be removed.
 
 @param count Number of log dump files which should be kept of file system after log rotations.
 
 @since 4.0
 */
+ (void)setMaximumNumberOfLogFiles:(NSUInteger)count;

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
