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
            
            for (NSDictionary *dictionary in dictionariesWithMessage) {
                
                [messages addObject:[dictionary objectForKey:@"message"]];
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


// Revers doesn't work
- (void)testReversInHistory {
    
    // Preparing data
    NSNumber *startDate = @((unsigned long long)([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]*10000000));
    NSNumber *endDate = @((unsigned long long)([[NSDate date] timeIntervalSince1970]*10000000));
    
    [self publish:@"Hello world 1" toChannel:_testChannel storeInHistory:YES];
    [self publish:@"Hello world 2" toChannel:_testChannel storeInHistory:YES];

    // Getting history from the test channel using reverse
    XCTestExpectation *historyExpectation = [self expectationWithDescription:@"Getting history"];
    __block NSMutableArray *messages;
    
    [_pubNub historyForChannel:_testChannel start:startDate end:endDate limit:2
                       reverse:YES  includeTimeToken:NO withCompletion:^(PNResult *result, PNStatus *status) {
                           
                           if (status.isError) {
                               
                               XCTFail(@"Error occurs during getting messages from history %@", status.data);
                           } else {
                               
                               NSArray *dictionariesWithMessage = (NSArray *)[result.data objectForKey:@"messages"];
                               messages = [NSMutableArray new];
                               
                               for (NSDictionary *dictionary in dictionariesWithMessage) {
                                   
                                   [messages addObject:[dictionary objectForKey:@"message"]];
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
    XCTAssertTrue([messages[0]  isEqualToString:@"Hello world 2"]);
    XCTAssertTrue([messages[1]  isEqualToString:@"Hello world 1"]);
}

// doesn't work
- (void)testHistoryForChannelStartEndDates {
    
    // Preparing data
    _testTimeToken1 = [self timeToken];
    [self publish:_testMessage toChannel:_testChannel storeInHistory:YES];
     _testTimeToken2 = [self timeToken];
    
    // Getting history from the channel between specified timeTokens
    XCTestExpectation *historyExpectation = [self expectationWithDescription:@"Getting history"];
    __block NSMutableArray *messages;
    
    [_pubNub historyForChannel:_testChannel start:_testTimeToken1 end:_testTimeToken2 limit:2
                       reverse:YES  includeTimeToken:NO withCompletion:^(PNResult *result, PNStatus *status) {
                           
                           if (status.isError) {
                               
                               XCTFail(@"Error occurs during getting messages from history %@", status.data);
                           } else {
                               
                               NSArray *dictionariesWithMessage = (NSArray *)[result.data objectForKey:@"messages"];
                               messages = [NSMutableArray new];
                               
                               for (NSDictionary *dictionary in dictionariesWithMessage) {
                                   
                                   [messages addObject:[dictionary objectForKey:@"message"]];
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
    XCTAssertTrue([_testMessage isEqual:messages[0]]);
}

- (void)testTimeTokenInHistory {
    
    // Preparing data
    [self publish:_testMessage toChannel:_testChannel storeInHistory:YES];
    
    NSNumber *startDate = @((unsigned long long)([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]*10000000));
    NSNumber *endDate = @((unsigned long long)([[NSDate date] timeIntervalSince1970]*10000000));
    
    double startTimetoken = [startDate longLongValue];
    double endTimetoken = [endDate longLongValue];

    // Getting history message with timeToken
    XCTestExpectation *historyExpectation = [self expectationWithDescription:@"Getting history"];
    __block NSMutableArray *messages;

    [_pubNub historyForChannel:_testChannel start:startDate end:endDate limit:2
                       reverse:YES includeTimeToken:NO withCompletion:^(PNResult *result, PNStatus *status) {
     
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting messages from history %@", status.data);
        } else {
            
            NSArray *dictionariesWithMessage = (NSArray *)[result.data objectForKey:@"messages"];
            messages = [NSMutableArray new];
            
            for (NSDictionary *dictionary in dictionariesWithMessage) {
                
                [messages addObject:[dictionary objectForKey:@"message"]];
            }
            [historyExpectation fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Checking result
    NSString *message = [messages lastObject];
    
    double historyTimetoken = 0.1;
    XCTAssertTrue(startTimetoken < historyTimetoken < endTimetoken, @"Error");
}

- (void)testDictionaryInHistory {
    
    // Preparing data
    NSDictionary *testDictionary = @{@"Name":@"Sergey", @"Sername":@"Kazanskiy"};
    [self publish:testDictionary toChannel:_testChannel storeInHistory:YES];
    
    // Getting history dictionary-message from the channel
    XCTestExpectation *historyExpectetion = [self expectationWithDescription:@"Getting history"];
    __block NSMutableArray *messages;
    
    [_pubNub historyForChannel:_testChannel withCompletion:^(PNResult *result, PNStatus *status) {
        if (status.isError) {
            XCTFail(@"Error occurs during getting history %@", status.data);
        } else {
            
            NSArray *dictionaryWithMessage = (NSArray *)[result.data objectForKey:@"messages"];
            messages = [NSMutableArray new];
            
            for (NSDictionary *dictionary in dictionaryWithMessage) {
                [messages addObject:[dictionary objectForKey:@"message"]];
            }
            [historyExpectetion fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Checking result
    NSDictionary *resultMessage = [messages lastObject];
    XCTAssertTrue([testDictionary isEqual:resultMessage], @"testDictionary: %@ resultDictionary: %@", testDictionary, resultMessage);
}

- (void)testArrayInHistory {
    
    // Preparing data
    NSArray *testArray = @[@"message 1", @"message 2", @"message 3"];
    [self publish:testArray toChannel:_testChannel storeInHistory:YES];
    
    // Getting history dictionary-message from the channel
    XCTestExpectation *historyExpectetion = [self expectationWithDescription:@"Getting history"];
    __block NSMutableArray *messages;
    
    [_pubNub historyForChannel:_testChannel withCompletion:^(PNResult *result, PNStatus *status) {
        if (status.isError) {
            XCTFail(@"Error occurs during getting history %@", status.data);
        } else {
            
            NSArray *dictionaryWithMessage = (NSArray *)[result.data objectForKey:@"messages"];
            messages = [NSMutableArray new];
            
            for (NSDictionary *dictionary in dictionaryWithMessage) {
                [messages addObject:[dictionary objectForKey:@"message"]];
            }
            [historyExpectetion fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Checking result
    NSArray *resultMessage = [messages lastObject];
    XCTAssertTrue([testArray isEqual:resultMessage], @"testDictionary: %@ resultDictionary: %@", testArray, resultMessage);
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

- (void)publish:(id)message toChannel:(NSString *)channelName storeInHistory:(BOOL)isStore {
    
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

@end
