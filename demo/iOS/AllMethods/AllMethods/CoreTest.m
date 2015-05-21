//
//  CoreTest.m
//  AllMethods
//
//  Created by Vadim Osovets on 5/18/15.
//  Copyright (c) 2015 PubNub Ltd. All rights reserved.
//

#import "CoreTest.h"
#import "PubNub+Core.h"
#import "TestConfigurator.h"

// We use time request only to check that confirugation is working properly.
#import "PubNub+Time.h"
#import "PNResult.h"
#import "PNStatus.h"

@implementation CoreTest {
    PubNub *_client;
}

- (void)run {

    [super run];
    
    // simple configuration
    _client = [PubNub clientWithPublishKey:[[TestConfigurator shared] mainPubKey] andSubscribeKey:[[TestConfigurator shared] mainSubKey]];
    
    [_client timeWithCompletion:^(PNResult *result, PNStatus *status) {
        if (result) {
            
            NSLog(@"Time token: %@", result.data);
        }
        else {
            NSLog(@"Request failed: %@", status);
            self.isFailed = YES;
        }
        
        if (self.isFailed) {
            [self.delegate test:self
            finishedWithSuccess:!self.isFailed];
            
            [self teardown];
        } else {
            _client.cipherKey = @"testkey";
            [_client commitConfiguration:^{
                [_client timeWithCompletion:^(PNResult *result, PNStatus *status) {
                    if (result) {
                        
                        NSLog(@"Time token: %@", result.data);
                    }
                    else {
                        NSLog(@"Request failed: %@", status);
                        self.isFailed = YES;
                    }

                    [self.delegate test:self
                    finishedWithSuccess:!self.isFailed];
                    
                    [self teardown];
                }];
            }];
        }
    }];
}

@end
