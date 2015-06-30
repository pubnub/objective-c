/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNLogFileManager.h"


#pragma mark Interface implementation

@implementation PNLogFileManager

- (instancetype)init {
    
    // Configure file manager with default storage in application's Documents folder.
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return [self initWithLogsDirectory:[documents lastObject]];
}

- (NSString *)newLogFileName {
    
    return [[super newLogFileName] stringByReplacingOccurrencesOfString:@".log"
                                                             withString:@".txt"];
}

- (BOOL)isLogFile:(NSString *)fileName {
    
    NSString *originalName = [fileName stringByReplacingOccurrencesOfString:@".txt"
                                                                 withString:@".log"];
    
    return [super isLogFile:originalName];
}

#pragma mark -


@end
