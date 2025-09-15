#import "PNTransportConfiguration+Private.h"
#import "PNRequestRetryConfiguration+Private.h"


#pragma mark Interface implementation

@implementation PNTransportConfiguration


#pragma mark - Copying implementation

- (id)copyWithZone:(NSZone *)zone {
    PNTransportConfiguration *configuration = [[PNTransportConfiguration allocWithZone:zone] init];
    configuration.retryConfiguration = [self.retryConfiguration copy];
    configuration.maximumConnections = self.maximumConnections;
    configuration.logger = self.logger;
    
    return configuration;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"maximumConnections": @(self.maximumConnections)
    }];
    if (self.retryConfiguration) dictionary[@"retryConfiguration"] = [self.retryConfiguration dictionaryRepresentation];
    
    return dictionary;
}

#pragma mark -


@end
