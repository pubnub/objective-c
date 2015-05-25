//
//  PNPublishTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/18/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>
#import "TestConfigurator.h"

@interface PNPublishTests : XCTestCase

@end

@implementation PNPublishTests  {
    
    PubNub *_pubNub;
    BOOL _isTestError;
    NSString *_testChannel;
    NSString *_testMessage;
}


- (void)setUp {
    
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:[[TestConfigurator shared] mainPubKey] andSubscribeKey:[[TestConfigurator shared] mainSubKey]];
    _pubNub.uuid = @"testUUID";
    _testChannel = @"testChannel";
    _testMessage = [self randomStringWithLength:10];
}

- (void)tearDown {
    
    _pubNub =nil;
    [super tearDown];
}

#warning PNResult *result

- (void)testPublishWithStoryInHistory {

    // Sending  message with story in history
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message"];

    [_pubNub publish:_testMessage toChannel:_testChannel storeInHistory:YES withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during publishing %@", status.data);
            _isTestError = YES;
        }
        [_publishExpectation fulfill];
    }];
    
    // Checking result
    NSString *savedMessage = [[self historyForChannel:_testChannel] lastObject];
    XCTAssertEqualObjects(_testMessage, savedMessage, @"Error, test-message: %@, saved-message: %@", _testMessage, savedMessage);
}

- (void)testPublishWithoutStoryInHistory {
    
    // Sending  message without story in history
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message"];
    
    [_pubNub publish:_testMessage toChannel:_testChannel storeInHistory:NO withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during publishing %@", status.data);
            _isTestError = YES;
        }
        [_publishExpectation fulfill];
    }];
    
    // Checking result
    NSString *savedMessage = [[self historyForChannel:_testChannel] lastObject];
    XCTAssertFalse([_testMessage isEqual:savedMessage], @"Error, test-message: %@, saved-message: %@", _testMessage, savedMessage);
}

#pragma mark - Private methods

- (NSArray *)historyForChannel:(NSString *)channelName {
    
    XCTestExpectation *_getHistoryExpectation = [self expectationWithDescription:@"Getting history"];
    __block NSMutableArray *messages = nil;
    
    [_pubNub historyForChannel:channelName withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting history %@", status.data);
        } else {
            
            NSArray *dictionariesWithMessage = (NSArray *)[result.data objectForKey:@"messages"];
            messages = [NSMutableArray new];
            
            for (NSDictionary *dic in dictionariesWithMessage) {
                
                [messages addObject:[dic objectForKey:@"message"]];
            }
        }
        [_getHistoryExpectation fulfill];
    }];
    
    // Waiting for result
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
        }
    }];
    
    return messages;
}

-(NSString *)randomStringWithLength:(int)length {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i=0; i<length; i++) {
        
        [randomString appendFormat: @"%C",[letters characterAtIndex:(NSUInteger)arc4random_uniform((u_int32_t)[letters length])]];
    }
    return randomString;
}

@end
