/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNLog.h"
#import "PNLogFileManager.h"
#import "PubNub+Core.h"


#pragma mark Static

/**
 @brief  Stores reference on shared logger helper instance.
 
 @since 4.0
 */
static PNLog *_sharedInstance = nil;


#pragma mark - Protected interface declaration

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
 @brief  Complete helper preparations.
 
 @since 4.0
 */
- (void)prepare;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNLog


#pragma mark - Initialization and configuration

+ (void)prepare {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [PNLog new];
        [_sharedInstance prepare];
    });
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

+ (void)dumpToFile:(BOOL)shouldDumpToFile {
    
    if (_sharedInstance.isFileLoggerActive != shouldDumpToFile) {
        
        if (!shouldDumpToFile) {
            
            DDLogInfo(@"<PubNub> File logger disabled");
            [DDLog removeLogger:_sharedInstance.fileLogger];
        }
        else {
            
            DDLogInfo(@"<PubNub> File logger enabnled");
            DDLogInfo(@"<PubNub> Log files stored in: %@",
                      [_sharedInstance.fileLogger.logFileManager logsDirectory]);
            [DDLog addLogger:_sharedInstance.fileLogger withLevel:(DDLogLevel)PNVerboseLogLevel];
        }
        _sharedInstance.fileLoggerActive = shouldDumpToFile;
    }
}

+ (BOOL)isDumpingToFile {
    
    return _sharedInstance.isFileLoggerActive;
}

- (void)prepare {
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Adding file logger for messages sent by PubNub client.
    self.fileLogger = [[DDFileLogger alloc] initWithLogFileManager:[PNLogFileManager new]];
    self.fileLogger.maximumFileSize = (5 * 1024 * 1024);
    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 5;
    self.fileLogger.logFileManager.logFilesDiskQuota = (50 * 1024 * 1024);
#if DEBUG
    [[self class] dumpToFile:YES];
#else
    [[self class] dumpToFile:NO];
#endif
}

#pragma mark -


@end
