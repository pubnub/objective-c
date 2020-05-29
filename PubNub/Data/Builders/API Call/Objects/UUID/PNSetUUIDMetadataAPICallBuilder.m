/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNSetUUIDMetadataAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNSetUUIDMetadataAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNSetUUIDMetadataAPICallBuilder * (^)(PNUUIDFields includeFields))includeFields {
    return ^PNSetUUIDMetadataAPICallBuilder * (PNUUIDFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNSetUUIDMetadataAPICallBuilder * (^)(NSString *externalId))externalId {
    return ^PNSetUUIDMetadataAPICallBuilder * (NSString *externalId) {
        if ([externalId isKindOfClass:[NSString class]] && externalId.length) {
            [self setValue:externalId forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNSetUUIDMetadataAPICallBuilder * (^)(NSString *profileUrl))profileUrl {
    return ^PNSetUUIDMetadataAPICallBuilder * (NSString *profileUrl) {
        if ([profileUrl isKindOfClass:[NSString class]] && profileUrl.length) {
            [self setValue:profileUrl forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNSetUUIDMetadataAPICallBuilder * (^)(NSDictionary *custom))custom {
    return ^PNSetUUIDMetadataAPICallBuilder * (NSDictionary *custom) {
        if ([custom isKindOfClass:[NSDictionary class]] && custom.count) {
            [self setValue:custom forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNSetUUIDMetadataAPICallBuilder * (^)(NSString *email))email {
    return ^PNSetUUIDMetadataAPICallBuilder * (NSString *email) {
        if ([email isKindOfClass:[NSString class]] && email.length) {
            [self setValue:email forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNSetUUIDMetadataAPICallBuilder * (^)(NSString *uuid))uuid {
    return ^PNSetUUIDMetadataAPICallBuilder * (NSString *uuid) {
        if ([uuid isKindOfClass:[NSString class]] && uuid.length) {
            [self setValue:uuid forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNSetUUIDMetadataAPICallBuilder * (^)(NSString *name))name {
    return ^PNSetUUIDMetadataAPICallBuilder * (NSString *name) {
        if ([name isKindOfClass:[NSString class]] && name.length) {
            [self setValue:name forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNSetUUIDMetadataCompletionBlock block))performWithCompletion {
    return ^(PNSetUUIDMetadataCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
