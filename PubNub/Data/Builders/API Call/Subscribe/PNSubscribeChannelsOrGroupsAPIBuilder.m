/**
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNSubscribeChannelsOrGroupsAPIBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNSubscribeChannelsOrGroupsAPIBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNSubscribeChannelsOrGroupsAPIBuilder * (^)(BOOL withPresence))withPresence {
    
    return ^PNSubscribeChannelsOrGroupsAPIBuilder * (BOOL withPresence) {
        [self setValue:@(withPresence) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNSubscribeChannelsOrGroupsAPIBuilder * (^)(NSNumber *withTimetoken))withTimetoken {
    
    return ^PNSubscribeChannelsOrGroupsAPIBuilder * (NSNumber *withTimetoken) {
        [self setValue:withTimetoken forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNSubscribeChannelsOrGroupsAPIBuilder * (^)(NSDictionary *state))state {
    
    return ^PNSubscribeChannelsOrGroupsAPIBuilder * (NSDictionary *state) {
        [self setValue:state forParameter:NSStringFromSelector(_cmd)];
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
