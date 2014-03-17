//
//  PNChannelHistoryParser+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 3/17/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelHistoryParser.h"


#pragma mark Class forward

@class PNMessagesHistory;


#pragma mark - Structures

typedef enum _PNChannelHistoryResponseFields {
    
    /**
     Stores reference on index under which messages list is stored.
     */
    PNChannelHistoryResponseMessagesList,
    
    /**
     Stores reference on index under which start date is stored.
     */
    PNChannelHistoryResponseStartDate,
    
    /**
     Stores reference on index under element end date is stores.
     */
    PNChannelHistoryResponseEndDate,
} PNChannelHistoryResponseFields;


#pragma mark - Private interface methods

@interface PNChannelHistoryParser ()


#pragma mark - Properties

// Stores reference on history data object
@property (nonatomic, strong) PNMessagesHistory *history;

#pragma mark -


@end
