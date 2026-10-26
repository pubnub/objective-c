// swift-tools-version:5.9
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

import Foundation
import PackageDescription

// Sources import headers by file name only (Xcode resolves them with header maps, SPM has none), so every source
// directory has to be on the header search path.
let sourcesPath = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("PubNub").path
let headerSearchPaths: [String] = {
  let enumerator = FileManager.default.enumerator(atPath: sourcesPath)
  var paths = [String]()
  while let relative = enumerator?.nextObject() as? String {
    var isDirectory: ObjCBool = false
    let exists = FileManager.default.fileExists(atPath: sourcesPath + "/" + relative, isDirectory: &isDirectory)
    guard exists, isDirectory.boolValue, !relative.hasPrefix("include") else { continue }
    paths.append(relative)
  }
  return paths.sorted()
}()

let package = Package(
  name: "PubNub",
  platforms: [
    .iOS("17.6"),
    .macOS("14.6"),
    .tvOS("17.6"),
    .watchOS("10.6")
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
      dependencies: ["PubNubCryptoKit"],
      path: "PubNub",
      exclude: ["Modules/Crypto/Cryptors/AES/CryptoKit"],
      resources: [.copy("../Framework/PubNub/PrivacyInfo.xcprivacy")],
      publicHeadersPath: "include",
      cSettings: [.headerSearchPath("include/PubNub")] + headerSearchPaths.map { .headerSearchPath($0) }
    ),
    .target(
      name: "PubNubCryptoKit",
      path: "PubNub/Modules/Crypto/Cryptors/AES/CryptoKit",
      sources: ["PNCryptoKitWrapper.swift"]
    )
  ],
  swiftLanguageVersions: [.v5]
)
