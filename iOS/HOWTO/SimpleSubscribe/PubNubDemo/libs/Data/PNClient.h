#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNChannelGroup, PNChannel;


/**
 This class allow to represent single remote channel and it's data. This objects used for: presence events,
 where / here now request.

 @author Sergey Mamontov
 @version 3.6.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PNClient : NSObject


#pragma mark - Properties

/**
 @brief List of channels which has state for client.
 
 @since 3.7.0
 */
@property (nonatomic, readonly) NSArray *channels;

/**
 Stores reference on channel in which this client reside.
 */
@property (nonatomic, readonly, strong) PNChannel *channel;

/**
 @brief Reference on channel group in which client reside.
 
 @discussion This property can be \c nil in case if client information has been retrieved from ordinary channel or this
 is anonymous client
 
 @since 3.7.0
 */
@property (nonatomic, readonly, strong) PNChannelGroup *group;

/**
 Property allow to identify concrete client among other subscribed to the channel.
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 Stores data which has been assigned to the client.
 */
@property (nonatomic, readonly, strong) NSDictionary *data
          DEPRECATED_MSG_ATTRIBUTE(" Use '-stateForChannel:' to get client's state for concrete channel");


#pragma mark - Instance methods

/**
 Check whether \b PNClient instance created for \a 'anonymous' record or not.

 @return \c YES if \a 'anonymous' client.
 */
- (BOOL)isAnonymous;

/**
 @brief Retrieve client's data inside concrete channel.
 
 @discussion \b PNClient can receive it's state for multiple channels at once (from channel group) and this method allow
 to get state for concrete channel (list of channels with data stored in \c channels property).
 
 @since 3.7.0
 */
/**
 @brief Retrieve client's data inside concrete channel.
 
 @discussion \b PNClient can receive it's state for multiple channels at once (from channel group) and this method allow
 to get state for concrete channel (list of channels with data stored in \c channels property).
 
 @param channel Reference on \b PNChannel for which \b PNClient should look for state.
 
 @return \a NSDictionary or \c nil in case if there is no state information for specified channel.
 
 @since 3.7.0
 */
- (NSDictionary *)stateForChannel:(PNChannel *)channel;

#pragma mark -


@end
