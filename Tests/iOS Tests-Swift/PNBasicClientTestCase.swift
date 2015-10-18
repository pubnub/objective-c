//
//  PNBasicClientTestCase.swift
//  PubNub Tests
//
//  Created by Jordan Zucker on 7/27/15.
//
//

import Foundation
import UIKit
import XCTest

typealias PNChannelGroupAssertions = (status: PNAcknowledgmentStatus!) -> (Void)

class PNBasicClientTestCase: JSZVCRTestCase {
    
    lazy var configuration: PNConfiguration = {
        let lazyConfig = PNConfiguration(publishKey: "demo-36", subscribeKey: "demo-36")
        lazyConfig.uuid = "322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C"
        return lazyConfig
    }()
    
    lazy var client: PubNub = {
        return PubNub.clientWithConfiguration(self.configuration)
    }()
    
    override func matcherClass() -> AnyObject.Type! {
        return JSZVCRUnorderedQueryMatcher.self
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: - Channel Group Helpers
    
    func performVerifiedAddChannels(channels: [String], channelGroup: String, assertions: PNChannelGroupAssertions?) {
        let addChannelsToGroupExpectation = self.expectationWithDescription("addChannels")
        
        self.client.addChannels(channels, toGroup: channelGroup) { (status: PNAcknowledgmentStatus!) -> Void in
            
            // FIXME :
//            if (assertions) {
//                assertions(status)
//            }
            
            addChannelsToGroupExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout addPushNotificationsOnChannels")
        })
    }

    func performVerifiedRemoveAllChannelsFromGroup(channelGroup: String, assertions: PNChannelGroupAssertions?) {
        let removeChannelsToGroupExpectation = self.expectationWithDescription("removeChannels")
        
        self.client.removeChannelsFromGroup(channelGroup) { (status: PNAcknowledgmentStatus!) -> Void in
            
            // FIXME :
//            if (assertions) {
//                assertions(status)
//            }
            
            removeChannelsToGroupExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout addPushNotificationsOnChannels")
        })
    }
    
    func performVerifiedRemoveChannels(channels: [String], channelGroup: String, assertions: PNChannelGroupAssertions?) {
        let removeSpecificChannelsExpectation = self.expectationWithDescription("removeSpecificChannels")
        
        self.client.removeChannels(channels, fromGroup: channelGroup) { (status: PNAcknowledgmentStatus!) -> Void in
            
            // FIXME :
//            if (assertions) {
//                assertions(status)
//            }
            
            removeSpecificChannelsExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout addPushNotificationsOnChannels")
        })
    }
}
