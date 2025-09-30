#import "PNStringLogEntry+Private.h"
#import "PNLogEntry+Private.h"


#pragma mark Interface implementation

@implementation PNStringLogEntry


#pragma mark - Initialization and Configuration

+ (instancetype)entryWithMessage:(NSString *)message {
    return [self entryWithMessage:message operation:PNUnknownLogMessageOperation];
}

+ (instancetype)entryWithMessage:(NSString *)message operation:(PNLogMessageOperation)operation {
    PNStringLogEntry *entry = [[self alloc] initWithMessageType:PNTextLogMessageType message:message];
    entry.operation = operation;
    
    return entry;
}

#pragma mark -


@end
