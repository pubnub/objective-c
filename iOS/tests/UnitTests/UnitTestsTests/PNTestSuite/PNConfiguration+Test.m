//
//  PNConfiguration+Test.m
//  UnitTests
//
//  Created by Vadim Osovets on 2/2/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import "PNConfiguration+Test.h"

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
