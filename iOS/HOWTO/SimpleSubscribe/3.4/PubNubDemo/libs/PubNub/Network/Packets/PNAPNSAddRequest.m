//
//  PNTimeTokenRequest.m
//  pubnub
//
//  This request object is used to describe
//  server time token retrival request which will
//  be scheduled on requests queue and executed
//  as soon as possible.
//
//
//  Created by Geremy Cohen on 05/08/13.
//
//

#import "PNAPNSAddRequest.h"
#import "PNServiceResponseCallbacks.h"
#import "PubNub+Protected.h"
#import "PNChannel+Protected.h"


#pragma mark Private interface methods

@interface PNAPNSAddRequest ()

#pragma mark - Properties

// Stores reference on device ID

@property(nonatomic, strong) NSString *deviceID;
@property(nonatomic, strong) PNChannel *channel;

@end



#pragma mark Public interface methods

@implementation PNAPNSAddRequest


#pragma mark - Class methods

/**
 * Returns reference on configured history download request
 * which will take into account default values for certain
 * parameters (if passed) to change itself to load full or
 * partial history
 */
+ (PNAPNSAddRequest *)enableAPNSOnChannel:(PNChannel *)channel
                                     forDevice:(NSString *)deviceID {

    return [[[self class] alloc] initForChannel:channel
            forDevice:deviceID];

}

#pragma mark - Instance methods

- (id)initForChannel:(PNChannel *)channel forDevice:(NSString *)deviceID {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.deviceID = deviceID;
        self.channel = channel;
    }

    return self;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.apnsAddCallback;
}

- (NSString *)resourcePath {

    return [NSString stringWithFormat:@"/v1/push/sub-key/%@/devices/%@?add=%@&callback=%@_%@",
                                      [PubNub sharedInstance].configuration.subscriptionKey,
                                      self.deviceID,
                                      self.channel,
                                      [self callbackMethodName],
                                      self.shortIdentifier];
}

#pragma mark -


@end
