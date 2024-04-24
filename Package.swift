// swift-tools-version:5.3
//
//  Package.swift
//
//  PubNub Real-time Cloud-Hosted Push API and Push Notification Client Frameworks
//  Copyright (c) 2013 PubNub Inc.
//  https://www.pubnub.com/
//  https://www.pubnub.com/terms
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  PubNub Real-time Cloud-Hosted Push API and Push Notification Client Frameworks
//  Copyright (c) 2013 PubNub Inc.
//  https://www.pubnub.com/
//  https://www.pubnub.com/terms
//

import PackageDescription

let package = Package(
  name: "PubNub",
  platforms: [
    .iOS(.v9),
    .macOS(.v10_11),
    .tvOS(.v10),
    .watchOS(.v4)
  ],
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(
      name: "PubNub",
      targets: ["PubNub"]
    ),
    .library(
      name: "PubNubBinaryFramework",
      targets: ["PubNubBinaryFramework"]
    )
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "PubNub",
      dependencies: []
    ),
    .binaryTarget(
      name: "PubNubBinaryFramework",
      url: "https://github.com/pubnub/objective-c/releases/download/v5.4.0/PubNub.ios.xcframework.zip",
      checksum: "9a0ed6ab4a452560ce163dadf195db7d2a4b709024eb6fe6bf891f954ce2957d"
    )
  ],
  swiftLanguageVersions: [.v5]
)
