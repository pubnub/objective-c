/**
 @author Sergey Mamontov
 @since <#version#>
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNUnsubscribeChannelsOrGroupsAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNUnsubscribeChannelsOrGroupsAPICallBuilder


#pragma mark - Configuration

- (PNUnsubscribeChannelsOrGroupsAPICallBuilder *(^)(BOOL withPresence))withPresence {
    
    return ^PNUnsubscribeChannelsOrGroupsAPICallBuilder* (BOOL withPresence) {
        
        [self setValue:@(withPresence) forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

#pragma mark - Execution

- (void(^)(void))perform {
    
    return ^{ [super performWithBlock:nil]; };
}

#pragma mark - 


@end
