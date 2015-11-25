//
//  PNBasicClientCryptTestCase.swift
//  PubNub Tests
//
//  Created by Vadim Osovets on 9/16/15.
//
//

import Foundation
import UIKit
import XCTest

class PNBasicClientCryptTestCase: PNBasicClientTestCase {
    
    lazy var cryptedConfiguration: PNConfiguration = {
        let lazyConfig = PNConfiguration(publishKey: "demo-36", subscribeKey: "demo-36")
        lazyConfig.uuid = "322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C"
        lazyConfig.cipherKey = "chiper key";
        return lazyConfig
        }()
    
    lazy var cryptedClient: PubNub = {
        return PubNub.clientWithConfiguration(self.cryptedConfiguration)
        }()
}
