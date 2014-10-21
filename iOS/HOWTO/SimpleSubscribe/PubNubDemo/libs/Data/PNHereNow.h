#import <Foundation/Foundation.h>


#pragma mark - Class forward

@class PNChannel;


/**
 This class allow to get access ro result of 'Where now' API and find out to which channel client (specified by \c
 identifier property) subscribed at this moment.

 @author Sergey Mamontov
 @since 3.4.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PNHereNow : NSObject


#pragma mark Properties

/**
 Stores reference on list of \b PNClient instances.
 
 @note In case if requested only number of participants, this array will be \c nil.
 */
@property (nonatomic, readonly, strong) NSArray *participants
DEPRECATED_MSG_ATTRIBUTE(" This property deprecated. Use '-participantsForChannel:' to retrieve participants list");

/**
 Stores how much participants have been found subscribed on concrete channel.
 */
@property (nonatomic, readonly, assign) unsigned long participantsCount
DEPRECATED_MSG_ATTRIBUTE(" This property deprecated. Use '-participantsCountForChannel:' to retrieve participants "
                         "count");

/**
 Stores reference on channel inside of which \b PubNub client searched for participants (clients).
 */
@property (nonatomic, readonly, strong) PNChannel *channel
DEPRECATED_MSG_ATTRIBUTE(" This property deprecated. Use 'channels' property to retrieve list of channels with "
                         "participants information");


#pragma mark - Instance methods

/**
 @brief Retrieve list of channels for which presence information available.
 
 @discussion This list if filled by channels from server response. So, if there is no presence information for requested
 channel or channel group, then this array won't contain requested channel.
 
 @since 3.7.0
 
 @return List of \b PNChannel instances for which data has been retrieved.
 */
- (NSArray *)channels;

/**
 Retrieve list of \b PNClient instances which represent participant inside of channel.
 
 @param channel
 \b PNChannel instance for which participants list should be retrieved from fetched data.
 
 @since 3.7.0
 
 @return \c nil in case if there is no subscriber (or \c channel wasn't part of fetch request) on target \c channel or 
 request has been made to retrieve number of participants.
 */
- (NSArray *)participantsForChannel:(PNChannel *)channel;

/**
 Retrieve number of participants for particular channel.
 
 @param channel
 \b PNChannel instance for which participants count should be retrieved from fetched data.
 
 @since 3.7.0
 
 @return \b 0 in case if there is no subscribers (or \c channel wasn't part of fetch request) on target \c channel.
 */
- (NSUInteger)participantsCountForChannel:(PNChannel *)channel;

#pragma mark -


@end
