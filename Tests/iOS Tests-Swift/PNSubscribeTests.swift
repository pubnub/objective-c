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
        
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNSubscribeStatus) -> (Void) in
            
            XCTAssertNotNil(status)
            XCTAssertEqual(self.client, client, "Incorrect client")
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.subscribedChannelGroups.count, 0)
            XCTAssertEqual(status.operation, PNOperationType.UnsubscribeOperation)
            
            self.unsubscribeExpectation.fulfill()
        }
        
        self.PNTest_unsubscribeFromChannels(subscriptionChannels, presense: true)
        
        super.tearDown()
    }
    
    func testSimpleSubscribeWithPresence() {
        
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNSubscribeStatus) -> (Void) in
            XCTAssertNotNil(status)
            XCTAssertEqual(self.client, client, "Incorrect client")
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.category, PNStatusCategory.PNConnectedCategory)
            XCTAssertNil(status.subscribedChannelGroups, "Subscribed channel groups not nil")
            let expectedPresenceSubscriptions: Set<String> = ["a", "a-pnpres"]
            XCTAssertEqual(status.operation, PNOperationType.SubscribeOperation)
            
            XCTAssertEqual(status.currentTimetoken, 14356472220766752)
            XCTAssertEqual(status.currentTimetoken, status.data.timetoken)
        }
        
        self.didReceiveMessageAssertions = {(client: PubNub!, message: PNMessageResult!) -> (Void) in
            
            XCTAssertEqual(self.client, client)
            XCTAssertEqual(client.uuid(), message.uuid);
            XCTAssertNotNil(message.uuid)
            XCTAssertNil(message.authKey)
            XCTAssertEqual(message.statusCode, 200)
            XCTAssertTrue(message.TLSEnabled)
            XCTAssertEqual(message.operation, PNOperationType.SubscribeOperation)
            
            let message: String! = message.data.message as! String
            XCTAssertEqual(message, "***********.... 6988 - 2015-06-29 23:53:42")
            
            self.subscribeExpectation.fulfill()
        }
        
        self.PNTest_subscribeToChannels(subscriptionChannels, presense: true)
    }
    
    func testSimpleSubscribeWithNoPresence() {
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNSubscribeStatus) -> (Void) in
            XCTAssertNotNil(status)
            XCTAssertEqual(self.client, client, "Incorrect client")
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.category, PNStatusCategory.PNConnectedCategory)
            XCTAssertNil(status.subscribedChannelGroups, "Subscribed channel group should be nil")
            let expectedPresenceSubscriptions: Set<String> = ["a"]
            XCTAssertEqual(status.operation, PNOperationType.SubscribeOperation)
            
            XCTAssertEqual(status.currentTimetoken, 14356472196232226)
            XCTAssertEqual(status.currentTimetoken, status.data.timetoken)
        }
        
        self.didReceiveMessageAssertions = {(client: PubNub!, message: PNMessageResult!) -> (Void) in
            
            XCTAssertEqual(self.client, client)
            XCTAssertEqual(client.uuid(), message.uuid);
            XCTAssertNotNil(message.uuid)
            XCTAssertNil(message.authKey)
            XCTAssertEqual(message.statusCode, 200)
            XCTAssertTrue(message.TLSEnabled)
            XCTAssertEqual(message.operation, PNOperationType.SubscribeOperation)
            
            let message: String! = message.data.message as! String
            XCTAssertEqual(message, "**********..... 6987 - 2015-06-29 23:53:40")
            
            self.subscribeExpectation.fulfill()
        }

        self.PNTest_subscribeToChannels(subscriptionChannels, presense: false)
    }
}
