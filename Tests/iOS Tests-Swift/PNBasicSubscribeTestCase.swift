//
//  PNBasicSubscribeTestCase.swift
//  PubNub Tests
//
//  Created by Jordan Zucker on 7/28/15.
//
//

import Foundation

typealias PNClientDidReceivePresenceEventAssertions = (client: PubNub, event: PNPresenceEventResult) -> Void
typealias PNClientDidReceiveStatusAssertions = (client: PubNub, status: PNStatus) -> Void

class PNBasicSubscribeTestCase: PNBasicClientTestCase, PNObjectEventListener {
    
    var testExpectation: XCTestExpectation? = nil
    var presenceEventExpectation: XCTestExpectation? = nil
    var subscribeExpectation: XCTestExpectation? = nil
    
    var assertDidReceivePresenceEvent: PNClientDidReceivePresenceEventAssertions?
    var didReceiveStatusAssertions: PNClientDidReceiveStatusAssertions?
    
    override func setUp() {
        super.setUp()
        self.client.addListener(self)
    }
    
    override func tearDown() {
        self.client.removeListener(self)
        super.tearDown()
    }
    
    func PNTest_subscribeToChannels(channels: [String]!, presence: Bool!) {
        if (presence == true) {
            self.presenceEventExpectation = self.expectationWithDescription("subscribePresenceEvent");
            self.client.subscribeToPresenceChannels(channels)
        } else {
            self.subscribeExpectation = self.expectationWithDescription("subscribeStatus")
            self.client.subscribeToChannels(channels, withPresence: presence)
        }
        
        self.waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with subscribe call")
        })
    }
    
    func client(client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        
        if self.assertDidReceivePresenceEvent != nil {
            
            self.assertDidReceivePresenceEvent!(client: self.client, event: event)
            self.presenceEventExpectation?.fulfill()
        }
    }
    
    func client(client: PubNub, didReceiveStatus status: PNStatus) {
        
        if self.didReceiveStatusAssertions != nil {
            
            self.didReceiveStatusAssertions!(client: client, status: status)
        }
    }
}
