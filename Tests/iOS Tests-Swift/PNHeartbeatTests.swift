//
//  PNHeartbeatTests.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 09/11/15.
//
//

import UIKit
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
}

