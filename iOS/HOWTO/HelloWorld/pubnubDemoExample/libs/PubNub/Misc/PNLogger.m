//
//  PNLogger.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNLogger.h"
#import "NSDate+PNAdditions.h"
#import "PNHelper.h"
#ifdef DEBUG
    #include <sys/sysctl.h>
    #include <sys/types.h>
    #include <stdbool.h>
    #include <unistd.h>
    #include <assert.h>
#endif
#include <stdlib.h>


#pragma mark Static

static NSString * const kPNLoggerDumpFileName = @"pubnub-console-dump.txt";
static NSString * const kPNLoggerOldDumpFileName = @"pubnub-console-dump.1.txt";

/**
 Stores maximum in-memory log size before storing it into the file. As soon as in-memory storage will reach this limit it
 will be flushed on file system.
 
 @note Default in-memory storage size is 16Kb.
 */
static NSUInteger const kPNLoggerMaximumInMemoryLogSize = (16 * 1024);

/**
 Stores maximum file size which should be stored on file system. As soon as limit will be reached, beginning of the file
 will be truncated.
 
 @note Default file size is 10Mb
 */
static NSUInteger const kPNLoggerMaximumDumpFileSize = (10 * 1024 * 1024);

/**
 Timeout which is used by timer to configure timeouts after which logger should force console dump.
 */
static NSTimeInterval const kPNLoggerDumpForceTimeout = 10.0f;


#pragma mark - Types

/**
 Enum represent available logger configuration bit masks.
 */
typedef NS_OPTIONS(NSUInteger, PNLoggerConfiguration) {

    PNConsoleOutput = 1 << 11,
    PNConsoleDumpIntoFile = 1 << 12,
    PNHTTPResponseDumpIntoFile = 1 << 13
};


#pragma mark - Private interface declaration

@interface PNLogger ()


#pragma mark - Properties

/**
 Stores bit field which keep logger configuration information.
 */
@property (atomic, assign) NSUInteger configuration;

/**
 Stores reference on full file path to the current file which is used as console dump.
 */
@property (nonatomic, copy) NSString *dumpFilePath;

/**
 Stores reference on full file path to the old file which is has been used as console dump earlier.
 */
@property (nonatomic, copy) NSString *oldDumpFilePath;

/**
 Stores reference on full path to the folder which will be used for HTTP packet storage.
 */
@property (nonatomic, copy) NSString *httpPacketStoreFolderPath;

/**
 Stores reference on queue which will be used during console dump and log rotation process to reduce main thread load.
 */
@property (nonatomic, pn_dispatch_property_ownership) dispatch_queue_t dumpProcessingQueue;

/**
 Stores reference on queue which will be used during HTTP packet saving process to reduce main thread load.
 */
@property (nonatomic, pn_dispatch_property_ownership) dispatch_queue_t httpProcessingQueue;

/**
 Stores reference on channel which is used to perform I/O operations when writting file in more efficient way.
 */
@property (nonatomic, pn_dispatch_property_ownership) dispatch_io_t consoleDumpStoringChannel;

/**
 Stores reference on data storage which is used to write into the file using GCD i/O.
 */
@property (nonatomic, strong) NSMutableData *consoleDump;

/**
 Stores reference on timer which should force dump process in case if buffer size is not enough and last dump update
 passed allowed delay.
 */
@property (nonatomic, strong) NSTimer *consoleDumpTimer;

/**
 Stores maximum dump file size after which it should be truncated or log rotation should be performed.
 */
@property (nonatomic, assign) NSUInteger maximumDumpFileSize;


#pragma mark - Class methods

/**
 Compose singleton instance which further will store configuration and handle all logging events.
 */
+ (PNLogger *)sharedInstance;


#pragma mark - Instance methods

/**
 Perform logger default configuration based on available macros specified in header file.
 */
- (void)applyDefaultConfiguration;

/**
 Prepare async processing "tools".
 */
- (void)prepareForAsynchronousFileProcessing;

/**
 Manage I/O channel which is responsible for console output dumping.
 */
- (void)openConsoleDumpChannel;
- (void)closeConsoleDumpChannel;

/**
 Check whether logger has been enabled for specified level or not.

 @param level
 Level against which check should be performed.

 @return \c YES if logging has been enabled for provided level or not.
 */
- (BOOL)isLoggerEnabledFor:(PNLogLevel)level;

/**
 Compose correct log prefix based on specified level (warn, info, error, delegate, reaschability).

 @param level
 Level against which check should be performed.

 @return Composed \b NSString instance which can be used for addendum in log output.
 */
- (NSString *)logEntryPrefixForLevel:(PNLogLevel)level;

/**
 Store currently accumulated console output into the file (if required.
 
 @param output
 If specified, this message will be placed into the dump if required, in case if this entry is empty, it will force data
 storage.
 */
- (void)dumpConsoleOutput:(NSString *)output;

/**
 Perform log rotation if required (depending on whether current log file reached limit or not).
 */
- (void)rotateDumpFiles;


#pragma mark - Handler methods

- (void)handleConsoleDumpTimer:(NSTimer *)timer;

#pragma mark -


@end


#pragma mark - Public interface declaration

@implementation PNLogger


#pragma mark 

/**
 Function allow to check whether debugger connected to the running process or not.
 
 @return \c false if application is running w/o debugger.
 */
static bool IsDebuggerAttached(void) {
    
    bool isDebuggerAttached = false;
#ifdef DEBUG
    struct kinfo_proc info;
    info.kp_proc.p_flag = 0;
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
    size_t size = sizeof(info);
    int junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);
    isDebuggerAttached = ((info.kp_proc.p_flag & P_TRACED) != 0);
#endif
    
    return isDebuggerAttached;
}

#pragma mark - Class methods

+ (PNLogger *)sharedInstance {

    static PNLogger *_sharedInstance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{

        _sharedInstance = [self new];
    });


    return _sharedInstance;
}

+ (void)prepare {

    // Retrieve path to the 'Documents' folder
    NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    [self sharedInstance].dumpFilePath = [documentsFolder stringByAppendingPathComponent:kPNLoggerDumpFileName];
    [self sharedInstance].oldDumpFilePath = [documentsFolder stringByAppendingPathComponent:kPNLoggerOldDumpFileName];
    [self sharedInstance].httpPacketStoreFolderPath = [documentsFolder stringByAppendingPathComponent:@"http-response-dump"];
    [self sharedInstance].maximumDumpFileSize = kPNLoggerMaximumDumpFileSize;

    [[self sharedInstance] prepareForAsynchronousFileProcessing];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[self sharedInstance].httpPacketStoreFolderPath isDirectory:NULL]) {

        [fileManager createDirectoryAtPath:[self sharedInstance].httpPacketStoreFolderPath withIntermediateDirectories:YES
                                attributes:nil error:NULL];
    }

    [[self sharedInstance] applyDefaultConfiguration];
    [[self sharedInstance] rotateDumpFiles];
}

+ (void)logFrom:(id)sender forLevel:(PNLogLevel)level message:(NSString *(^)(void))messageBlock {

    // Ensure that user allowed message output for provided logging level.
    if ([[self sharedInstance] isLoggerEnabledFor:level] && messageBlock) {

        // Checking whether logger allowed to log or dump console output.
        if ([self isLoggerEnabled] || [self isDumpingToFile]) {

            __block __unsafe_unretained id weakSender = sender;
            NSString *message = [NSString stringWithFormat:@"%@ (%p) %@%@", NSStringFromClass([weakSender class]),
                                         weakSender, [[self sharedInstance] logEntryPrefixForLevel:level], messageBlock()];

            // Checking whether logger should print out log entries in console depending on user configuration
            // and on whether app is running through Xcode debugger connected to it or not.
            if ([self isLoggerEnabled] && IsDebuggerAttached()) {

                NSLog(@"%@", message);
            }
            
            if ([self isDumpingToFile]) {
                
                [[self sharedInstance] dumpConsoleOutput:message];
            }
        }
    }
}

+ (void)logGeneralMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock {

    [self logFrom:sender forLevel:PNLogGeneralLevel message:messageBlock];
}

+ (void)logDelegateMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock {

    [self logFrom:sender forLevel:PNLogDelegateLevel message:messageBlock];
}

+ (void)logReachabilityMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock {

    [self logFrom:sender forLevel:PNLogReachabilityLevel message:messageBlock];
}

+ (void)logDeserializerInfoMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock {

    [self logFrom:sender forLevel:PNLogDeserializerInfoLevel message:messageBlock];
}

+ (void)logDeserializerErrorMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock {

    [self logFrom:sender forLevel:PNLogDeserializerErrorLevel message:messageBlock];
}

+ (void)logConnectionErrorMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock {

    [self logFrom:sender forLevel:PNLogConnectionLayerErrorLevel message:messageBlock];
}

+ (void)logConnectionInfoMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock {

    [self logFrom:sender forLevel:PNLogConnectionLayerInfoLevel message:messageBlock];
}

+ (void)logCommunicationChannelErrorMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock {

    [self logFrom:sender forLevel:PNLogCommunicationChannelLayerErrorLevel message:messageBlock];
}

+ (void)logCommunicationChannelWarnMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock {

    [self logFrom:sender forLevel:PNLogCommunicationChannelLayerWarnLevel message:messageBlock];
}

+ (void)logCommunicationChannelInfoMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock {

    [self logFrom:sender forLevel:PNLogCommunicationChannelLayerInfoLevel message:messageBlock];
}

+ (void)storeHTTPPacketData:(NSData *(^)(void))httpPacketBlock {

    if ([self isDumpingHTTPResponse] && httpPacketBlock) {

        NSString *storePath = [[self sharedInstance].httpPacketStoreFolderPath stringByAppendingFormat:@"/response-%@.dmp",
                               [[NSDate date] consoleOutputTimestamp]];

        NSData *packetData = httpPacketBlock();
        dispatch_async([self sharedInstance].httpProcessingQueue, ^{

            if(![packetData writeToFile:storePath atomically:YES]){

                NSLog(@"CAN'T SAVE DUMP: %@", packetData);
            }
        });
    }
}


#pragma mark - General logger state manipulation

+ (void)loggerEnabled:(BOOL)isLoggerEnabled {

    unsigned long configuration = [self sharedInstance].configuration;
    (isLoggerEnabled ? [PNBitwiseHelper addTo:&configuration bit:PNConsoleOutput] :
                       [PNBitwiseHelper removeFrom:&configuration bit:PNConsoleOutput]);
    [self sharedInstance].configuration = configuration;
}

+ (BOOL)isLoggerEnabled {

    return [PNBitwiseHelper is:[self sharedInstance].configuration containsBit:PNConsoleOutput];
}

+ (void)dumpToFile:(BOOL)shouldDumpToFile {

    BOOL isDumpingIntoFile = [self isDumpingToFile];
    unsigned long configuration = [self sharedInstance].configuration;
    (shouldDumpToFile ? [PNBitwiseHelper addTo:&configuration bit:PNConsoleDumpIntoFile] :
                        [PNBitwiseHelper removeFrom:&configuration bit:PNConsoleDumpIntoFile]);
    [self sharedInstance].configuration = configuration;

    if (isDumpingIntoFile != [self isDumpingToFile] && [self isDumpingToFile]) {

        [[self sharedInstance] rotateDumpFiles];
        if ([self isDumpingToFile] && ![self sharedInstance].consoleDumpTimer) {
            
            [self sharedInstance].consoleDumpTimer = [NSTimer timerWithTimeInterval:kPNLoggerDumpForceTimeout
                                                                             target:[self sharedInstance]
                                                                           selector:@selector(handleConsoleDumpTimer:)
                                                                           userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:[self sharedInstance].consoleDumpTimer forMode:NSRunLoopCommonModes];
        } else if (![self isDumpingToFile] && [[self sharedInstance].consoleDumpTimer isValid]) {
            
            [[self sharedInstance].consoleDumpTimer invalidate];
            [self sharedInstance].consoleDumpTimer = nil;
        }
    }
}

+ (BOOL)isDumpingToFile {

    return [PNBitwiseHelper is:[self sharedInstance].configuration containsBit:PNConsoleDumpIntoFile];
}

+ (NSString *)dumpFilePath {

    return [self sharedInstance].dumpFilePath;
}


#pragma mark - File dump manipulation methods

+ (void)setMaximumDumpFileSize:(NSUInteger)fileSize {

    [self sharedInstance].maximumDumpFileSize = fileSize;
}


#pragma mark - HTTP response dump methods

+ (void)dumpHTTPResponseToFile:(BOOL)shouldDumpHTTPResponseToFile {

    unsigned long configuration = [self sharedInstance].configuration;
    (shouldDumpHTTPResponseToFile ? [PNBitwiseHelper addTo:&configuration bit:PNHTTPResponseDumpIntoFile] :
                                    [PNBitwiseHelper removeFrom:&configuration bit:PNHTTPResponseDumpIntoFile]);
    [self sharedInstance].configuration = configuration;
}

+ (BOOL)isDumpingHTTPResponse {

    return [PNBitwiseHelper is:[self sharedInstance].configuration containsBit:PNHTTPResponseDumpIntoFile];
}


#pragma mark - Levels manipulation methods

+ (void)enableFor:(PNLogLevel)level {

    unsigned long configuration = [self sharedInstance].configuration;
    [PNBitwiseHelper addTo:&configuration bit:level];
    [self sharedInstance].configuration = configuration;
}

+ (void)disableFor:(PNLogLevel)level {

    unsigned long configuration = [self sharedInstance].configuration;
    [PNBitwiseHelper removeFrom:&configuration bit:level];
    [self sharedInstance].configuration = configuration;
}


#pragma mark - Instance methods

- (void)applyDefaultConfiguration {

    [[self class] loggerEnabled:(PNLOG_LOGGING_ENABLED == 1)];
    [[self class] dumpToFile:(PNLOG_STORE_LOG_TO_FILE == 1)];
    [[self class] dumpHTTPResponseToFile:(PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_STORING_ENABLED == 1)];

    PNLogLevel level = 0;
    #if PNLOG_GENERAL_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogGeneralLevel];
    #endif

    #if PNLOG_DELEGATE_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogDelegateLevel];
    #endif

    #if PNLOG_REACHABILITY_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogReachabilityLevel];
    #endif

    #if PNLOG_DESERIALIZER_INFO_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogDeserializerInfoLevel];
    #endif

    #if PNLOG_DESERIALIZER_ERROR_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogDeserializerErrorLevel];
    #endif

    #if PNLOG_COMMUNICATION_CHANNEL_LAYER_ERROR_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogCommunicationChannelLayerErrorLevel];
    #endif

    #if PNLOG_COMMUNICATION_CHANNEL_LAYER_INFO_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogCommunicationChannelLayerInfoLevel];
    #endif

    #if PNLOG_COMMUNICATION_CHANNEL_LAYER_WARN_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogCommunicationChannelLayerWarnLevel];
    #endif

    #if PNLOG_CONNECTION_LAYER_ERROR_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogConnectionLayerErrorLevel];
    #endif

    #if PNLOG_CONNECTION_LAYER_INFO_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogConnectionLayerInfoLevel];
    #endif

    #if PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogConnectionLayerHTTPLoggingLevel];
    #endif
    
    [[self class] enableFor:level];
}

- (void)prepareForAsynchronousFileProcessing {

    self.consoleDump = [NSMutableData data];
    dispatch_queue_t dumpProcessingQueue = dispatch_queue_create("com.pubnub.logger-dump-processing", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(dumpProcessingQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    [PNDispatchHelper retain:dumpProcessingQueue];
    self.dumpProcessingQueue = dumpProcessingQueue;
    [self openConsoleDumpChannel];
    
    dispatch_queue_t httpProcessingQueue = dispatch_queue_create("com.pubnub.logger-http-processing", DISPATCH_QUEUE_SERIAL);
    [PNDispatchHelper retain:httpProcessingQueue];
    self.httpProcessingQueue = httpProcessingQueue;
}

- (void)openConsoleDumpChannel {
    
    dispatch_async(self.dumpProcessingQueue, ^{
        
        dispatch_io_t consoleDumpStoringChannel = dispatch_io_create_with_path(DISPATCH_IO_STREAM, [self.dumpFilePath UTF8String],
                                                                               (O_RDWR|O_CREAT|O_NONBLOCK|O_APPEND), (S_IRWXU|S_IRWXG|S_IRWXO),
                                                                               self.dumpProcessingQueue, ^(int error) {
               
               if (error != 0) {
                   
                   [self closeConsoleDumpChannel];
               }
           });
        [PNDispatchHelper retain:consoleDumpStoringChannel];
        self.consoleDumpStoringChannel = consoleDumpStoringChannel;
    });
}

- (void)closeConsoleDumpChannel {
    
    if (self.consoleDumpStoringChannel) {
        
        dispatch_async(self.dumpProcessingQueue, ^{
            
            dispatch_io_close(self.consoleDumpStoringChannel, 0);
            [PNDispatchHelper release:self.consoleDumpStoringChannel];
            self.consoleDumpStoringChannel = NULL;
        });
    }
}

- (BOOL)isLoggerEnabledFor:(PNLogLevel)level {

    return [PNBitwiseHelper is:self.configuration containsBit:level];
}

- (NSString *)logEntryPrefixForLevel:(PNLogLevel)level {

    NSString *prefix = @"";
    PNLogLevel delegateMask = PNLogDelegateLevel;
    PNLogLevel reachabilityMask = PNLogReachabilityLevel;
    PNLogLevel infoMask = (PNLogDeserializerInfoLevel|PNLogConnectionLayerInfoLevel|
                           PNLogConnectionLayerHTTPLoggingLevel|PNLogCommunicationChannelLayerInfoLevel);
    PNLogLevel errorMask = (PNLogDeserializerErrorLevel|PNLogConnectionLayerErrorLevel|
                            PNLogCommunicationChannelLayerErrorLevel);
    PNLogLevel warnMask = (PNLogDeserializerErrorLevel|PNLogConnectionLayerErrorLevel|
                           PNLogCommunicationChannelLayerErrorLevel);
    if ([PNBitwiseHelper is:level containsBit:delegateMask]) {

        prefix = @"{DELEGATE} ";
    }
    else if ([PNBitwiseHelper is:level containsBit:reachabilityMask]) {

        prefix = @"{REACHABILITY} ";
    }
    else if ([PNBitwiseHelper is:level containsBit:infoMask]) {

        prefix = @"{INFO} ";
    }
    else if ([PNBitwiseHelper is:level containsBit:errorMask]) {

        prefix = @"{ERROR} ";
    }
    else if ([PNBitwiseHelper is:level containsBit:warnMask]) {

        prefix = @"{WARN} ";
    }


    return prefix;
}

- (void)dumpConsoleOutput:(NSString *)output {
    
    dispatch_async(self.dumpProcessingQueue, ^{
        
        if (output) {
            
            [self.consoleDump appendData:[[[[NSDate date] consoleOutputTimestamp] stringByAppendingFormat:@"> %@\n", output]
                                          dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        
        if (([self.consoleDump length] >= kPNLoggerMaximumInMemoryLogSize || !output) && [self.consoleDump length] > 0) {
            
            if (self.consoleDumpStoringChannel) {
                
                dispatch_data_t data = dispatch_data_create([self.consoleDump bytes], [self.consoleDump length],
                                                            self.dumpProcessingQueue, NULL);
                [self.consoleDump setLength:0];
                dispatch_io_write(self.consoleDumpStoringChannel, 0, data, self.dumpProcessingQueue,
                                  ^(bool done, dispatch_data_t data, int error) {
                                      
                                      if (!done && error != 0) {
                                          
                                          NSLog(@"PNLog: Can't write into file (%@)", [self dumpFilePath]);
                                          [self closeConsoleDumpChannel];
                                      }
                                  });
            }
            else {
                
                FILE *consoleDumpFilePointer = fopen([[self dumpFilePath] UTF8String], "a+");
                if (consoleDumpFilePointer == NULL) {
                    
                    NSLog(@"PNLog: Can't open console dump file (%@)", [self dumpFilePath]);
                }
                else {
                    
                    fwrite([self.consoleDump bytes], [self.consoleDump length], 1, consoleDumpFilePointer);
                    fclose(consoleDumpFilePointer);
                    [self.consoleDump setLength:0];
                }
            }
        }
    });
}

- (void)rotateDumpFiles {

    if ([[self class] isDumpingToFile]) {
        
        [self dumpConsoleOutput:nil];
        [self closeConsoleDumpChannel];
        dispatch_async(self.dumpProcessingQueue, ^{
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:self.dumpFilePath]) {
                
                NSError *attributesFetchError = nil;
                NSDictionary *fileInformation = [fileManager attributesOfItemAtPath:self.dumpFilePath error:&attributesFetchError];
                if (attributesFetchError == nil) {
                    
                    unsigned long long consoleDumpFileSize = [(NSNumber *)[fileInformation valueForKey:NSFileSize] unsignedLongLongValue];
                    
                    NSLog(@"PNLog: Current console dump file size is %lld bytes (maximum allowed: %lu bytes)",
                          consoleDumpFileSize, (unsigned long)self.maximumDumpFileSize);
                    
                    if (consoleDumpFileSize > self.maximumDumpFileSize) {
                        
                        NSError *oldLogDeleteError = nil;
                        if ([fileManager fileExistsAtPath:self.oldDumpFilePath]) {
                            
                            [fileManager removeItemAtPath:self.oldDumpFilePath error:&oldLogDeleteError];
                        }
                        
                        if (oldLogDeleteError == nil) {
                            
                            NSError *fileCopyError;
                            [fileManager copyItemAtPath:self.dumpFilePath toPath:self.oldDumpFilePath error:&fileCopyError];
                            
                            if (fileCopyError == nil) {
                                
                                if ([fileManager fileExistsAtPath:self.dumpFilePath]) {
                                    
                                    NSError *currentLogDeleteError = nil;
                                    [fileManager removeItemAtPath:self.dumpFilePath error:&currentLogDeleteError];
                                    
                                    if (currentLogDeleteError != nil) {
                                        
                                        NSLog(@"PNLog: Can't remove current console dump log (%@) because of error: %@",
                                              self.dumpFilePath, currentLogDeleteError);
                                    }
                                }
                            }
                            else {
                                
                                NSLog(@"PNLog: Can't copy current log (%@) to new location (%@) because of error: %@",
                                      self.dumpFilePath, self.oldDumpFilePath, fileCopyError);
                            }
                        }
                        else {
                            
                            NSLog(@"PNLog: Can't remove old console dump log (%@) because of error: %@",
                                  self.oldDumpFilePath, oldLogDeleteError);
                        }
                    }
                }
                [self openConsoleDumpChannel];
            }
        });
    }
}


#pragma mark - Handler methods

- (void)handleConsoleDumpTimer:(NSTimer *)timer {
    
    [self dumpConsoleOutput:nil];
}


#pragma mark - Misc methods

- (void)dealloc {

    if (_consoleDumpStoringChannel) {
        
        dispatch_io_close(_consoleDumpStoringChannel, 0);
    }
    [PNDispatchHelper release:_consoleDumpStoringChannel];
    _consoleDumpStoringChannel = NULL;
    _consoleDump = nil;
    [PNDispatchHelper release:_dumpProcessingQueue];
    _dumpProcessingQueue = NULL;
    [PNDispatchHelper release:_httpProcessingQueue];
    _httpProcessingQueue = NULL;
}

#pragma mark -


@end
