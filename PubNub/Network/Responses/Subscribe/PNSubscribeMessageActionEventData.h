#import <PubNub/PNSubscribeEventData.h>
#import <PubNub/PNMessageAction.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Message action event` data.
@interface PNSubscribeMessageActionEventData : PNSubscribeEventData


#pragma mark - Properties

/// `Action` for which event has been received.
@property(strong, nonatomic, readonly) PNMessageAction *action;

/// Name of action for which `message action` event has been sent.
@property(copy, nonatomic, readonly) NSString *event;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
