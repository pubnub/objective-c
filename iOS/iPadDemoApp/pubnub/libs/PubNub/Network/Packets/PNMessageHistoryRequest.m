//
//  PNMessageHistoryRequest.h
// 
//
//  Created by moonlight on 1/20/13.
//
//


#import "PNMessageHistoryRequest.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "PNChannel+Protected.h"
#import "NSString+PNAddition.h"
#import "PNConfiguration.h"
#import "PNMacro.h"
#import "PNDate.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub messages history request must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNMessageHistoryRequest ()


#pragma mark - Properties

// Stores reference on channel for which history should
// be pulled out
@property (nonatomic, strong) PNChannel *channel;

// Stores reference on history time frame start/end dates (time tokens)
@property (nonatomic, strong) PNDate *startDate;
@property (nonatomic, strong) PNDate *endDate;

// Stores reference on maximum number of messages which
// should be returned from backend
@property (nonatomic, assign) NSUInteger limit;

// Stores reference on whether messages should revert
// their order in response or not
@property (nonatomic, assign, getter = shouldRevertMessages) BOOL revertMessages;

/**
 Stores whether response should include messages times stamp or not.
 */
@property (nonatomic, assign, getter = shouldIncludeTimeToken) BOOL includeTimeToken;

@property (nonatomic, copy) NSString *subscriptionKey;


@end


#pragma mark - Public interface methods

@implementation PNMessageHistoryRequest


#pragma mark - Class methods

+ (PNMessageHistoryRequest *)messageHistoryRequestForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                                                       limit:(NSUInteger)limit reverseHistory:(BOOL)shouldReverseMessagesInResponse
                                          includingTimeToken:(BOOL)shouldIncludeTimeToken {

    return [[[self class] alloc] initForChannel:channel from:startDate to:endDate limit:limit
                                 reverseHistory:shouldReverseMessagesInResponse
                             includingTimeToken:shouldIncludeTimeToken];
}


#pragma mark - Instance methods

- (id)initForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
      reverseHistory:(BOOL)shouldReverseMessagesInResponse includingTimeToken:(BOOL)shouldIncludeTimeToken {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.channel = channel;
        self.startDate = startDate;
        self.endDate = endDate;
        self.limit = limit;
        self.includeTimeToken = shouldIncludeTimeToken;
        self.revertMessages = shouldReverseMessagesInResponse;
    }


    return self;
}

- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier {
    
    [super finalizeWithConfiguration:configuration clientIdentifier:clientIdentifier];
    
    self.subscriptionKey = configuration.subscriptionKey;
    self.clientIdentifier = clientIdentifier;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.messageHistoryCallback;
}

- (NSString *)resourcePath {

    // Composing parameters list
    NSMutableString *parameters = [NSMutableString stringWithFormat:@"?callback=%@_%@", [self callbackMethodName],
                                                                    self.shortIdentifier];

    // Swap dates if user specified them in wrong order
    if (self.startDate && self.endDate && [self.endDate.date compare:self.startDate.date] == NSOrderedAscending) {

        PNDate *date = self.startDate;
        self.startDate = self.endDate;
        self.endDate = date;
    }

    // Checking whether user specified start/end date(s) which can be used
    // to set message history time frame or not
    if (self.startDate) {

        [parameters appendFormat:@"&start=%@", PNStringFromUnsignedLongLongNumber(self.startDate.timeToken)];
    }
    if (self.endDate) {

        [parameters appendFormat:@"&end=%@", PNStringFromUnsignedLongLongNumber(self.endDate.timeToken)];
    }

    // Check whether user specified limit or not
    self.limit = self.limit > 0 ? self.limit : 100;
    [parameters appendFormat:@"&count=%ld", (unsigned long)self.limit];
    [parameters appendFormat:@"&reverse=%@", self.shouldRevertMessages?@"true":@"false"];
    [parameters appendFormat:@"&include_token=%@", self.shouldIncludeTimeToken?@"true":@"false"];


    return [NSString stringWithFormat:@"/v2/history/sub-key/%@/channel/%@%@%@&pnsdk=%@",
                    [self.subscriptionKey pn_percentEscapedString], [self.channel escapedName],
                    parameters, ([self authorizationField]?[NSString stringWithFormat:@"&%@", [self authorizationField]]:@""),
                    [self clientInformationField]];
}

- (NSString *)debugResourcePath {
    
    NSString *subscriptionKey = [self.subscriptionKey pn_percentEscapedString];
    return [[self resourcePath] stringByReplacingOccurrencesOfString:subscriptionKey withString:PNObfuscateString(subscriptionKey)];
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@|%@>", NSStringFromClass([self class]), [self debugResourcePath]];
}

#pragma mark -


@end
