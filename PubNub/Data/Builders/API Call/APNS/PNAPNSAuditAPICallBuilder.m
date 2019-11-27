/**
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.5.4
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNAPNSAuditAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNAPNSAuditAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNAPNSAuditAPICallBuilder * (^)(id token))token {
    return ^PNAPNSAuditAPICallBuilder * (id token) {
        [self setValue:token forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNAPNSAuditAPICallBuilder * (^)(NSData *token))apnsToken {
    return self.pushType(PNAPNSPush).token;
}

- (PNAPNSAuditAPICallBuilder * (^)(NSString *token))fcmToken {
    return self.pushType(PNFCMPush).token;
}

- (PNAPNSAuditAPICallBuilder * (^)(NSString *token))mpnsToken {
    return ^PNAPNSAuditAPICallBuilder * (NSString *token) {
        [self setValue:token forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNAPNSAuditAPICallBuilder * (^)(PNAPNSEnvironment environment))environment {
    return ^PNAPNSAuditAPICallBuilder * (PNAPNSEnvironment environment) {
        [self setValue:@(environment) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNAPNSAuditAPICallBuilder * (^)(PNPushType pushType))pushType {
    return ^PNAPNSAuditAPICallBuilder * (PNPushType pushType) {
        [self setValue:@(pushType) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNAPNSAuditAPICallBuilder * (^)(NSString *topic))topic {
    return ^PNAPNSAuditAPICallBuilder * (NSString *topic) {
        [self setValue:topic forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNPushNotificationsStateAuditCompletionBlock block))performWithCompletion {
    return ^(PNPushNotificationsStateAuditCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
