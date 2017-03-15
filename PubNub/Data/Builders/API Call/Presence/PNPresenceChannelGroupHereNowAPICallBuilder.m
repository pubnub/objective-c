/**
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNPresenceChannelGroupHereNowAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceChannelGroupHereNowAPICallBuilder


#pragma mark - Configuration

- (PNPresenceChannelGroupHereNowAPICallBuilder *(^)(PNHereNowVerbosityLevel verbosity))verbosity {
    
    return ^PNPresenceChannelGroupHereNowAPICallBuilder* (PNHereNowVerbosityLevel verbosity) {
        
        [self setValue:@(verbosity) forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNChannelGroupHereNowCompletionBlock block))performWithCompletion {
    
    return ^(PNChannelGroupHereNowCompletionBlock block){ [super performWithBlock:block]; };
}

#pragma mark -


@end
