#import <Foundation/Foundation.h>
#import "PNChannel.h"

/**
 This class used to represent one of channel registry entities which hold set of channels registered under unique name inside
 of one created namespaces.
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PNChannelGroup : PNChannel


#pragma mark - Properties

/**
 Stores reference on unique channel group name inside namespace in \b PubNub cloud.
 */
@property (nonatomic, readonly, copy) NSString *groupName;

/**
 Stores reference on unique namespace name inside of which group and channels stored.
 */
@property (nonatomic, readonly, copy) NSString *nspace;

/**
 Stores reference on list of channels which has been added for this channel group.
 
 @warning This array filled only after request which retrieve them.
 */
@property (nonatomic, readonly, strong) NSArray *channels;


#pragma mark - Class methods

/**
 Construct channel group which is used to represent set of channels on which client should be able to subscribe.
 
 @param groupName
 Name under which this channel group object is stored inside namespace in \b PubNub cloud.
 
 @return Reference on ready to use \b PNChannelGroup object or \c nil in case if wrong \c name 
 (with forbidden characters) or \c nspace (with forbidden characters). Also will return \c nil in
 case if name will be specified in wrong format (required: "namespace name:group name").
 */
+ (PNChannelGroup *)channelGroupWithName:(NSString *)name;

/**
 @brief Construct global scope channel group for subscription.
 
 @discussion This method mostly should be used to create reference on channel group when used with subscribe API. This 
 method also allow to specify whether channel group events should arrive to \b PubNub client or not.
 
 @param name            Name of channel group in global (subscription key) scope
 @param observePresence Whether \b PubNub client should receive presence events from channels registered in channel or 
                        not
 
 @return Reference on ready to use \b PNChannelGroup instance with specified behaviour as for
 presence events or \c nil in case if wrong \c name (with forbidden characters) or \c nspace (with
 forbidden characters).
 
 @since 3.7.0
 */
+ (PNChannelGroup *)channelGroupWithName:(NSString *)name shouldObservePresence:(BOOL)observePresence;

/**
 Construct channel group which is used to represent set of channels on which client should be able to subscribe.
 
 @param name
 Name under which this channel group object is stored inside namespace in \b PubNub cloud.
 
 @param nspace
 Name of namespace under which this channel group and channels stored.
 
 @return Reference on ready to use \b PNChannelGroup object or \c nil in case if wrong \c name 
 (with forbidden characters) or \c nspace (with forbidden characters).
 */
+ (PNChannelGroup *)channelGroupWithName:(NSString *)name inNamespace:(NSString *)nspace;

/**
 @brief Construct channel group from namespace for subscription.
 
 @discussion This method mostly should be used to create reference on channel group when used with subscribe API. This
 method also allow to specify whether channel group events should arrive to \b PubNub client or not.
 
 @param name            Name of channel group in inside of namespace
 @param nspace          Name of namespace under which this channel group and channels stored.
 @param observePresence Whether \b PubNub client should receive presence events from channels
                        registered in channel or not
 
 @return Reference on ready to use \b PNChannelGroup instance with specified behaviour as for 
 presence events or \c nil in case if wrong \c name (with forbidden characters) or \c nspace (with 
 forbidden characters).
 
 @since 3.7.0
 */
+ (PNChannelGroup *)channelGroupWithName:(NSString *)name inNamespace:(NSString *)nspace
                   shouldObservePresence:(BOOL)observePresence;

#pragma mark -


@end
