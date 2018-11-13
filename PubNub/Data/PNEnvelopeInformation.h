#import <Foundation/Foundation.h>


/**
 @brief      Class describe real-time event envelope information.
 @discussion Real-time events on subscribed channels arrive in envelop which is full of debug information 
             which is useful during system reliability tests and issues debugging.

 @author Sergey Mamontov
 @since 4.3.0
 @copyright © 2010-2018 PubNub Inc.
 */
@interface PNEnvelopeInformation : NSObject


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on shard identifier on which event has been stored.
 */
@property (nonatomic, nullable, readonly, copy) NSString *shardIdentifier;

/**
 @brief  Stores reference on numeric representation of enabled debug flags.
 */
@property (nonatomic, nullable, readonly, copy) NSNumber *debugFlags;

/**
 @brief  Stores reference on identifier of client which sent message (set only for publish).
 */
@property (nonatomic, nullable, readonly, copy) NSString *senderIdentifier;

/**
 @brief  Stores reference on sequence nubmer of published messages (clients keep track of their own value 
         locally).
 */
@property (nonatomic, nullable, readonly, copy) NSNumber *sequenceNumber;

/**
 @brief  Stores reference on key under which stored application's subscribe key.
 */
@property (nonatomic, nullable, readonly, copy) NSString *subscribeKey;

/**
 @brief  Stores reference on representation of event replication map (region based).
 */
@property (nonatomic, nullable, readonly, copy) NSNumber *replicationMap;

/**
 @brief  Stores reference on boolean flag which tell whether message should be stored in memory or removed 
         after delivering.
 */
@property (nonatomic, readonly, assign)BOOL shouldEatAfterReading;

/**
 @brief  Stores reference on user-provided (during publish) metadata which will be taken into account by
         filtering algorithms.
 */
@property (nonatomic, nullable, readonly, copy) NSDictionary *metadata;

/**
 @brief  Stores reference information about waypoints.
 */
@property (nonatomic, nullable, readonly, copy) NSArray *waypoints;


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Construct and configure real-time event envelope information instance.

 @param payload  Event envelope dictionary which contain event delivery information.

 @return Configured and ready to use event envelope information instance.

 @since 4.3.0
 */
+ (nonnull instancetype)envelopeInformationWithPayload:(nonnull NSDictionary *)payload;

#pragma mark -


@end
