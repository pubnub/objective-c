#import <PubNub/PNSubscribeEventData.h>
#import <PubNub/PNSubscribeCursorData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General real-time subscription update private extension.
@interface PNSubscribeEventData ()


#pragma mark - Properties

/// User-defined (local) `publish` time.
@property(strong, nullable, nonatomic, readonly) PNSubscribeCursorData *userTimetoken;

/// Event `publish` time.
///
/// This is the time when message has been received by **PubNub** network.
@property(strong, nonatomic, readonly) PNSubscribeCursorData *publishTimetoken;

/// Identifier of client which sent message (set only for publish).
@property(strong, nullable, nonatomic, readonly) NSString *senderIdentifier;

/// Sequence number of published messages (clients keep track of their own value locally).
@property(strong, nullable, nonatomic, readonly) NSNumber *sequenceNumber;

/// Shard number on which the event has been stored.
@property(strong, nonatomic, readonly) NSString *shardIdentifier;

/// Unique payload message finerprint.
@property(strong, nullable, nonatomic) NSString *pnFingerprint;

/// PubNub defined event type.
@property(strong, nullable, nonatomic) NSNumber *messageType;

/// A numeric representation of enabled debug flags.
@property(strong, nonatomic, readonly) NSNumber *debugFlags;

/// Stores reference on **PubNub** server region identifier (which generated `timetoken` value).
@property (nonatomic, readonly) NSNumber *region;


#pragma mark - Misc

/// Serialize subscribe event data object.
///
/// - Returns: Subscribe event object data represented as `NSDictionary`.
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
