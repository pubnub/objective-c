/**
 @author Sergey Mamontov
 @since 4.5.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNLLogger.h"
#import "PNLLogFileInformation.h"
#import "PNLockSupport.h"
#import <sys/uio.h>
#import <pthread.h>
#import <unistd.h>


#pragma mark Defines

#if TARGET_OS_IOS
    #define USE_PTHREAD_THREADID_NP (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0)
#elif TARGET_OS_WATCH || TARGET_OS_TV
    #define USE_PTHREAD_THREADID_NP YES
#else
    #define USE_PTHREAD_THREADID_NP (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber10_10)
#endif // TARGET_OS_IOS


#pragma mark - Static

/**
 @brief  Spin-lock which is used to protect access to shared resources from multiple threads.
 
 @since 4.5.0
 */
static os_unfair_lock pnl_cacheAccessLock = OS_UNFAIR_LOCK_INIT;

/**
 @brief  Stores maximum log entry timestamp string length.
 
 @since 4.5.0
 */
static int const kPNLLogEntryTimestampLength = 24;

/**
 @brief  Stores default maximum logs file size.
 
 @since 4.5.0
 */
static NSUInteger kPNLDefaultLogFileSize = (1 * 1024 * 1024);

/**
 @brief  Stores how many log files allowed by default.
 
 @since 4.5.0
 */
static NSUInteger kPNLDefaultNumberOfLogFiles = 5;

/**
 @brief  Stores default maximum logs folder size.
 
 @since 4.5.0
 */
static NSUInteger kPNLDefaultLogFilesDiskQuota = (20 * 1024 * 1024);

/**
 @brief      Stores reference on default extension which should be used for log file.
 @discussion If user didn't provided any information about log file extension logger will use this value.
 
 @since 4.5.0
 */
static NSString * const kPNLDefaultLogFileExtension = @"txt";


#pragma mark - Private interface declaration

@interface PNLLogger () {
    
    BOOL _writeToConsole;
    BOOL _writeToFile;
    
    char *_applicationCName;
    size_t _applicationNameLength;
    
    char *_applicationProcessCID;
    size_t _applicationProcessIDLength;
    
    NSUInteger _maximumLogFileSize;
    NSUInteger _maximumNumberOfLogFiles;
}


#pragma mark - Properties

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *directory;

/**
 @brief  Stores name of application / process inside of which logger is used.
 
 @since 4.5.0
 */
@property (nonatomic, copy) NSString *applicationName;

/**
 @brief  Stores reference on currently running application process identifier.
 
 @since 4.5.0
 */
@property (nonatomic, copy) NSString *applicationProcessID;

/**
 @brief  Stores reference on log file extension.
 
 @since 4.5.0
 */
@property (nonatomic, copy) NSString *logFileExtension;

/**
 @brief  Stores list of models which represent previously created log files.
 
 @since 4.5.0
 */
@property (nonatomic, strong) NSMutableArray<PNLLogFileInformation *> *logFilesInformation;

/**
 @brief  Stores reference on currently opened for writtings log file information.
 
 @since 4.5.0
 */
@property (nonatomic, weak) PNLLogFileInformation *currentLogInformation;

/**
 @brief  Stores reference on log file access handler instance.
 
 @since 4.5.0
 */
@property (nonatomic, strong) NSFileHandle *currentLogHandler;

/**
 @brief  Stores reference on dispatch source which is configured as log file watchdog to track when it will be
         moved (or renamed).
 
 @since 4.5.0
 */
@property (nonatomic, strong) dispatch_source_t logFileWatchdog;

@property (nonatomic, assign) NSUInteger logLevel;

/**
 @brief  Stores bit fields of calendar units which take part in timetoken composition.
 
 @since 4.5.0
 */
@property (nonatomic, assign) NSCalendarUnit calendarUnits;

/**
 @brief  Stores reference on date formatter which is used during file name composition.
 
 @since 4.5.0
 */
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

/**
 @brief      Stores reference on queue which is used to issue log requests.
 @discussion This queue is used to send logged message to console (if enabled) and file (if enabled) in 
             asynchronous manner.
 
 @since 4.5.0
 */
@property (nonatomic, strong) dispatch_queue_t queue;

/**
 @brief  Spin-lock which is used to protect access to shared resources from multiple threads.
 
 @since 4.5.0
 */
@property (nonatomic, assign) os_unfair_lock accessLock;


#pragma mark - Initialization and Configuration

/**
 @brief      Initialize logger instance with pre-defined \c identifier.
 @discussion Specified identifier used to store instance in shared loggers cache. Known identifier make it
             possible to receive reference on concrete logger instance from any part of application.
 
 @since 4.5.0
 
 @param identifier        Reference on unique logger identifier.
 @param logsDirectoryPath Full path to directory where log files (if enabled) will be stored. Default 
                          directory will be used it \c nil passed.
 @param extension         Reference on custom log file extension. \c .txt extension will be used by default if
                          \c nil passed.
 
 @return Initialized and ready to use logger instance.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier directory:(nullable NSString *)logsDirectoryPath 
                      logExtension:(nullable NSString *)extension;


#pragma mark - File logging

/**
 @brief  Compose name of log file which should be created.
 
 @since 4.5.0
 
 @return Log file name.
 */
- (NSString *)newLogFileName;

/**
 @brief  Create new log file on file system inside of working directory.
 
 @since 4.5.0
 
 @return Full path to created log file.
 */
- (NSString *)createLogFile;

/**
 @brief      Verify most recent log file information and roll if required.
 @discussion If most recent file not archived yet and exceed specified log file size it will be archived and 
             new file will be created.
 
 @since 4.5.0
 */
- (void)rollRecentLogFileIfRequired;

/**
 @brief      Complete all pending log file write operations and archived.
 @discussion This method allow to roll logs and if required perform logs clean up (if too many logs).
 
 @since 4.5.0
 
 @param rollOnFileMove Whether current log file rolled because it has been moved from it's previous location 
                       or not.
 */
- (void)rollCurrentLogFileOnMove:(BOOL)rollOnFileMove;

/**
 @brief      Check how many log fies currently persist on device file system and if number of them larger than 
             specified maximum number of log files olrder entries will be removed.
 @discussion Logger use file creation date to filter oldest files which should be removed.
 
 @since 4.5.0
 */
- (void)deleteOldLogsIfRequired;

/**
 @brief  Index list of log files which has been created during previous logger sessions.
 
 @since 4.5.0
 */
- (void)indexExistingLogFiles;

/**
 @brief  Filter list of file \c names to find among them names which correspond to log file name format.
 
 @since 4.5.0
 
 @param names List of file names which is found in working directory and should be filtered out.
 
 @return Filtered list of names which contain only log file names.
 */
- (NSArray<NSString *> *)filteredLogFileNames:(NSArray<NSString *> *)names;


#pragma mark - Misc

/**
 @brief      Retrieve reference on shared loggers cache.
 @discussion Logger instances in cache mapped to their unique identifiers.
 
 @since 4.5.0
 
 @return Active logger cache.
 */
+ (NSMutableDictionary<NSString *, PNLLogger *> *)loggersCache;

/**
 @bried      Retrieve reference on default logs location directory.
 @discussion Depending on environment where logger is working there can be different directory location.
 
 @since 4.5.0
 
 @return Full path to logger's logs root folder where subfolders for different logger instances is stored (if
         configured to write to file).
 */
+ (NSString *)defaultLogsDirectoryPath;

/**
 @bried      Retrieve reference on directory path which should be used by this logger instance.
 @discussion Logger is instance based and to differ output from different instances each of logger has unique 
             identifier which is used during working directory path composition.
 
 @since 4.5.0
 
 @param logsDirectoryPath Reference on logs root directory where sub folders for each logger instance is
                          stored.
 
 @return Full path to directory where log files can be stored (if configured to write to file).
 */
- (NSString *)workingDirectoryPath:(NSString *)logsDirectoryPath;

/**
 @brief      Cache current environment information.
 @discussion Gather call environment information which may be useful during logger operation.
 
 @since 4.5.0
 */
- (void)retrieveEnvironmentInformation;

/**
 @brief  Prepare all components which is required during timetoken string calculation.
 
 @since 4.5.0
 */
- (void)prepareDateFormatter;

/**
 @brief  Retrieve ID of thread from which method has been called.
 
 @since 4.5.0
 
 @return Current thread identifier string.
 */
- (NSString *)currentThreadID;

/**
 @brief  Compose log entry timetoken string using passed log \c date.
 
 @since 4.5.0
 
 @param timestamp Reference on stack-allocated storage for formatted timestamp.
 @param date      Reference on date for which string should be composed
 
 @return Resulting formatted timestamp string length.
 */
- (NSUInteger)getTimestamp:(char *)timestamp fromDate:(NSDate *)date;

/**
 @brief      Methods to start / stop observation on \c mutable properties which can be changed.
 @discussion Observer will receive updates and make corresponding adjustments in messages processing flow.
 
 @since 4.5.0
 */
- (void)startPropertiesModificationObservation;
- (void)stopPropertiesModificationObservation;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNLLogger


#pragma mark - Synthesize

@synthesize writeToConsole = _writeToConsole;
@synthesize writeToFile = _writeToFile;


#pragma mark - Information

- (BOOL)writeToConsole {
    
    __block BOOL writeToConsole = NO;
    pn_trylock(&_accessLock, ^{ writeToConsole = _writeToConsole; });
    
    return writeToConsole;
}

- (void)setWriteToConsole:(BOOL)writeToConsole {
    
    pn_trylock(&_accessLock, ^{ _writeToConsole = writeToConsole; });
}

- (BOOL)writeToFile {
    
    __block BOOL writeToFile = NO;
    pn_trylock(&_accessLock, ^{ writeToFile = _writeToFile; });
    
    return writeToFile;
}

- (void)setWriteToFile:(BOOL)writeToFile {
    
    pn_trylock(&_accessLock, ^{ _writeToFile = writeToFile; });
}

- (void)setMaximumLogFileSize:(NSUInteger)maximumLogFileSize {
    
    __block BOOL changed = NO;
    pn_trylock(&_accessLock, ^{
        
        changed = (_maximumLogFileSize != maximumLogFileSize);
        _maximumLogFileSize = maximumLogFileSize;
    });
    if (changed) { dispatch_async(self.queue, ^{ @autoreleasepool { [self rollRecentLogFileIfRequired]; }}); }
}

- (void)setMaximumNumberOfLogFiles:(NSUInteger)maximumNumberOfLogFiles {
    
    __block BOOL changed = NO;
    pn_trylock(&_accessLock, ^{
        changed = (_maximumNumberOfLogFiles != maximumNumberOfLogFiles);
        _maximumNumberOfLogFiles = maximumNumberOfLogFiles;
    });
    if (changed) { dispatch_async(self.queue, ^{ @autoreleasepool { [self deleteOldLogsIfRequired]; }}); }
}

- (PNLLogFileInformation *)currentLogInformation {
    
    pn_trylock(&_accessLock, ^{
        
        if (_currentLogInformation == nil) {
            
            [self rollRecentLogFileIfRequired];
            PNLLogFileInformation *recentLogInfomration = self.logFilesInformation.firstObject;
            if (recentLogInfomration && !recentLogInfomration.isArchived) {
                
                _currentLogInformation = recentLogInfomration;
            }
            else {
                
                NSString *logFilePath = [self createLogFile];
                PNLLogFileInformation *information = [PNLLogFileInformation informationForFileAtPath:logFilePath];
                _currentLogInformation = information;
                [self.logFilesInformation insertObject:_currentLogInformation atIndex:0];
            }
        }
    });
    
    return _currentLogInformation;
}

- (NSFileHandle *)currentLogHandler {
    
    pn_trylock(&_accessLock, ^{
        
        if (_currentLogHandler == nil) {
            
            _currentLogHandler = [NSFileHandle fileHandleForWritingAtPath:self.currentLogInformation.path];
            [_currentLogHandler seekToEndOfFile];
            if (_currentLogHandler) {
                
                _logFileWatchdog = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, 
                                                          [_currentLogHandler fileDescriptor], 
                                                          DISPATCH_VNODE_DELETE | DISPATCH_VNODE_RENAME, 
                                                          _queue);
                dispatch_source_set_event_handler(_logFileWatchdog, ^{
                    
                    @autoreleasepool { [self rollCurrentLogFileOnMove:YES]; }
                });
                
                dispatch_resume(_logFileWatchdog);
            }
        }
    });
    
    return _currentLogHandler;
}


#pragma mark - Initialization and Configuration

+ (instancetype)loggerWithIdentifier:(NSString *)identifier {
    
    return [self loggerWithIdentifier:identifier directory:nil];
}

+ (instancetype)loggerWithIdentifier:(NSString *)identifier directory:(NSString *)path {
    
    return [self loggerWithIdentifier:identifier directory:path logExtension:nil];
}

+ (instancetype)loggerWithIdentifier:(NSString *)identifier directory:(NSString *)logsDirectoryPath 
                        logExtension:(NSString *)extension {
    
    __block PNLLogger *logger = nil;
    pn_trylock(&pnl_cacheAccessLock, ^{
        
        logger = [self loggersCache][identifier];
        if (!logger) { 
            
            NSString *path = (logsDirectoryPath?: [self defaultLogsDirectoryPath]);
            logger = [[self alloc] initWithIdentifier:identifier directory:path 
                                         logExtension:(extension?: kPNLDefaultLogFileExtension)];
            [self loggersCache][identifier] = logger;
        }
    });
    
    return logger;
}

- (instancetype)initWithIdentifier:(NSString *)identifier directory:(NSString *)logsDirectoryPath 
                      logExtension:(NSString *)extension {
    
    // Check whether initialization has been successful or not.
    if ((self = [super init])) {
        
        [self retrieveEnvironmentInformation];
        _identifier = [identifier copy];
        _directory = [[self workingDirectoryPath:logsDirectoryPath] copy];
        _logFileExtension = [extension copy];
        _maximumLogFileSize = kPNLDefaultLogFileSize;
        _logFilesDiskQuota = kPNLDefaultLogFilesDiskQuota;
        
        const char *queueIdentifier = [[identifier stringByAppendingString:@".logger.queue"] UTF8String];
        _queue = dispatch_queue_create(queueIdentifier, DISPATCH_QUEUE_SERIAL);
        _accessLock = OS_UNFAIR_LOCK_INIT;
        
        [self prepareDateFormatter];
        [self indexExistingLogFiles];
        [self startPropertiesModificationObservation];
        
        _maximumNumberOfLogFiles = MAX(_logFilesInformation.count, kPNLDefaultNumberOfLogFiles);
    }
    
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    
    pn_trylock(&_accessLock, ^{ _enabled = enabled; });
}

- (void)enableLogLevel:(NSUInteger)level {
    
    pn_trylock(&_accessLock, ^{ 
        
        BOOL notifyChange = (_logLevel != (_logLevel | level) && _logLevelChangeHandler);
        _logLevel |= level;
        if (notifyChange) { dispatch_async(dispatch_get_main_queue(), _logLevelChangeHandler); }
    });
}

- (void)disableLogLevel:(NSUInteger)level {
    
    pn_trylock(&_accessLock, ^{ 
        
        BOOL notifyChange = (_logLevel != (_logLevel & ~level) && _logLevelChangeHandler);
        _logLevel &= ~level;
        if (notifyChange) { dispatch_async(dispatch_get_main_queue(), _logLevelChangeHandler); }
    });
}

- (void)setLogLevel:(NSUInteger)level {
    
    pn_trylock(&_accessLock, ^{ 
        
        BOOL notifyChange = (_logLevel != level && _logLevelChangeHandler);
        _logLevel = level;
        if (level == 0) { _enabled = NO; }
        if (notifyChange) { dispatch_async(dispatch_get_main_queue(), _logLevelChangeHandler); }
    });
}


#pragma mark - Logging

- (void)log:(NSUInteger)level format:(NSString *)format, ... {
    
    __block BOOL shouldHandleLog = NO;
    pn_trylock(&_accessLock, ^{ shouldHandleLog = (_logLevel & level); });
    if (shouldHandleLog && format.length) {
        
        va_list args;
        va_start(args, format);
        [self log:level message:[[NSString alloc] initWithFormat:format arguments:args]];
        va_end(args);
    }
}

- (void)log:(NSUInteger)level message:(NSString *)message {
    
    if (self.enabled || level == 0) {
        
        NSString *threadID = [self currentThreadID];
        NSDate *logDate = [NSDate date];
        dispatch_async(self.queue, ^{
            
            char timestamp[kPNLLogEntryTimestampLength];
            NSUInteger timestampLength = [self getTimestamp:timestamp fromDate:logDate];
            if (self.writeToConsole) {
                
                NSUInteger length = [message lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
                const BOOL useStackMemory = length < (1024 * 4);
                char *cMessage = (char *)(useStackMemory ? alloca(length + 1) : malloc(length + 1));
                [message getCString:cMessage maxLength:(length + 1) encoding:NSUTF8StringEncoding];
                
                const char *threadCID = [threadID cStringUsingEncoding:NSUTF8StringEncoding];
                char tid[9];
                int threadIDLength = MIN(snprintf(tid, 9, "%s", threadCID), 8);
                
                struct iovec vector[10];
                vector[0] = (struct iovec){.iov_base = timestamp, .iov_len = timestampLength};
                vector[1] = (struct iovec){.iov_base = " ", .iov_len = 1};
                vector[2] = (struct iovec){.iov_base = _applicationCName, .iov_len = _applicationNameLength};
                vector[3] = (struct iovec){.iov_base = "[", .iov_len = 1};
                vector[4] = (struct iovec){.iov_base = _applicationProcessCID, .iov_len = _applicationProcessIDLength};
                vector[5] = (struct iovec){.iov_base = ":", .iov_len = 1};
                vector[6] = (struct iovec){.iov_base = tid, .iov_len = threadIDLength};
                vector[7] = (struct iovec){.iov_base = "] ", .iov_len = 2};
                vector[8] = (struct iovec){.iov_base = cMessage, .iov_len = length};
                vector[9] = (struct iovec){.iov_base = "\n", .iov_len = (cMessage[length] == '\n' ? 0 : 1)};
                
                writev(STDERR_FILENO, vector, 10);
                if (!useStackMemory) { free(cMessage); }
            }
            
            if (self.writeToFile) {
                
                NSString *formattedMessage = [NSString stringWithFormat:@"%s %@[%@:%@] %@%@", timestamp, 
                                              _applicationName, _applicationProcessID, threadID, message,
                                              ([message hasSuffix:@"\n"] ? @"" : @"\n")];
                NSData *messageData = [formattedMessage dataUsingEncoding:NSUTF8StringEncoding];
                @try {
                    
                    [[self currentLogHandler] writeData:messageData];
                    [self rollRecentLogFileIfRequired];
                } @catch (NSException *exception) { /* Nothing can't be done useful because of exception. */ }
            }
        });
    }
}


#pragma mark - File logging

- (NSString *)newLogFileName {
    
    NSInteger maximumCopyNumber = -1;
    NSString *baseName = [NSString stringWithFormat:@"%@ %@", self.applicationName,
                          [self.dateFormatter stringFromDate:[NSDate date]]];
    NSString *targetName = [baseName stringByAppendingPathExtension:self.logFileExtension];
    NSArray<NSString *> *existingNames = [self.logFilesInformation valueForKey:@"name"];
        
    NSString *pattern = [NSString stringWithFormat:@"%@(\\s\\d+)?\\.(?:%@)", baseName, 
                         self.logFileExtension];
    NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options
                                                                             error:nil];
    for (NSString *name in existingNames) {
        
        if (maximumCopyNumber == -1 && [name hasPrefix:baseName]) { maximumCopyNumber = 0; }
        NSRange matchRange = NSMakeRange(0, name.length);
        NSArray *matches = [regex matchesInString:name options:(NSMatchingOptions)0 range:matchRange];
        if (matches.count) {
            
            for (NSTextCheckingResult *match in matches) {
                
                NSRange matchRange = [match rangeAtIndex:1];
                if (matchRange.location != NSNotFound) {
                    
                    NSInteger fileCopyNumber = [name substringWithRange:matchRange].integerValue;
                    maximumCopyNumber = MAX(maximumCopyNumber, fileCopyNumber);
                }
            }
        }
    }
        
    if (maximumCopyNumber >= 0) {
        
        targetName = [NSString stringWithFormat:@"%@ %lu.%@", baseName, 
                      (unsigned long)(maximumCopyNumber + 1), self.logFileExtension];
    }
    
    return targetName;
}

- (NSString *)createLogFile {
    
    NSString *filePath = [self.directory stringByAppendingPathComponent:[self newLogFileName]];
#if TARGET_OS_IOS
    NSDictionary *attributes = @{NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication};
#else
    NSDictionary *attributes = nil;
#endif // TARGET_OS_IOS
    
    // Create logs folder if required.
    if (![[NSFileManager defaultManager] fileExistsAtPath:_directory]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:_directory withIntermediateDirectories:YES
                                                   attributes:nil error:nil];
    }
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:attributes];
    [self deleteOldLogsIfRequired];
    
    return filePath;
}

- (void)rollRecentLogFileIfRequired {
    
    pn_trylock(&_accessLock, ^{
        
        PNLLogFileInformation *recentLogInfomration = self.logFilesInformation.firstObject;
        if (recentLogInfomration && !recentLogInfomration.archived) {
            
            BOOL isCurrentLog = (_currentLogInformation && [_currentLogInformation isEqual:recentLogInfomration]);
            unsigned long long size = recentLogInfomration.size;
            if (isCurrentLog && _currentLogHandler) { size = _currentLogHandler.offsetInFile; }
            if (_maximumLogFileSize > 0 && size >= _maximumLogFileSize) {
                
                if (isCurrentLog) { [self rollCurrentLogFileOnMove:NO]; }
                else { recentLogInfomration.archived = YES; }
            }
        }
    });
}

- (void)rollCurrentLogFileOnMove:(BOOL)rollOnFileMove {
    
    pn_trylock(&_accessLock, ^{
        
        if (_currentLogHandler) {
            
            unsigned long long logFileSize = _currentLogHandler.offsetInFile;
            [_currentLogHandler synchronizeFile];
            [_currentLogHandler closeFile];
            _currentLogHandler = nil;
            
            if (!rollOnFileMove) {
                
                _currentLogInformation.size = logFileSize;
                _currentLogInformation.archived = YES;
            }
            else { [self.logFilesInformation removeObject:_currentLogInformation]; }
            _currentLogInformation = nil;
            
            if (_logFileWatchdog) {
                
                dispatch_source_cancel(_logFileWatchdog);
                _logFileWatchdog = NULL;
            }
        }
    });
}

- (void)deleteOldLogsIfRequired {
    
    pn_trylock(&_accessLock, ^{
        
        NSMutableArray<PNLLogFileInformation *> *informationsForRemoval = [NSMutableArray new];
        if (_maximumNumberOfLogFiles > 0 && self.logFilesInformation.count >= _maximumNumberOfLogFiles) {
            
            NSUInteger filesCount = self.logFilesInformation.count;
            for (NSUInteger infoIndex = _maximumNumberOfLogFiles - 1; infoIndex < filesCount; infoIndex++) {
                
                PNLLogFileInformation *informationForRemoval = self.logFilesInformation[infoIndex];
                [[NSFileManager defaultManager] removeItemAtPath:informationForRemoval.path error:nil];
                [informationsForRemoval addObject:informationForRemoval];
            }
            [self.logFilesInformation removeObjectsInArray:informationsForRemoval];
            [informationsForRemoval removeAllObjects];
        }
        
        if (self.logFilesInformation.count) {
            
            NSNumber *logsFileSize = [self.logFilesInformation valueForKeyPath:@"@sum.size"];
            if ([logsFileSize compare:@(_logFilesDiskQuota)] == NSOrderedDescending) {
                
                NSUInteger filesCount = self.logFilesInformation.count;
                unsigned long long currentLogsFileSize = logsFileSize.unsignedLongLongValue;
                for (NSInteger infoIndex = filesCount - 1; infoIndex >= 0; infoIndex--) {
                    
                    PNLLogFileInformation *informationForRemoval = self.logFilesInformation[infoIndex];
                    if (!_currentLogInformation || ![informationForRemoval isEqual:_currentLogInformation]) {
                        
                        currentLogsFileSize -= informationForRemoval.size;
                        [[NSFileManager defaultManager] removeItemAtPath:informationForRemoval.path error:nil];
                        [informationsForRemoval addObject:informationForRemoval];
                    }
                    
                    if (currentLogsFileSize < _logFilesDiskQuota) { break; }
                }
                [self.logFilesInformation removeObjectsInArray:informationsForRemoval];
            }
        }
    });
}

- (void)indexExistingLogFiles {
    
    self.logFilesInformation = [NSMutableArray new];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray<NSString *> *fileNames = [fileManager contentsOfDirectoryAtPath:self.directory error:nil];
    NSArray<NSString *> *logFileNames = [self filteredLogFileNames:fileNames];
    NSArray<NSString *> *logFilePaths = nil;
    if (logFileNames.count) { logFilePaths = [self.directory stringsByAppendingPaths:logFileNames]; }
    
    for (NSString *filePath in logFilePaths) {
        
        [self.logFilesInformation addObject:[PNLLogFileInformation informationForFileAtPath:filePath]];
    }
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    [self.logFilesInformation sortUsingDescriptors:@[descriptor]];
}


#pragma mark - Hanlders

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary<NSString *, NSNumber *> *)change context:(void *)context {
    
    NSUInteger previousFlagValue = change[NSKeyValueChangeOldKey].unsignedIntegerValue;
    NSUInteger currentFlagValue = change[NSKeyValueChangeNewKey].unsignedIntegerValue;
    
    // Check whether value really changed or not.
    if (previousFlagValue != currentFlagValue) {
        
        if (!currentFlagValue || [keyPath isEqualToString:NSStringFromSelector(@selector(logFilesDiskQuota))]) {
            
            [self deleteOldLogsIfRequired]; 
        }
        
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(enabled))]) {
            
            [self log:0 message:[NSString stringWithFormat:@"<Logger::%@> Logger %@.",
                                 self.identifier, (currentFlagValue ? @"enabled" : @"disabled")]];
        }
        
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(writeToFile))]) {
            
            [self log:0 message:[NSString stringWithFormat:@"<Logger::%@> File logger %@.",
                                 self.identifier, (currentFlagValue ? @"enabled" : @"disabled")]];
            if (currentFlagValue) {
                
                [self log:0 message:[NSString stringWithFormat:@"<Logger::%@> Log files stored in: %@.",
                                     self.identifier, self.directory]];
            }
        }
        
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(logFilesDiskQuota))]) {
            
            [self log:0 message:[NSString stringWithFormat:@"<Logger::%@> Disk quota changed to %lu bytes.",
                                 self.identifier, (unsigned long)currentFlagValue]];
        }
    }
}


#pragma mark - Misc

+ (NSMutableDictionary<NSString *, PNLLogger *> *)loggersCache {
    
    static NSMutableDictionary<NSString *, PNLLogger *> * _sharedLoggersCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ _sharedLoggersCache = [NSMutableDictionary new]; });
    
    return _sharedLoggersCache;
}

+ (NSString *)defaultLogsDirectoryPath {
    
    NSSearchPathDirectory searchPath = (TARGET_OS_IPHONE ? NSCachesDirectory : NSLibraryDirectory);
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(searchPath, NSUserDomainMask, YES);
    NSString *baseDirectory = (paths.count > 0 ? paths.firstObject : NSTemporaryDirectory());
    
    return [baseDirectory stringByAppendingPathComponent:@"Logs"];
}

- (NSString *)workingDirectoryPath:(NSString *)logsDirectoryPath {
    
    NSString *logsDirectory = logsDirectoryPath;
#if !TARGET_OS_IPHONE
    if ([[[self class] defaultLogsDirectoryPath] isEqualToString:logsDirectoryPath]) {
        
        logsDirectory = [logsDirectory stringByAppendingPathComponent:_applicationName];
    }
#endif // TARGET_OS_IPHONE
    logsDirectory = [logsDirectory stringByAppendingPathComponent:self.identifier];
    
    return logsDirectory;
}

- (void)retrieveEnvironmentInformation {
    
    _applicationName = ([[NSProcessInfo processInfo] processName]?: [[NSBundle mainBundle] bundleIdentifier]);
    if (!_applicationName) { _applicationName = @"PNLUnknownApplicationName"; }
    _applicationNameLength = [_applicationName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    _applicationCName = malloc(_applicationNameLength + 1);
    [_applicationName getCString:_applicationCName maxLength:(_applicationNameLength + 1) 
                        encoding:NSUTF8StringEncoding];
    
    _applicationProcessID = [NSString stringWithFormat:@"%i", (int)getpid()];
    _applicationProcessIDLength = [_applicationProcessID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    _applicationProcessCID = malloc(_applicationProcessIDLength + 1);
    [_applicationProcessID getCString:_applicationProcessCID maxLength:(_applicationProcessIDLength + 1) 
                             encoding:NSUTF8StringEncoding];
}

- (void)prepareDateFormatter {
    
    _calendarUnits = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour |
                      NSCalendarUnitMinute | NSCalendarUnitSecond);
    
    _dateFormatter = [NSDateFormatter new];
    _dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    _dateFormatter.dateFormat = @"yyyy'-'MM'-'dd' 'HH'-'mm'";
    _dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
}

- (NSString *)currentThreadID {
    
    NSString *tid = nil;
    if (USE_PTHREAD_THREADID_NP) {
        __uint64_t threadID;
        pthread_threadid_np(NULL, &threadID);
        tid = [NSString stringWithFormat:@"%llu", threadID];
    }
    else { tid = [NSString stringWithFormat:@"%x", pthread_mach_thread_np(pthread_self())]; }
    
    return tid;
}

- (NSUInteger)getTimestamp:(char *)timestamp fromDate:(NSDate *)date {
    
    NSDateComponents *components = [[NSCalendar autoupdatingCurrentCalendar] components:self.calendarUnits
                                                                               fromDate:date];
    NSTimeInterval seconds = [date timeIntervalSince1970];
    int milliseconds = (int)((seconds - floor(seconds)) * 1000);
    snprintf(timestamp, kPNLLogEntryTimestampLength, "%04ld-%02ld-%02ld %02ld:%02ld:%02ld:%03d", 
             (long)components.year, (long)components.month, (long)components.day, (long)components.hour,
             (long)components.minute, (long)components.second, milliseconds);
    
    return (kPNLLogEntryTimestampLength - 1);
}

- (void)startPropertiesModificationObservation {
    
    NSKeyValueObservingOptions options = (NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew);
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(enabled)) options:options context:nil];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(writeToFile)) options:options 
              context:nil];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(logFilesDiskQuota)) options:options 
              context:nil];
    
}

- (void)stopPropertiesModificationObservation {
    
    @try {
        
        [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(enabled))];
        [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(writeToFile))];
        [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(logFilesDiskQuota))];
    } @catch (NSException *exception) { /* Just cache expection in case if observer already removed. */ }
}

- (NSArray<NSString *> *)filteredLogFileNames:(NSArray<NSString *> *)names {
    
    NSString *pattern = [NSString stringWithFormat:@".+\\s\\d{4}-\\d{2}-\\d{2}\\s\\d{2}-\\d{2}(\\s\\d+)?\\.(%@)", 
                         self.logFileExtension];
    NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options
                                                                             error:nil];
    NSMutableArray<NSString *> *logFileNames = [NSMutableArray arrayWithCapacity:names.count];
    for (NSString *fileName in names) {
        
        NSRange matchRange = NSMakeRange(0, fileName.length);
        NSArray *matches = [regex matchesInString:fileName options:(NSMatchingOptions)0 range:matchRange];
        if (matches.count > 0) { [logFileNames addObject:fileName]; }
    }
    
    return logFileNames;
}

- (void)dealloc {
    
    [self stopPropertiesModificationObservation];
    [self rollCurrentLogFileOnMove:NO];
}

#pragma mark - 


@end
