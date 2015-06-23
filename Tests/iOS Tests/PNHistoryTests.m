//
//  PNHistoryTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/23/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"

@interface PNHistoryTests : PNBasicClientTestCase
@end

@implementation PNHistoryTests

- (BOOL)isRecording {
    return NO;
}

- (void)testHistory {
    XCTestExpectation *historyExpectation = [self expectationWithDescription:@"history"];
    [self.client historyForChannel:@"a" start:@14350904008290302 end:@14350906104420848 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
        XCTAssertNil(status);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.statusCode, 200);
        XCTAssertEqualObjects(result.data.start, @14350904028698810);
        XCTAssertEqualObjects(result.data.end, @14350906104420848);
        XCTAssertEqual(result.operation, PNHistoryOperation);
        // might want to assert message array is exactly equal, for now just get count
        XCTAssertNotNil(result.data.messages);
        XCTAssertEqual(result.data.messages.count, 99);
        NSLog(@"result: %@", result);
        NSLog(@"status: %@", status);
        [historyExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
}

@end
