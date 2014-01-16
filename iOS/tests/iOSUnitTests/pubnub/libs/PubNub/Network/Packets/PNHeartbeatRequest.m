//
//  PNHeartbeatRequest.m
//  pubnub
//
//  Created by Sergey Mamontov on 1/7/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNBaseRequest+Protected.h"
#import "PNServiceResponseCallbacks.h"
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

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNHeartbeatRequest


#pragma mark - Class methods

+ (PNHeartbeatRequest *)heartbeatRequestForChannel:(PNChannel *)channel {

    return [self heartbeatRequestForChannels:@[channel]];
}

+ (PNHeartbeatRequest *)heartbeatRequestForChannels:(NSArray *)channels {

    return [[self alloc] initWithChannels:channels];
}


#pragma mark - Instance methods

- (id)initWithChannels:(NSArray *)channels {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = NO;
        self.channels = [NSArray arrayWithArray:channels];
        self.clientIdentifier = [PubNub escapedClientIdentifier];
    }


    return self;
}

- (NSString *)resourcePath {

    return [NSString stringWithFormat:@"/v2/presence/sub-key/%@/channel/%@/heartbeat?uuid=%@%@",
                                      [[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString],
                                      [[self.channels valueForKey:@"escapedName"] componentsJoinedByString:@","],
                                      self.clientIdentifier,
                                      ([self authorizationField]?[NSString stringWithFormat:@"&%@", [self authorizationField]]:@"")];
}

- (NSString *)debugResourcePath {

    NSMutableArray *resourcePathComponents = [[[self resourcePath] componentsSeparatedByString:@"/"] mutableCopy];
    [resourcePathComponents replaceObjectAtIndex:4 withObject:PNObfuscateString([[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString])];

    return [resourcePathComponents componentsJoinedByString:@"/"];
}

#pragma mark -


@end
