/**
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-14 PubNub Inc.
 
 */

#import "PNChannelGroup.h"


#pragma mark Protected interface declaration

@interface PNChannelGroup (Protected)


#pragma mark - Properties

@property (nonatomic, strong) NSArray *channels;


#pragma mark - Class methods

/**
 @brief Construct channel group from namespace for subscription.
 
 @discussion This method mostly should be used to create reference on channel group when used with subscribe API. This
 method also allow to specify whether channel group events should arrive to \b PubNub client or not.
 
 @param name                              Name of channel group in inside of namespace
 @param nspace                            Name of namespace under which this channel group and 
                                          channels stored.
 @param observePresence                   Whether \b PubNub client should receive presence events 
                                          from channels registered in channel or not
 @param shouldUpdatePresenceObservingFlag Whether presence observation flasg should be updated or 
                                          not.
 
 @return Reference on ready to use \b PNChannelGroup instance with specified behaviour as for 
 presence events or \c nil in case if wrong \c name (with forbidden characters) or \c nspace (with 
 forbidden characters).
 
 @since 3.7.3
 */
+ (PNChannelGroup *)channelGroupWithName:(NSString *)name inNamespace:(NSString *)nspace
                   shouldObservePresence:(BOOL)observePresence
       shouldUpdatePresenceObservingFlag:(BOOL)shouldUpdatePresenceObservingFlag;

#pragma mark -


@end
