//
//  PNTempTest.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/21/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

typedef NSString *(^intToString)(NSUInteger parametr);

intToString inlineconventer = ^(NSUInteger parametr) {
    
    return [NSString stringWithFormat:@"%lu", parametr];
};

@interface PNTempTest : XCTestCase

@end

@implementation PNTempTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExampleBlock {
    
//    1
//    NSLog(@"!!!%@", [self intToStrng:5]);

//   2
//    NSString *(^intToString)(NSUInteger) = ^(NSUInteger parametr) {
//        
//        return [NSString stringWithFormat:@"%lu", parametr];
//    };
    
//    NSLog(@"!!!%@", intToString(15));
    
//   3
    
//    NSLog(@"!!!%@", [self convertIntToString:123 blockObject:intToString]);
    
//   4.2
//    NSLog(@"!!!%@", [self convertIntToString:1235 blockObject:inlineconventer]);
    
//
////   5
//    
     NSLog(@"!!!%@", [self convertIntToString:12356 blockObject:^NSString *(NSUInteger parametr) {
         
         return [NSString stringWithFormat:@"%lu", parametr];
     }]);
//
  }
//
////   4.1




//- (NSString *)intToStrng:(NSUInteger)parametr {
//    
//    return [NSString stringWithFormat:@"%lu",parametr];
//}

//   For 3,5
- (NSString *)convertIntToString:(NSUInteger)parametrInteger
                     blockObject:(intToString)parametrBlock {
    sleep(5);
    return parametrBlock(parametrInteger * 2);
}

//   For 4


//- (void)testHistoryForChannel {
//    
//    // Preparing data
//    [self publish:_testMessage toChannel:_testChannel storeInHistory:YES];
//    
//    // Getting history from
//    _messagesFromHistory = [self historyForChannel:_testChannel];
//    
//    // Checking result
//    XCTAssertTrue([_testMessage isEqual:[_messagesFromHistory lastObject]]);
//}

//- (void)testHistory {
//    
//    // Get timetoken until send message
//    XCTestExpectation *timeToken1Expectation = [self expectationWithDescription:@"Get timeToken1"];
//    
//    __block NSNumber *_timetoken1;
//    [_pubNub timeWithCompletion:^(PNResult *result, PNStatus *status) {
//        
//        if (status.isError) {
//            
//            XCTFail(@"Error occurs during getting timetoken %@", status.data);
//            _isTestError = YES;
//        } else {
//            
//            _timetoken1 = [NSNumber numberWithLongLong:[[result.data objectForKey:@"tt"] longLongValue] ];
//        }
//        [timeToken1Expectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
//        
//        if (error) {
//            
//            XCTFail(@"Timeout is fired");
//            _isTestError = YES;
//        }
//    }];
//    
//    if (_isTestError) {
//        
//        return;
//    }
//    
//    // Send message to channel
//    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message"];
//    
//    [_pubNub publish:@"Hello world" toChannel:@"testChannel1" storeInHistory:NO withCompletion:^(PNStatus *status) {
//        
//        if (status.isError) {
//            
//            XCTFail(@"Error occurs during publishing message %@", status.data);
//        }
//        [_publishExpectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
//        
//        if (error) {
//            
//            XCTFail(@"Timeout is fired");
//            _isTestError = YES;
//        }
//    }];
//    
//    if (_isTestError) {
//        
//        return;
//    }
//    
//    // Get timetoken after send message
//    XCTestExpectation *timeToken2Expectation = [self expectationWithDescription:@"Get timeToken2"];
//    
//    __block NSNumber *_timetoken2;
//    [_pubNub timeWithCompletion:^(PNResult *result, PNStatus *status) {
//        
//        if (status.isError) {
//            
//            XCTFail(@"Error occurs during getting timetoken %@", status.data);
//            _isTestError = YES;
//        } else {
//            
//            _timetoken2 = [NSNumber numberWithLongLong:[[result.data objectForKey:@"tt"] longLongValue] ];
//        }
//        [timeToken2Expectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
//        
//        if (error) {
//            
//            XCTFail(@"Timeout is fired");
//            _isTestError = YES;
//        }
//    }];
//    
//    // Get history for channel
//    XCTestExpectation *_getHistoryExpectation = [self expectationWithDescription:@"Getting history"];
//    
//    [_pubNub historyForChannel:@"testChannel1" start:_timetoken1 end:_timetoken2 limit:1 reverse:NO includeTimeToken:YES withCompletion:^(PNResult *result, PNStatus *status) {
//        
//        if (status.isError) {
//            
//            XCTFail(@"Error occurs during getting messages from history %@", status.data);
//        }
//        [_getHistoryExpectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
//        
//        if (error) {
//            
//            XCTFail(@"Timeout is fired");
//            _isTestError = YES;
//        }
//    }];


@end
