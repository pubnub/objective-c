//
//  PNClientChannelsHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/2/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNClientChannelsHelper.h"


#pragma mark Private interface declaration

@interface PNClientChannelsHelper ()


#pragma mark - Properties

/**
 Property will store fetched list of channels for concrete client identifier.
 */
@property (nonatomic, strong) NSArray *fetchedChannels;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNClientChannelsHelper


#pragma mark - Instance methods

- (BOOL)isAbleToProcessRequest {
    
    return self.clientIdentifier && ![self.clientIdentifier pn_isEmpty];
}

- (NSArray *)channels {

    return self.fetchedChannels;
}

- (void)performRequestWithBlock:(PNClientParticipantChannelsHandlingBlock)handlerBlock {
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [PubNub requestParticipantChannelsList:self.clientIdentifier
                       withCompletionBlock:^(NSString *clientIdentifier, NSArray *channels, PNError *requestError) {
                           
                           weakSelf.fetchedChannels = channels;
                           
                           if (handlerBlock) {
                               
                               handlerBlock(clientIdentifier, channels, requestError);
                           }
                       }];
}

#pragma mark -


@end
