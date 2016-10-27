/**
 @author Sergey Mamontov
 @since <#version#>
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNPresenceWhereNowAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceWhereNowAPICallBuilder


#pragma mark - Configuration

- (PNPresenceWhereNowAPICallBuilder *(^)(NSString *uuid))uuid {
    
    return ^PNPresenceWhereNowAPICallBuilder* (NSString *uuid) {
        
        [self setValue:uuid forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNWhereNowCompletionBlock block))performWithCompletion {
    
    return ^(PNWhereNowCompletionBlock block){ [super performWithBlock:block]; };
}

#pragma mark -


@end
