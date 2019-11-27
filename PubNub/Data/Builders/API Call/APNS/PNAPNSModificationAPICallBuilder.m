/**
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.5.4
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNAPNSModificationAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNAPNSModificationAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNAPNSModificationAPICallBuilder * (^)(id token))token {
    return ^PNAPNSModificationAPICallBuilder * (id token) {
        [self setValue:token forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNAPNSModificationAPICallBuilder * (^)(NSData *token))apnsToken {
    return self.pushType(PNAPNSPush).token;
}

- (PNAPNSModificationAPICallBuilder * (^)(NSString *token))fcmToken {
    return self.pushType(PNFCMPush).token;
}

- (PNAPNSModificationAPICallBuilder * (^)(NSArray<NSString *> *channels))channels {
    return ^PNAPNSModificationAPICallBuilder * (NSArray<NSString *> *channels) {
        [self setValue:channels forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNAPNSModificationAPICallBuilder * (^)(PNAPNSEnvironment environment))environment {
    return ^PNAPNSModificationAPICallBuilder * (PNAPNSEnvironment environment) {
        [self setValue:@(environment) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNAPNSModificationAPICallBuilder * (^)(PNPushType pushType))pushType {
    return ^PNAPNSModificationAPICallBuilder * (PNPushType pushType) {
        [self setValue:@(pushType) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNAPNSModificationAPICallBuilder * (^)(NSString *topic))topic {
    return ^PNAPNSModificationAPICallBuilder * (NSString *topic) {
        [self setValue:topic forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNPushNotificationsStateModificationCompletionBlock block))performWithCompletion {
    return ^(PNPushNotificationsStateModificationCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
