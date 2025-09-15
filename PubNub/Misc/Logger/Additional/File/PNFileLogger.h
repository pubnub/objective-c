#import <Foundation/Foundation.h>
#import <PubNub/PNLogger.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Persistent file logger.
///
/// Additional logger that will write log entries to the file at specified location.
///
/// > Important: This logger should be used together with `PNConsoleLogger`.
@interface PNFileLogger : NSObject <PNLogger>


#pragma mark - Properties

/// Maximum number of log dump files on the file system after log rotations.
///
/// Log file will be removed if, after rotation, the number of existing log dump files exceeds this limit.
///
/// **Default:** `5`.
@property(assign, nonatomic) NSUInteger maximumNumberOfLogFiles;

/// Maximum single log file size in bytes.
///
/// As soon as the log file reaches this limit, the logger will rotate logs and start writing to the new one.
///
/// > Note: Depending on ``maximumNumberOfLogFiles`` and ``logFilesDiskQuota`` log files can be removed.
///
/// **Default:** `1` Mb.
@property(assign, nonatomic) NSUInteger maximumLogFileSize;

/// Maximum logs folder size in bytes.
///
/// Logger will try to keep the logs folder within specified limits, removing old log files.
///
/// **Default:** `20` Mb.
@property(assign, nonatomic) NSUInteger logFilesDiskQuota;


#pragma mark - Initialization and Configuration

/// Create a `file`-based logger.
///
/// - Parameter path: Path to directory where log files will be stored. It should be a folder exclusively used for logs.
/// - Returns: Ready-to-use `file`-based logger.
+ (instancetype)loggerWithLogsDirectoryPath:(NSString *)path;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
