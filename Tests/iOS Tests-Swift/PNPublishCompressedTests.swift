//
//  PNPublishCompressedTests.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 09/14/15.
//
//

import UIKit
import XCTest

class PNPublishCompressedTests: PNBasicClientTestCase {
    
    let publishChannelString = "F16CB07C-9F3F-41AA-8A0A-313960F21AAB"
    
    override func isRecording() -> Bool {
        return false
    }
    
    func testSimplePublishCompressed() {
        self.performVerifiedPublish("test", onChannel: self.publishChannelString, compressed: true) { (status: PNPublishStatus!) -> Void in
            
            XCTAssertNotNil(status)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.operation, PNOperationType.PublishOperation)
            XCTAssertEqual(status.statusCode, 200)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.data.information as String, "Sent")
            XCTAssertEqual(status.data.timetoken, NSNumber(longLong:14355315263325276))
        }
    }
    
    func testSimplePublishNotCompressed() {
        self.performVerifiedPublish("test", onChannel: self.publishChannelString, compressed: false) { (status: PNPublishStatus!) -> Void in
            
            XCTAssertNotNil(status)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.operation, PNOperationType.PublishOperation)
            XCTAssertEqual(status.statusCode, 200)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.data.information as String, "Sent")
            XCTAssertEqual(status.data.timetoken, NSNumber(longLong:14355315264254610))
        }
    }
    
    
    func testPublishNilMessageCompressed() {
        
        let localTestExpectation = self.expectationWithDescription("network")
        
        self.client.publish(nil, toChannel:self.publishChannelString, compressed: true) { (status) -> Void in

            XCTAssertNotNil(status)
            XCTAssertEqual(status.category, PNStatusCategory.PNBadRequestCategory)
            XCTAssertEqual(status.operation, PNOperationType.PublishOperation)
            XCTAssertEqual(status.statusCode, 400)
            XCTAssertTrue(status.error)
            XCTAssertNil(status.data)
            
            localTestExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func testPublishNilMessageNotCompressed() {
        
        let networkExpectation = self.expectationWithDescription("network")
        
        self.client.publish(nil, toChannel:self.publishChannelString, compressed: false) { (status) -> Void in
            
            XCTAssertNotNil(status)
            XCTAssertEqual(status.category, PNStatusCategory.PNBadRequestCategory)
            XCTAssertEqual(status.operation, PNOperationType.PublishOperation)
            XCTAssertEqual(status.statusCode, 400)
            XCTAssertTrue(status.error)
            XCTAssertNil(status.data)
            
            networkExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func testPublishDictionaryCompressed() {
        self.performVerifiedPublish(["test" : "test"], onChannel: self.publishChannelString, compressed: true) { (status: PNPublishStatus!) -> Void in
            
            XCTAssertNotNil(status)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.operation, PNOperationType.PublishOperation)
            XCTAssertEqual(status.statusCode, 200)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.data.information as String, "Sent")
            XCTAssertEqual(status.data.timetoken, NSNumber(longLong:14355315261129449))
        }
    }
    
    func testPublishDictionaryNotCompressed() {
        self.performVerifiedPublish(["test" : "test"], onChannel: self.publishChannelString, compressed: false) { (status: PNPublishStatus!) -> Void in
            
            XCTAssertNotNil(status)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.operation, PNOperationType.PublishOperation)
            XCTAssertEqual(status.statusCode, 200)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.data.information as String, "Sent")
            XCTAssertEqual(status.data.timetoken, NSNumber(longLong:14355315262089406))
        }
    }
    
    func testPublishToNilChannelCompressed() {
        
        let networkExpectation = self.expectationWithDescription("network")
        
        self.client.publish(["test" : "test"], toChannel:nil, compressed: true) { (status) -> Void in
            
            XCTAssertNotNil(status)
            XCTAssertEqual(status.category, PNStatusCategory.PNBadRequestCategory)
            XCTAssertEqual(status.operation, PNOperationType.PublishOperation)
            XCTAssertEqual(status.statusCode, 400)
            XCTAssertTrue(status.error)
            XCTAssertNil(status.data)
            
            networkExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func testPublishToNilChanneNotCompressed() {
        
        let networkExpectation = self.expectationWithDescription("network")
        
        self.client.publish(["test" : "test"], toChannel:nil, compressed: false) { (status) -> Void in
            
            XCTAssertNotNil(status)
            XCTAssertEqual(status.category, PNStatusCategory.PNBadRequestCategory)
            XCTAssertEqual(status.operation, PNOperationType.PublishOperation)
            XCTAssertEqual(status.statusCode, 400)
            XCTAssertTrue(status.error)
            XCTAssertNil(status.data)
            
            networkExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
}

extension PNPublishCompressedTests {
    func performVerifiedPublish(message: AnyObject, onChannel:String,
        compressed: Bool, withAssertions: PNPublishCompletionBlock) {
            
            let networkExpectation = self.expectationWithDescription("network")
            
            self.client.publish(message, toChannel: onChannel, compressed: compressed) { (status) -> Void in
                withAssertions(status)
                networkExpectation.fulfill()
            }
            waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
                XCTAssertNil(error, "Encountered error with publish call")
            })
    }
}
