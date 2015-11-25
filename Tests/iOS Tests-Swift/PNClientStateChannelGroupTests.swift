//
//  PNClientStateChannelGroupTests.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 09/07/15.
//
//

import UIKit
import XCTest

class PNClientStateChannelGroupTests: PNBasicSubscribeTestCase {
    
    let kPNChannelGroupTestsName = "PNClientStateChannelGroupTests"
    
    let nonExistentChannelGroup = "42"
    
    lazy var channelGroups: [String] = {
        return ["PNClientStateChannelGroupTests"]
        }()
    
    override func isRecording() -> Bool {
        return false
    }
    
    override func setUp() {
        
        super.setUp()
        self.performVerifiedRemoveAllChannelsFromGroup(kPNChannelGroupTestsName, assertions: nil)
    }
    
    override func tearDown() {
        
        self.performVerifiedRemoveAllChannelsFromGroup(kPNChannelGroupTestsName, assertions: nil)
            super.tearDown()
    }
    
    func testSetClientStateOnSubscribedChannelGroup() {
        self.didReceiveStatusAssertions = nil;

        let stateExpectation = self.expectationWithDescription("clientState")
        
        let clientState: [NSObject: AnyObject]! = ["test" : "test"]
        
        self.client.setState(clientState, forUUID:self.client.uuid(), onChannelGroup: kPNChannelGroupTestsName) { (status: PNClientStateUpdateStatus!) -> Void in
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.operation, PNOperationType.SetStateOperation)
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.statusCode, 200)
            
            let expectedState: [String: String]! = ["test" : "test"]
            let dataState: [String: String]! = status.data.state as? [String: String]
            
            XCTAssertTrue(dataState == expectedState, "States are not equal")
            stateExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout channelsForGroupExpectation")
        })
    }
    
    func testSetClientStateOnNotExistingChannelGroup() {
        self.didReceiveStatusAssertions = nil;
            
        let stateExpectation = self.expectationWithDescription("clientState")
        let clientState: [NSObject: AnyObject]! = ["test" : "test"]
        
        self.client.setState(clientState, forUUID:self.client.uuid(), onChannelGroup: self.nonExistentChannelGroup) { (status: PNClientStateUpdateStatus!) -> Void in
            XCTAssertNotNil(status)
            
            XCTAssertTrue(status.error);
//            XCTAssertEqual(status.operation, PNSetStateOperation);
//    XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
    //        XCTAssertNil(status.data.state);
    // TOOD: there should be a property for this?
    //        XCTAssertEqualObjects(status.data, @"No valid channels specified");
            
            stateExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout channelsForGroupExpectation")
        })
    }
    
    func testStateForUUIDOnSubscribedChannelGroup() {
        
        self.performVerifiedAddChannels(["a", "b"], channelGroup: kPNChannelGroupTestsName) { (status: PNAcknowledgmentStatus!) -> (Void) in
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
//            XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
            XCTAssertEqual(status.category, PNStatusCategory.PNAcknowledgmentCategory)
            XCTAssertEqual(status.statusCode, 200)
        }
    
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNStatus) -> (Void) in
            XCTAssertEqual(self.client, client)
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            XCTAssertTrue(status.category == .PNConnectedCategory)
            
            let expectedChannelGroups: [String] = [self.kPNChannelGroupTestsName, self.kPNChannelGroupTestsName + "-pnpres"]
            
            let subscribedStatus = status as? PNSubscribeStatus
            
            if (subscribedStatus != nil) {
                XCTAssertEqual(subscribedStatus?.subscribedChannelGroups.count, expectedChannelGroups.count);
                
                var resultSet: Set<String> = []
                for element in (subscribedStatus?.subscribedChannelGroups as? [String])! {
                    resultSet.insert(element)
                }
                
                let expectedChannelGroupsSet: Set<String> = Set(expectedChannelGroups)
                
                XCTAssertTrue(resultSet == expectedChannelGroupsSet, "Channel groups are not equal")
                
                XCTAssertEqual(subscribedStatus?.currentTimetoken, NSNumber(longLong:14356954400894751))
                XCTAssertEqual(subscribedStatus?.currentTimetoken, subscribedStatus?.data.timetoken)
            }
            
            self.channelGroupSubscribeExpectation.fulfill()
        }
        
        self.PNTest_subscribeToChannelGroups(self.channelGroups, presense: true)
        self.didReceiveStatusAssertions = nil;
        
        let stateExpectation = self.expectationWithDescription("clientState")
//        let channelStates = ["a" : [
//            "test" : "test"],
//            "b" : ["test" : "test"]]
        
        self.client.stateForUUID(self.client.uuid(), onChannelGroup:kPNChannelGroupTestsName) { (result: PNChannelGroupClientStateResult!, status: PNErrorStatus!) -> Void in
            
            XCTAssertNil(status)
            XCTAssertNotNil(result)
            
            XCTAssertEqual(result.statusCode, 200)
            
            //            XCTAssertEqual(result.data.channels == channels, "Channels are not equal")
            
            stateExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout channelsForGroupExpectation")
        })
    }
    
    func testStateForUUIDOnNonExistentChannelGroup() {
        
        let stateExpectation = self.expectationWithDescription("clientState")
        
        self.client.stateForUUID(self.client.uuid(), onChannelGroup: self.nonExistentChannelGroup) { (result: PNChannelGroupClientStateResult!, status: PNErrorStatus!) -> Void in
            XCTAssertNil(result)
            XCTAssertNotNil(status)
            XCTAssertTrue(status.error)
//            XCTAssertEqual(status.category, PNBadRequestCategory)
//            XCTAssertEqual(status.operation, PNStateForChannelGroupOperation);
            XCTAssertEqual(status.statusCode, 400)
            
            stateExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout channelsForGroupExpectation")
        })
    }
    
}
