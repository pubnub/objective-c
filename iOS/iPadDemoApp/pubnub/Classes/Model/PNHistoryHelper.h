//
//  PNHistoryHelper.h
//  pubnub
//
//  Created by Sergey Mamontov on 4/3/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - Public interface declaration

@interface PNHistoryHelper : NSObject


#pragma mark - Properties

/**
 Stores reference on target channel name.
 */
@property (nonatomic, copy) NSString *channelName;

/**
 Stores reference on maximum number of messages in response.
 */
@property (nonatomic, assign) NSUInteger maximumNumberOfMessages;

/**
 Stores whether \b PubNub service should return time tokens for message or not.
 */
@property (nonatomic, assign, getter = shouldFetchTimeTokens) BOOL fetchTimeTokens;

/**
 Stores whether older messages should come first in response or not.
 */
@property (nonatomic, assign, getter = shouldTraverseHistory) BOOL traverseHistory;

/**
 Stores whether helper should fetch history using maged mechanism or not.
 */
@property (nonatomic, assign, getter = shouldFetchHistoryByPages) BOOL fetchHistoryByPages;

/**
 Stores whether helper should fetch next page or previous one.
 */
@property (nonatomic, assign, getter = shouldFetchNextHistoryPage) BOOL fetchNextHistoryPage;

/**
 Stores reference on time frame dates (start and end dates).
 */
@property (nonatomic, strong) PNDate *startDate;
@property (nonatomic, strong) PNDate *endDate;


#pragma mark - Instance methods

/**
 Retrieve list of channels on which \b PubNub client subscribed at this moment.
 
 @return List of \b PNChannel instances.
 */
- (NSArray *)channels;

/**
 Retrieve history depending on helper settings.
 
 @param handlerBlock
 Block called during history retrieval process and pass five parametersL messages, channel, start date, end date and error.
 */
- (void)fetchHistoryWithBlock:(PNClientHistoryLoadHandlingBlock)handlerBlock;

#pragma mark -


@end
