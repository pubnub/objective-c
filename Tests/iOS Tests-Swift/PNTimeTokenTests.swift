//
//  PNTimeTokenTests.swift
//  PubNub Tests
//
//  Created by Jordan Zucker on 7/28/15.
//
//

import UIKit
import XCTest

class PNTimeTokenTests: PNBasicSubscribeTestCase {
    override func isRecording() -> Bool {
        return false
    }

    func testTimeToken() {
        // This is an example of a functional test case.
        let testTokenExpectation = self.expectationWithDescription("timeToken")
        self.client.timeWithCompletion { (result, status) -> Void in
            XCTAssertNil(status)
            XCTAssertNotNil(result)
            XCTAssertEqual(result!.operation, PNOperationType.TimeOperation)
            XCTAssertEqual(result!.statusCode, 200)
            XCTAssertEqual(result!.data.timetoken, NSNumber(longLong: 14355553745683928))
            testTokenExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error, "Encountered error with time token test")
        })
    }
}
