//
//  PNHereNowRequest.h
// 
//
//  Created by moonlight on 1/22/13.
//
//


#import "PNHereNowRequest.h"
#import "PNChannel+Protected.h"
#import "NSString+PNAddition.h"
#import "PNRequestsImport.h"
#import "PubNub+Protected.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub here now request must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNHereNowRequest ()


#pragma mark - Properties

// Stores reference on channel for which participants list will be requested
@property (nonatomic, strong) PNChannel *channel;

/**
 Stores whether request should fetch client identifiers or just get number of participants.
 */
@property (nonatomic, assign, getter = isClientIdentifiersRequired) BOOL clientIdentifiersRequired;

/**
 Stores whether request should fetch client's state or not.
 */
@property (nonatomic, assign, getter = shouldFetchClientState) BOOL fetchClientState;


@end


@implementation PNHereNowRequest


#pragma mark Class methods

+ (PNHereNowRequest *)whoNowRequestForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                                  clientState:(BOOL)shouldFetchClientState {

    return [[[self class] alloc] initWithChannel:channel clientIdentifiersRequired:isClientIdentifiersRequired
                                     clientState:shouldFetchClientState];
}


#pragma mark - Instance methods

- (id)initWithChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
          clientState:(BOOL)shouldFetchClientState {

    // Check whether initialization was successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.channel = channel;
        self.clientIdentifiersRequired = isClientIdentifiersRequired;
        self.fetchClientState = shouldFetchClientState;
    }


    return self;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.channelParticipantsCallback;
}

- (NSString *)resourcePath {

    return [NSString stringWithFormat:@"/v2/presence/sub-key/%@%@?callback=%@_%@&disable_uuids=%@&state=%@%@&pnsdk=%@",
                                      [[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString],
                                      (self.channel ? [NSString stringWithFormat:@"/channel/%@", [self.channel escapedName]] : @""),
                                      [self callbackMethodName], self.shortIdentifier, (self.isClientIdentifiersRequired ? @"0" : @"1"),
                                      (self.shouldFetchClientState ? @"1" : @"0"),
                                      ([self authorizationField]?[NSString stringWithFormat:@"&%@", [self authorizationField]]:@""),
                                      [self clientInformationField]];
}

- (NSString *)debugResourcePath {

    NSMutableArray *resourcePathComponents = [[[self resourcePath] componentsSeparatedByString:@"/"] mutableCopy];
    [resourcePathComponents replaceObjectAtIndex:4 withObject:PNObfuscateString([[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString])];

    return [resourcePathComponents componentsJoinedByString:@"/"];
}

#pragma mark -


@end
