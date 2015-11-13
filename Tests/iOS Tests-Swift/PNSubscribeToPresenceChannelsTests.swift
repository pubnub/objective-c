//
//  PNSubscribeToPresenceChannelsTests.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 10/20/15.
//
//

import UIKit
import XCTest

import Foundation

class PNSubscribeToPresenceChannelsTests: PNBasicSubscribeTestCase {
    
    let subscriptionChannels = ["a"]
    
    override func isRecording() -> Bool {
        return false
    }
    
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
    
    func testSimpleSubscribeToPresenceChannels() {
        
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNStatus) -> (Void) in
            XCTAssertNotNil(status)
            XCTAssertEqual(self.client, client, "Incorrect client")
            XCTAssertFalse(status.error)
            XCTAssertTrue(status.operation == .SubscribeOperation)
            
            let expectedChannels: [String] = ["a-pnpres"]
            
            let subscribedStatus = status as? PNSubscribeStatus
            
            if (subscribedStatus != nil) {
                var resultSet: Set<String> = []
                for element in (subscribedStatus?.subscribedChannels as? [String])! {
                    resultSet.insert(element)
                }
                
                let expectedChannelsSet: Set<String> = Set(expectedChannels)
                
                XCTAssertTrue(resultSet == expectedChannelsSet, "Subscribed channel groups list are not equal")
                
                XCTAssertEqual(subscribedStatus?.currentTimetoken, subscribedStatus?.data.timetoken)
                
                XCTAssertEqual(subscribedStatus?.currentTimetoken, NSDecimalNumber(string : "14356558880455349"))
                XCTAssertEqual(subscribedStatus?.currentTimetoken, subscribedStatus?.data.timetoken)
            }
            
            XCTAssertTrue(status.operation == .SubscribeOperation)
            
            self.subscribeExpectation?.fulfill()
        }
        
        self.PNTest_subscribeToPresenceChannels(self.subscriptionChannels)
    }
}
