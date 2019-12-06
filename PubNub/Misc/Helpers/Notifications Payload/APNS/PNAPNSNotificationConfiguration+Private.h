#import "PNAPNSNotificationConfiguration.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNAPNSNotificationConfiguration (Private)


#pragma mark - Misc

/**
 * @brief Translate user-provided information into payload which can be consumed by \b PubNub mobile
 * notification service and delivered to target devices.
 */
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
