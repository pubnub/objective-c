#import "PNStringLogEntry.h"
#import "PNLogEntry+Private.h"


#pragma mark Interface implementation

@implementation PNStringLogEntry


#pragma mark - Initialization and Configuration

+ (instancetype)entryWithMessage:(NSString *)message {
    return [[self alloc] initWithMessageType:PNTextLogMessageType message:message];
}

#pragma mark -


@end
