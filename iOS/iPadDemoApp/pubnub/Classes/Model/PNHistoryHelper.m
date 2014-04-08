//
//  PNHistoryHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/3/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNHistoryHelper.h"


#pragma mark Public interface implementation

@implementation PNHistoryHelper


#pragma mark - Instance methods

- (NSArray *)channels {
    
    return [PubNub subscribedChannels];
}

- (void)fetchHistoryWithBlock:(PNClientHistoryLoadHandlingBlock)handlerBlock {
    
    // Check whether full history should be loaded or not.
    if (!self.startDate && !self.endDate) {
        
        [PubNub requestFullHistoryForChannel:[PNChannel channelWithName:self.channelName] includingTimeToken:self.shouldFetchTimeTokens
                         withCompletionBlock:handlerBlock];
    }
    else {
        
        PNDate *startDate = self.startDate;
        PNDate *endDate = self.endDate;
        if (self.shouldFetchHistoryByPages) {
            
            endDate = nil;
            startDate = (self.shouldFetchNextHistoryPage ? self.endDate : self.startDate);
        }
        
        [PubNub requestHistoryForChannel:[PNChannel channelWithName:self.channelName] from:startDate
                                      to:endDate limit:self.maximumNumberOfMessages
                          reverseHistory:self.shouldTraverseHistory includingTimeToken:self.shouldFetchTimeTokens
                     withCompletionBlock:handlerBlock];
    }
}

#pragma mark -


@end
