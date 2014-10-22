/**
 Extending \b PNClient class with properties and methods which can be used internally by \b PubNub client.

 @author Sergey Mamontov
 @version 3.6.0
 @copyright © 2009-13 PubNub Inc.
 */

#import "PNClient.h"


#pragma mark Private interface declaration

@interface PNClient ()


#pragma mark - Properties

@property (nonatomic, strong) PNChannel *channel;
@property (nonatomic, strong) PNChannelGroup *group;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) NSDictionary *data;

/**
 @brief Stores reference on list for which there is client's state data avaialable.
 
 @since 3.7.0
 */
@property (nonatomic, strong) NSMutableArray *channelsWithState;

/**
 @brief Stores reference on client's state across multiple channels (or single)
 
 @since 3.7.0
 */
@property (nonatomic, strong) NSMutableDictionary *clientData;

/**
 @brief Stores reference on on client's state data which doesn't have link to channel.
 
 @since 3.7.0
 */
@property (nonatomic, strong) NSDictionary *unboundData;


#pragma mark - Class methods

/**
 Construct and return reference on client configured instance which should represent anonymous client.

 @return \b PNClient instance.
 */
+ (PNClient *)anonymousClient;

/**
 Construct and return reference on client configured instance which should represent anonymous client.

 @param channel
 \b PNChannel instance which describe where this client reside at this moment / or leaved.

 @return \b PNClient instance.
 */
+ (PNClient *)anonymousClientForChannel:(PNChannel *)channel;

/**
 Construct and return reference on client configured instance which should represent single client subscribed to the
 channel.

 @param identifier
 \b NSString instance which allow to identify client among other.

 @param channel
 \b PNChannel instance which describe where this client reside at this moment / or leaved.

 @param data
 \b NSDictionary instance which hold applied to the client during subscription.

 @return \b PNClient instance.
 */
+ (PNClient *)clientForIdentifier:(NSString *)identifier channel:(PNChannel *)channel andData:(NSDictionary *)data;


#pragma mark - Instance methods

/**
 Initialize instance which should represent single client subscribed to the channel.

 @param identifier
 \b NSString instance which allow to identify client among other.

 @param channel
 \b PNChannel instance which describe where this client reside at this moment / or leaved.

 @param data
 \b NSDictionary instance which hold applied to the client during subscription or state fetch request.

 @return \b PNClient instance.
 */
- (id)initWithIdentifier:(NSString *)identifier channel:(PNChannel *)channel andData:(NSDictionary *)data;

/**
 @brief Bind client's data to channel.
 
 @discussion State will be stored in linkage to specified channel.
 
 @param data    \b NSDictionary instance which hold applied to the client during subscription or state fetch request.
 @param channel \b PNChannel name will be used to create linkage between state information and channel.
 
 @since 3.7.0
 */
- (void)addClientData:(NSDictionary *)data forChannel:(PNChannel *)channel;

#pragma mark -


@end
