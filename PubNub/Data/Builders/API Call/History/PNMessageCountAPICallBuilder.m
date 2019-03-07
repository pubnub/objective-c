/**
 * @since 4.8.4
 *
 * @author Serhii Mamontov
 * @version 4.8.3
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNMessageCountAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNMessageCountAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNMessageCountAPICallBuilder * (^)(NSArray<NSString *> *channels))channels {
    
    return ^PNMessageCountAPICallBuilder * (NSArray<NSString *> *channels) {
        if ([channels isKindOfClass:[NSArray class]]) {
            [self setValue:channels forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNMessageCountAPICallBuilder * (^)(NSArray<NSNumber *> *timetokens))timetokens {
    
    return ^PNMessageCountAPICallBuilder * (NSArray<NSNumber *> *timetokens) {
        if ([timetokens isKindOfClass:[NSArray class]]) {
            [self setValue:timetokens forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNMessageCountCompletionBlock block))performWithCompletion {
    
    return ^(PNMessageCountCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
