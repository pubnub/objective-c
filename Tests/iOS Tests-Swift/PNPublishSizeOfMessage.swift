//
//  PNPublishSizeOfMessage.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 09/15/15.
//
//

import UIKit
import XCTest

extension String {
 
    static func randomStringWithLength (len : Int) -> NSString {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
}

class PNPublishSizeOfMessage: PNBasicClientTestCase {
    
    func testSizeOfMessageToChannel() {
        let channelName = NSUUID().UUIDString
        let message = "test"

        let expectation = self.expectationWithDescription("Completion")
        
        self.client.sizeOfMessage(message,
            toChannel: channelName) { (size: Int) -> Void in
            XCTAssertTrue(abs(size - 376) <= 20)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }

    func testSizeOfMessageToNilChannel() {
        let message = "test"
        
        let expectation = self.expectationWithDescription("Completion")
        
        self.client.sizeOfMessage(message,
            toChannel: nil) { (size: Int) -> Void in
                XCTAssertEqual(size, -1, "Sizes are not equal")
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }

    func testSizeOfMessageStoreInHistory() {
        let message = "test"
        let expectation = self.expectationWithDescription("Completion")
        
        self.client.sizeOfMessage(message, toChannel: nil, storeInHistory: true) { (size: Int) -> Void in
            XCTAssertEqual(size, -1, "Sizes are not equal")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func testSizeOfMessageCompressed() {
        let channelName = NSUUID().UUIDString
        let message = "test"
        
        let expectation = self.expectationWithDescription("Completion")
        
        self.client.sizeOfMessage(message,
            toChannel: channelName, compressed: true) { (size: Int) -> Void in
                XCTAssertTrue(abs(size - 496) <= 20)
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func testSizeOfMessageStoreInHistoryAndCompressed() {
        let channelName = NSUUID().UUIDString
        let message = "test"
        
        let expectation = self.expectationWithDescription("Completion")
        
        self.client.sizeOfMessage(message,
            toChannel: channelName, compressed: true, storeInHistory: true) { (size: Int) -> Void in
                XCTAssertTrue(abs(size - 496) <= 20)
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func testSizeOfMessageStoreInHistoryNotCompressed() {
        let channelName = NSUUID().UUIDString
        let message = "test"
        
        let expectation = self.expectationWithDescription("Completion")
        
        self.client.sizeOfMessage(message,
            toChannel: channelName, compressed: false, storeInHistory: true) { (size: Int) -> Void in
                XCTAssertTrue(abs(size - 386) <= 20)
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }

    func testSizeOfMessageNotStoreInHistoryNotCompressed() {
        let channelName = NSUUID().UUIDString
        let message = "test"
        
        let expectation = self.expectationWithDescription("Completion")
        
        self.client.sizeOfMessage(message,
            toChannel: channelName, compressed: false, storeInHistory: false) { (size: Int) -> Void in
                XCTAssertTrue(abs(size - 386) <= 20)
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func testSizeOfMessageNotStoreInHistoryCompressed() {
        let channelName = NSUUID().UUIDString
        let message = "test"
        
        let expectation = self.expectationWithDescription("Completion")
        
        self.client.sizeOfMessage(message,
            toChannel: channelName, compressed: true, storeInHistory: false) { (size: Int) -> Void in
                XCTAssertTrue(abs(size - 504) <= 20)
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }

    func testSize10kMessageStoreInHistoryCompressed() {
        let channelName = NSUUID().UUIDString
        let message = String.randomStringWithLength(10000)
        
        let expectation = self.expectationWithDescription("Completion")
        
        self.client.sizeOfMessage(message,
            toChannel: channelName, compressed: true, storeInHistory: true) { (size: Int) -> Void in
                XCTAssertTrue(abs(size - 8000) <= 500)
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func testSize100kMessageStoreInHistoryCompressed() {
        let channelName = NSUUID().UUIDString
        let message = String.randomStringWithLength(100000)
        
        let expectation = self.expectationWithDescription("Completion")
        
        self.client.sizeOfMessage(message,
            toChannel: channelName, compressed: true, storeInHistory: true) { (size: Int) -> Void in
                XCTAssertTrue(abs(size - 75000) <= 5000)
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func testSizeDictionaryMessageStoreInHistoryCompressed() {
        let channelName = NSUUID().UUIDString
        let message = ["1": "3", "2": "3"]
        
        let expectation = self.expectationWithDescription("Completion")
        
        self.client.sizeOfMessage(message,
            toChannel: channelName, compressed: true, storeInHistory: true) { (size: Int) -> Void in
                XCTAssertTrue(abs(size - 503) <= 20)
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func testSizeNestedDictionaryMessageStoreInHistoryCompressed() {
        let channelName = NSUUID().UUIDString
        let message = ["1": ["1": ["3": "5"]], "2": "3"]
        
        let expectation = self.expectationWithDescription("Completion")
        
        self.client.sizeOfMessage(message,
            toChannel: channelName, compressed: true, storeInHistory: true) { (size: Int) -> Void in
                XCTAssertTrue(abs(size - 513) <= 20)
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }

    
    func testSizeArrayMessageStoreInHistoryCompressed() {
        let channelName = NSUUID().UUIDString
        let message = ["1", "2", "3", "4"]
        
        let expectation = self.expectationWithDescription("Completion")
        
        self.client.sizeOfMessage(message,
            toChannel: channelName, compressed: true, storeInHistory: true) { (size: Int) -> Void in
                XCTAssertTrue(abs(size - 504) <= 20)
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
}
