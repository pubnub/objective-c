/**
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
*/
#import "PNAPNSNotificationConfiguration+Private.h"
#import "PNBaseNotificationPayload+Private.h"
#import "PNAPNSNotificationPayload+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNAPNSNotificationPayload ()

/**
 * @brief APNS or APNS over HTTP/2 push type.
 */
@property (nonatomic, assign) PNPushType apnsPushType;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNAPNSNotificationPayload


#pragma mark - Information

- (NSMutableDictionary *)notification {
    return self.payload[@"aps"];
}

- (void)setTitle:(NSString *)title {
    self.payload[@"aps"][@"alert"][@"title"] = [title copy];
}

- (void)setSubtitle:(NSString *)subtitle {
    self.payload[@"aps"][@"alert"][@"subtitle"] = [subtitle copy];
}

- (void)setBody:(NSString *)body {
    self.payload[@"aps"][@"alert"][@"body"] = [body copy];
}

- (void)setBadge:(NSNumber *)badge {
    self.payload[@"aps"][@"badge"] = [badge copy];
}

- (void)setSound:(NSString *)sound {
    self.payload[@"aps"][@"sound"] = [sound copy];
}


#pragma mark - Initialization & Configuration

- (void)setDefaultPayloadStructure {
    self.payload[@"aps"] = [NSMutableDictionary new];
    self.payload[@"aps"][@"alert"] = [NSMutableDictionary new];
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *payload = [self.payload mutableCopy];
    NSMutableDictionary *aps = payload[@"aps"];
    NSMutableDictionary *alert = aps[@"alert"];
    
    if (self.isSilent) {
        payload[@"aps"][@"content-available"] = @1;
    }
    
    if (self.apnsPushType == PNAPNS2Push) {
        NSArray<PNAPNSNotificationConfiguration *> *configurations = self.configurations;
        NSMutableArray *serializedConfigurations = [NSMutableArray new];
        
        if (!configurations.count) {
            configurations = @[[PNAPNSNotificationConfiguration defaultConfiguration]];
        }
        
        [configurations enumerateObjectsUsingBlock:^(PNAPNSNotificationConfiguration *configuration,
                                                     __unused NSUInteger idx,
                                                     __unused BOOL *stop) {
            
            [serializedConfigurations addObject:[configuration dictionaryRepresentation]];
        }];
        
        payload[@"pn_push"] = serializedConfigurations;
    }
    
    if (!alert.count) {
        [aps removeObjectForKey:@"alert"];
    }
    
    if (self.isSilent) {
        [alert removeAllObjects];
        [aps removeObjectsForKeys:@[@"alert", @"badge", @"sound"]];
    }
    
    return self.isSilent || alert.count ? payload : nil;
}

#pragma mark -


@end
