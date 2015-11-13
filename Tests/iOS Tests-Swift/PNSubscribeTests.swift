//
//  PNSubscribeTests.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 8/17/15.
//
//

import UIKit
import XCTest

import Foundation

class PNSubscribeTests: PNBasicSubscribeTestCase {
    
    override func isRecording() -> Bool {
        return false
    }
    
    let subscriptionChannels = ["a"]
    
    override func tearDown() {
        
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNStatus) -> (Void) in
            
            XCTAssertNotNil(status)
            XCTAssertEqual(self.client, client, "Incorrect client")
            XCTAssertFalse(status.error)
            
            let subscribedStatus = status as? PNSubscribeStatus
            
            if (subscribedStatus != nil) {
                XCTAssertEqual(subscribedStatus?.subscribedChannelGroups.count, 0)
            } else {
                // TODO: investigate me
//                XCTFail("Unexpected status")
            }

//            XCTAssertTrue(status.category == .UnsubscribeOperation)
            
            self.unsubscribeExpectation.fulfill()
        }
        
        self.PNTest_unsubscribeFromChannels(subscriptionChannels, presense: true)
        
        super.tearDown()
    }
    
    func testSimpleSubscribeWithPresence() {
        
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNStatus) -> (Void) in
            XCTAssertNotNil(status)
            XCTAssertEqual(self.client, client, "Incorrect client")
            XCTAssertFalse(status.error)
            XCTAssertTrue(status.operation == .SubscribeOperation)
            
            let subscribedStatus = status as? PNSubscribeStatus
            
            if (subscribedStatus != nil) {
                XCTAssertNil(subscribedStatus?.subscribedChannelGroups, "Subscribed channel groups not nil")
                XCTAssertEqual(subscribedStatus?.currentTimetoken, NSDecimalNumber(string : "14356472220766752"))
                XCTAssertEqual(subscribedStatus?.currentTimetoken, subscribedStatus?.data.timetoken)
            }
            
            XCTAssertTrue(status.operation == .SubscribeOperation)
            
            self.subscribeExpectation?.fulfill()
        }

// TODO: investigate different behaviour from Obj-C method.
// in this test we didn't call this assertions at all
        /*
        self.didReceiveMessageAssertions = {(client: PubNub!, message: PNMessageResult!) -> (Void) in
            
            XCTAssertEqual(self.client, client)
            XCTAssertEqual(client.uuid(), message.uuid);
            XCTAssertNotNil(message.uuid)
            XCTAssertNil(message.authKey)
            XCTAssertEqual(message.statusCode, 200)
            XCTAssertTrue(message.TLSEnabled)
            XCTAssertEqual(message.operation, PNOperationType.SubscribeOperation)
            
            let messageString: String! = message.data.message as! String
            XCTAssertEqual(messageString, "***********.... 6988 - 2015-06-29 23:53:42")
        }
*/
        
        self.PNTest_subscribeToChannels(subscriptionChannels, presense: true)
    }
    
    func testSimpleSubscribeWithNoPresence() {
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNStatus) -> (Void) in
            XCTAssertNotNil(status)
            XCTAssertEqual(self.client, client, "Incorrect client")
            XCTAssertFalse(status.error)
//            XCTAssertTrue(status.category == .PNConnectedCategory)
            let expectedPresenceSubscriptions = ["a"]
            
            let subscribedStatus = status as? PNSubscribeStatus
            
            if (subscribedStatus != nil) {
                XCTAssertEqual(subscribedStatus?.subscribedChannelGroups as! [NSString], expectedPresenceSubscriptions, "Subscribed channel group shouldn't be nil")
            }
            
            XCTAssertTrue(status.operation == .SubscribeOperation)
            
            self.subscribeExpectation?.fulfill()
        }
        
        self.didReceiveMessageAssertions = {(client: PubNub!, message: PNMessageResult!) -> (Void) in
            
            XCTAssertEqual(self.client, client)
            XCTAssertEqual(client.uuid(), message.uuid)
            XCTAssertNotNil(message.uuid)
            XCTAssertNil(message.authKey)
            XCTAssertEqual(message.statusCode, 200)
            
            XCTAssertTrue(message.TLSEnabled)
            XCTAssertEqual(message.operation, PNOperationType.SubscribeOperation)
            
            let message: String! = message.data.message as! String
            XCTAssertEqual(message, "**********..... 6987 - 2015-06-29 23:53:40")
            
            self.subscribeExpectation?.fulfill()
        }

        self.PNTest_subscribeToChannels(subscriptionChannels, presense: false)
    }
}
