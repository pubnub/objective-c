//
//  PNPublishTests.swift
//  PubNub Tests
//
//  Created by Jordan Zucker on 7/28/15.
//
//

import UIKit
import XCTest

class PNPublishTests: PNBasicClientTestCase {

    override func isRecording() -> Bool {
        return false
    }
    
    let publishTestsChannelName = "2EC925F0-B996-47A4-AF54-A605E1A9AEBA"
    
    func testSimplePublish() {
        self.performVerifiedPublish("test", onChannel: publishTestsChannelName) { (status) -> Void in
            XCTAssertNotNil(status)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.operation, PNOperationType.PublishOperation)
            XCTAssertEqual(status.statusCode, 200)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.data.information, "Sent")
            XCTAssertEqual(status.data.timetoken, NSNumber(longLong: 14355311066264140))
        }
    }
    
    func testPublishDictionary() {
        self.performVerifiedPublish(["test" : "test"], onChannel: publishTestsChannelName) { (status) -> Void in
            XCTAssertNotNil(status)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.operation, PNOperationType.PublishOperation)
            XCTAssertEqual(status.statusCode, 200)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.data.information, "Sent")
            XCTAssertEqual(status.data.timetoken, NSNumber(longLong: 14355311062532489))
        }
    }

}

extension PNPublishTests {
    func performVerifiedPublish(message: AnyObject, onChannel:String, withAssertions: PNPublishCompletionBlock) {
        let networkExpectation = self.expectationWithDescription("network")
        client.publish(message, toChannel: onChannel) { (status) -> Void in
            withAssertions(status)
            networkExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
}
