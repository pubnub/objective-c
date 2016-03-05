/**
 @author Sergey Mamontov
 @since 4.3.0
 @copyright © 2009-15 PubNub Inc.
 */
#import "PNEnvelopeInformation.h"
#import "PNJSON.h"


#pragma mark Structures

/**
 @brief  Describes overall real-time event format.
 */
struct PNEventDebugEnvelopeStructure {
    
    /**
     @brief  Stores reference key under which stored shard identifier on which event has been stored.
     */
    __unsafe_unretained NSString *shardIdentifier;
    
    /**
     @brief  Stores reference key under which stored numeric representation of enabled debug flags.
     */
    __unsafe_unretained NSString *debugFlags;
    
    /**
     @brief  Stores reference on key under which stored identifier of client which sent message
     (set only for publish).
     */
    __unsafe_unretained NSString *senderIdentifier;
    
    /**
     @Brief  Stores reference on key under which stored sequence nubmer of published messages
     (clients keep track of their own value locally).
     */
    __unsafe_unretained NSString *sequenceNumber;
    
    /**
     @brief  Stores reference on key under which stored application's subscribe key.
     */
    __unsafe_unretained NSString *subscribeKey;
    
    /**
     @brief  Stores reference on key under which stored numeric representation of event replication
     map (region based).
     */
    __unsafe_unretained NSString *replicationMap;
    
    /**
     @brief  Stores reference on key under which stored boolean flag which tell whether message
     should be stored in memory or removed after delivering.
     */
    __unsafe_unretained NSString *eatAfterReading;
    
    /**
     @brief  Stores reference on key under which stored user-provided (during publish) metadata
     which will be taken into account by filtering algorithms.
     */
    __unsafe_unretained NSString *metadata;
    
    /**
     @brief  Stores reference on key under which stored information about waypoints.
     */
    __unsafe_unretained NSString *waypoints;
} PNDebugEventEnvelope = {
    .shardIdentifier = @"a",
    .debugFlags = @"f",
    .senderIdentifier = @"i",
    .sequenceNumber = @"s",
    .subscribeKey = @"k",
    .replicationMap = @"r",
    .eatAfterReading = @"ear",
    .metadata = @"u",
    .waypoints = @"w"
};


#pragma mark Private interface declaration

@interface PNEnvelopeInformation ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *shardIdentifier;
@property (nonatomic, copy) NSNumber *debugFlags;
@property (nonatomic, copy) NSString *senderIdentifier;
@property (nonatomic, copy) NSNumber *sequenceNumber;
@property (nonatomic, copy) NSString *subscribeKey;
@property (nonatomic, copy) NSNumber *replicationMap;
@property (nonatomic, copy) NSNumber *eatAfterReading;
@property (nonatomic, copy) NSDictionary *metadata;
@property (nonatomic, copy) NSArray *waypoints;


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize real-time event envelope information instance.
 
 @param payload  Event envelop dictionary which contain event delivery information.
 
 @return Initialized and ready to use event envelope information instance.
 
 @since 4.3.0
 */
- (nonnull instancetype)initWithPayload:(nonnull NSDictionary *)payload;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNEnvelopeInformation


#pragma mark - Initialization and Configuration

+ (nonnull instancetype)envelopeInformationWithPayload:(nonnull NSDictionary *)payload {
    
    return [[self alloc] initWithPayload:payload];
}

- (nonnull instancetype)initWithPayload:(nonnull NSDictionary *)payload {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _shardIdentifier = [payload[PNDebugEventEnvelope.shardIdentifier] copy];
        _debugFlags = [payload[PNDebugEventEnvelope.debugFlags] copy];
        _senderIdentifier = [payload[PNDebugEventEnvelope.senderIdentifier] copy];
        _sequenceNumber = [payload[PNDebugEventEnvelope.sequenceNumber] copy];
        _subscribeKey = [payload[PNDebugEventEnvelope.subscribeKey] copy];
        _replicationMap = [payload[PNDebugEventEnvelope.replicationMap] copy];
        _eatAfterReading = payload[PNDebugEventEnvelope.eatAfterReading];
        _metadata = [payload[PNDebugEventEnvelope.metadata] copy];
        _waypoints = [payload[PNDebugEventEnvelope.waypoints] copy];
    }
    
    return self;
}

- (BOOL)shouldEatAfterReading {
    
    return self.eatAfterReading.boolValue;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    
    return @{@"Shard identifier": (self.shardIdentifier?: @"<null>"), 
             @"Flags": (self.debugFlags?: @"<null>"), 
             @"Client Identifier": (self.senderIdentifier?: @"<null>"),
             @"Sequence number": (self.sequenceNumber?: @"<null>"),
             @"Subscribe key": (self.subscribeKey?: @"<null>"),
             @"Replication map": (self.replicationMap?: @"<null>"),
             @"Eat after reading": (self.eatAfterReading ? (self.shouldEatAfterReading ? @"YES" : @"NO") : @"<null>"),
             @"Metadata": (self.metadata ? [PNJSON JSONStringFrom:self.metadata withError:nil] : @"<null>"),
             @"Waypoints": (self.waypoints ? [PNJSON JSONStringFrom:self.waypoints withError:nil] : @"<null>")};
}

- (NSString *)stringifiedRepresentation {
    
    return [PNJSON JSONStringFrom:[self dictionaryRepresentation] withError:NULL];
}

- (NSString *)debugDescription {
    
    return [[self dictionaryRepresentation] description];
}


#pragma mark -


@end
