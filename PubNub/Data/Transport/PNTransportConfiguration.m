#import "PNTransportConfiguration+Private.h"


#pragma mark Interface implementation

@implementation PNTransportConfiguration


#pragma mark - Copying implementation

- (id)copyWithZone:(NSZone *)zone {
    PNTransportConfiguration *configuration = [[PNTransportConfiguration allocWithZone:zone] init];
    configuration.retryConfiguration = [self.retryConfiguration copy];
    configuration.maximumConnections = self.maximumConnections;

#ifndef PUBNUB_DISABLE_LOGGER
    configuration.logger = self.logger;
#endif // PUBNUB_DISABLE_LOGGER
    
    return configuration;
}

#pragma mark -


@end
