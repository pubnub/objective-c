/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNLogFileManager.h"


#pragma mark Interface implementation

@implementation PNLogFileManager

- (instancetype)init {
    
    // Configure file manager with default storage in application's Documents folder.
    NSArray<NSString *> *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = documents.lastObject;
#if __MAC_OS_X_VERSION_MIN_REQUIRED
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if (NSClassFromString(@"XCTestExpectation")) { bundleIdentifier = @"com.pubnub.objc-tests"; }
    documents = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    documentsPath = [[documents.lastObject stringByAppendingPathComponent:bundleIdentifier]
                     stringByAppendingPathComponent:@"logs"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentsPath isDirectory:NULL]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsPath withIntermediateDirectories:YES
                                                   attributes:nil error:nil];
    }
#endif   
    
    return [self initWithLogsDirectory:documentsPath];
}

- (NSString *)newLogFileName {
    
    return [[super newLogFileName] stringByReplacingOccurrencesOfString:@".log" withString:@".txt"];
}

- (BOOL)isLogFile:(NSString *)fileName {
    
    NSString *originalName = [fileName stringByReplacingOccurrencesOfString:@".txt" withString:@".log"];
    
    return [super isLogFile:originalName];
}

#pragma mark -


@end
