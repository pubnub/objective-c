/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNCreateUserAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNCreateUserAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNCreateUserAPICallBuilder * (^)(PNUserFields includeFields))includeFields {
    return ^PNCreateUserAPICallBuilder * (PNUserFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNCreateUserAPICallBuilder * (^)(NSString *externalId))externalId {
    return ^PNCreateUserAPICallBuilder * (NSString *externalId) {
        if ([externalId isKindOfClass:[NSString class]] && externalId.length) {
            [self setValue:externalId forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNCreateUserAPICallBuilder * (^)(NSString *profileUrl))profileUrl {
    return ^PNCreateUserAPICallBuilder * (NSString *profileUrl) {
        if ([profileUrl isKindOfClass:[NSString class]] && profileUrl.length) {
            [self setValue:profileUrl forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNCreateUserAPICallBuilder * (^)(NSDictionary *custom))custom {
    return ^PNCreateUserAPICallBuilder * (NSDictionary *custom) {
        if ([custom isKindOfClass:[NSDictionary class]] && custom.count) {
            [self setValue:custom forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNCreateUserAPICallBuilder * (^)(NSString *userId))userId {
    return ^PNCreateUserAPICallBuilder * (NSString *userId) {
        if ([userId isKindOfClass:[NSString class]] && userId.length) {
            [self setValue:userId forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNCreateUserAPICallBuilder * (^)(NSString *email))email {
    return ^PNCreateUserAPICallBuilder * (NSString *email) {
        if ([email isKindOfClass:[NSString class]] && email.length) {
            [self setValue:email forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNCreateUserAPICallBuilder * (^)(NSString *name))name {
    return ^PNCreateUserAPICallBuilder * (NSString *name) {
        if ([name isKindOfClass:[NSString class]] && name.length) {
            [self setValue:name forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNCreateUserCompletionBlock block))performWithCompletion {
    return ^(PNCreateUserCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
