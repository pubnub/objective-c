#import "PNNetworkRequestLogEntry+Private.h"
#import "PNLogEntry+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Network request log entry representation object private extension.
@interface PNNetworkRequestLogEntry ()


#pragma mark - Properties

/// Whether the request has been canceled or not.
@property(assign, atomic, getter = isCanceled) BOOL canceled;

/// Whether the request processing failed or not.
@property(assign, atomic, getter = isFailed) BOOL failed;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNNetworkRequestLogEntry


#pragma mark - Initialization and Configuration

+ (instancetype)entryWithMessage:(PNTransportRequest *)message details:(NSString *)details {
    return [self entryWithMessage:message details:details canceled:NO failed:NO];
}

+ (instancetype)entryWithMessage:(PNTransportRequest *)message
                         details:(NSString *)details
                        canceled:(BOOL)canceled
                          failed:(BOOL)failed {
    PNNetworkRequestLogEntry *entry = [[self alloc] initWithMessageType:PNNetworkRequestLogMessageType message:message];
    entry.canceled = canceled;
    entry.details = details;
    entry.failed = failed;
    
    return entry;
}

#pragma mark -


@end
