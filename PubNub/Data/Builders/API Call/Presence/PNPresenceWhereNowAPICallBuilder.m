/**
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNPresenceWhereNowAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceWhereNowAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNPresenceWhereNowAPICallBuilder * (^)(NSString *uuid))uuid {
    
    return ^PNPresenceWhereNowAPICallBuilder * (NSString *uuid) {
        [self setValue:uuid forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNWhereNowCompletionBlock block))performWithCompletion {
    
    return ^(PNWhereNowCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
