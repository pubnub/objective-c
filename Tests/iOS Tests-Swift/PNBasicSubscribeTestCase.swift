//
//  PNBasicSubscribeTestCase.swift
//  PubNub Tests
//
//  Created by Jordan Zucker on 7/28/15.
//
//

import Foundation

typealias PNClientDidReceiveMessageAssertions = (client: PubNub!, message: PNMessageResult!) -> (Void)
typealias PNClientDidReceivePresenceEventAssertions = (client: PubNub, event: PNPresenceEventResult) -> (Void)
typealias PNClientDidReceiveStatusAssertions = (client: PubNub, status: PNSubscribeStatus) -> (Void)

class PNBasicSubscribeTestCase: PNBasicClientTestCase, PNObjectEventListener {
    
    var didReceiveMessageAssertions: PNClientDidReceiveMessageAssertions?;
    var didReceivePresenceEventAssertions: PNClientDidReceivePresenceEventAssertions?;
    var didReceiveStatusAssertions: PNClientDidReceiveStatusAssertions?;
    
    var subscribeExpectation: XCTestExpectation!;
    var unsubscribeExpectation: XCTestExpectation!;
    var channelGroupSubscribeExpectation: XCTestExpectation!;
    var channelGroupUnsubscribeExpectation: XCTestExpectation!;
    
    var presenceEventExpectation: XCTestExpectation!;
    var testExpectation: XCTestExpectation!;
    
    var assertDidReceivePresenceEvent: PNClientDidReceivePresenceEventAssertions?
    
    override func setUp() {
        super.setUp()
        self.client.addListener(self)
    }
    
    override func tearDown() {
        self.client.removeListener(self)
        super.tearDown()
    }
    
    func PNTest_subscribeToChannels(channels: [String]!, presense: Bool) {
        subscribeExpectation = self.expectationWithDescription("subscribe")
        self.client.subscribeToChannelGroups(channels, withPresence: presense)
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func PNTest_subscribeToPresenceChannels(channels: [String]!) {
        subscribeExpectation = self.expectationWithDescription("subscribe")
        self.client.subscribeToPresenceChannels(channels)
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func PNTest_unsubscribeFromChannels(channels: [String]!, presense: Bool) {
        unsubscribeExpectation = self.expectationWithDescription("unsubscribe")
        self.client.subscribeToChannelGroups(channels, withPresence: presense)
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func PNTest_unsubscribeFromPresenceChannels(channels: [String]!) {
        unsubscribeExpectation = self.expectationWithDescription("unsubscribe")
        self.client.unsubscribeFromPresenceChannels(channels)
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func PNTest_subscribeToChannelGroups(groups: [String]!, presense: Bool) {
        channelGroupSubscribeExpectation = self.expectationWithDescription("channel group subscribe")
        self.client.subscribeToChannelGroups(groups, withPresence: presense)
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }

    
    func PNTest_unsubscribeFromChannelGroups(groups: [String]!, presense: Bool) {
        channelGroupUnsubscribeExpectation = self.expectationWithDescription("channel group unsubscribe")
        self.client.subscribeToChannelGroups(groups, withPresence: presense)
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func PNTest_subscribeToChannels(channels: [String]!, presence: Bool!) {
        if (presence == true) {
            self.presenceEventExpectation = self.expectationWithDescription("subscribeEvent");
        } else {
            self.testExpectation = self.expectationWithDescription("network")
        }
        
        self.client.subscribeToPresenceChannels(channels)
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with subscribe call")
        })
    }
    
// MARK: PNDelegateListener
    
    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {
        if didReceiveMessageAssertions != nil {
            didReceiveMessageAssertions!(client: client, message: message)
        }
    }
    
    func client(client: PubNub!, didReceiveStatus status: PNSubscribeStatus!) {
        if didReceiveStatusAssertions != nil {
            didReceiveStatusAssertions!(client: client, status: status)
        }
    }
    
    func client(client: PubNub!, didReceivePresenceEvent event: PNPresenceEventResult!) {
        if self.assertDidReceivePresenceEvent != nil {
            self.assertDidReceivePresenceEvent!(client: self.client, event: event)
            self.presenceEventExpectation?.fulfill()
        }
    }
}
