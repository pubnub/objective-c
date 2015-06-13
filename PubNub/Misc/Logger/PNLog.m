/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNLog.h"
#import "PNLogFileManager.h"
#import "PubNub+Core.h"


#pragma mark Protected interface declaration

@interface PNLog ()

/**
 @brief  Stores whether file logging enabled at this moment or not.
 
 @since 4.0
 */
@property (nonatomic, assign, getter = isFileLoggerActive) BOOL fileLoggerActive;

/**
 @brief  Stores reference on file logger which can be registered in case if console output should
         be saved.
 
 @since 4.0
 */
@property (nonatomic, strong) DDFileLogger *fileLogger;


#pragma mark - Initialization and configuration

/**
 @brief  Retrieve reference on singleton logger instance.
 
 @return Configured and ready to use logger manager.
 
 @since 4.0
 */
+ (PNLog *)sharedInstance;

/**
 @brief  Complete helper preparations.
 
 @since 4.0
 */
- (void)prepare;

- (void)dumpToFile:(BOOL)shouldDumpToFile;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNLog


#pragma mark - Initialization and configuration

+ (PNLog *)sharedInstance {
    
    static PNLog *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [PNLog new];
        [_sharedInstance prepare];
    });
    
    return _sharedInstance;
}

- (void)prepare {
    
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:PNVerboseLogLevel];
    
    // Adding file logger for messages sent by PubNub client.
    self.fileLogger = [[DDFileLogger alloc] initWithLogFileManager:[PNLogFileManager new]];
    self.fileLogger.maximumFileSize = (5 * 1024 * 1024);
    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 5;
    self.fileLogger.logFileManager.logFilesDiskQuota = (50 * 1024 * 1024);
}

+ (void)enabled:(BOOL)isLoggingEnabled {
    
    if (isLoggingEnabled) {
        
        [self setLogLevel:PNVerboseLogLevel];
    }
    else {
        
        [self setLogLevel:PNSilentLogLevel];
    }
}

+ (void)enableLogLevel:(PNLogLevel)logLevel {
    
    [self setLogLevel:([DDLog levelForClass:[PubNub class]] | logLevel)];
}

+ (void)disableLogLevel:(PNLogLevel)logLevel {
    
    [self setLogLevel:([DDLog levelForClass:[PubNub class]] & ~logLevel)];
}

+ (void)setLogLevel:(PNLogLevel)logLevel {
    
    // Check whether all log levels should be disabled.
    if (logLevel & PNSilentLogLevel) {
        
        logLevel = PNSilentLogLevel;
    }
    
    [DDLog setLevel:(DDLogLevel)logLevel forClass:[PubNub class]];
}


#pragma mark - File logging

+ (void)setMaximumLogFileSize:(NSUInteger)size {
    
    [self sharedInstance].fileLogger.maximumFileSize = size;
}

+ (void)setMaximumNumberOfLogFiles:(NSUInteger)count {
    
    [self sharedInstance].fileLogger.logFileManager.maximumNumberOfLogFiles = count;
}

+ (void)dumpToFile:(BOOL)shouldDumpToFile {
    
    [[self sharedInstance] dumpToFile:shouldDumpToFile];
}

- (void)dumpToFile:(BOOL)shouldDumpToFile {
    
    if (self.isFileLoggerActive != shouldDumpToFile) {
        
        if (!shouldDumpToFile) {
            
            DDLogInfo(@"<PubNub> File logger disabled");
            [DDLog removeLogger:self.fileLogger];
        }
        else {
            
            DDLogInfo(@"<PubNub> File logger enabnled");
            DDLogInfo(@"<PubNub> Log files stored in: %@",
                      [self.fileLogger.logFileManager logsDirectory]);
            [DDLog addLogger:self.fileLogger withLevel:(DDLogLevel)PNVerboseLogLevel];
        }
        self.fileLoggerActive = shouldDumpToFile;
    }
}

+ (BOOL)isDumpingToFile {
    
    return [self sharedInstance].isFileLoggerActive;
}

#pragma mark -


@end
