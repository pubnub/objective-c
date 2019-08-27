/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNUpdateUserAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNUpdateUserAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNUpdateUserAPICallBuilder * (^)(PNUserFields includeFields))includeFields {
    return ^PNUpdateUserAPICallBuilder * (PNUserFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNUpdateUserAPICallBuilder * (^)(NSString *externalId))externalId {
    return ^PNUpdateUserAPICallBuilder * (NSString *externalId) {
        if ([externalId isKindOfClass:[NSString class]] && externalId.length) {
            [self setValue:externalId forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNUpdateUserAPICallBuilder * (^)(NSString *profileUrl))profileUrl {
    return ^PNUpdateUserAPICallBuilder * (NSString *profileUrl) {
        if ([profileUrl isKindOfClass:[NSString class]] && profileUrl.length) {
            [self setValue:profileUrl forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNUpdateUserAPICallBuilder * (^)(NSDictionary *custom))custom {
    return ^PNUpdateUserAPICallBuilder * (NSDictionary *custom) {
        if ([custom isKindOfClass:[NSDictionary class]] && custom.count) {
            [self setValue:custom forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNUpdateUserAPICallBuilder * (^)(NSString *userId))userId {
    return ^PNUpdateUserAPICallBuilder * (NSString *userId) {
        if ([userId isKindOfClass:[NSString class]] && userId.length) {
            [self setValue:userId forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNUpdateUserAPICallBuilder * (^)(NSString *email))email {
    return ^PNUpdateUserAPICallBuilder * (NSString *email) {
        if ([email isKindOfClass:[NSString class]] && email.length) {
            [self setValue:email forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNUpdateUserAPICallBuilder * (^)(NSString *name))name {
    return ^PNUpdateUserAPICallBuilder * (NSString *name) {
        if ([name isKindOfClass:[NSString class]] && name.length) {
            [self setValue:name forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNUpdateUserCompletionBlock block))performWithCompletion {
    return ^(PNUpdateUserCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
