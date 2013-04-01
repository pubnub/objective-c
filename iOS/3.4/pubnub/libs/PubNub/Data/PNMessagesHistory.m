//
//  PNMessagesHistory.h
// 
//
//  Created by moonlight on 1/20/13.
//
//


#import "PNMessagesHistory.h"
#import "PNDate.h"


#pragma mark Private interface methods

@interface PNMessagesHistory ()


#pragma mark - Properties

@property (nonatomic, strong) PNDate *startDate;
@property (nonatomic, strong) PNDate *endDate;
@property (nonatomic, strong) PNChannel *channel;
@property (nonatomic, strong) NSArray *messages;


#pragma mark - Instance methods

/**
 * Initialize history object with specified criteria
 */
- (id)initHistoryBetween:(PNDate *)startDate andEndDate:(PNDate *)endDate;

#pragma mark -


@end


#pragma mark - Public interface methods

@implementation PNMessagesHistory


#pragma mark - Class methods

+ (instancetype)historyBetween:(PNDate *)startDate andEndDate:(PNDate *)endDate; {

    return [[self alloc] initHistoryBetween:startDate andEndDate:endDate];
}

#pragma mark - Instance methods

/**
 * Initialize history object with specified criteria
 */
- (id)initHistoryBetween:(PNDate *)startDate andEndDate:(PNDate *)endDate {

    // Check whether intialization was successful or not
    if ((self = [super init])) {

        self.startDate = startDate;
        self.endDate = endDate;
    }


    return self;
}

#pragma mark -


@end