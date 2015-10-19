//
//  PNClientConfigurationTests.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 09/03/15.
//
//

import UIKit
import XCTest

class PNClientConfigurationTests: PNBasicSubscribeTestCase {
    
    override func isRecording() -> Bool {
        return false
    }
    
    lazy var subscriptionChannels: [String] = {
        let channels = ["a"]
        return channels
        }()
    
    func testCreateClientWithBasicConfiguration() {
        let config = PNConfiguration(publishKey: "demo-36", subscribeKey: "demo-36")
        XCTAssertNotNil(config)
        let simpleClient = PubNub.clientWithConfiguration(config);
        XCTAssertNotNil(simpleClient)
    }
    
    func testCreateClientWithCallbackQueue() {
        let config = PNConfiguration(publishKey: "demo-36", subscribeKey: "demo-36")
        XCTAssertNotNil(config)
        
        let callbackQueue: dispatch_queue_t = dispatch_queue_create("com.testCreateClientWithCallbackQueue", DISPATCH_QUEUE_SERIAL);
        
        let simpleClient = PubNub.clientWithConfiguration(config, callbackQueue: callbackQueue);
        XCTAssertNotNil(simpleClient)
    }
    
    // we should do something if we are trying to make a copy with no changes, instead of silently failing
    func testSimpleCopyConfigurationWithNoSubscriptions() {
        XCTAssertNotNil(self.client)
        
        XCTAssertEqual(self.client.uuid(), "322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C")
        
        let copyExpectation = self.expectationWithDescription("copy")
        let changedUUID = "changed"
        
        self.configuration.uuid = changedUUID
        
        self.client.copyWithConfiguration(self.configuration) { (client:PubNub!) -> Void in
            XCTAssertNotEqual(self.client, client.uuid())
            XCTAssertEqual(client.uuid(), changedUUID)
            copyExpectation.fulfill()
        }
    
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout channelsForGroupExpectation")
        })
    }
    
    func testSimpleCopyConfigurationWithNoSubscriptionAndCallbackQueue() {
        XCTAssertNotNil(self.client)
        XCTAssertEqual(self.client.uuid(), "322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C")
        
        let copyExpectation = self.expectationWithDescription("copy")
        
        self.client.copyWithConfiguration(self.configuration) { (client: PubNub!) -> Void in
            XCTAssertNotEqual(self.client, client.uuid())
            XCTAssertEqual(client.uuid(), self.client.uuid())
            copyExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout channelsForGroupExpectation")
        })
    }
    
    func prepareForSubscribedPartOfTest() {
        
        self.didReceiveStatusAssertions = {(client: PubNub, status: PNStatus) -> (Void) in
            
            XCTAssertEqual(self.client, client)
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            
//            XCTAssertEqual(status.category, PNStatusCategory.PNConnectedCategory)
            
            let subscribedStatus = status as? PNSubscribeStatus
            
            if (subscribedStatus != nil) {
                XCTAssertEqual(subscribedStatus?.subscribedChannelGroups.count, 1)
                
                let expectedPresenceSubscriptions: [String] = ["a"]
                
                var resultSet: Set<String> = []
                for element in (subscribedStatus?.subscribedChannelGroups as? [String])! {
                    resultSet.insert(element)
                }
                
                let expectedPresenceSubscriptionsSet: Set<String> = Set(expectedPresenceSubscriptions)
                
                XCTAssertTrue(resultSet == expectedPresenceSubscriptionsSet, "Subscribed channel groups list are not equal")
            }
            
            self.channelGroupSubscribeExpectation.fulfill()
        }
    
        self.PNTest_subscribeToChannelGroups(self.subscriptionChannels, presense: false)
        self.didReceiveStatusAssertions = nil
    }
    
    func testCopyConfigurationWithSubscribedChannels() {
        self.prepareForSubscribedPartOfTest()
            
        XCTAssertNotNil(self.client)
        XCTAssertEqual(self.client.uuid(), "322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C")
            
        let copyExpectation = self.expectationWithDescription("copy")
        let changedUUID = "changed"
            
        self.configuration.uuid = changedUUID
        
        self.client.copyWithConfiguration(self.configuration) { (client: PubNub!) -> Void in
            XCTAssertNotEqual(self.client, client.uuid())
            XCTAssertEqual(client.uuid(), changedUUID)
            copyExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout channelsForGroupExpectation")
        })
    }
    
    func testCopyConfigurationWithSubscribedChannelsAndCallbackQueue() {
        
        self.prepareForSubscribedPartOfTest()
        
        XCTAssertNotNil(self.client)
        XCTAssertEqual(self.client.uuid(), "322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C")
        
        let copyExpectation = self.expectationWithDescription("copy")
        let changedUUID = "changed"
        
        self.configuration.uuid = changedUUID
        
        let callbackQueue: dispatch_queue_t = dispatch_queue_create("com.testCreateClientWithCallbackQueue", DISPATCH_QUEUE_SERIAL);

        self.client.copyWithConfiguration(self.configuration, callbackQueue: callbackQueue) { (client: PubNub!) -> Void in
            XCTAssertNotEqual(self.client, client.uuid())
            XCTAssertEqual(client.uuid(), changedUUID)
            copyExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout channelsForGroupExpectation")
        })
    }
}
