//
//  PNChannelGroupTests.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 08/27/15.
//
//

import UIKit
import XCTest

class PNChannelGroupTests: PNBasicClientTestCase {
    
    let groupName = "PNChannelGroupTestsName"
    
    override func isRecording() -> Bool {
        return false
    }
    
    override func setUp() {
        super.setUp()
        
        self.performVerifiedRemoveAllChannelsFromGroup(self.groupName, assertions: nil)
    }
    
    override func tearDown() {
        self.performVerifiedRemoveAllChannelsFromGroup(self.groupName, assertions: nil);
            super.tearDown();
        }
    
    func testChannelGroupAdd() {
        self.performVerifiedAddChannels(["a", "b"], channelGroup: self.groupName) { (status: PNAcknowledgmentStatus!) -> (Void) in
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.operation, PNOperationType.AddChannelsToGroupOperation)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.statusCode, 200)
        }
    }
    
    func testChannelsForGroup() {
        
        let channelGroups = ["a", "c"]
        
        self.performVerifiedAddChannels(channelGroups, channelGroup: self.groupName) { (status: PNAcknowledgmentStatus!) -> (Void) in
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.operation, PNOperationType.AddChannelsToGroupOperation)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.statusCode, 200)
        }
        
        let channelsForGroupExpectation = self.expectationWithDescription("channelsForGroupExpectation")
        
        self.client.channelsForGroup(self.groupName) { (result: PNChannelGroupChannelsResult!, status: PNErrorStatus!) -> Void in
            XCTAssertNil(status)
            XCTAssertNotNil(result)
            XCTAssertEqual(result.statusCode, 200)
            XCTAssertEqual(result.operation, PNOperationType.ChannelsForGroupOperation)
            
            XCTAssertTrue((result.data.channels as? [String])! == channelGroups)
            
            channelsForGroupExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout channelsForGroupExpectation")
        })
    }
    
    func testChannelGroupRemoveAll() {
        self.performVerifiedAddChannels(["a", "c"], channelGroup: self.groupName) { (status: PNAcknowledgmentStatus!) -> (Void) in
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.operation, PNOperationType.AddChannelsToGroupOperation)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.statusCode, 200)
        }
        
        self.performVerifiedRemoveAllChannelsFromGroup(self.groupName) { (status: PNAcknowledgmentStatus!) -> (Void) in
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.operation, PNOperationType.RemoveGroupOperation)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.statusCode, 200);
        }
    }
    
    func testRemoveSpecificChannelsFromGroup() {
        self.performVerifiedAddChannels(["a", "c"], channelGroup: self.groupName) { (status: PNAcknowledgmentStatus!) -> (Void) in
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.operation, PNOperationType.AddChannelsToGroupOperation)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.statusCode, 200)
        }
        
        self.performVerifiedRemoveChannels(["a"], channelGroup: self.groupName) { (status: PNAcknowledgmentStatus!) -> (Void) in
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.operation, PNOperationType.RemoveChannelsFromGroupOperation)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.statusCode, 200)
        }
    }
    
    func testGetAllChannelGroupsForClient() {
        let allChannelGroupsExpectation = self.expectationWithDescription("allChannelGroupsExpectation")
        
        self.client.channelsForGroup(self.groupName) { (result: PNChannelGroupChannelsResult!, status: PNErrorStatus!) -> Void in
            
            XCTAssertNotNil(result)
            XCTAssertNil(status)

            // TODO: ivestigate more why we have there PNOperationType
//            XCTAssertEqual(result.operation, PNOperationType.ChannelGroupsOperation)
            XCTAssertEqual(result.statusCode, 200)
            // TODO: assert on actual groups, for now just do count
//            let groups: Array = result.data.groups as Array
//            XCTAssertEqual(groups.count == 64, "Count groups are not equal")
            
            allChannelGroupsExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout addPushNotificationsOnChannels")
        })
    }
}

