//
//  PNMessagesHistory.h
// 
//
//  Created by moonlight on 1/20/13.
//
//


#import "PNMessagesHistory.h"


#pragma mark Private interface methods

@interface PNMessagesHistory ()


#pragma mark - Properties

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *startTimeToken;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSNumber *endTimeToken;
@property (nonatomic, strong) PNChannel *channel;
@property (nonatomic, strong) NSArray *messages;


#pragma mark - Instance methods

/**
 * Initialize history object with specified criteria
 */
- (id)initHistoryBetween:(NSDate *)startDate
          startTimeToken:(NSNumber *)startTimeToken
              andEndDate:(NSDate *)endDate
            endTimeToken:(NSNumber *)endTimeToken;

#pragma mark -


@end


#pragma mark - Public interface methods

@implementation PNMessagesHistory


#pragma mark - Class methods

+ (instancetype)historyBetween:(NSDate *)startDate
                startTimeToken:(NSNumber *)startTimeToken
                    andEndDate:(NSDate *)endDate
                  endTimeToken:(NSNumber *)endTimeToken {

    return [[self alloc] initHistoryBetween:startDate
                             startTimeToken:startTimeToken
                                 andEndDate:endDate
                               endTimeToken:endTimeToken];
}

#pragma mark - Instance methods

/**
 * Initialize history object with specified criteria
 */
- (id)initHistoryBetween:(NSDate *)startDate
          startTimeToken:(NSNumber *)startTimeToken
              andEndDate:(NSDate *)endDate
            endTimeToken:(NSNumber *)endTimeToken {

    // Check whether intialization was successful or not
    if ((self = [super init])) {

        self.startDate = startDate;
        self.startTimeToken = startTimeToken;
        self.endDate = endDate;
        self.endTimeToken = endTimeToken;
    }


    return self;
}

#pragma mark -


@end