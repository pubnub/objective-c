#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      PubNub logger.
 @discussion Lightweight logger which is used in \b PubNub SDKs. Depending from configurations logger is able 
             to store logs in file and / or output to debug console.
 
 @author Sergey Mamontov
 @since 4.5.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNLLogger : NSObject


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on unique logger identifier.
 
 @since 4.5.0
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 @brief  Stores path to directory where log files will be stored (if configured to write to files).
 
 @since 4.5.0
 */
@property (nonatomic, readonly, copy) NSString *directory;

/**
 @brief      Stores currently configured log messages level.
 @discussion If passed data for processing will use bit field which is not set in log \c level it will be 
             ignored by logger.
 
 @since 4.5.0
 */
@property (nonatomic, readonly, assign) NSUInteger logLevel;

/**
 @brief  Stores whether passed messages should be sent to console (if enabled) and file (if enabled) or not.
 
 @since 4.5.0
 */
@property (nonatomic, assign) BOOL enabled;

/**
 @brief  Stores whether passed messages should be sent to debug console or not.
 
 @since 4.5.0
 */
@property (nonatomic, assign) BOOL writeToConsole;

/**
 @brief      Stores maximum file size (in bytes) for single log file.
 @discussion As soon as file will exceed specified \c size it will be rotated and depending on configuration 
             can be removed.
 
 @since 4.5.0
 */
@property (nonatomic, assign) NSUInteger maximumLogFileSize;

/**
 @brief      Stores maximum number of log dump files which should be kept of file system after log rotations.
 @discussion If in case of logs rotation new file will be created and overall count of files will
             exceed \c count older files will be removed.
 
 @since 4.5.0
 */
@property (nonatomic, assign) NSUInteger maximumNumberOfLogFiles;

/**
 @brief      Stores maximum logs folder content size.
 @discussion As soon as quota will be reached logger will remove oldest log files to free up some space.
 
 @since 4.5.0
 */
@property (nonatomic, assign) NSUInteger logFilesDiskQuota;

/**
 @brief  Stores whether passed messages should be sent to file or not.
 
 @since 4.5.0
 */
@property (nonatomic, assign) BOOL writeToFile;

/**
 @brief  Stores reference on block which will be called each time when enabled log levels modified.
 
 @since 4.5.0
 */
@property (nonatomic, nullable, copy) dispatch_block_t logLevelChangeHandler;


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief      Create and configure logger instance with pre-defined \c identifier.
 @discussion Specified identifier used to store instance in shared loggers cache. Known identifier make it
             possible to receive reference on concrete logger instance from any part of application.
 
 @since 4.5.0
 
 @param identifier Reference on unique logger identifier.
 
 @return Configured and ready to use logger instance.
 */
+ (instancetype)loggerWithIdentifier:(NSString *)identifier;

/**
 @brief      Create and configure logger instance with pre-defined \c identifier.
 @discussion Specified identifier used to store instance in shared loggers cache. Known identifier make it
             possible to receive reference on concrete logger instance from any part of application.
 
 @since 4.5.0
 
 @param identifier        Reference on unique logger identifier.
 @param logsDirectoryPath Full path to directory where log files (if enabled) will be stored. Default 
                          directory will be used it \c nil passed.
 
 @return Configured and ready to use logger instance.
 */
+ (instancetype)loggerWithIdentifier:(NSString *)identifier directory:(nullable NSString *)logsDirectoryPath;

/**
 @brief      Create and configure logger instance with pre-defined \c identifier.
 @discussion Specified identifier used to store instance in shared loggers cache. Known identifier make it
             possible to receive reference on concrete logger instance from any part of application.
 
 @since 4.5.0
 
 @param identifier        Reference on unique logger identifier.
 @param logsDirectoryPath Full path to directory where log files (if enabled) will be stored. Default 
                          directory will be used it \c nil passed.
 @param extension         Reference on custom log file extension. \c .txt extension will be used by default if
                          \c nil passed.
 
 @return Configured and ready to use logger instance.
 */
+ (instancetype)loggerWithIdentifier:(NSString *)identifier directory:(nullable NSString *)logsDirectoryPath 
                        logExtension:(nullable NSString *)extension;

/**
 @brief      Enable particular logging level.
 @discussion If any call to logger with specified \c level will be done it will be handled and message will be
             printed out and written into file (if enabled).
 
 @param level Log level for which logger should start processing data.
 
 @since 4.5.0
 */
- (void)enableLogLevel:(NSUInteger)level;

/**
 @brief      Disable particular logging level.
 @discussion If any call to logger with specified \c level will be done it will be ignored.
 
 @param level Log level for which logger should ignore passed data.
 
 @since 4.5.0
 */
- (void)disableLogLevel:(NSUInteger)level;

/**
 @brief  Rewrite current logger \c logLevel property values with new one.
 @note   If \b 0 is set then it will be the same as call to \c -enabled: with \b NO parameter value.
 
 @param level New log level which should replace levels which has been set before.
 
 @since 4.5.0
 */
- (void)setLogLevel:(NSUInteger)level;


///------------------------------------------------
/// @name Logging
///------------------------------------------------

/**
 @brief      Process log \c message with specified \c level.
 @discussion If logger can process \c log rquest with specified logging \c level it will build message from 
             \c format and variable list of parametesr which will be sent to console (if enabled) and file 
             (if enabled).
 
 @since 4.5.0
 
 @param level  Reference on bitfield against which configured \c logLevel will be checked to decode whether 
               log should be handled or not.
 @param format Reference on message \c format which should be used to compose resulting log messages.
 @param ...    Variable list of parameters which should be used along with \c format string for log message 
               composition.
 */
- (void)log:(NSUInteger)level format:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);

/**
 @brief  Process log message with specified \c level and format.
 
 @since 4.5.0
 
 @param level   Reference on bitfield against which configured \c logLevel will be checked to decide whether 
                log should be handled or not.
 @param message Reference on composed log message which should be sent to console (if enabled) and file (if 
                enabled).
 */
- (void)log:(NSUInteger)level message:(NSString *)message;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
