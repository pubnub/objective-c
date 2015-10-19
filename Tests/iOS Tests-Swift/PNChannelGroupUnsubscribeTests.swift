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
        
        // TODO: investigate me
        
//        self.didReceiveStatusAssertions = {(client: PubNub, status: PNSubscribeStatus) -> (Void) in
//            
//            XCTAssertEqualObjects(self.client, client)
//            XCTAssertNotNil(status)
//            XCTAssertFalse(status.error)
//            XCTAssertEqual(status.category, PNStatusCategory.PNConnectedCategory)
//            XCTAssertEqual(status.subscribedChannels.count, 0)
//            XCTAssertTrue(status.subscribedChannelGroups ==expectedChannelGroups, "Channel groups are not equal")
//            XCTAssertEqual(status.operation, PNSubscribeOperation)
//            
//            XCTAssertEqual(status.currentTimetoken, status.data.timetoken)
//        }
        
//        self.didReceiveMessageAssertions = {(client: PubNub!, message: PNMessageResult!) -> (Void) in
//            
//            XCTAssertEqualObjects(self.client, client);
//            XCTAssertEqualObjects(client.uuid, message.uuid);
//            XCTAssertNotNil(message.uuid);
//            XCTAssertNil(message.authKey);
//            XCTAssertEqual(message.statusCode, 200);
//            XCTAssertTrue(message.TLSEnabled);
//            XCTAssertEqual(message.operation, PNSubscribeOperation);
//            NSLog(@"message:");
//            NSLog(@"%@", message.data.message);
//            
//            self.channelGroupSubscribeExpectation.fulfill();
//        }
    }
    
    func testSimpleUnsubscribeWithPresence() {
        
        let shouldObservePresence = true
        let expectedMessage = "*****.......... 583 - 2015-06-28 21:52:31"
        let expectedTimeToken = 14355535508745522
        let expectedChannelGroups = ["PNChannelGroupUnsubscribeTests", "PNChannelGroupUnsubscribeTests-pnpres"]
        
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNSubscribeStatus) -> (Void) in
            
            XCTAssertEqual(self.client, client)
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.category, PNStatusCategory.PNConnectedCategory)
            XCTAssertEqual(status.subscribedChannels.count, 0)
            
            // TODO: investigate
//            XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannelGroups],
//                [NSSet setWithArray:expectedChannelGroups]);
//            XCTAssertEqual(status.operation, PNSubscribeOperation);
            
            //        XCTAssertEqualObjects(status.currentTimetoken, expectedTimeToken);
            XCTAssertEqual(status.currentTimetoken, status.data.timetoken)
            
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
        
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNSubscribeStatus) -> (Void) in
            
            XCTAssertNotNil(client)
            XCTAssertNotNil(status)
            XCTAssertEqual(self.client, client)
//            XCTAssertEqual(status.category, PNStatusCategory.PNDisconnectedCategory)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.statusCode, 200)
//            XCTAssertEqual(status.operation, PNOperationType.UnsubscribeOperation)
            
            self.channelGroupUnsubscribeExpectation.fulfill();
        }

        self.PNTest_unsubscribeFromChannelGroups(self.channelGroups, presense: true)
    }
    
    func testSimpleUnsubscribeWithNoPresence() {
        
        let shouldObservePresence = false
        let expectedMessage = "*****.......... 583 - 2015-06-28 21:52:31"
        let expectedTimeToken = 14355535508745522
        let expectedChannelGroups = ["PNChannelGroupUnsubscribeTests"]
        
        
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
        
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNSubscribeStatus) -> (Void) in
            
            XCTAssertNotNil(client)
            XCTAssertNotNil(status)
            XCTAssertEqual(self.client, client)
            
            // TODO: try to investigate it
            
//            XCTAssertEqual(status.category, PNStatusCategory.PNDisconnectedCategory)
            XCTAssertFalse(status.error)
            
            XCTAssertEqual(status.statusCode, 200)
//            XCTAssertEqual(status.operation, PNOperationType.UnsubscribeOperation)
            
            self.channelGroupUnsubscribeExpectation.fulfill();
        }
        
        self.PNTest_unsubscribeFromChannelGroups(self.channelGroups, presense: false)
    }
}
