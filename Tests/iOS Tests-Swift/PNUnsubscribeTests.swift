//
//  PNUnsubscribeTests.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 10/20/15.
//
//

import UIKit
import XCTest

import Foundation

class PNUnsubscribeTests: PNBasicSubscribeTestCase {
    
    override func isRecording() -> Bool {
        return false
    }
    
    let subscriptionChannels = ["a"]
    
    
    override func setUp() {
        super.setUp()
        
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNStatus) -> (Void) in
            
            XCTAssertEqual(self.client, client)
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
//            XCTAssertTrue(status.category == .PNConnectedCategory)
            
            
            let expectedChannels: [String] = ["a", "a-pnpres"]
            
            let subscribedStatus = status as? PNSubscribeStatus
            
            if (subscribedStatus != nil) {
                var resultSet: Set<String> = []
                for element in (subscribedStatus?.subscribedChannels as? [String])! {
                    resultSet.insert(element)
                }
                
                let expectedChannelsSet: Set<String> = Set(expectedChannels)
                
                XCTAssertTrue(resultSet == expectedChannelsSet, "Subscribed channel groups list are not equal")
                
                XCTAssertEqual(subscribedStatus?.currentTimetoken, subscribedStatus?.data.timetoken)
                
                
                XCTAssertEqual(subscribedStatus?.currentTimetoken, NSDecimalNumber(string : "14356475647691168"))
                XCTAssertEqual(subscribedStatus?.currentTimetoken, subscribedStatus?.data.timetoken)
            }
            
            XCTAssertTrue(status.operation == .SubscribeOperation)
            
            self.subscribeExpectation.fulfill()
        }
        
        // TODO: investimate why it is not called
        
        self.didReceiveMessageAssertions = {(client: PubNub!, message: PNMessageResult!) -> (Void) in
            
            XCTAssertEqual(self.client, client)
            XCTAssertEqual(client.uuid(), message.uuid)
            XCTAssertNotNil(message.uuid)
            XCTAssertNil(message.authKey)
            XCTAssertEqual(message.statusCode, 200)
            XCTAssertTrue(message.TLSEnabled)
            XCTAssertTrue(message.operation == .SubscribeOperation)
            XCTAssertEqual(message.data.message as? String, "****........... 7161 - 2015-06-29 23:59:25")
        };
        
        self.PNTest_subscribeToChannels(self.subscriptionChannels, presense: true)
    }
    
    func testUnsubscribeWithPresence() {
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNStatus) -> (Void) in
            
            XCTAssertNotNil(client)
            XCTAssertNotNil(status)
            XCTAssertEqual(self.client, client)
//            XCTAssertTrue(status.category == .PNDisconnectedCategory)
            XCTAssertFalse(status.error)
        //    XCTAssertEqual(status.statusCode, 200)
//            XCTAssertTrue(status.operation == .UnsubscribeOperation)
            self.unsubscribeExpectation.fulfill()
        }
        
        self.PNTest_unsubscribeFromChannels(self.subscriptionChannels, presense: true)
    }
}
