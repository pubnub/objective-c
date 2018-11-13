/**
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNPresenceChannelHereNowAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceChannelHereNowAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNPresenceChannelHereNowAPICallBuilder * (^)(PNHereNowVerbosityLevel verbosity))verbosity {
    
    return ^PNPresenceChannelHereNowAPICallBuilder * (PNHereNowVerbosityLevel verbosity) {
        [self setValue:@(verbosity) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNHereNowCompletionBlock block))performWithCompletion {
    
    return ^(PNHereNowCompletionBlock block) {
        [super performWithBlock:block];
    };
}


#pragma mark -


@end
