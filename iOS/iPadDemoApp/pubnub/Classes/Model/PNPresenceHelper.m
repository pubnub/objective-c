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
@property (nonatomic, strong) PNChannel *channel;

/**
 Reference on client identifier for which presence information can be pulled out.
 */
@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, assign, getter = shouldFetchIdentifiers) BOOL fetchIdentifiers;
@property (nonatomic, assign, getter = shouldFetchState) BOOL fetchState;

/**
 Array may include list of participants or list of channels on which concrete client subscribed at this moment.
 */
@property (nonatomic, strong) NSArray *fetchedData;


#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNPresenceHelper


#pragma mark - Instance methods

- (void)configureForChannel:(id)channel clientIdentifier:(NSString *)identifier
           fetchIdentifiers:(BOOL)shouldFetchIdentifiers fetchState:(BOOL)shouldFetchState {
    
    if (channel) {
        
        if ([channel isKindOfClass:[NSString class]]) {
            
            channel = [PNChannel channelWithName:channel];
        }
        
        self.channel = channel;
    }
    
    self.identifier = identifier;
    self.fetchIdentifiers = shouldFetchIdentifiers;
    self.fetchState = shouldFetchState;
}

- (void)fetchPresenceInformationWithBlock:(PNClientParticipantsHandlingBlock)handlerBlock {
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
        
    PNClientParticipantsHandlingBlock presenceHandlingBlock = ^(NSArray *participants, PNChannel *channel, PNError *requestError) {
        
        if (!requestError) {
            
            weakSelf.fetchedData = participants;
        }
        
        if (handlerBlock) {
            
            ((PNClientParticipantsHandlingBlock)handlerBlock)(participants, channel, requestError);
        }
    };
        
    [PubNub requestParticipantsListForChannel:self.channel clientIdentifiersRequired:self.shouldFetchIdentifiers
                                  clientState:self.shouldFetchState withCompletionBlock:presenceHandlingBlock];
}

- (NSArray *)data {
    
    return self.fetchedData;
}

#pragma mark -


@end
