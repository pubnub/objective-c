//
//  PNClientStateChannelTests.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 09/09/15.
//
//

import UIKit
import XCTest

class PNClientStateChannelTests: PNBasicSubscribeTestCase {

    let subscriptionChannels = ["a"]
    let unsubscribedChannels = ["21"]
    
    override func isRecording() -> Bool {
        return false
    }
    
    override func setUp() {
        super.setUp()
        
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNStatus) -> (Void) in
            
            XCTAssertEqual(self.client, client)
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            
            self.subscribeExpectation.fulfill()
        }
        
        self.PNTest_subscribeToChannels(self.subscriptionChannels, presense: false)
        self.didReceiveStatusAssertions = nil;
    }
    
    override func tearDown() {
        
        
        let channelsToRemove = self.subscriptionChannels + self.unsubscribedChannels
        
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNStatus) -> (Void) in
            
            XCTAssertEqual(self.client, client)
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            
            let subscribedStatus = status as? PNSubscribeStatus
            
            if (subscribedStatus != nil) {
                XCTAssertEqual(subscribedStatus?.subscribedChannelGroups.count, 0)
            }
            
            self.unsubscribeExpectation.fulfill()
        }
        
        
        self.PNTest_unsubscribeFromChannels(channelsToRemove, presense: true)
        
        super.tearDown()
    }
            
    func testSetClientStateOnSubscribedChannel() {
        
        let stateExpectation = self.expectationWithDescription("clientState")
        let clientState: [NSObject: AnyObject]! = ["test" : "test"]
        
        self.client.setState(clientState, forUUID: self.client.uuid(), onChannel: subscriptionChannels.first) { (status: PNClientStateUpdateStatus!) -> Void in
            
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            let expectedState: [String: String]! = ["test" : "test"]
            let dataState: [String: String]! = status.data.state as? [String: String]
            
            XCTAssertTrue(dataState == expectedState, "States are not equal")
            stateExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout channelsForGroupExpectation")
        })
    }
    
    func testSetClientStateOnNotSubscribedChannel() {
        
        let stateExpectation = self.expectationWithDescription("clientState")
        let clientState: [NSObject: AnyObject]! = ["test" : "test"]
        
        
        self.client.setState(clientState, forUUID: self.client.uuid(), onChannel: unsubscribedChannels.first) { (status: PNClientStateUpdateStatus!) -> Void in
            
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            let expectedState: [String: String]! = ["test" : "test"]
            let dataState: [String: String]! = status.data.state as? [String: String]
            
            XCTAssertTrue(dataState == expectedState, "States are not equal")
            stateExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout channelsForGroupExpectation")
        })
    }
    
    func testStateForUUIDOnSubscribedChannel() {
        
        let stateExpectation = self.expectationWithDescription("clientState")
        
        self.client.stateForUUID(self.client.uuid(), onChannel: self.subscriptionChannels.first) { (result: PNChannelClientStateResult!, status: PNErrorStatus!) -> Void in
            
            XCTAssertNotNil(result)
            XCTAssertNil(status)
            let expectedState: [String: String]! = ["test" : "test"]
            let dataState: [String: String]! = result.data.state as? [String: String]
            
            XCTAssertTrue(dataState == expectedState, "States are not equal")
            stateExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout channelsForGroupExpectation")
        })
    }
    
    func testStateForUUIDOnUnsubscribedChannel() {
        
        let stateExpectation = self.expectationWithDescription("clientState")
        
        self.client.stateForUUID(self.client.uuid(), onChannel: self.unsubscribedChannels.first) { (result: PNChannelClientStateResult!, status: PNErrorStatus!) -> Void in
            
            XCTAssertNotNil(result)
            XCTAssertNil(status)
            let expectedState: [String: String]! = ["test" : "test"]
            let dataState: [String: String]! = result.data.state as? [String: String]
            
            XCTAssertTrue(dataState == expectedState, "States are not equal")
            stateExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout channelsForGroupExpectation")
        })
    }
}

