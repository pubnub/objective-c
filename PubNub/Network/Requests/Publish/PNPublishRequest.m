/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNBasePublishRequest+Private.h"
#import "PNPublishRequest.h"


#pragma mark - Interface implementation

@implementation PNPublishRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNPublishOperation;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithChannel:(NSString *)channel {
    return [[self alloc] initWithChannel:channel];
}

#pragma mark -


@end
