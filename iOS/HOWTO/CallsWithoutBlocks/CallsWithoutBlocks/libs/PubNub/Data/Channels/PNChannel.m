//
//  PNChannel.m
//  pubnub
//
//  Represents object which is used to subscribe
//  for channels and presence.
//
//
//  Created by Sergey Mamontov on 12/11/12.
//
//

#import "PNChannel+Protected.h"
#import "PNChannelPresence+Protected.h"
#import "PNHereNow+Protected.h"
#import "NSString+PNAddition.h"
#import "PNPresenceEvent.h"
#import "PNDate.h"


#pragma mark Static

static NSMutableDictionary *_channelsCache = nil;


#pragma mark - Private interface methods

@interface PNChannel ()


#pragma mark - Properties

// Channel name
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *updateTimeToken;
@property (nonatomic, strong) PNDate *presenceUpdateDate;
@property (nonatomic, assign) NSUInteger participantsCount;
@property (nonatomic, strong) NSMutableArray *participantsList;
@property (nonatomic, assign, getter = shouldObservePresence) BOOL observePresence;
@property (nonatomic, assign, getter = isUserDefinedPresenceObservation)BOOL userDefinedPresenceObservation;


#pragma mark - Class methods

+ (NSDictionary *)channelsCache;


#pragma mark - Instance methods

/**
 * Return initialized channel instance with specified name
 * (if name already was used during client connection session
 * when instance will be pulled out from cache).
 */
- (id)initWithName:(NSString *)channelName;


@end


#pragma mark - Public interface methods

@implementation PNChannel


#pragma mark - Class methods

+ (NSArray *)channelsWithNames:(NSArray *)channelsName {

    NSMutableArray *channels = [NSMutableArray arrayWithCapacity:[channelsName count]];

    [channelsName enumerateObjectsUsingBlock:^(NSString *channelName,
                                               NSUInteger channelNameIdx,
                                               BOOL *channelNamesEnumerator) {

        [channels addObject:[PNChannel channelWithName:channelName]];
    }];


    return channels;
}

+ (id)channelWithName:(NSString *)channelName {

    id channel = nil;
    if ([PNChannelPresence isPresenceObservingChannelName:channelName]) {

        channel = [PNChannelPresence presenceForChannelWithName:channelName];
    }
    else {

        channel = [self channelWithName:channelName shouldObservePresence:NO shouldUpdatePresenceObservingFlag:NO];
    }

    return channel;
}

+ (PNChannel *)channelWithName:(NSString *)channelName shouldObservePresence:(BOOL)observePresence {

    PNChannel *channel = [self channelWithName:channelName shouldObservePresence:observePresence shouldUpdatePresenceObservingFlag:YES];
    channel.userDefinedPresenceObservation = NO;


    return channel;
}

+ (id)            channelWithName:(NSString *)channelName
            shouldObservePresence:(BOOL)observePresence
shouldUpdatePresenceObservingFlag:(BOOL)shouldUpdatePresenceObservingFlag {

    PNChannel *channel = [[[self class] channelsCache] valueForKey:channelName];

    if (channel == nil) {

        channel = [[[self class] alloc] initWithName:channelName];
        [[[self class] channelsCache] setValue:channel forKey:channelName];
    }

    if (shouldUpdatePresenceObservingFlag) {

        channel.observePresence = observePresence;
    }


    return channel;
}

+ (void)purgeChannelsCache {
    
    @synchronized(self) {
        
        if([_channelsCache count] > 0) {
            
            [_channelsCache removeAllObjects];
        }
    }
}

+ (NSDictionary *)channelsCache {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _channelsCache = [NSMutableDictionary dictionary];
    });
    
    
    return _channelsCache;
}


#pragma mark - Instance methods

- (id)initWithName:(NSString *)channelName {
    
    // Check whether initialization was successful or not
    if((self = [super init])) {
        
        [self resetUpdateTimeToken];
        self.name = channelName;
        self.participantsList = [NSMutableArray array];
    }
    
    
    return self;
}

- (PNChannelPresence *)presenceObserver {
    
    PNChannelPresence *presence = nil;
    if (self.shouldObservePresence) {
        
        presence = [PNChannelPresence presenceForChannel:self];
    }
    
    
    return presence;
}

- (void)resetUpdateTimeToken {
    
    self.updateTimeToken = @"0";
}

- (NSArray *)participants {
    
    return self.participantsList;
}

- (void)updateWithEvent:(PNPresenceEvent *)event {

    self.participantsCount = event.occupancy;


    // Checking whether someone is joined to channel or not
    if (event.type == PNPresenceEventJoin) {

        [self.participantsList addObject:event.uuid];
    }
    // Looks like someone leaved or was kicked by timeout
    else {

        [self.participantsList removeObject:event.uuid];
    }

    self.presenceUpdateDate = [PNDate dateWithDate:[NSDate date]];
}

- (void)updateWithParticipantsList:(PNHereNow *)hereNow {

    self.presenceUpdateDate = [PNDate dateWithDate:[NSDate date]];
    self.participantsCount = hereNow.participantsCount;
    self.participantsList = [hereNow.participants mutableCopy];
}

- (NSString *)escapedName {
    
    return [self.name percentEscapedString];
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@(%p) %@", NSStringFromClass([self class]), self, self.name];
}

- (BOOL)isPresenceObserver {

    return NO;
}

#pragma mark -


@end
