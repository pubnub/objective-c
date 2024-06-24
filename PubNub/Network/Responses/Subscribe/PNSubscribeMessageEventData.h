#import <PubNub/PNSubscribeEventData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Message event` data.
@interface PNSubscribeMessageEventData : PNSubscribeEventData


#pragma mark - Properties

/// Message which has been delivered through data object live feed.
@property(strong, nullable, nonatomic, readonly) id message;

/// Message sender identifier.
///
/// Unique identifier of configured remote client which sent this ``message``.
@property(strong, nonatomic, readonly) NSString *publisher;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
