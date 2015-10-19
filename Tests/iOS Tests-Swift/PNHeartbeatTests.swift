//
//  PNHeartbeatTests.swift
//  PubNub Tests
//
//  Created by Sergey Mamontov on 10/14/15.
//
//

import XCTest

class PNHeartbeatTests: PNBasicSubscribeTestCase {

    override func isRecording() -> Bool {
        
        return false
    }
    
    func testSimpleHeartbeat() {
        let config = PNConfiguration(publishKey: "demo-36", subscribeKey: "demo-36")
        XCTAssertNotNil(config)
        
        let simpleClient = PubNub.clientWithConfiguration(config);
        XCTAssertNotNil(simpleClient)
        
        configuration.presenceHeartbeatInterval = 5
        let heartbeatClient = PubNub.clientWithConfiguration(configuration)
        XCTAssertNotNil(heartbeatClient)
    }
    
    override func overrideClientConfiguration(configuration: PNConfiguration) -> PNConfiguration! {
        
        configuration.presenceHeartbeatInterval = 5
        configuration.presenceHeartbeatValue = 60
        return configuration
    }
    
    func testHeartbeatCallbackFail() {
        
        let heartbeatExpectation = self.expectationWithDescription("heartbeatFailure");
        self.didReceiveStatusAssertions = { (client: PubNub!, status: PNStatus!) -> Void in

            if status.operation == .SubscribeOperation {
                
                XCTAssertFalse(status.error, "Subscription should be successful to test heartbeat.");
                self.subscribeExpectation?.fulfill()
            }
            else if status!.operation == .HeartbeatOperation {
                
                XCTAssertTrue(status.error, "Only failed heartbeat status should be passed.");
                heartbeatExpectation.fulfill()
            }
        }
        self.PNTest_subscribeToChannels(["heartbeat-test"], presence: false)
    }
}

