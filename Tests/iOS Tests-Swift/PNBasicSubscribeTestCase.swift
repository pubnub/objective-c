//
//  PNBasicSubscribeTestCase.swift
//  PubNub Tests
//
//  Created by Jordan Zucker on 7/28/15.
//
//

import Foundation

class PNBasicSubscribeTestCase: PNBasicClientTestCase, PNObjectEventListener {
    override func setUp() {
        super.setUp()
        self.client.addListener(self)
    }
    
    override func tearDown() {
        self.client.removeListener(self)
        super.tearDown()
    }
}
