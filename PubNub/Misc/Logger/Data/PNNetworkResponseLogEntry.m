#import "PNNetworkResponseLogEntry+Private.h"
#import "PNLogEntry+Private.h"


#pragma mark Interface implementation

@implementation PNNetworkResponseLogEntry


#pragma mark - Initialization and Configuration

+ (instancetype)entryWithMessage:(id<PNTransportResponse>)message {
    return [[self alloc] initWithMessageType:PNNetworkResponseLogMessageType message:message];
}

#pragma mark -


@end
