//
//  PNConfiguration+Test.m
//  UnitTests
//
//  Created by Vadim Osovets on 2/2/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import "PNConfiguration+Test.h"

// Stores reference on host URL which is used to access PubNub services during testing
static NSString * const kTestPNOriginHost = @"pubsub.pubnub.com";

// Stores reference on keys which is required to establish connection and send packets to it
// Now here we are using Vadim's Keys
// Access Manager is disabled
static NSString * const kTestPNPublishKey = @"pub-c-12b1444d-4535-4c42-a003-d509cc071e09";
static NSString * const kTestPNSubscriptionKey = @"sub-c-6dc508c0-bff0-11e3-a219-02ee2ddab7fe";
static NSString * const kTestPNSecretKey = @"sec-c-YjIzMWEzZmEtYWVlYS00MzMzLTkyZGItNWJkMjRlZGQ4MjAz";

static NSString * const kTestPNCipherKey = @"1234234213432142341234";
static NSString * const kTestPNAuthorizationKey = nil;


// It is keys for an account with 'Access Manager' feature enabled.
static NSString * const kPNPublishKey = @"pub-c-c37b4f44-6eab-4827-9059-3b1c9a4085f6";
static NSString * const kPNSubscriptionKey = @"sub-c-fb5d8de4-3735-11e4-8736-02ee2ddab7fe";
static NSString * const kPNSecretKey = @"sec-c-NDA1YjYyYjktZTA0NS00YmIzLWJmYjQtZjI4MGZmOGY0MzIw";

@implementation PNConfiguration (Test)

+ (PNConfiguration *)defaultTestConfiguration {
    
    return [self configurationForOrigin:kTestPNOriginHost
                             publishKey:kTestPNPublishKey
                            subscribeKey:kTestPNSubscriptionKey
                              secretKey:kTestPNSecretKey
                              cipherKey:kTestPNCipherKey];
}

+ (PNConfiguration *)accessManagerTestConfiguration {
    
    return [self configurationForOrigin:kTestPNOriginHost
                             publishKey:kPNPublishKey
                           subscribeKey:kPNSubscriptionKey
                              secretKey:kPNSecretKey
                              cipherKey:kTestPNCipherKey];
}


@end
