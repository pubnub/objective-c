//
//  PNBasicSubscribeTestCase.swift
//  PubNub Tests
//
//  Created by Jordan Zucker on 7/28/15.
//
//

import Foundation

typealias PNClientDidReceivePresenceEventAssertions = (client: PubNub, event: PNPresenceEventResult) -> Void

class PNBasicSubscribeTestCase: PNBasicClientTestCase, PNObjectEventListener {
    
    var testExpectation: XCTestExpectation? = nil
    var presenceEventExpectation: XCTestExpectation? = nil
    
    var assertDidReceivePresenceEvent: PNClientDidReceivePresenceEventAssertions?
    
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
            self.presenceEventExpectation = self.expectationWithDescription("subscribeEvent");
        } else {
            self.testExpectation = self.expectationWithDescription("network")
        }
        
        self.client.subscribeToPresenceChannels(channels)
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with subscribe call")
        })
    }
    
    func client(client: PubNub!, didReceivePresenceEvent event: PNPresenceEventResult!) {
        if self.assertDidReceivePresenceEvent != nil {
            self.assertDidReceivePresenceEvent!(client: self.client, event: event)
            self.presenceEventExpectation?.fulfill()
        }
    }
}
