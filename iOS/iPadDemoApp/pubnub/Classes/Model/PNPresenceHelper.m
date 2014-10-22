//
//  PNPresenceHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 3/25/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNPresenceHelper.h"


#pragma mark Private interface declaration

@interface PNPresenceHelper ()


#pragma mark - Properties

/**
 Reference on channel for which presence manipulation can be performed in future.
 */
@property (nonatomic, strong) id <PNChannelProtocol> object;

/**
 Reference on client identifier for which presence information can be pulled out.
 */
@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, assign, getter = shouldFetchForChannelGroup) BOOL fetchForChannelGroup;
@property (nonatomic, assign, getter = shouldFetchIdentifiers) BOOL fetchIdentifiers;
@property (nonatomic, assign, getter = shouldFetchState) BOOL fetchState;
@property (nonatomic, assign) NSUInteger numberOfParticipants;

/**
 Array may include list of participants or list of channels on which concrete client subscribed at this moment.
 */
@property (nonatomic, strong) NSArray *fetchedData;

/**
 Stores reference on composed list of active channels.
 */
@property (nonatomic, strong) NSMutableArray *fetchedChannels;

/**
 Stores map of channel-to-clients references.
 */
@property (nonatomic, strong) NSMutableDictionary *mappedParticipants;


#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNPresenceHelper


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];
    
    self.fetchedChannels = [NSMutableArray array];
    self.mappedParticipants = [NSMutableDictionary dictionary];
}

- (void)configureForObject:(NSString *)objectName namespace:(NSString *)objectNamespace
          clientIdentifier:(NSString *)identifier channelGroup:(BOOL)isChannelGroup
          fetchIdentifiers:(BOOL)shouldFetchIdentifiers fetchState:(BOOL)shouldFetchState {
    
    self.fetchForChannelGroup = isChannelGroup;
    if (objectName) {
        
        if (!self.shouldFetchForChannelGroup) {
            
            self.object = [PNChannel channelWithName:objectName];
        }
        else if (objectName && objectNamespace) {
            
            self.object = [PNChannelGroup channelGroupWithName:objectName inNamespace:objectNamespace];
        }
    }
    
    self.identifier = identifier;
    self.fetchIdentifiers = shouldFetchIdentifiers;
    self.fetchState = shouldFetchState;
}

- (NSArray *)channels {
    
    return self.fetchedChannels;
}

- (NSArray *)participants {
    
    NSArray *participants = self.fetchedData;
    
    if (self.shouldFetchForChannelGroup) {
        
        participants = [self.mappedParticipants valueForKey:self.currentChannel.name];
    }
    
    return participants;
}

- (void)fetchPresenceInformationWithBlock:(PNClientParticipantsHandlingBlock)handlerBlock {
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
        
    PNClientParticipantsHandlingBlock presenceHandlingBlock = ^(PNHereNow *presenceInformation, NSArray *channels, PNError *requestError) {
        
        if (!requestError) {
            
            __block NSUInteger totalParticipantsCount = 0;
            NSMutableArray *participants = [NSMutableArray array];
            @autoreleasepool {
                
                [[presenceInformation channels] enumerateObjectsUsingBlock:^(PNChannel *channel, NSUInteger channelIdx,
                                                                             BOOL *channelEnumeratorStop) {
                    
                    NSUInteger participantsCount = [presenceInformation participantsCountForChannel:channel];
                    totalParticipantsCount += participantsCount;
                    if (participantsCount) {
                        
                        [participants addObjectsFromArray:[presenceInformation participantsForChannel:channel]];
                        
                        if (weakSelf.shouldFetchForChannelGroup) {
                            
                            [participants enumerateObjectsUsingBlock:^(PNClient *client, NSUInteger clientIdx,
                                                                       BOOL *clientEnumeratorStop) {
                                
                                if (client.channel.name) {
                                    
                                    NSMutableArray *participants = [weakSelf.mappedParticipants valueForKey:client.channel.name];
                                    if (!participants) {
                                        
                                        participants = [NSMutableArray array];
                                        [weakSelf.mappedParticipants setValue:participants forKey:client.channel.name];
                                    }
                                    if (![participants containsObject:client]) {
                                        
                                        [participants addObject:client];
                                    }
                                }
                            }];
                        }
                    }
                }];
            }
            
            if (weakSelf.shouldFetchForChannelGroup) {
                
                weakSelf.fetchedChannels = [[presenceInformation channels] mutableCopy];
                [weakSelf.fetchedChannels sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                               ascending:YES]]];
            }
            else {
                
                weakSelf.fetchedData = [participants copy];
            }
            weakSelf.numberOfParticipants = totalParticipantsCount;
        }
        
        if (handlerBlock) {
            
            ((PNClientParticipantsHandlingBlock)handlerBlock)(presenceInformation, channels, requestError);
        }
    };

    [PubNub requestParticipantsListFor:@[self.object] clientIdentifiersRequired:self.shouldFetchIdentifiers
                           clientState:self.shouldFetchState withCompletionBlock:presenceHandlingBlock];
}

- (void)reset {
    
    self.numberOfParticipants = 0;
    [self.fetchedChannels removeAllObjects];
    [self.mappedParticipants removeAllObjects];
}

#pragma mark -


@end
