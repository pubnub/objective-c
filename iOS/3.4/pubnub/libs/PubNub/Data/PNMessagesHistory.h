//
//  PNMessagesHistory.h
// 
//
//  Created by moonlight on 1/20/13.
//
//


#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNChannel;


@interface PNMessagesHistory : NSObject


#pragma mark - Properties

// Stores reference on history time frame start date
@property (nonatomic, readonly, strong) NSDate *startDate;

// Stores reference on history time frame start time token
@property (nonatomic, readonly, strong) NSNumber *startTimeToken;

// Stores reference on history time frame end date
@property (nonatomic, readonly, strong) NSDate *endDate;

// Stores reference on history time frame end time token
@property (nonatomic, readonly, strong) NSNumber *endTimeToken;

// Store reference on channel for which history has been
// downloaded
@property (nonatomic, readonly, strong) PNChannel *channel;

// Stores reference on list of messages which has been downloaded
@property (nonatomic, readonly, strong) NSArray *messages;

#pragma mark -


@end