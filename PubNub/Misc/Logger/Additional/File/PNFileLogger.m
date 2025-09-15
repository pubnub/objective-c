#import "PNFileLogger.h"
#import "PNFileLoggerFileInformation.h"
#import "PNNetworkResponseLogEntry.h"
#import "PNNetworkRequestLogEntry.h"
#import "PNLogEntry+Private.h"
#import "PNLockSupport.h"


#pragma mark Statics

/// Default maximum number of log dump files on the file system after log rotations.
static NSUInteger kPNDefaultMaximumNumberOfLogFiles = 5;

/// Default maximum single log file size in bytes.
static NSUInteger kPNDefaultMaximumLogFileSize = (1 * 1024 * 1024);

/// Default maximum logs folder size in bytes.
static NSUInteger kPNDefaultLogFilesDiskQuota = (20 * 1024 * 1024);


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

/// `File`-based logger private extension.
@interface PNFileLogger ()


#pragma mark - Properties

/// List of models which represent previously created log files.
@property(strong, nonatomic) NSMutableArray<PNFileLoggerFileInformation *> *logFilesInformation;

/// Currently opened for writings log file information.
@property(weak, nullable, nonatomic) PNFileLoggerFileInformation *currentLogInformation;

/// Dispatch source, which is configured as a log file watchdog to track when it will be moved (or renamed).
@property(strong, nullable, nonatomic) dispatch_source_t currentLogFileWatchdog;

/// Current log file access handler instance.
@property(strong, nullable, nonatomic) NSFileHandle *currentLogHandler;

/// Formatter that is used to translate log entry timestamp to ISO8601 standardized string.
@property(strong, nonatomic) NSISO8601DateFormatter *dateFormatter;

/// Shared resources access protection lock.
@property(assign, nonatomic) pthread_mutex_t accessLock;

/// Queue which is used to issue log write requests.
///
/// Queue is used to asynchronously send logged messages to the file.
@property(strong, nonatomic) dispatch_queue_t queue;

/// Path to directory where log files will be stored.
@property(copy, nonatomic) NSString *directory;


#pragma mark - Initialization and Configuration

/// Create a `file`-based logger.
///
/// - Parameter path: Path to directory where log files will be stored. It should be a folder exclusively used for logs.
/// - Returns: Ready-to-use `file`-based logger.
- (instancetype)initWithLogsDirectoryPath:(NSString *)path;


#pragma mark - Logging

/// Store log entry to the log file.
///
/// - Parameter message: Entry that should be stringified and written to the file.
- (void)logMessage:(PNLogEntry *)message;

/// Scan logs directory for log files created during previous sessions.
- (void)indexExistingLogFiles;

/// Verify most recent log file information and roll if required.
///
/// If the most recent file is not archived yet and exceeds the specified log file size, it will be archived, and a new
/// file will be created.
- (void)rollRecentLogFileIfRequired;

/// Complete all pending log file write operations and archived.
///
/// - Parameter rollOnFileMove: Whether the current log file rolled because it has been moved from its previous
/// location or not.
- (void)rollCurrentLogFileOnMove:(BOOL)rollOnFileMove;

/// Check how many log files currently persist on the device file system, and if the number of them is larger than the
/// specified maximum number of log files, older entries will be removed.
- (void)deleteLogsIfRequired;


#pragma mark - Misc

/// Create new log file on file system inside of working directory.
///
/// - Returns: Full path to created log file.
- (NSString *)createLogFile;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNFileLogger


#pragma mark - Properties

- (void)setMaximumNumberOfLogFiles:(NSUInteger)maximumNumberOfLogFiles {
    __block BOOL changed = NO;
    
    pn_lock(&_accessLock, ^{
        changed = self->_maximumNumberOfLogFiles != maximumNumberOfLogFiles;
        self->_maximumNumberOfLogFiles = maximumNumberOfLogFiles;
    });
    
    if (!changed) return;
    
    dispatch_async(self.queue, ^{
        @autoreleasepool {
            pn_lock(&self->_accessLock, ^{
                [self deleteLogsIfRequired];
            });
        }
    });
}

- (void)setMaximumLogFileSize:(NSUInteger)maximumLogFileSize {
    __block BOOL changed = NO;
    
    pn_lock(&_accessLock, ^{
        changed = self->_maximumLogFileSize != maximumLogFileSize;
        self->_maximumLogFileSize = maximumLogFileSize;
    });
    
    if (!changed) return;
    
    dispatch_async(self.queue, ^{
        @autoreleasepool {
            pn_lock(&self->_accessLock, ^{
                [self rollRecentLogFileIfRequired];
            });
        }
    });
}

- (void)setLogFilesDiskQuota:(NSUInteger)logFilesDiskQuota {
    __block BOOL changed = NO;
    
    pn_lock(&_accessLock, ^{
        changed = self->_logFilesDiskQuota != logFilesDiskQuota;
        self->_logFilesDiskQuota = logFilesDiskQuota;
    });
    
    if (!changed) return;
    
    dispatch_async(self.queue, ^{
        @autoreleasepool {
            pn_lock(&self->_accessLock, ^{
                [self deleteLogsIfRequired];
            });
        }
    });
}

- (PNFileLoggerFileInformation *)currentLogInformation {
    if (self->_currentLogInformation) return self->_currentLogInformation;
    [self rollRecentLogFileIfRequired];
    
    PNFileLoggerFileInformation *recentLogFileInformation = self.logFilesInformation.firstObject;
    
    if (recentLogFileInformation && !recentLogFileInformation.isArchived) {
        self->_currentLogInformation = recentLogFileInformation;
    } else {
        NSString *filePath = [self createLogFile];
        PNFileLoggerFileInformation *information = [PNFileLoggerFileInformation informationForFileAtPath:filePath];
        self->_currentLogInformation = information;
        [self.logFilesInformation insertObject:information atIndex:0];
    }
    
    return self->_currentLogInformation;
}

- (NSFileHandle *)currentLogHandler {
    if (!self->_currentLogHandler) {
        self->_currentLogHandler = [NSFileHandle fileHandleForWritingAtPath:self.currentLogInformation.path];
        [self->_currentLogHandler seekToEndOfFile];
        
        if (self->_currentLogHandler) {
            self->_currentLogFileWatchdog = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,
                                                                   [self->_currentLogHandler fileDescriptor],
                                                                   DISPATCH_VNODE_DELETE | DISPATCH_VNODE_RENAME,
                                                                   self->_queue);
            dispatch_source_set_event_handler(self->_currentLogFileWatchdog, ^{
                @autoreleasepool {
                    pn_lock(&self->_accessLock, ^{
                        [self rollCurrentLogFileOnMove:YES];
                    });
                }
            });
            dispatch_resume(self->_currentLogFileWatchdog);
        }
    }
    
    return self->_currentLogHandler;
}


#pragma mark - Initialization and Configuration

+ (instancetype)loggerWithLogsDirectoryPath:(NSString *)path {
    return [[self alloc] initWithLogsDirectoryPath:path];
}

- (instancetype)initWithLogsDirectoryPath:(NSString *)path {
    if ((self = [super init])) {
        _dateFormatter = [NSISO8601DateFormatter new];
        _dateFormatter.formatOptions = NSISO8601DateFormatWithInternetDateTime;
        
        _maximumNumberOfLogFiles = kPNDefaultMaximumNumberOfLogFiles;
        _maximumLogFileSize = kPNDefaultMaximumLogFileSize;
        _logFilesDiskQuota = kPNDefaultLogFilesDiskQuota;
        _directory = [path copy];
        
        _queue = dispatch_queue_create("com.pubnub.file-logger", DISPATCH_QUEUE_SERIAL);
        pthread_mutex_init(&_accessLock, nil);
        
        [self prepareLogsDirectory];
        [self indexExistingLogFiles];
        [self deleteLogsIfRequired];
    }
    
    return self;
}

- (void)prepareLogsDirectory {
    if ([[NSFileManager defaultManager] fileExistsAtPath:_directory]) return;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:_directory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
}


#pragma mark - PNLogger protocol

- (void)debugWithMessage:(PNLogEntry *)message {
    [self logMessage:message];
}

- (void)errorWithMessage:(PNLogEntry *)message {
    [self logMessage:message];
}

- (void)infoWithMessage:(PNLogEntry *)message {
    [self logMessage:message];
}

- (void)traceWithMessage:(PNLogEntry *)message {
    [self logMessage:message];
}

- (void)warnWithMessage:(PNLogEntry *)message {
    [self logMessage:message];
}


#pragma mark - Logging

- (void)logMessage:(PNLogEntry *)message {
    if (!message.preProcessedString) return;
    
    dispatch_async(self.queue, ^{
        NSData *messageData = [message.preProcessedString dataUsingEncoding:NSUTF8StringEncoding];
        
        @try {
            pn_lock(&self->_accessLock, ^{
                [[self currentLogHandler] writeData:messageData];
                [self rollRecentLogFileIfRequired];
            });
        } @catch(NSException *exception)  { /* Nothing can't be done useful because of exception. */ }
    });
}

- (void)indexExistingLogFiles {
    NSFileManager *manager = [NSFileManager defaultManager];
    self.logFilesInformation = [NSMutableArray new];
    
    NSMutableArray<NSString *> *fileNames = [[manager contentsOfDirectoryAtPath:self.directory error:nil] mutableCopy];
    NSArray<NSString *> *logFilePaths = [self.directory stringsByAppendingPaths:fileNames];
    
    for (NSString *filePath in logFilePaths) {
        [self.logFilesInformation addObject:[PNFileLoggerFileInformation informationForFileAtPath:filePath]];
    }
    
    // Sort in the order of creation.
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    [self.logFilesInformation sortUsingDescriptors:@[descriptor]];
}

- (void)rollRecentLogFileIfRequired {
    PNFileLoggerFileInformation *recentLogInformation = self.logFilesInformation.firstObject;
    
    if (recentLogInformation && !recentLogInformation.archived) {
        BOOL isCurrentLog = self->_currentLogInformation && [self->_currentLogInformation isEqual:recentLogInformation];
        unsigned long long size = recentLogInformation.size;
        
        if (isCurrentLog && self->_currentLogHandler) [self->_currentLogHandler getOffset:&size error:nil];
        if (self->_maximumLogFileSize == 0 || size < self->_maximumLogFileSize) return;
         
        if (!isCurrentLog) recentLogInformation.archived = YES;
        else [self rollCurrentLogFileOnMove:NO];
    }
}

- (void)rollCurrentLogFileOnMove:(BOOL)rollOnFileMove {
    if (!self->_currentLogHandler) return;
    
    // Retrieve current log file size.
    unsigned long long logFileSize;
    [self->_currentLogHandler getOffset:&logFileSize error:nil];
    
    [self->_currentLogHandler synchronizeFile];
    [self->_currentLogHandler closeFile];
    self->_currentLogHandler = nil;
    
    if (!rollOnFileMove) {
        self->_currentLogInformation.size = logFileSize;
        self->_currentLogInformation.archived = YES;
    } else [self.logFilesInformation removeObject:self->_currentLogInformation];
    
    self->_currentLogInformation = nil;
}

- (void)deleteLogsIfRequired {
    NSMutableArray<PNFileLoggerFileInformation *> *forRemoval = [NSMutableArray new];
    
    if (self->_maximumNumberOfLogFiles > 0 && self.logFilesInformation.count >= self->_maximumNumberOfLogFiles) {
        NSUInteger filesCount = self.logFilesInformation.count;
        
        for (NSUInteger infoIndex = self->_maximumNumberOfLogFiles - 1; infoIndex < filesCount; infoIndex++) {
            PNFileLoggerFileInformation *informationForRemoval = self.logFilesInformation[infoIndex];
            [[NSFileManager defaultManager] removeItemAtPath:informationForRemoval.path error:nil];
            [forRemoval addObject:informationForRemoval];
        }
        
        [self.logFilesInformation removeObjectsInArray:forRemoval];
        [forRemoval removeAllObjects];
    }
    
    if (!self.logFilesInformation.count) return;
    
    NSNumber *logsFileSize = [self.logFilesInformation valueForKeyPath:@"@sum.size"];
    if ([logsFileSize compare:@(self->_logFilesDiskQuota)] != NSOrderedDescending) return;
    
    NSUInteger filesCount = self.logFilesInformation.count;
    unsigned long long currentLogsFileSize = logsFileSize.unsignedLongLongValue;
    
    for (NSUInteger infoIndex = filesCount - 1; infoIndex >= 0; infoIndex--) {
        PNFileLoggerFileInformation *informationForRemoval = self.logFilesInformation[infoIndex];
        
        if (!self->_currentLogInformation || ![informationForRemoval isEqual:self->_currentLogInformation]) {
            currentLogsFileSize -= informationForRemoval.size;
            [[NSFileManager defaultManager] removeItemAtPath:informationForRemoval.path error:nil];
            [forRemoval addObject:informationForRemoval];
        }
        
        if (currentLogsFileSize < self->_logFilesDiskQuota) break;
    }
    
    [self.logFilesInformation removeObjectsInArray:forRemoval];
}


#pragma mark - Misc

- (NSString *)createLogFile {
    NSString *name = [NSString stringWithFormat:@"pubnub-%@.txt", [self.dateFormatter stringFromDate:[NSDate date]]];
    NSString *filePath = [self.directory stringByAppendingPathComponent:name];
#if TARGET_OS_IOS
    NSDictionary *attributes = @{NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication};
#else
    NSDictionary *attributes = nil;
#endif // TARGET_OS_IOS
    
    [NSFileManager.defaultManager createFileAtPath:filePath contents:nil attributes:attributes];
    [self deleteLogsIfRequired];
    
    return filePath;
}


#pragma mark -

@end
