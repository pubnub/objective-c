//
//  PNConfiguration+Test.m
//  UnitTests
//
//  Created by Vadim Osovets on 2/2/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import "PNConfiguration+Test.h"

@implementation PNConfiguration (Test)

+ (PNConfiguration *)defaultTestConfiguration {
    
    return [self configurationForOrigin:kTestPNOriginHost
                             publishKey:kTestPNPublishKey
                            subscribeKey:kTestPNSubscriptionKey
                              secretKey:kTestPNSecretKey
                              cipherKey:kTestPNCipherKey];
}

@end
