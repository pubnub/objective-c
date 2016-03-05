//
//  PNConfigurationChiperKeyTests.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 9/16/15.
//
//

import Foundation
import XCTest

class PNConfigurationChiperKeyTests: PNBasicClientCryptTestCase {
    
    let channelString = "9BA810C6-985D-4797-926F-CC81749CC774"
    let cryptedChannelName = "9FA810C6-985D-4797-926F-CC81749CC774"
    
    override func isRecording() -> Bool {
        return false
    }
    
    func testHistoryWithChiperKey() {
        
        let testExpectation = self.expectationWithDescription("history")
        
        self.cryptedClient.historyForChannel(self.channelString) { (result, status) -> Void in
            XCTAssertNotNil(status, "Status shouldn't be nil")
            XCTAssertNil(result, "Results should be nil.")
            
            XCTAssertEqual(status!.statusCode, 400, "Status codes are not equal.")
            XCTAssertEqual(status!.category, PNStatusCategory.PNDecryptionErrorCategory, "Categories are not equal.")
            XCTAssertEqual(status!.operation, PNOperationType.HistoryOperation, "Operations are not equal.");
            
            testExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func testHistoryWithChiperKeyOnlyCryptedMessages() {
        
        let testExpectation = self.expectationWithDescription("history")
        
        self.cryptedClient.historyForChannel(self.cryptedChannelName, withCompletion: { (result, status) -> Void in
            XCTAssertNotNil(result, "Result shouldn't be nil")
            XCTAssertNil(status, "Status should be nil.")
            
            XCTAssertEqual(result!.statusCode, 200, "Status codes are not equal.")
            XCTAssertEqual(result!.operation, PNOperationType.HistoryOperation, "Operations are not equal.");
            
            let messages =             [
            "Test 2",
            "Test 3",
            "Test 1",
            ]
            
            let resultMessages: [String] = result!.data.messages as! [String]
            
            XCTAssertTrue(messages == resultMessages, "Messages are not equal.")
            XCTAssertEqual(NSDecimalNumber(string:"14422371436802799"), result!.data.end, "Messages are not equal.")
            XCTAssertEqual(NSDecimalNumber(string:"14422371428544005"), result!.data.start, "Messages are not equal.")
            
            testExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }

}

