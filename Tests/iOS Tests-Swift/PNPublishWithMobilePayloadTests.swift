//
//  PNPublishWithMobilePayloadTests.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 10/20/15.
//
//

import UIKit
import XCTest

class PNPublishWithMobilePayloadTests: PNBasicClientTestCase {
    
    override func isRecording() -> Bool {
        return false
    }
    
    let channelName = "02290046-2F36-43DD-97F0-2F51D925451A"
    
    func testSimplePublishSimpleMobilePushPayload() {
        let payload = ["aps" :
            ["alert" : "You got your emails",
                "badge" : 9,
                "sound" : "bingbong.aiff"],
            "acme 1" : 42]
        
        self.performVerifiedPublish("test",
            onChannel: self.channelName,
            mobilePushPayload: payload,
            storeInHistory: true, compressed: true) { (status: PNPublishStatus!) -> Void in
                XCTAssertNotNil(status)
                XCTAssertTrue(status.category == .PNAcknowledgmentCategory)
                XCTAssertTrue(status.operation == .PublishOperation)
                XCTAssertEqual(status.statusCode, 200)
                XCTAssertFalse(status.error)
                XCTAssertEqual(status.data.information, "Sent")
                XCTAssertEqual(status.data.timetoken, 14355449397087311)
        }
    }
    
    func testSimplePublishNilMobilePushPayload() {
        
        self.performVerifiedPublish("test",
            onChannel: self.channelName,
            mobilePushPayload: nil,
            storeInHistory: true, compressed: true) { (status: PNPublishStatus!) -> Void in
                XCTAssertNotNil(status)
                XCTAssertTrue(status.category == .PNAcknowledgmentCategory)
                XCTAssertTrue(status.operation == .PublishOperation)
                XCTAssertEqual(status.statusCode, 200)
                XCTAssertFalse(status.error)
                XCTAssertEqual(status.data.information, "Sent")
                XCTAssertEqual(status.data.timetoken, 14355449396125368)
        }
    }
    
    func testPublishMobilePayloadNotStoreInHistory() {
        let payload = ["aps" :
            ["alert" : "You got your emails",
                "badge" : 9,
                "sound" : "bingbong.aiff"],
            "acme 1" : 42]
        
        self.performVerifiedPublish("test",
            onChannel: self.channelName,
            mobilePushPayload: payload,
            storeInHistory: false, compressed: true) { (status: PNPublishStatus!) -> Void in
                XCTAssertNotNil(status)
                XCTAssertTrue(status.category == .PNAcknowledgmentCategory)
                XCTAssertTrue(status.operation == .PublishOperation)
                XCTAssertEqual(status.statusCode, 200)
                XCTAssertFalse(status.error)
                XCTAssertEqual(status.data.information, "Sent")
                XCTAssertEqual(status.data.timetoken, 14355449393962620)
        }
    }

    func testPublishMobilePayloadNotStoreInHistoryNotCompressed() {
        let payload = ["aps" :
            ["alert" : "You got your emails",
                "badge" : 9,
                "sound" : "bingbong.aiff"],
            "acme 1" : 42]
        
        self.performVerifiedPublish("test",
            onChannel: self.channelName,
            mobilePushPayload: payload,
            storeInHistory: false, compressed: false) { (status: PNPublishStatus!) -> Void in
                XCTAssertNotNil(status)
                XCTAssertTrue(status.category == .PNAcknowledgmentCategory)
                XCTAssertTrue(status.operation == .PublishOperation)
                XCTAssertEqual(status.statusCode, 200)
                XCTAssertFalse(status.error)
                XCTAssertEqual(status.data.information, "Sent")
                // TODO: investigate me, changes every time
//                XCTAssertEqual(status.data.timetoken, 14453551891858438)
        }
    }
    
    func testPublishMobilePayloadToNillChannnel() {
        let payload = ["aps" :
            ["alert" : "You got your emails",
                "badge" : 9,
                "sound" : "bingbong.aiff"],
            "acme 1" : 42]
        
        self.performVerifiedPublish("test",
            onChannel: nil,
            mobilePushPayload: payload,
            storeInHistory: false, compressed: false) { (status: PNPublishStatus!) -> Void in
                XCTAssertNotNil(status)
                XCTAssertTrue(status.category == .PNBadRequestCategory)
                XCTAssertTrue(status.operation == .PublishOperation)
                XCTAssertEqual(status.statusCode, 400)
                XCTAssertTrue(status.error)
        }
    }
}

extension PNPublishWithMobilePayloadTests {
    func performVerifiedPublish(message: AnyObject,
        onChannel:String!,
        mobilePushPayload : [NSObject : AnyObject]!,
        storeInHistory: Bool,
        compressed: Bool,
        withAssertions: PNPublishCompletionBlock) {
            
        let networkExpectation = self.expectationWithDescription("network")
            
        self.client.publish(message, toChannel: onChannel, mobilePushPayload: mobilePushPayload, storeInHistory: storeInHistory, compressed: compressed) { (status: PNPublishStatus!) -> Void in
            withAssertions(status)
            networkExpectation.fulfill()
        }
            
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
}
