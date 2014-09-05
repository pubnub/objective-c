//
//  PNDate.m
//  pubnub
//
//  Created by Sergey Mamontov on 04/01/13.
//
//

#import "PNDate.h"
#import "PNMacro.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub date must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface declaration

@interface PNDate ()


#pragma mark - Properties

@property (nonatomic, strong) NSNumber *timeToken;
@property (nonatomic, strong) NSDate *date;


#pragma mark - Instance methods

- (id)initWithTimeToken:(NSNumber *)timeToken;


@end


#pragma mark - Public interface implementation

@implementation PNDate


#pragma mark - Class methods

+ (instancetype)dateWithDate:(NSDate *)date {
    
    PNDate *dateObject = nil;
    if (date != nil) {
        
        dateObject = [[self alloc] initWithTimeToken:PNTimeTokenFromDate(date)];
    }
    

    return dateObject;
}

+ (instancetype)dateWithToken:(NSNumber *)number {
    
    PNDate *dateObject = nil;
    if (number != nil) {
        
        dateObject = [[self alloc] initWithTimeToken:number];
    }

    
    return dateObject;
}


#pragma mark - Instance methods

- (id)initWithTimeToken:(NSNumber *)timeToken {

    // Check whether initialization successfull or not
    if ((self = [super init])) {

        self.timeToken = timeToken;
    }


    return self;
}

- (NSDate *)date {

    if (_date == nil) {

        _date = [NSDate dateWithTimeIntervalSince1970:PNUnixTimeStampFromTimeToken(self.timeToken)];
    };


    return _date;
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p) <date: %@; time token: %@>", NSStringFromClass([self class]),
                    self, self.date, self.timeToken];
}

- (NSString *)logDescription {
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    return [NSString stringWithFormat:@"<%@|%@>", (self.date ? [self.date performSelector:@selector(logDescription)] : [NSNull null]),
            (self.timeToken ? self.timeToken : [NSNull null])];
    #pragma clang diagnostic pop
}

#pragma mark -


@end
