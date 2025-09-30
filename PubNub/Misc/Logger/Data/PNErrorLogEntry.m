#import "PNErrorLogEntry+Private.h"
#import "PNLogEntry+Private.h"


#pragma mark Interface implementation

@implementation PNErrorLogEntry


#pragma mark - Initialization and Configuration

+ (instancetype)entryWithMessage:(NSError *)message {
    return [self entryWithMessage:message operation:PNUnknownLogMessageOperation];
}

+ (instancetype)entryWithMessage:(NSError *)message operation:(PNLogMessageOperation)operation {
    PNErrorLogEntry *entry = [[self alloc] initWithMessageType:PNErrorLogMessageType message:message];
    entry.operation = operation;
    
    return entry;
}

#pragma mark -


@end
