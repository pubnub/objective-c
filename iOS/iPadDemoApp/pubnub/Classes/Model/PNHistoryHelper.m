//
//  PNHistoryHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/3/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNHistoryHelper.h"


#pragma mark Private interface declaration

@interface PNHistoryHelper ()


#pragma mark - Properties

/**
 @brief Stores reference on list of filtered channels on which channel subscribed at this moment.
 
 @since 3.7.0
 */
@property (nonatomic,  strong) NSArray *activeChannels;


#pragma mark - Instance methods

/**
 @brief Initialize all required data which is required by helper.
 
 @since 3.7.0
 */
- (void)prepareData;

#pragma mark -


@end


#pragma mark Public interface implementation

@implementation PNHistoryHelper


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward to the super class
    [super awakeFromNib];
    
    [self prepareData];
}

- (void)prepareData {
    
    NSMutableArray *filteredChannels = [[PubNub subscribedObjectsList] mutableCopy];
    
    [[filteredChannels copy] enumerateObjectsUsingBlock:^(id<PNChannelProtocol> object, NSUInteger objectIdx,
                                                          BOOL *objectENumeratorStop) {
        
        BOOL isChannelGroup = ([object isKindOfClass:[PNChannelGroupNamespace class]] ||
                               [object isKindOfClass:[PNChannelGroup class]]);
        if (isChannelGroup) {
            
            [(NSMutableArray *)filteredChannels removeObject:object];
        }
    }];
    
    self.activeChannels = [filteredChannels copy];
}

- (NSArray *)channels {
    
    return self.activeChannels;
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
