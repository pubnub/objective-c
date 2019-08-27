/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNUpdateSpaceAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNUpdateSpaceAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNUpdateSpaceAPICallBuilder * (^)(PNSpaceFields includeFields))includeFields {
    return ^PNUpdateSpaceAPICallBuilder * (PNSpaceFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNUpdateSpaceAPICallBuilder * (^)(NSString *information))information {
    return ^PNUpdateSpaceAPICallBuilder * (NSString *information) {
        if ([information isKindOfClass:[NSString class]] && information.length) {
            [self setValue:information forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNUpdateSpaceAPICallBuilder * (^)(NSDictionary *custom))custom {
    return ^PNUpdateSpaceAPICallBuilder * (NSDictionary *custom) {
        if ([custom isKindOfClass:[NSDictionary class]] && custom.count) {
            [self setValue:custom forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNUpdateSpaceAPICallBuilder * (^)(NSString *spaceId))spaceId {
    return ^PNUpdateSpaceAPICallBuilder * (NSString *spaceId) {
        if ([spaceId isKindOfClass:[NSString class]] && spaceId.length) {
            [self setValue:spaceId forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNUpdateSpaceAPICallBuilder * (^)(NSString *name))name {
    return ^PNUpdateSpaceAPICallBuilder * (NSString *name) {
        if ([name isKindOfClass:[NSString class]] && name.length) {
            [self setValue:name forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNUpdateSpaceCompletionBlock block))performWithCompletion {
    return ^(PNUpdateSpaceCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
