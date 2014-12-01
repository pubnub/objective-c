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
#import "NSObject+PNAdditions.h"
#import "NSString+PNAddition.h"
#import "PNHereNow+Protected.h"
#import "PNClient+Protected.h"
#import "PNPrivateImports.h"
#import "PNPresenceEvent.h"
#import "PNLoggerSymbols.h"
#import "PNChannelGroup.h"
#import "PNConstants.h"
#import "PNHelper.h"
#import "PNDate.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub channel must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Static

static NSMutableDictionary *_channelsCache = nil;
static NSObject *_synchronizationObject = nil;

#pragma mark - Private interface methods

@interface PNChannel ()


#pragma mark - Properties

// Channel name
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *updateTimeToken;
@property (nonatomic, strong) PNDate *presenceUpdateDate;
@property (nonatomic, assign) NSUInteger participantsCount;
@property (nonatomic, strong) NSMutableDictionary *participantsList;
@property (nonatomic, assign, getter = isChannelGroup) BOOL channelGroup;
@property (nonatomic, assign, getter = shouldObservePresence) BOOL observePresence;
@property (nonatomic, assign, getter = isAbleToResetTimeToken) BOOL ableToResetTimeToken;
@property (nonatomic, assign, getter = isLinkedWithPresenceObservationChannel)BOOL linkedWithPresenceObservationChannel;


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

+ (void)initialize {
    
    if (self == [PNChannel class]) {
        
        _synchronizationObject = [NSObject new];
        [_synchronizationObject pn_setupPrivateSerialQueueWithIdentifier:@"channel"
                                                             andPriority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
    }
    
    [super initialize];
}

+ (NSArray *)channelsWithNames:(NSArray *)channelsName {

    NSMutableArray *channels = [NSMutableArray arrayWithCapacity:[channelsName count]];

    [channelsName enumerateObjectsUsingBlock:^(NSString *channelName, NSUInteger channelNameIdx,
                                               BOOL *channelNamesEnumerator) {

        PNChannel *channel = [PNChannel channelWithName:channelName];
        if (channel) {

            [channels addObject:channel];
        }
    }];


    return channels;
}

+ (id)channelWithName:(NSString *)channelName {

    id channel = nil;
    if ([PNChannelPresence isPresenceObservingChannelName:channelName]) {

        channel = [PNChannelPresence presenceForChannelWithName:channelName];
    }
    else if ([channelName rangeOfString:@":"].location != NSNotFound) {
        
        channel = [PNChannelGroup channelGroupWithName:channelName];
    }
    else {

        channel = [self channelWithName:channelName shouldObservePresence:NO shouldUpdatePresenceObservingFlag:NO];
    }

    return channel;
}

+ (PNChannel *)channelWithName:(NSString *)channelName shouldObservePresence:(BOOL)observePresence {

    PNChannel *channel = [self channelWithName:channelName shouldObservePresence:observePresence shouldUpdatePresenceObservingFlag:YES];
    channel.linkedWithPresenceObservationChannel = YES;


    return channel;
}

+ (id)              channelWithName:(NSString *)channelName shouldObservePresence:(BOOL)observePresence
  shouldUpdatePresenceObservingFlag:(BOOL)shouldUpdatePresenceObservingFlag {

    PNChannel *channel = [[self channelsCache] valueForKey:channelName];
    if (channel == nil && [channelName length] > 0) {

        channel = [[self alloc] initWithName:channelName];
        [[self channelsCache] setValue:channel forKey:channelName];
    }
    else if ([channelName length] == 0) {

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.channel.nameRequired];
        }];
    }

    if (shouldUpdatePresenceObservingFlag) {

        channel.observePresence = observePresence;
    }


    return channel;
}

+ (void)purgeChannelsCache {

    [_synchronizationObject pn_dispatchBlock:^{

        if ([_channelsCache count] > 0) {

            [_channelsCache removeAllObjects];
        }
    }];
}

+ (void)removeChannelFromCache:(PNChannel *)channel {

    [_synchronizationObject pn_dispatchBlock:^{

        if ([_channelsCache count] > 0 && channel) {

            [_channelsCache removeObjectForKey:channel.name];
        }
    }];
}

+ (NSDictionary *)channelsCache {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _channelsCache = [NSMutableDictionary dictionary];
    });
    
    
    return _channelsCache;
}

+ (NSString *)largestTimetokenFromChannels:(NSArray *)channels {

    NSSortDescriptor *tokenSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updateTimeToken" ascending:YES];
    NSArray *timeTokens = [[channels sortedArrayUsingDescriptors:@[tokenSortDescriptor]] valueForKey:@"updateTimeToken"];

    NSString *token = [timeTokens lastObject];


    return token ? token : @"0";
}


#pragma mark - Instance methods

- (id)initWithName:(NSString *)channelName {
    
    // Check whether initialization was successful or not
    if((self = [super init])) {
        
        [self resetUpdateTimeToken];
        self.ableToResetTimeToken = YES;
		self.updateTimeToken = @"0";
        self.name = channelName;
        self.participantsList = [NSMutableDictionary dictionary];
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

- (PNChannel *)observedChannel {

    return self;
}

- (void)setUpdateTimeToken:(NSString *)updateTimeToken {

    if (![self isTimeTokenChangeLocked]) {

        _updateTimeToken = updateTimeToken;
    }
}

- (void)resetUpdateTimeToken {

    if (![self isTimeTokenChangeLocked]) {

        self.updateTimeToken = @"0";
    }
}

- (BOOL)isTimeTokenChangeLocked {
    
    return !self.isAbleToResetTimeToken;
}

- (void)lockTimeTokenChange {

    self.ableToResetTimeToken = NO;
}

- (void)unlockTimeTokenChange {

    self.ableToResetTimeToken = YES;
}

- (NSArray *)participants {
    
    __block NSArray *participants = nil;
    [_synchronizationObject pn_dispatchBlock:^{

        participants = [self.participantsList allValues];
    }];
    
    
    return participants;
}

- (void)updateWithEvent:(PNPresenceEvent *)event {

    [_synchronizationObject pn_dispatchBlock:^{

        self.participantsCount = event.occupancy;

        // Checking whether someone is joined to channel or not
        if (event.type == PNPresenceEventJoin) {

            event.client.channel = self;
            [self.participantsList setValue:event.client forKey:event.client.identifier];
        }
            // Looks like someone leaved or was kicked by timeout
        else if (event.type == PNPresenceEventLeave || event.type == PNPresenceEventTimeout) {

            [self.participantsList removeObjectForKey:event.client.identifier];
        }

        self.presenceUpdateDate = [PNDate dateWithDate:[NSDate date]];
    }];
}

- (void)updateWithParticipantsList:(NSArray *)participants andCount:(NSUInteger)participantsCount {

    [_synchronizationObject pn_dispatchBlock:^{

        self.presenceUpdateDate = [PNDate dateWithDate:[NSDate date]];
        self.participantsCount = participantsCount;
        self.participantsList = [NSMutableDictionary dictionary];
        [participants enumerateObjectsUsingBlock:^(PNClient *client, NSUInteger clientIdx, BOOL *clientEnumeratorStop) {

            NSString *clientStoreIdentifier = client.identifier;
            if ([client isAnonymous]) {

                client.channel = self;
                clientStoreIdentifier = [PNHelper UUID];
            }
            [self.participantsList setValue:client forKey:clientStoreIdentifier];
        }];
    }];
}

- (NSString *)escapedName {
    
    return [self.name pn_percentEscapedString];
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@(%p) %@", NSStringFromClass([self class]), self, self.name];
}

- (NSString *)logDescription {
    
    return [NSString stringWithFormat:@"<%@>", self.name];
}

- (BOOL)isPresenceObserver {

    return NO;
}

- (void)dealloc {
    
    [_synchronizationObject pn_destroyPrivateDispatchQueue];
    _synchronizationObject = nil;
}

#pragma mark -


@end
