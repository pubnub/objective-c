//
//  PNGlobalPresenceHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/3/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNGlobalPresenceHelper.h"


#pragma mark  Private interface declaration

@interface PNGlobalPresenceHelper ()


#pragma mark - Properties

@property (nonatomic, assign) NSUInteger numberOfParticipants;

/**
 Stores reference on composed list of active channels (fetched from retrieved \b PNClient instances).
 */
@property (nonatomic, strong) NSMutableArray *fetchedChannels;

/**
 Stores map of channel-to-clients references.
 */
@property (nonatomic, strong) NSMutableDictionary *mappedParticipants;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNGlobalPresenceHelper


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];
    
    self.fetchedChannels = [NSMutableArray array];
    self.mappedParticipants = [NSMutableDictionary dictionary];
}

- (NSArray *)channels {
    
    return self.fetchedChannels;
}

- (NSArray *)participants {
    
    return [self.mappedParticipants valueForKey:self.currentChannel.name];
}

- (void)fetchPresenceInformationWithBlock:(PNClientParticipantsHandlingBlock)handlerBlock {
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    PNClientParticipantsHandlingBlock requestHandler = ^(PNHereNow *presenceInformation, NSArray *channels, PNError *requestError) {
        
        NSMutableArray *channelsWithPresenceData = [[presenceInformation channels] mutableCopy];
        
        __block NSUInteger totalParticipantsCount = 0;
        [channelsWithPresenceData enumerateObjectsUsingBlock:^(PNChannel *channel, NSUInteger channelIdx,
                                                               BOOL *channelEnumeratorStop) {
            
            totalParticipantsCount += [presenceInformation participantsCountForChannel:channel];
            NSArray *clients = [presenceInformation participantsForChannel:channel];
            [clients enumerateObjectsUsingBlock:^(PNClient *client, NSUInteger clientIdx, BOOL *clientEnumeratorStop) {
                
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
        }];
        weakSelf.numberOfParticipants = totalParticipantsCount;
        
        
        [channelsWithPresenceData sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        weakSelf.fetchedChannels = [channelsWithPresenceData copy];
        if (handlerBlock) {
            
            handlerBlock(presenceInformation, channels, requestError);
        }
    };
    [PubNub requestParticipantsListWithClientIdentifiers:self.shouldFetchParticipantNames
                                             clientState:self.shouldFetchParticipantState
                                      andCompletionBlock:requestHandler];
}

- (void)reset {
    
    self.numberOfParticipants = 0;
    [self.fetchedChannels removeAllObjects];
    [self.mappedParticipants removeAllObjects];
}

#pragma mark -


@end
