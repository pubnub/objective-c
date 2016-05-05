//
//  XCTestCase+PNClientState.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 5/5/16.
//
//

#import "XCTestCase+PNClientState.h"

@implementation XCTestCase (PNClientState)

- (PNSetStateCompletionBlock)PN_successfulSetClientState:(NSDictionary *)state {
    __block XCTestExpectation *setClientStateExpectation = [self expectationWithDescription:@"set client state expecation"];
    return ^void (PNClientStateUpdateStatus *status) {
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNSetStateOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertEqualObjects(status.data.state, state);
        [setClientStateExpectation fulfill];
    };
}

@end
