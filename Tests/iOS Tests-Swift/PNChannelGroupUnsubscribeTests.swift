//
//  PNChannelGroupUnsubscribeTests.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 09/02/15.
//
//

import UIKit
import XCTest

class PNChannelGroupUnsubscribeTests: PNBasicSubscribeTestCase {
    
    let groupName = "PNChannelGroupUnsubscribeTests"
    
    override func isRecording() -> Bool {
        return false
    }
    
    lazy var channelGroups: [String] = {
        let groups = [self.groupName]
        return groups
        }()
    
    override func setUp() {
        super.setUp()
        
        self.performVerifiedRemoveAllChannelsFromGroup(self.groupName, assertions: nil)
        
        self.performVerifiedAddChannels(["a", "b"], channelGroup: self.groupName) { (status: PNAcknowledgmentStatus!) -> (Void) in
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.operation, PNOperationType.AddChannelsToGroupOperation)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.statusCode, 200)
        }
    }
    
    func testSimpleUnsubscribeWithPresence() {
        
        let shouldObservePresence = true
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNStatus) -> (Void) in
            
            XCTAssertEqual(self.client, client)
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.category, PNStatusCategory.PNConnectedCategory)
            
            let subscribedStatus = status as? PNSubscribeStatus
            
            if (subscribedStatus != nil) {
                XCTAssertEqual(subscribedStatus?.subscribedChannels.count, 0)
                XCTAssertEqual(subscribedStatus?.currentTimetoken, subscribedStatus?.data.timetoken)
            }
        };
        self.didReceiveMessageAssertions = {(client: PubNub!, message: PNMessageResult!) -> (Void) in
            
            XCTAssertEqual(self.client, client)
            XCTAssertEqual(client.uuid(), message.uuid)
            XCTAssertNotNil(message.uuid)
            XCTAssertNil(message.authKey)
            XCTAssertEqual(message.statusCode, 200)
            XCTAssertTrue(message.TLSEnabled)
            XCTAssertEqual(message.operation, PNOperationType.SubscribeOperation)
            
            //        XCTAssertEqualObjects(message.data.message, expectedMessage);
            
            self.channelGroupSubscribeExpectation.fulfill()
        };
        
        self.PNTest_subscribeToChannelGroups(self.channelGroups, presense:shouldObservePresence)
        
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNStatus) -> (Void) in
            
            XCTAssertNotNil(client)
            XCTAssertNotNil(status)
            XCTAssertEqual(self.client, client)
//            XCTAssertTrue(status.operation == .UnsubscribeOperation)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.statusCode, 200)
            
            self.channelGroupUnsubscribeExpectation.fulfill();
        }

        self.PNTest_unsubscribeFromChannelGroups(self.channelGroups, presense: true)
    }
    
    func testSimpleUnsubscribeWithNoPresence() {
        
        let shouldObservePresence = false
        
        self.didReceiveMessageAssertions = {(client: PubNub!, message: PNMessageResult!) -> (Void) in
            
            XCTAssertEqual(self.client, client)
            XCTAssertEqual(client.uuid(), message.uuid)
            XCTAssertNotNil(message.uuid)
            XCTAssertNil(message.authKey)
            XCTAssertEqual(message.statusCode, 200)
            XCTAssertTrue(message.TLSEnabled)
            XCTAssertEqual(message.operation, PNOperationType.SubscribeOperation)
            
            //        XCTAssertEqualObjects(message.data.message, expectedMessage);
            
            self.channelGroupSubscribeExpectation.fulfill()
        };
        
        self.PNTest_subscribeToChannelGroups(self.channelGroups, presense:shouldObservePresence)
        
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNStatus) -> (Void) in
            
            XCTAssertNotNil(client)
            XCTAssertNotNil(status)
            XCTAssertEqual(self.client, client)
            
//            XCTAssertTrue(status.category == .PNDisconnectedCategory)
            XCTAssertFalse(status.error)
            
            XCTAssertEqual(status.statusCode, 200)
//            XCTAssertTrue(status.operation == .UnsubscribeOperation)
            
            self.channelGroupUnsubscribeExpectation.fulfill();
        }
        
        self.PNTest_unsubscribeFromChannelGroups(self.channelGroups, presense: false)
    }
}
