//
//  PNAPNSTests.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 08/19/15.
//
//

import UIKit
import XCTest

class PNAPNSTests: PNBasicClientTestCase {
    
    let pushKey = "6652cff7f17536c86bc353527017741ec07a91699661abaf68c5977a83013091"

    
    override func isRecording() -> Bool {
        return false
    }
    
    lazy var pushToken : NSData! = {
        return NSData.fromHexString(self.pushKey)
    }()

    lazy var apnsConfiguration: PNConfiguration = {
        let lazyConfig = PNConfiguration(publishKey: "pub-c-12b1444d-4535-4c42-a003-d509cc071e09", subscribeKey: "sub-c-6dc508c0-bff0-11e3-a219-02ee2ddab7fe")
        lazyConfig.uuid = "322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C"
        return lazyConfig
        }()
    
    lazy var apnsClient: PubNub = {
        return PubNub.clientWithConfiguration(self.apnsConfiguration)
        }()
    
    func testAddPushOnChannels() {
        let networkExpectation = self.expectationWithDescription("Add Push Expectation.")
        
        let channels = ["1", "2", "3"]
        self.apnsClient.addPushNotificationsOnChannels(channels, withDevicePushToken: self.pushToken) { (status: PNAcknowledgmentStatus!) -> Void in
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.statusCode, 200, "Response status code is not 200")
            
            networkExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout addPushNotificationsOnChannels")
        })
    }
    
    func testAddPushOnNilChannels() {
        let networkExpectation = self.expectationWithDescription("Add Push Expectation.")
        
        self.apnsClient.addPushNotificationsOnChannels(nil, withDevicePushToken: self.pushToken) { (status: PNAcknowledgmentStatus!) -> Void in
            XCTAssertNotNil(status)
            XCTAssertTrue(status.error)
            XCTAssertEqual(status.statusCode, 400, "Response status code is not 400")
            
            networkExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout addPushNotificationsOnChannels")
        })
    }

    func testAddPushOnChannelsWithNilPushToken() {
        let networkExpectation = self.expectationWithDescription("Add Push Expectation.")
        
        let channels = ["1", "2", "3"]
        
        self.apnsClient.addPushNotificationsOnChannels(channels, withDevicePushToken:nil) { (status: PNAcknowledgmentStatus!) -> Void in
            XCTAssertNotNil(status)
            XCTAssertTrue(status.error)
            XCTAssertEqual(status.statusCode, 400, "Response status code is not 400")
            
            networkExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout addPushNotificationsOnChannels")
        })
    }
    
    func testRemovePushNotificationFromChannel() {
        let networkExpectation = self.expectationWithDescription("Remove Push Expectation.")
        
        let channels = ["1", "2", "3"]
        
        self.apnsClient.removePushNotificationsFromChannels(channels, withDevicePushToken: self.pushToken) { (status: PNAcknowledgmentStatus!) -> Void in
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.operation, PNOperationType.RemovePushNotificationsFromChannelsOperation, "Wrong operation.")
            
            XCTAssertEqual(status.statusCode, 200, "Response status code is not 200")
            
            networkExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout addPushNotificationsOnChannels")
        })
    }
    
    func testRemovePushNotificationFromNilChannel() {
        let networkExpectation = self.expectationWithDescription("Remove Push Expectation.")
        
        self.apnsClient.removePushNotificationsFromChannels(nil, withDevicePushToken: self.pushToken) { (status: PNAcknowledgmentStatus!) -> Void in
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.operation, PNOperationType.RemoveAllPushNotificationsOperation, "Wrong operation.")
            
            XCTAssertEqual(status.statusCode, 200, "Response status code is not 200")

            networkExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout addPushNotificationsOnChannels")
        })
    }
    
    func testRemovePushNotificationFromNilChannelWithNilDevicePushToken() {
        let networkExpectation = self.expectationWithDescription("Remove Push Expectation.")
        
        self.apnsClient.removePushNotificationsFromChannels(nil, withDevicePushToken: nil) { (status: PNAcknowledgmentStatus!) -> Void in
            XCTAssertNotNil(status)
            XCTAssertTrue(status.error)
            XCTAssertEqual(status.operation, PNOperationType.RemoveAllPushNotificationsOperation, "Wrong operation.")
            
            XCTAssertEqual(status.statusCode, 400, "Response status code is not 400")
            
            networkExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout remove push notifications from nil channels")
        })
    }
    
    func testRemovePushNotificationFromChannelWithNilDevicePushToken() {
        let networkExpectation = self.expectationWithDescription("Remove Push Expectation.")
        
        let channels = ["1", "2", "3"]
        
        self.apnsClient.removePushNotificationsFromChannels(channels, withDevicePushToken: nil) { (status: PNAcknowledgmentStatus!) -> Void in
            XCTAssertNotNil(status)
            XCTAssertTrue(status.error)
            XCTAssertEqual(status.operation, PNOperationType.RemovePushNotificationsFromChannelsOperation, "Wrong operation.")
            XCTAssertEqual(status.statusCode, 400, "Response status code is not 400")
            
            networkExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout remove push notification from channels")
        })
    }
    
    func testRemoveAllPushNotificationFromDevice() {
        let networkExpectation = self.expectationWithDescription("Remove Push Expectation.")
        
        self.apnsClient.removeAllPushNotificationsFromDeviceWithPushToken(self.pushToken) { (status: PNAcknowledgmentStatus!) -> Void in
            XCTAssertNotNil(status)
            XCTAssertFalse(status.error)
            XCTAssertEqual(status.operation, PNOperationType.RemoveAllPushNotificationsOperation, "Wrong operation.")
            
            XCTAssertEqual(status.statusCode, 200, "Response status code is not 200")
            
            networkExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout remove push expectation")
        })
    }


    func testRemoveAllPushNotificationFromDeviceWithNilToken() {
        let networkExpectation = self.expectationWithDescription("Remove Push Expectation.")

        
        self.apnsClient.removeAllPushNotificationsFromDeviceWithPushToken(nil) { (status: PNAcknowledgmentStatus!) -> Void in
            XCTAssertNotNil(status)
            XCTAssertTrue(status.error)
            XCTAssertEqual(status.operation, PNOperationType.RemoveAllPushNotificationsOperation, "Wrong operation.");
            
            XCTAssertEqual(status.statusCode, 400, "Response status code is not 400")
            
            networkExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout remove push expectation")
        })
    }
    
    func testAuditPushNotificationStatus() {
        let networkExpectation = self.expectationWithDescription("Push Expectation.")
        
        self.apnsClient.pushNotificationEnabledChannelsForDeviceWithPushToken(self.pushToken) { (result: PNAPNSEnabledChannelsResult!, PNErrorStatus status: PNErrorStatus!) -> Void in
            XCTAssertNil(status)
            XCTAssertEqual(result.operation, PNOperationType.PushNotificationEnabledChannelsOperation, "Wrong operation.")
            
            XCTAssertEqual(result.statusCode, 200, "Response status code is not 200");
            
            let channels : Array? = result.data.channels as Array?
            XCTAssertTrue(channels?.count == 3, "Channel list is not equal.")
            
            networkExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout audit push expecation")
        })
    }
    
    func testAuditPushNotificationStatusWithNilPushToken() {
        let networkExpectation = self.expectationWithDescription("Push Expectation.")
        
        self.apnsClient.pushNotificationEnabledChannelsForDeviceWithPushToken(nil) { (result: PNAPNSEnabledChannelsResult!, PNErrorStatus status: PNErrorStatus!) -> Void in
            XCTAssertNil(result)
            XCTAssertNotNil(status)
            XCTAssertEqual(status.operation, PNOperationType.PushNotificationEnabledChannelsOperation, "Wrong operation.")
            
            XCTAssertEqual(status.statusCode, 400, "Response status code is not 400")
            
            networkExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout addPushNotificationsOnChannels")
        })
    }

}
