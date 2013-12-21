//
//  PNMessagesHistory.h
// 
//
//  Created by moonlight on 1/20/13.
//
//


#import "PNMessagesHistory.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub messages history must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


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
