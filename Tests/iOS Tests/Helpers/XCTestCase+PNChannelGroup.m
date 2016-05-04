//
//  XCTestCase+PNChannelGroup.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 5/4/16.
//
//

#import "XCTestCase+PNChannelGroup.h"

@implementation XCTestCase (PNChannelGroup)

- (PNChannelGroupChangeCompletionBlock)PN_channelGroupAdd {
    __block XCTestExpectation *channelGroupAddExpectation = [self expectationWithDescription:@"channel group add expectation"];
    return ^void (PNAcknowledgmentStatus *status) {
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
        [channelGroupAddExpectation fulfill];
    };
}

- (PNChannelGroupChangeCompletionBlock)PN_channelGroupRemoveSomeChannels {
    __block XCTestExpectation *channelGroupRemoveSomeExpectation = [self expectationWithDescription:@"channel group remove some expectation"];
    return ^void (PNAcknowledgmentStatus *status) {
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNRemoveChannelsFromGroupOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
        [channelGroupRemoveSomeExpectation fulfill];
    };
}

- (PNGroupChannelsAuditCompletionBlock)PN_channelGroupAudit  {
    __block XCTestExpectation *channelGroupAuditExpectation = [self expectationWithDescription:@"channel group audit expectation"];
    return ^void (PNChannelGroupChannelsResult *result, PNErrorStatus *status) {
        XCTAssertNotNil(result);
        XCTAssertEqual(result.statusCode, 200);
        XCTAssertEqual(result.operation, PNChannelsForGroupOperation);
        [channelGroupAuditExpectation fulfill];
    };
}

- (PNChannelGroupChangeCompletionBlock)PN_channelGroupRemoveAllChannels {
    __block XCTestExpectation *channelGroupRemoveAllExpectation = [self expectationWithDescription:@"channel group remove all expectation"];
    return ^void (PNAcknowledgmentStatus *status) {
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNRemoveGroupOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
        [channelGroupRemoveAllExpectation fulfill];
    };
}

@end
