#import <Foundation/Foundation.h>
#import "PNPrivateStructures.h"


/**
 * @brief Class describe real-time event envelope information.
 *
 * @discussion Real-time events on subscribed channels arrive in envelop which is full of debug
 * information which is useful during system reliability tests and issues debugging.
 *
 * @author Serhii Mamontov
 * @version 4.9.0
 * @since 4.3.0
 * @copyright © 2010-2019 PubNub Inc.
 */
@interface PNEnvelopeInformation : NSObject


#pragma mark - Information

/**
 * @brief Shard identifier on which event has been stored.
 */
@property (nonatomic, nullable, readonly, copy) NSString *shardIdentifier;

/**
 * @brief Numeric representation of enabled debug flags.
 */
@property (nonatomic, nullable, readonly, copy) NSNumber *debugFlags;

/**
 * @brief Identifier of client which sent message (set only for publish).
 */
@property (nonatomic, nullable, readonly, copy) NSString *senderIdentifier;

/**
 * @brief Sequence nubmer of published messages (clients keep track of their own value locally).
 */
@property (nonatomic, nullable, readonly, copy) NSNumber *sequenceNumber;

/**
 * @brief Application's subscribe key.
 */
@property (nonatomic, nullable, readonly, copy) NSString *subscribeKey;

/**
 * @brief Object's message type.
 */
@property (nonatomic, readonly, assign) PNMessageType messageType;

/**
 * @brief Event replication map (region based).
 */
@property (nonatomic, nullable, readonly, copy) NSNumber *replicationMap;

/**
 * @brief Whether message should be stored in memory or removed after delivering.
 */
@property (nonatomic, readonly, assign)BOOL shouldEatAfterReading;

/**
 * @brief User-provided (during publish) metadata which will be taken into account by filtering
 * algorithms.
 */
@property (nonatomic, nullable, readonly, copy) NSDictionary *metadata;

/**
 * @brief Information about waypoints.
 */
@property (nonatomic, nullable, readonly, copy) NSArray *waypoints;


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure real-time event envelope information instance.
 *
 * @param payload Event envelope dictionary which contain event delivery information.
 *
 * @return Configured and ready to use event envelope information instance.
 */
+ (nonnull instancetype)envelopeInformationWithPayload:(nonnull NSDictionary *)payload;

#pragma mark -


@end
