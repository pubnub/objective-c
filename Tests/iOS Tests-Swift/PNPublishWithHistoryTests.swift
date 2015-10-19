//
//  PNPublishWithHistoryTests.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 09/22/15.
//
//

import UIKit
import XCTest

class PNPublishWithHistoryTests: PNBasicClientTestCase {
    
    
    let publishChannelString = "9BA810C6-985D-4797-926F-CC81749CC774"
        
    override func isRecording() -> Bool {
        return false
    }
    
    func testSimplePublishWithHistory() {
        self.performVerifiedPublish("test", onChannel: publishChannelString, storeInHistory: true) { (status) -> Void in
            
            XCTAssertNotNil(status)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.operation, PNOperationType.PublishOperation)
            XCTAssertEqual(status.statusCode, 200)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.data.information, "Sent")
            XCTAssertEqual(status.data.timetoken, NSDecimalNumber(string: "14355338601176506"))
        }
    }
    
    func testSimplePublishWithoutHistory() {
        self.performVerifiedPublish("test", onChannel: publishChannelString, storeInHistory: false) { (status) -> Void in
            
            XCTAssertNotNil(status)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.operation, PNOperationType.PublishOperation)
            XCTAssertEqual(status.statusCode, 200)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.data.information, "Sent")
            XCTAssertEqual(status.data.timetoken, NSDecimalNumber(string: "14355338601978693"))
        }
    }
    
    func testPublishWithoutHistoryNilMessage() {
        self.performVerifiedPublish(nil, onChannel: publishChannelString, storeInHistory: false) { (status) -> Void in
            
            XCTAssertNotNil(status)
            XCTAssertTrue(status.category == .PNBadRequestCategory)
            XCTAssertTrue(status.operation == .PublishOperation)
            XCTAssertEqual(status.statusCode, 400)
            XCTAssertTrue(status.error)
            XCTAssertNil(status.data)
        }
    }
    
    func testPublishDictionaryWithHistory() {
        self.performVerifiedPublish(["test" : "test"], onChannel: publishChannelString, storeInHistory: true) { (status) -> Void in
            
            XCTAssertNotNil(status)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.operation, PNOperationType.PublishOperation)
            XCTAssertEqual(status.statusCode, 200)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.data.information, "Sent")
            XCTAssertEqual(status.data.timetoken, NSDecimalNumber(string: "14355338598726743"))
        }
    }
    
    func testPublishDictionaryWithoutHistory() {
        self.performVerifiedPublish(["test" : "test"], onChannel: publishChannelString, storeInHistory: false) { (status) -> Void in
            
            XCTAssertNotNil(status)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.operation, PNOperationType.PublishOperation)
            XCTAssertEqual(status.statusCode, 200)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.data.information, "Sent")
            XCTAssertEqual(status.data.timetoken, NSDecimalNumber(string: "14355338599684259"))
        }
    }
    
    func testPublishToNilChannelWithHistory() {
        self.performVerifiedPublish(["test" : "test"], onChannel: nil, storeInHistory: true) { (status) -> Void in
            
            XCTAssertNotNil(status)
            XCTAssertTrue(status.category == .PNBadRequestCategory)
            XCTAssertTrue(status.operation == .PublishOperation)
            XCTAssertEqual(status.statusCode, 400)
            XCTAssertTrue(status.error)
            XCTAssertNil(status.data)
        }
    }
    
    func testPublishToNilChannelWithoutHistory() {
        self.performVerifiedPublish(["test" : "test"], onChannel: nil, storeInHistory: false) { (status) -> Void in
            
            XCTAssertNotNil(status)
            XCTAssertTrue(status.category == .PNBadRequestCategory)
            XCTAssertTrue(status.operation == .PublishOperation)
            XCTAssertEqual(status.statusCode, 400)
            XCTAssertTrue(status.error)
            XCTAssertNil(status.data)
        }
    }
}

extension PNPublishWithHistoryTests {
    func performVerifiedPublish(message: AnyObject?, onChannel: String?,
        storeInHistory: Bool, withAssertions: PNPublishCompletionBlock) {
            
            let networkExpectation = self.expectationWithDescription("network")
            
            self.client.publish(message, toChannel: onChannel, storeInHistory: storeInHistory) { (status) -> Void in
                withAssertions(status)
                networkExpectation.fulfill()
            }
            waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
                XCTAssertNil(error, "Encountered error with publish call")
            })
    }
}

