/**
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
*/
#import "PNBaseNotificationPayload+Private.h"
#import "PNMPNSNotificationPayload.h"


#pragma mark Interface implementation

@implementation PNMPNSNotificationPayload


#pragma mark - Information

- (void)setBackContent:(NSString *)backContent {
    _backContent = [backContent copy];
    self.payload[@"back_content"] = _backContent;
}

- (void)setBackTitle:(NSString *)backTitle {
    _backTitle = [backTitle copy];
    self.payload[@"back_title"] = _backTitle;
}

- (void)setCount:(NSNumber *)count {
    _count = count;
    self.payload[@"count"] = _count;
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.payload[@"title"] = _title;
}

- (void)setType:(NSString *)type {
    _type = [type copy];
    self.payload[@"type"] = _type;
}

- (void)setSubtitle:(NSString *)subtitle {
    self.backTitle = subtitle;
}

- (void)setBody:(NSString *)body {
    self.backContent = body;
}

- (void)setBadge:(NSNumber *)badge {
    self.count = badge;
}


#pragma mark - Initialization & Configuration

- (void)setDefaultPayloadStructure {
    // No payload structure required for MPNS because all data is set in object root.
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    return self.payload.count ? [self.payload copy] : nil;
}

#pragma mark -


@end
