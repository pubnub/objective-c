// swift-tools-version:5.0
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
    .library(
      name: "PubNub",
      targets: ["PubNub"]
    )
  ],
  dependencies: [],
  targets: [
    .target(
      name: "PubNub",
      dependencies: [],
      path: "Sources/PubNub",
      publicHeadersPath: "include",
      cSettings: [
          .headerSearchPath("include"),
          .define("PUBLIC_HEADER", to: "include"),
      ]
    )
  ],
  swiftLanguageVersions: [.v5]
)
