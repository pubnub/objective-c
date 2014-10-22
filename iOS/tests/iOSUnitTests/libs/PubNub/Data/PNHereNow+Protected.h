/**
 Extending \b PNHereNow class with properties which can be used internally by \b PubNub client.

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.
 */

#import "PNHereNow.h"


#pragma mark Class forward

@class PNChannel, PNClient;


#pragma mark - Private interface methods

@interface PNHereNow ()


#pragma mark - Properties

@property (nonatomic, strong) NSArray *participants DEPRECATED_MSG_ATTRIBUTE(" This property deprecated. Use '-participantsForChannel:' to retrieve participants list");
@property (nonatomic, assign) unsigned long participantsCount DEPRECATED_MSG_ATTRIBUTE(" This property deprecated. Use '-participantsCountForChannel:' to retrieve participants count");
@property (nonatomic, strong) PNChannel *channel DEPRECATED_MSG_ATTRIBUTE(" This property deprecated. Use 'channels' property to retrieve list of channels with participants information");

/**
 Stores reference on dictionary which hold information about participants and their count in linkage to the channels.
 */
@property (nonatomic, strong) NSMutableDictionary *participantsMap;


#pragma mark - Instance methods

/**
 Link participant client to channel at which it has been found.
 
 @param participant
 Reference on \b PNClient instance which represent person on channel with it state on it (if has been requested along with 
 identifier).
 
 @param channel
 Reference on on \b PNChannel at which client reside at this moment.
 */
- (void)addParticipant:(PNClient *)participant forChannel:(PNChannel *)channel;

/**
 Update number of participants on particular channel (we can't rely on number of participants stored in array and better 
 to double protect here).
 
 @param count
 Number of participants retrieved from JSON response (not from parsed and stored list of \b PNClient instances).
 
 @param channel
 Reference on \b PNChannel instance for which number of participants is stored.
 */
- (void)setParticipantsCount:(NSUInteger)count forChannel:(PNChannel *)channel;


#pragma mark - Misc method

/**
 Try to fetch previuosly parsed channel presence information.
 
 @param channel
 Reference on \b PNChannel instance for which information should be pulled out.
 
 @return \a NSMutableDictionary instance which hold list of channels and number of participants for target \c channel.
 */
- (NSMutableDictionary *)presenceInformationForChannel:(PNChannel *)channel;

#pragma mark -


@end
