#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PubNub;


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Presence heartbeat manager used by client to ping \b PubNub network.
 @discussion Allow to notify service and tell what subscriber still alive and waiting for events from live 
             feed.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNHeartbeat : NSObject


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Construct and configure heartbeat manager.
 
 @param client Reference on \b PubNub client for which heartbeat manager has been created.
 
 @return Constructed and ready to use heartbeat manager.
 
 @since 4.0
 */
+ (instancetype)heartbeatForClient:(PubNub *)client;


///------------------------------------------------
/// @name Client presence
///------------------------------------------------

/**
 * @brief  List of all objects for which client's presence is set to \c connected.
 *
 * @return Reference on list of channels and groups for which client is marked as \c connected.
 *
 * @since 4.7.5
 */
- (NSArray<NSString *> *)allObjects;

/**
 * @brief  List of channels for which client's presence is set to \c connected.
 *
 * @return Reference on list of channels for which client is marked as \c connected.
 *
 * @since 4.7.5
 */
- (NSArray<NSString *> *)channels;

/**
 * @brief  List of channel groups for which client's presence is set to \c connected.
 *
 * @return Reference on list of channel groups for which client is marked as \c connected.
 *
 * @since 4.7.5
 */
- (NSArray<NSString *> *)channelGroups;

/**
 * @brief      Update client's presence connected state for \c channels.
 * @discussion Mark client as \c connected or \c leaved for remote subscribers which is listening for
 *             events on \c channels.
 *
 * @param channels Reference on list of channels (even those to which client not subscribed) for which
 *                 client's presence state should be changed.
 *
 * @since 4.7.5
 */
- (void)setConnected:(BOOL)connected forChannels:(NSArray<NSString *> *)channels;

/**
 * @brief      Update client's presence connected state for channel \c groups.
 * @discussion Mark client as \c connected or \c leaved for remote subscribers which is listening for
 *             events on channel \c groups.
 *
 * @param channelGroups Reference on list of channel groups (even those to which client not subscribed)
 *                      for which client's presence state should be changed.
 *
 * @since 4.7.5
 */
- (void)setConnected:(BOOL)connected forChannelGroups:(NSArray<NSString *> *)channelGroups;


///------------------------------------------------
/// @name State manipulation
///------------------------------------------------

/**
 @brief  If client configured with heartbeat value and interval client will send "heartbeat" 
         notification to \b PubNub service.
 
 @since 4.0
 */
- (void)startHeartbeatIfRequired;

/**
 @brief  In case if there is active heartbeat timer it will be stopped.

 @since 4.0
 */
- (BOOL)stopHeartbeatIfPossible;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
