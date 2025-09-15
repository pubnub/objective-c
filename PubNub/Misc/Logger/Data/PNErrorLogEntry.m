#import "PNErrorLogEntry.h"
#import "PNLogEntry+Private.h"


#pragma mark Interface implementation

@implementation PNErrorLogEntry


#pragma mark - Initialization and Configuration

+ (instancetype)entryWithMessage:(NSError *)message {
    return [[self alloc] initWithMessageType:PNErrorLogMessageType message:message];
}

#pragma mark -


@end
