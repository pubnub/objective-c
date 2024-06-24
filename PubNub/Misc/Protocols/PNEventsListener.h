#import <Foundation/Foundation.h>
#import <PubNub/PubNub+Core.h>


#pragma mark Class forward

@class PNPresenceEventResult, PNSubscribeStatus, PNMessageResult, PNSignalResult, PNErrorStatus;
@class PNMessageActionResult, PNObjectEventResult, PNFileEventResult;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface declaration

/// Events handler protocol.
///
/// Classes which would like to receive real-time updates from PubNub client should implement this protocol.
@protocol PNEventsListener <NSObject>


@optional

#pragma mark - Message, Actions, Signals and Events handler callbacks

/// New real-time message callback.
///
/// - Parameters:
///   - client: **PubNub** client which triggered this callback method call.
///   - message: Instance which store message information in `data` property.
- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message;

/// New real-time signal callback.
///
/// - Parameters:
///   - client: **PubNub** client which triggered this callback method call.
///   - signal: Instance which store signal information in `data` property.
- (void)client:(PubNub *)client didReceiveSignal:(PNSignalResult *)signal;

/// New message reaction callback.
///
/// - Parameters:
///   - client: **PubNub** client which triggered this callback method call.
///   - action: Instance which store `action` information in `data` property.
- (void)client:(PubNub *)client didReceiveMessageAction:(PNMessageActionResult *)action;

/// Channels' presence change callback.
///
/// - Parameters:
///   - client: **PubNub** client which triggered this callback method call.
///   - event: Instance which store presence event information in `data` property.
- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event;

/// App Context object state update callback.
///
/// - Parameters:
///   - client: **PubNub** client which triggered this callback method call.
///   - event: Instance which store information about received event from Objects API use.
- (void)client:(PubNub *)client didReceiveObjectEvent:(PNObjectEventResult *)event;

/// File sharing event callback.
///
/// - Parameters:
///   - client: **PubNub** client which triggered this callback method call.
///   - event: Instance which store information about received event from File API use.
- (void)client:(PubNub *)client didReceiveFileEvent:(PNFileEventResult *)event;


#pragma mark - Status change handler.

/// Subscription state changes callback.
///
/// This callback can fire when client tried to subscribe on channels for which it doesn't have access rights or when
/// network went down and client unexpectedly disconnected.
///
/// - Parameters:
///   - client: Reference on **PubNub** client which triggered this callback method call.
///   - status: Reference on ``PNStatus`` instance which store subscriber state information.
- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status;

#pragma mark -


@end


#pragma mark - Deprecated

DEPRECATED_MSG_ATTRIBUTE("This protocol has been deprecated. Please use PNEventsListener instead.")
@protocol PNObjectEventListener <PNEventsListener>

#pragma mark -


@end

NS_ASSUME_NONNULL_END
