#import <Foundation/Foundation.h>
#import "PubNub+Subscribe.h"


#pragma mark Class forward

@class PNPresenceEventResult, PNSubscribeStatus, PNMessageResult, PNSignalResult, PNErrorStatus;
@class PNMembershipEventResult, PNMessageActionResult, PNSpaceEventResult, PNUserEventResult;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Interface description for classes which would like to be registered for events from data
 * object live feed.
 *
 * @author Serhii Mamontov
 * @version 4.9.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@protocol PNObjectEventListener <NSObject>


@optional

#pragma mark - Message, Actions, Signals and Events handler callbacks

/**
 * @brief Notify listener about new message which arrived from one of remote data object's live feed
 * on which client subscribed at this moment.
 *
 * @param client \b PubNub client which triggered this callback method call.
 * @param message Instance which store message information in \c data
 * property.
 */
- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message;

/**
 * @brief Notify listener about new signal which arrived from one of remote data object's live feed
 * on which client subscribed at this moment.
 *
 * @param client \b PubNub client which triggered this callback method call.
 * @param signal Instance which store signal information in \c data property.
 */
- (void)client:(PubNub *)client didReceiveSignal:(PNSignalResult *)signal;

/**
 * @brief Notify listener about new \c action which arrived from one of remote data object's live
 * feed on which client subscribed at this moment.
 *
 * @param client \b PubNub client which triggered this callback method call.
 * @param action Instance which store \c action information in \c data property.
 */
- (void)client:(PubNub *)client didReceiveMessageAction:(PNMessageActionResult *)action;

/**
 * @brief Notify listener about new presence events which arrived from one of remote data object's
 * presence live feed on which client subscribed at this moment.
 *
 * @param client \b PubNub client which triggered this callback method call.
 * @param event Instance which store presence event information in \c data property.
 */
- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event;

/**
 * @brief Notify listener about new \c user events which arrived from one of remote data object's
 * presence live feed on which client subscribed at this moment.
 *
 * @param client \b PubNub client which triggered this callback method call.
 * @param event Instance which store \c user event information in \c data property.
 */
- (void)client:(PubNub *)client didReceiveUserEvent:(PNUserEventResult *)event;

/**
 * @brief Notify listener about new \c space events which arrived from one of remote data object's
 * presence live feed on which client subscribed at this moment.
 *
 * @param client \b PubNub client which triggered this callback method call.
 * @param event Instance which store \c space event information in \c data property.
 */
- (void)client:(PubNub *)client didReceiveSpaceEvent:(PNSpaceEventResult *)event;

/**
 * @brief Notify listener about new \c membership events which arrived from one of remote data
 * object's presence live feed on which client subscribed at this moment.
 *
 * @param client \b PubNub client which triggered this callback method call.
 * @param event Instance which store \c membership event information in \c data property.
 */
- (void)client:(PubNub *)client didReceiveMembershipEvent:(PNMembershipEventResult *)event;


#pragma mark - Status change handler.

/**
 * @brief Notify listener about subscription state changes.
 *
 * @discussion This callback can fire when client tried to subscribe on channels for which it
 * doesn't have access rights or when network went down and client unexpectedly disconnected.
 *
 * @param client Reference on \b PubNub client which triggered this callback method call.
 * @param status  Reference on \b PNStatus instance which store subscriber state information.
 */
- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
