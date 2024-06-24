#import <PubNub/PNSubscribeEventData.h>
#import <PubNub/PNChannelMetadata.h>
#import <PubNub/PNUUIDMetadata.h>
#import <PubNub/PNMembership.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `App Context event` data.
@interface PNSubscribeObjectEventData : PNSubscribeEventData


#pragma mark - Properties

/// This property will be set only if event `type` is `channel` and represent `channel metadata`.
@property(strong, nullable, nonatomic, readonly) PNChannelMetadata *channelMetadata;

/// This property will be set only if event `type` is `uuid` and represent `uuid metadata`.
@property(strong, nullable, nonatomic, readonly) PNUUIDMetadata *uuidMetadata;

/// This property will be set only if event `type` is `membership` and represent `uuid membership`.
@property(strong, nullable, nonatomic, readonly) PNMembership *membership;

/// Time when `object` event has been triggered.
@property(strong, nonatomic, readonly) NSNumber *timestamp;

/// Name of action for which `object` event has been sent.
@property(strong, nonatomic, readonly) NSString *event;

/// Type of `object` which has been changed and triggered event.
@property(strong, nonatomic, readonly) NSString *type;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
