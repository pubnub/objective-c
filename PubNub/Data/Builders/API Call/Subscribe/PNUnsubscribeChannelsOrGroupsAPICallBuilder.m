/**
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNUnsubscribeChannelsOrGroupsAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNUnsubscribeChannelsOrGroupsAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNUnsubscribeChannelsOrGroupsAPICallBuilder * (^)(BOOL withPresence))withPresence {
    
    return ^PNUnsubscribeChannelsOrGroupsAPICallBuilder * (BOOL withPresence) {
        [self setValue:@(withPresence) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

#pragma mark - Execution

- (void(^)(void))perform {
    
    return ^{
        [super performWithBlock:nil];
    };
}

#pragma mark - 


@end
