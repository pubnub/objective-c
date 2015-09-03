//
//  PNPresenceEventTests.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 8/28/15.
//
//

import UIKit
import XCTest

class PNPresenceEventTests: PNBasicSubscribeTestCase {
    
    let channels = ["2EC925F0-B996-47A4-AF54-A605E1A9AEBA"]
    
    override func isRecording() -> Bool {
        return false
    }
    
    func testJoinEvent() {
        
        self.assertDidReceivePresenceEvent = { (client: PubNub!, didReceivePresenceEvent: PNPresenceEventResult!) -> Void in
            XCTAssertEqual(self.client, client)
            XCTAssertNotNil(didReceivePresenceEvent)
            XCTAssertTrue(didReceivePresenceEvent.statusCode == 200, "Status code is not right")
            
            XCTAssertEqual(didReceivePresenceEvent.operation, PNOperationType.SubscribeOperation)
            
            XCTAssertEqual(didReceivePresenceEvent.data.presence.occupancy, 1, "Occupancy is not equal")
            XCTAssertEqual(didReceivePresenceEvent.data.presence.uuid, "affcb408-f5c1-4e97-923a-143701f3b083", "Occupancy is not equal")
            XCTAssertEqual(didReceivePresenceEvent.data.presence.timetoken, NSDecimalNumber(string: "1440754948"), "Timetoken is not the same.")
            XCTAssertEqual(didReceivePresenceEvent.data.presenceEvent, "join");
            XCTAssertEqual(didReceivePresenceEvent.data.subscribedChannel, "2EC925F0-B996-47A4-AF54-A605E1A9AEBA", "Subscribed channel are not equal.")
            XCTAssertEqual(didReceivePresenceEvent.data.timetoken,  NSDecimalNumber(string: "14407549482844872"), "Timetoken is not the same.")
        }
        
        self.PNTest_subscribeToChannels(channels, presence: true)
    }
    
    func testLeaveEvent() {
        
        self.assertDidReceivePresenceEvent = { (client: PubNub!, didReceivePresenceEvent: PNPresenceEventResult!) -> Void in
            XCTAssertEqual(self.client, client)
            XCTAssertNotNil(didReceivePresenceEvent)
            XCTAssertTrue(didReceivePresenceEvent.statusCode == 200, "Status code is not right")
            
            XCTAssertEqual(didReceivePresenceEvent.operation, PNOperationType.SubscribeOperation)
            
            XCTAssertEqual(didReceivePresenceEvent.data.presence.occupancy, 0, "Occupancy is not equal")
            XCTAssertEqual(didReceivePresenceEvent.data.presence.uuid, "affcb408-f5c1-4e97-923a-143701f3b083", "Occupancy is not equal")
            XCTAssertEqual(didReceivePresenceEvent.data.presence.timetoken, NSDecimalNumber(string: "1440773488"), "Timetoken is not the same.")
            XCTAssertEqual(didReceivePresenceEvent.data.presenceEvent, "leave");
            XCTAssertEqual(didReceivePresenceEvent.data.subscribedChannel, "2EC925F0-B996-47A4-AF54-A605E1A9AEBA", "Subscribed channel are not equal.")
            XCTAssertEqual(didReceivePresenceEvent.data.timetoken,  NSDecimalNumber(string: "14407734890045162"), "Timetoken is not the same.")
        }
        
        self.PNTest_subscribeToChannels(channels, presence: true)
    }
    
    func testTimeoutEvent() {
        
        self.assertDidReceivePresenceEvent = { (client: PubNub!, didReceivePresenceEvent: PNPresenceEventResult!) -> Void in
            XCTAssertEqual(self.client, client)
            XCTAssertNotNil(didReceivePresenceEvent)
            XCTAssertTrue(didReceivePresenceEvent.statusCode == 200, "Status code is not right")
            
            XCTAssertEqual(didReceivePresenceEvent.operation, PNOperationType.SubscribeOperation)
            
            XCTAssertEqual(didReceivePresenceEvent.data.presence.occupancy, 1, "Occupancy are not equal")
            XCTAssertEqual(didReceivePresenceEvent.data.presence.uuid, "29624e62-59e4-48f1-9f80-46bbac8fbc2e", "UUIDs are not equal")
            XCTAssertEqual(didReceivePresenceEvent.data.presence.timetoken, NSDecimalNumber(string: "1440776740"), "Timetoken is not the same.")
            XCTAssertEqual(didReceivePresenceEvent.data.presenceEvent, "timeout")
            XCTAssertEqual(didReceivePresenceEvent.data.subscribedChannel, "2EC925F0-B996-47A4-AF54-A605E1A9AEBA", "Subscribed channel are not equal.")
            XCTAssertEqual(didReceivePresenceEvent.data.timetoken, NSDecimalNumber(string: "14407767410944227"), "Timetoken is not the same.")
        }
        
        self.PNTest_subscribeToChannels(channels, presence: true)
    }

    func testStateChangeEvent() {
        
        self.assertDidReceivePresenceEvent = { (client: PubNub!, didReceivePresenceEvent: PNPresenceEventResult!) -> Void in
            XCTAssertEqual(self.client, client)
            XCTAssertNotNil(didReceivePresenceEvent)
            XCTAssertTrue(didReceivePresenceEvent.statusCode == 200, "Status code is not right")
            
            XCTAssertEqual(didReceivePresenceEvent.operation, PNOperationType.SubscribeOperation)
            
            XCTAssertEqual(didReceivePresenceEvent.data.presence.uuid, "29624e62-59e4-48f1-9f80-46bbac8fbc2e", "UUIDs are not equal")
            XCTAssertEqual(didReceivePresenceEvent.data.presence.timetoken, NSDecimalNumber(string: "1440778413"), "Timetoken is not the same.");
            XCTAssertEqual(didReceivePresenceEvent.data.presenceEvent, "state-change");
            XCTAssertEqual(didReceivePresenceEvent.data.subscribedChannel, "2EC925F0-B996-47A4-AF54-A605E1A9AEBA", "Subscribed channel are not equal.")
            
            let expectedValue: [String : String] = (didReceivePresenceEvent.data.presence.state as? [String : String])!
            
            XCTAssertTrue(expectedValue == ["test" : "test"], "State are not equal")
            
            XCTAssertEqual(didReceivePresenceEvent.data.timetoken, NSDecimalNumber(string: "14407784131674496"), "Timetoken is not the same.")
        }
        
        self.PNTest_subscribeToChannels(channels, presence: true)
    }
    
    func testIntervalEvent() {
        
        self.assertDidReceivePresenceEvent = { (client: PubNub!, didReceivePresenceEvent: PNPresenceEventResult!) -> Void in
            XCTAssertEqual(self.client, client)
            XCTAssertNotNil(didReceivePresenceEvent)
            XCTAssertTrue(didReceivePresenceEvent.statusCode == 200, "Status code is not right")
            
            XCTAssertEqual(didReceivePresenceEvent.operation, PNOperationType.SubscribeOperation)
            
            XCTAssertNil(didReceivePresenceEvent.data.presence.uuid, "UUI should be nil")
            XCTAssertEqual(didReceivePresenceEvent.data.presenceEvent, "interval");
            XCTAssertEqual(didReceivePresenceEvent.data.subscribedChannel, "2EC925F0-B996-47A4-AF54-A605E1A9AEBA", "Subscribed channel are not equal.")
            
            XCTAssertEqual(didReceivePresenceEvent.data.timetoken, NSDecimalNumber(string: "14411068884747343"), "Timetoken is not the same.")
        }
        
        self.PNTest_subscribeToChannels(channels, presence: true)
    }
    
}
