/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNCreateSpaceAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNCreateSpaceAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNCreateSpaceAPICallBuilder * (^)(PNSpaceFields includeFields))includeFields {
    return ^PNCreateSpaceAPICallBuilder * (PNSpaceFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNCreateSpaceAPICallBuilder * (^)(NSString *information))information {
    return ^PNCreateSpaceAPICallBuilder * (NSString *information) {
        if ([information isKindOfClass:[NSString class]] && information.length) {
            [self setValue:information forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNCreateSpaceAPICallBuilder * (^)(NSDictionary *custom))custom {
    return ^PNCreateSpaceAPICallBuilder * (NSDictionary *custom) {
        if ([custom isKindOfClass:[NSDictionary class]] && custom.count) {
            [self setValue:custom forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNCreateSpaceAPICallBuilder * (^)(NSString *spaceId))spaceId {
    return ^PNCreateSpaceAPICallBuilder * (NSString *spaceId) {
        if ([spaceId isKindOfClass:[NSString class]] && spaceId.length) {
            [self setValue:spaceId forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNCreateSpaceAPICallBuilder * (^)(NSString *name))name {
    return ^PNCreateSpaceAPICallBuilder * (NSString *name) {
        if ([name isKindOfClass:[NSString class]] && name.length) {
            [self setValue:name forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNCreateSpaceCompletionBlock block))performWithCompletion {
    return ^(PNCreateSpaceCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
