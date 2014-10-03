/**
 Extending \b PNHereNowResponseParser class with properties and methods which can be used internally by \b PubNub client.

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.
 */


#pragma mark Static

/**
 Stores reference on key under which list of clients information is stored (it can be list of \b NSString or \b
 NSDictionary)
 */
static NSString * const kPNResponseUUIDKey = @"uuids";

/**
 Stores reference on key under which stored client unique identifier (in case if response returned list of \b
 NSDictionary)
 */
static NSString * const kPNResponseClientUUIDKey = @"uuid";

/**
 Stores reference on key under which stored client additional information (in case if response returned list of \b
 NSDictionary)
 */
static NSString * const kPNResponseClientStateKey = @"state";

// Stores reference on key under which number of participants
// in room is stored
static NSString * const kPNResponseOccupancyKey = @"occupancy";

/**
 Stores reference on key under which list of channels is stored.
 */
static NSString * const kPNResponseChannelsKey = @"channels";


#pragma mark - Class forward

@class PNHereNow, PNChannel, PNClient;


#pragma mark - Private interface methods

@interface PNHereNowResponseParser ()


#pragma mark - Properties

/**
 Stores reference on object which stores information about who is in the channel and how many of them.
 */
@property (nonatomic, strong) PNHereNow *hereNow;


#pragma mark - Instance methods

#pragma mark - Misc methods

/**
 Process provided set of clients information for specific channel.

 @param clientsInformation
 Array of strings or dictionaries which allow describe clients.

 @param channel
 \b PNChannel instance which represent channel in which clients reside at this moment.

 @return list of \b PNClient instances.

 @since 3.6.0
 */
- (NSArray *)clientsFromData:(NSArray *)clientsInformation forChannel:(PNChannel *)channel;

/**
 Construct \b PNClient instance basing on available data.

 @param clientInformation
 Dictionary or string which allow to describe client.

 @param channel
 \b PNChannel instance which represent channel in which client reside at this moment.

 @return Initialized \b PNClient instance.

 @since 3.6.0
 */
- (PNClient *)clientFromData:(id)clientInformation forChannel:(PNChannel *)channel;

#pragma mark -


@end
