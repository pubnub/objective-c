//
//  PNHeartbeatRequest.m
//  pubnub
//
//  Created by Sergey Mamontov on 1/7/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNBaseRequest+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "NSString+PNAddition.h"
#import "PNHeartbeatRequest.h"
#import "PubNub+Protected.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub heartbeat request must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface declaration

@interface PNHeartbeatRequest ()


#pragma mark - Properties

/**
 Stores reference on list of channels for which heartbeat will be performed.
 */
@property (nonatomic, strong) NSArray *channels;

/**
 Stores reference on client identifier for which heartbeat should be sent.
 */
@property (nonatomic, copy) NSString *clientIdentifier;

/**
 Stores reference on state \b NSDictionary instance which should be sent along with acknowledgment that client is
 still active.
 */
@property (nonatomic, strong) NSDictionary *state;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNHeartbeatRequest


#pragma mark - Class methods

+ (PNHeartbeatRequest *)heartbeatRequestForChannel:(PNChannel *)channel withClientState:(NSDictionary *)clientState {

    return [self heartbeatRequestForChannels:@[channel] withClientState:clientState];
}

+ (PNHeartbeatRequest *)heartbeatRequestForChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState {

    return [[self alloc] initWithChannels:channels withClientState:clientState];
}


#pragma mark - Instance methods

- (id)initWithChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = NO;
        self.channels = [NSArray arrayWithArray:channels];
        self.clientIdentifier = [PubNub escapedClientIdentifier];
        self.state = clientState;
    }


    return self;
}

- (NSString *)resourcePath {

    NSString *heartbeatValue = @"";
    if ([PubNub sharedInstance].configuration.presenceHeartbeatTimeout > 0.0f) {
        
        heartbeatValue = [NSString stringWithFormat:@"&heartbeat=%d", [PubNub sharedInstance].configuration.presenceHeartbeatTimeout];
    }

    NSString *state = @"";
    if (self.state) {

        state = [NSString stringWithFormat:@"&state=%@",
                        [[PNJSONSerialization stringFromJSONObject:self.state] percentEscapedString]];
    }

    return [NSString stringWithFormat:@"/v2/presence/sub-key/%@/channel/%@/heartbeat?uuid=%@%@%@%@&pnsdk=%@",
                                      [[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString],
                                      [[self.channels valueForKey:@"escapedName"] componentsJoinedByString:@","],
                                      self.clientIdentifier, state, heartbeatValue,
                                      ([self authorizationField] ? [NSString stringWithFormat:@"&%@", [self authorizationField]] : @""),
                                      [self clientInformationField]];
}

- (NSString *)debugResourcePath {

    NSMutableArray *resourcePathComponents = [[[self resourcePath] componentsSeparatedByString:@"/"] mutableCopy];
    [resourcePathComponents replaceObjectAtIndex:4 withObject:PNObfuscateString([[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString])];

    return [resourcePathComponents componentsJoinedByString:@"/"];
}

#pragma mark -


@end
