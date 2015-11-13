//
//  PNHistoryTests.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 8/6/15.
//
//

import UIKit
import XCTest

class PNHistoryTests: PNBasicClientTestCase {
    
    override func isRecording() -> Bool {
        return false
    }
    
    let publishTestsChannelName = "2EC925F0-B996-47A4-AF54-A605E1A9AEBA"
    
    func testHistory() {
        let networkExpectation = self.expectationWithDescription("network")
        self.client.historyForChannel("a", start:NSDecimalNumber(string: "14356962344283504"), end:NSDecimalNumber(string: "14356962619609342"), withCompletion: { (result, status) -> Void in
            XCTAssertNil(status)
            XCTAssertNotNil(result)
            XCTAssertEqual(result.statusCode, 200)
            XCTAssertEqual(result.data.start, NSDecimalNumber(string: "14356962364490888"))
            XCTAssertEqual(result.data.end, NSDecimalNumber(string: "14356962609521455"))
            XCTAssertEqual(result.operation, PNOperationType.HistoryOperation)
            // might want to assert message array is exactly equal, for now just get count
            XCTAssertNotNil(result.data.messages)
            XCTAssertEqual(result.data.messages.count, 13)
            
            let expectedMessages  = ["*********...... 1244 - 2015-06-30 13:30:35",
                                        "**********..... 1245 - 2015-06-30 13:30:37",
                                        "***********.... 1246 - 2015-06-30 13:30:39",
                                        "************... 1247 - 2015-06-30 13:30:41",
                                        "*************.. 1248 - 2015-06-30 13:30:43",
                                        "**************. 1249 - 2015-06-30 13:30:45",
                                        "*************** 1250 - 2015-06-30 13:30:47",
                                        "*.............. 1251 - 2015-06-30 13:30:49",
                                        "**............. 1252 - 2015-06-30 13:30:51",
                                        "***............ 1253 - 2015-06-30 13:30:53",
                                        "****........... 1254 - 2015-06-30 13:30:55",
                                        "*****.......... 1255 - 2015-06-30 13:30:58",
                                        "******......... 1256 - 2015-06-30 13:31:00"]
            
            let receivedMessages: [String] = result.data.messages as! [String];
            XCTAssert(expectedMessages == receivedMessages, "Messages are not equal.")
            
            networkExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
                    XCTAssertNil(error, "Encountered error with publish call")
        })
    }

    func testHistoryWithTimeToken() {
        let networkExpectation = self.expectationWithDescription("network")
        
        self.client.historyForChannel("a", start:NSDecimalNumber(string: "14356962344283504"), end:NSDecimalNumber(string: "14356962619609342"), includeTimeToken:true, withCompletion: { (result, status) -> Void in
            XCTAssertNil(status)
            XCTAssertNotNil(result)
            XCTAssertEqual(result.statusCode, 200)
            XCTAssertEqual(result.data.start, NSDecimalNumber(string: "14356962364490888"))
            XCTAssertEqual(result.data.end, NSDecimalNumber(string: "14356962609521455"))
            XCTAssertEqual(result.operation, PNOperationType.HistoryOperation)
            // might want to assert message array is exactly equal, for now just get count
            XCTAssertNotNil(result.data.messages)
            XCTAssertEqual(result.data.messages.count, 13)
            
            let expectedMessages: [[String: NSObject]] = [
                [
                    "message" : "*********...... 1244 - 2015-06-30 13:30:35",
                    "timetoken" : NSDecimalNumber(string: "14356962364490888")
                ],
                [
                    "message" : "**********..... 1245 - 2015-06-30 13:30:37",
                    "timetoken" : NSDecimalNumber(string: "14356962384898753")
                ],
                [
                    "message" : "***********.... 1246 - 2015-06-30 13:30:39",
                    "timetoken" : NSDecimalNumber(string: "14356962405294305")
                ],
                [
                    "message" : "************... 1247 - 2015-06-30 13:30:41",
                    "timetoken" : NSDecimalNumber(string: "14356962425704863")
                ],
                [
                    "message" : "*************.. 1248 - 2015-06-30 13:30:43",
                    "timetoken" : NSDecimalNumber(string: "14356962446126788")
                ],
                [
                "message" : "**************. 1249 - 2015-06-30 13:30:45",
                "timetoken" : NSDecimalNumber(string: "14356962466542248")
                ],
                [
                "message" : "*************** 1250 - 2015-06-30 13:30:47",
                "timetoken" : NSDecimalNumber(string: "14356962486987818")
                ],
                [
                "message" : "*.............. 1251 - 2015-06-30 13:30:49",
                "timetoken" : NSDecimalNumber(string: "14356962507478694")
                ],
                [
                "message" : "**............. 1252 - 2015-06-30 13:30:51",
                "timetoken" : NSDecimalNumber(string: "14356962527885179")
                ],
                [
                "message" : "***............ 1253 - 2015-06-30 13:30:53",
                "timetoken" : NSDecimalNumber(string: "14356962548281499")
                ],
                [
                "message" : "****........... 1254 - 2015-06-30 13:30:55",
                "timetoken" : NSDecimalNumber(string: "14356962568708660")
                ],
                [
                "message" : "*****.......... 1255 - 2015-06-30 13:30:58",
                "timetoken" : NSDecimalNumber(string: "14356962589101722")
                ],
                [
                "message" : "******......... 1256 - 2015-06-30 13:31:00",
                "timetoken" : NSDecimalNumber(string: "14356962609521455")]]

            let receivedMessages: [[String: NSObject]]! = result.data.messages as! [[String: NSObject]]
            XCTAssert(receivedMessages == expectedMessages, "Unexpected result")
            
            networkExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func testHistoryWithLimit() {
        let networkExpectation = self.expectationWithDescription("network")
        
        self.client.historyForChannel("a", start:NSDecimalNumber(string: "14356962344283504"), end:NSDecimalNumber(string: "14356962619609342"), limit:3, withCompletion: { (result, status) -> Void in
            XCTAssertNil(status)
            XCTAssertNotNil(result)
            XCTAssertEqual(result.statusCode, 200)
            XCTAssertEqual(result.data.start, NSDecimalNumber(string: "14356962364490888"))
            XCTAssertEqual(result.data.end, NSDecimalNumber(string: "14356962405294305"))
            XCTAssertEqual(result.operation, PNOperationType.HistoryOperation)
            // might want to assert message array is exactly equal, for now just get count
            XCTAssertNotNil(result.data.messages)
            XCTAssertEqual(result.data.messages.count, 3)
            
            let expectedMessages: [String] = [
                "*********...... 1244 - 2015-06-30 13:30:35",
                "**********..... 1245 - 2015-06-30 13:30:37",
                "***********.... 1246 - 2015-06-30 13:30:39"
                ]
            
            let receivedMessages: [String]! = result.data.messages as! [String]
            XCTAssert(receivedMessages == expectedMessages, "Unexpected result")
            
            networkExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
    
    func testHistoryWithLimitAndTimeToken() {
        let networkExpectation = self.expectationWithDescription("network")
        
        self.client.historyForChannel("a", start:NSDecimalNumber(string: "14356962344283504"), end:NSDecimalNumber(string: "14356962619609342"), limit:3, includeTimeToken:true, withCompletion: { (result, status) -> Void in
            XCTAssertNil(status)
            XCTAssertNotNil(result)
            XCTAssertEqual(result.statusCode, 200)
            XCTAssertEqual(result.data.start, NSDecimalNumber(string: "14356962364490888"))
            XCTAssertEqual(result.data.end, NSDecimalNumber(string: "14356962405294305"))
            XCTAssertEqual(result.operation, PNOperationType.HistoryOperation)
            // might want to assert message array is exactly equal, for now just get count
            XCTAssertNotNil(result.data.messages)
            XCTAssertEqual(result.data.messages.count, 3)
            
            let expectedMessages: [[String: NSObject]] =
                [[
                "message" : "*********...... 1244 - 2015-06-30 13:30:35",
                "timetoken" : NSDecimalNumber(string: "14356962364490888")
                ],
                [
                "message" : "**********..... 1245 - 2015-06-30 13:30:37",
                "timetoken" : NSDecimalNumber(string: "14356962384898753")
                ],
                [
                "message" : "***********.... 1246 - 2015-06-30 13:30:39",
                "timetoken" : NSDecimalNumber(string: "14356962405294305")
                ]]
            
            let receivedMessages: [[String: NSObject]]! = result.data.messages as! [[String: NSObject]]
            XCTAssert(receivedMessages == expectedMessages, "Messages are not equal")
            
            networkExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with publish call")
        })
    }
}

