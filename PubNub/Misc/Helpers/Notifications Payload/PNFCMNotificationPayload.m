/**
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
*/
#import "PNBaseNotificationPayload+Private.h"
#import "PNFCMNotificationPayload.h"


#pragma mark Interface implementation

@implementation PNFCMNotificationPayload


#pragma mark - Information

- (NSMutableDictionary *)notification {
    return self.payload[@"notification"];
}

- (void)setTitle:(NSString *)title {
    self.payload[@"notification"][@"title"] = [title copy];
}

- (void)setBody:(NSString *)body {
    self.payload[@"notification"][@"body"] = [body copy];
}

- (void)setSound:(NSString *)sound {
    self.payload[@"notification"][@"sound"] = [sound copy];
}

- (void)setIcon:(NSString *)icon {
    self.payload[@"notification"][@"icon"] = [icon copy];
}

- (void)setTag:(NSString *)tag {
    self.payload[@"notification"][@"tag"] = [tag copy];
}

- (NSMutableDictionary *)data {
    return self.payload[@"data"];
}


#pragma mark - Initialization & Configuration

- (void)setDefaultPayloadStructure {
    self.payload[@"notification"] = [NSMutableDictionary new];
    self.payload[@"data"] = [NSMutableDictionary new];
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *data = [self.payload[@"data"] mutableCopy];
    NSMutableDictionary *payload = [NSMutableDictionary new];
    NSDictionary *notification = nil;
    
    /**
     * Check whether additional data has been passed outside of 'data' object and put it into it
     * if required.
     */
    if (self.payload.count > 2) {
        NSMutableDictionary *additionalData = [self.payload mutableCopy];
        [additionalData removeObjectsForKeys:@[@"data", @"notification"]];
        
        [data addEntriesFromDictionary:additionalData];
    }
    
    if (self.isSilent) {
        [data addEntriesFromDictionary:@{ @"notification": self.payload[@"notification"] }];
    } else {
        notification = self.payload[@"notification"];
    }
    
    if (data.count) {
        payload[@"data"] = data;
    }
    
    if (notification.count) {
        payload[@"notification"] = notification;
    }
    
    return payload.count ? payload : nil;;
}

#pragma mark -


@end
