//
//  PNChannelGroupSubscribeTests.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 08/25/15.
//
//

import UIKit
import XCTest

class PNChannelGroupSubscribeTests: PNBasicSubscribeTestCase {
    
    let groupName = "PNChannelGroupSubscribeTests"
    
    lazy var channelGroups: [String] = {
        return [self.groupName]
        }()
    
    override func isRecording() -> Bool {
        return false
    }

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
    
    func testSimpleSubscribeWithPresence() {
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNStatus) -> (Void) in
            
            XCTAssertEqual(self.client, client)
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            XCTAssertTrue(status.category == .PNConnectedCategory)
            
            let expectedChannelGroups: [String] = [self.groupName, self.groupName + "-pnpres"]
            
            let subscribedStatus = status as? PNSubscribeStatus
            
            if (subscribedStatus != nil) {
                XCTAssertEqual(subscribedStatus?.subscribedChannels.count, 0)
                
                var resultSet: Set<String> = []
                for element in (subscribedStatus?.subscribedChannelGroups as? [String])! {
                    resultSet.insert(element)
                }
                
                let expectedChannelGroupsSet: Set<String> = Set(expectedChannelGroups)
                
                XCTAssertTrue(resultSet == expectedChannelGroupsSet, "Subscribed channel groups list are not equal");
                
                XCTAssertEqual(subscribedStatus?.currentTimetoken, 14355524859273802)
                XCTAssertEqual(subscribedStatus?.currentTimetoken, subscribedStatus?.data.timetoken)
            }
            
            XCTAssertTrue(status.operation == .SubscribeOperation)
            
            XCTAssertNotNil(status)
            XCTAssertEqual(self.client, client, "Incorrect client")
            XCTAssertFalse(status.error)
            XCTAssertTrue(status.category == .PNConnectedCategory)
        }
    
        self.didReceiveMessageAssertions = {(client: PubNub!, message: PNMessageResult!) -> (Void) in
            
            XCTAssertEqual(self.client, client)
            XCTAssertEqual(client.uuid(), message.uuid)
            XCTAssertNotNil(message.uuid)
            XCTAssertNil(message.authKey)
            XCTAssertEqual(message.statusCode, 200)
            XCTAssertTrue(message.TLSEnabled)
            XCTAssertEqual(message.operation, PNOperationType.SubscribeOperation)
            
            XCTAssertNotNil(message.data)
            XCTAssertEqual(message.data.message as? String,"**************. 52 - 2015-06-28 21:34:46")
            XCTAssertEqual(message.data.actualChannel, "a")
            XCTAssertEqual(message.data.subscribedChannel, self.groupName)
            XCTAssertEqual(message.data.timetoken, 14355524878034000)
            self.channelGroupSubscribeExpectation.fulfill()
        }
        
        self.PNTest_subscribeToChannelGroups(self.channelGroups, presense: true)
    }
    
    func testSimpleSubscribeWithNoPresence() {
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNStatus) -> (Void) in
            
            XCTAssertEqual(self.client, client)
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.category, PNStatusCategory.PNConnectedCategory)
            
            let subscribedStatus = status as? PNSubscribeStatus
            
            if (subscribedStatus != nil) {
                XCTAssertEqual(subscribedStatus?.subscribedChannels.count, 0)
                XCTAssertEqual((subscribedStatus?.subscribedChannelGroups as? [String])!, self.channelGroups);
                XCTAssertEqual(subscribedStatus?.currentTimetoken, 14355524847292283)
                XCTAssertEqual(subscribedStatus?.currentTimetoken, subscribedStatus?.data.timetoken)
            }
            
            XCTAssertTrue(status.operation == .SubscribeOperation)
        }
        
        self.didReceiveMessageAssertions = {(client: PubNub!, message: PNMessageResult!) -> (Void) in
            
            XCTAssertEqual(self.client, client)
            XCTAssertEqual(client.uuid(), message.uuid)
            XCTAssertNotNil(message.uuid)
            XCTAssertNil(message.authKey)
            XCTAssertEqual(message.statusCode, 200)
            XCTAssertTrue(message.TLSEnabled)
            XCTAssertEqual(message.operation, PNOperationType.SubscribeOperation)
            XCTAssertNotNil(message.data)
            // the string from this channel is absurd, should simplify at some point, but want to just keep cranking for now
            // cast to NSData to compare
            
            XCTAssertEqual(message.data.message as? String, "*************.. 51 - 2015-06-28 21:34:44")
            XCTAssertEqual(message.data.actualChannel, "a")
            XCTAssertEqual(message.data.subscribedChannel, self.groupName)
            XCTAssertEqual(message.data.timetoken, 14355524857638372)
            self.channelGroupSubscribeExpectation.fulfill()

        }
        
        self.PNTest_subscribeToChannelGroups(self.channelGroups, presense: false)
    }
}
