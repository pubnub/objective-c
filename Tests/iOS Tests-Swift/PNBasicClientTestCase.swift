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

}
