//
//  PNHistoryTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/18/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "GCDGroup.h"
#import "GCDWrapper.h"

#import "TestConfigurator.h"

@interface PNHistoryTests : XCTestCase

@end

@implementation PNHistoryTests {
    
    PubNub *_pubNub;
    BOOL _isTestError;
    NSNumber *_testTimeToken1;
    NSNumber *_testTimeToken2;
    NSString *_testChannel;
    NSString *_testMessage;
    NSArray *_messagesFromHistory;
    
}


- (void)setUp {
    
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:[[TestConfigurator shared] mainPubKey] andSubscribeKey:[[TestConfigurator shared] mainSubKey]];
    _pubNub.uuid = @"testUUID";
    _testChannel = @"testChannel";
    _testMessage = @"Hello world";
}

- (void)tearDown {
    
    _pubNub =nil;
    [super tearDown];
}


#pragma mark - Tests

- (void)testHistoryForChannels {
    
    // Preparing data
    [self publish:_testMessage toChannel:_testChannel storeInHistory:YES];
    
    // Getting history from channel
    XCTestExpectation *historyExpectation = [self expectationWithDescription:@"Getting history"];
    __block NSMutableArray *messages = nil;
    
    [_pubNub historyForChannel:_testChannel withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting history %@", status.data);
        } else {
            
            NSArray *dictionariesWithMessage = (NSArray *)[result.data objectForKey:@"messages"];
            messages = [NSMutableArray new];
            
            for (NSDictionary *dic in dictionariesWithMessage) {
                
                [messages addObject:[dic objectForKey:@"message"]];
            }
        }
        [historyExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Checking result
    XCTAssertTrue([_testMessage isEqual:[messages lastObject]]);
}


- (void)testHistoryForChannel {
    
    // Preparing data
    [self publish:_testMessage toChannel:_testChannel storeInHistory:YES];
    
    // Getting history from
    _messagesFromHistory = [self historyForChannel:_testChannel];
    
     // Checking result
    XCTAssertTrue([_testMessage isEqual:[_messagesFromHistory lastObject]]);
}

// Revers doesn't work
- (void)testReversInHistory {
    
    // Preparing data
    NSNumber *startDate = @((unsigned long long)([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]*10000000));
    NSNumber *endDate = @((unsigned long long)([[NSDate date] timeIntervalSince1970]*10000000));
    
    [self publish:@"Hello world 1" toChannel:_testChannel storeInHistory:YES];
    [self publish:@"Hello world 2" toChannel:_testChannel storeInHistory:YES];

    // Getting history using revers
    _messagesFromHistory = [self historyForChannel:_testChannel start:startDate end:endDate limit:2 reverse:YES includeTimeToken:NO];
    
    // Checking result
    XCTAssertTrue([_messagesFromHistory[0]  isEqualToString:@"Hello world 2"]);
    XCTAssertTrue([_messagesFromHistory[1]  isEqualToString:@"Hello world 1"]);
}

// doesn't work
- (void)testHistoryForChannelStartEndDates {
    
    // Preparing data
    _testTimeToken1 = [self timeToken];
    
    [self publish:_testMessage toChannel:_testChannel storeInHistory:YES];
    
     _testTimeToken2 = [self timeToken];
    
    // Getting history from start to end
    _messagesFromHistory = [self historyForChannel:_testChannel start:_testTimeToken1 end:_testTimeToken2 limit:1 reverse:NO includeTimeToken:NO];
    
    // Checking result
    XCTAssertTrue([_testMessage isEqual:_messagesFromHistory[0]]);
}

- (void)testTimeTokenInHistory {
    
    // Preparing data
    NSNumber *startDate = @((unsigned long long)([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]*10000000));
    NSNumber *endDate = @((unsigned long long)([[NSDate date] timeIntervalSince1970]*10000000));
    
    
    double startTimetoken = [startDate longLongValue];
    double endTimetoken = [endDate longLongValue];

    // Getting history message with timeToken
    _messagesFromHistory = [self historyForChannel:_testChannel start:startDate end:endDate limit:10 reverse:YES includeTimeToken:YES];
    
    // Checking result
    double historyTimetoken = 0.1;
    XCTAssertTrue(startTimetoken < historyTimetoken < endTimetoken, @"Error");
}


- (void)testDictionaryInHistory {
    
    XCTFail(@"%s: not implemented", __FUNCTION__);
}

- (void)testBigMassageInHistory {
    
    XCTFail(@"%s: not implemented", __FUNCTION__);
}



#pragma mark - Private methods

- (NSNumber *)timeToken {
    
    XCTestExpectation *timeTokenExpectation = [self expectationWithDescription:@"Get timeToken1"];
    
    __block NSNumber *timeToken;
    [_pubNub timeWithCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting timetoken %@", status.data);
            _isTestError = YES;
        } else {
            
            timeToken = [NSNumber numberWithLongLong:[[result.data objectForKey:@"tt"] longLongValue]];
        }
        [timeTokenExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (!_isTestError && timeToken) {
        
        return timeToken;
    }
    return nil;
}

- (void)publish:(NSString *)message toChannel:(NSString *)channelName storeInHistory:(BOOL)isStore {
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message"];
    
    [_pubNub publish:message toChannel:channelName storeInHistory:isStore withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during publishing message %@", status.data);
        }
        [_publishExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        
        return;
    }
}

- (NSArray *)historyForChannel:(NSString *)channelName start:(NSNumber *)startTimeToken end:(NSNumber *)endTimeToken limit:(NSUInteger)numberOfMessages reverse:(BOOL)isReverse includeTimeToken:(BOOL)withTimeToken {
    
    XCTestExpectation *_getHistoryExpectation = [self expectationWithDescription:@"Getting history"];
    __block NSMutableArray *messages;
    
    [_pubNub historyForChannel:channelName start:startTimeToken end:endTimeToken limit:numberOfMessages
                       reverse:isReverse  includeTimeToken:withTimeToken withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting messages from history %@", status.data);
        } else {
            
            NSArray *dictionariesWithMessage = (NSArray *)[result.data objectForKey:@"messages"];
            messages = [NSMutableArray new];
            
            for (NSDictionary *dic in dictionariesWithMessage) {
                
                [messages addObject:[dic objectForKey:@"message"]];
            }
        }
        [_getHistoryExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    return messages;
}

- (NSArray *)historyForChannel:(NSString *)channelName {
    
    XCTestExpectation *_getHistoryExpectation = [self expectationWithDescription:@"Getting history"];
    __block NSMutableArray *messages = nil;
    
    [_pubNub historyForChannel:channelName withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting history %@", status.data);
            _isTestError = YES;
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
            _isTestError = YES;
        }
    }];
    
    return messages;
}

- (void)testHistory {

    // Get timetoken until send message
    XCTestExpectation *timeToken1Expectation = [self expectationWithDescription:@"Get timeToken1"];
    
    __block NSNumber *_timetoken1;
    [_pubNub timeWithCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting timetoken %@", status.data);
            _isTestError = YES;
        } else {
            
            _timetoken1 = [NSNumber numberWithLongLong:[[result.data objectForKey:@"tt"] longLongValue] ];
        }
        [timeToken1Expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        
        return;
    }

    // Send message to channel
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message"];
    
    [_pubNub publish:@"Hello world" toChannel:@"testChannel1" storeInHistory:NO withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during publishing message %@", status.data);
        }
        [_publishExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        
        return;
    }

    // Get timetoken after send message
    XCTestExpectation *timeToken2Expectation = [self expectationWithDescription:@"Get timeToken2"];
    
    __block NSNumber *_timetoken2;
    [_pubNub timeWithCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting timetoken %@", status.data);
            _isTestError = YES;
        } else {
            
            _timetoken2 = [NSNumber numberWithLongLong:[[result.data objectForKey:@"tt"] longLongValue] ];
        }
        [timeToken2Expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];

    // Get history for channel
    XCTestExpectation *_getHistoryExpectation = [self expectationWithDescription:@"Getting history"];

    [_pubNub historyForChannel:@"testChannel1" start:_timetoken1 end:_timetoken2 limit:1 reverse:NO includeTimeToken:YES withCompletion:^(PNResult *result, PNStatus *status) {

        if (status.isError) {
            
            XCTFail(@"Error occurs during getting messages from history %@", status.data);
        }
        [_getHistoryExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
}

@end
