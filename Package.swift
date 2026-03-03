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
    .iOS(.v14),
    .macOS(.v11),
    .tvOS(.v14),
    .watchOS(.v7)
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
      resources: [.copy("../../Framework/PubNub/PrivacyInfo.xcprivacy")],
      cSettings: [
        .headerSearchPath("."),
        .headerSearchPath("Core"),
        .headerSearchPath("Data"),
        .headerSearchPath("Data/Builders"),
        .headerSearchPath("Data/Builders/API Call/APNS"),
        .headerSearchPath("Data/Builders/API Call/Actions/Message"),
        .headerSearchPath("Data/Builders/API Call/Files"),
        .headerSearchPath("Data/Builders/API Call/History"),
        .headerSearchPath("Data/Builders/API Call/Objects"),
        .headerSearchPath("Data/Builders/API Call/Objects/Channel"),
        .headerSearchPath("Data/Builders/API Call/Objects/Membership"),
        .headerSearchPath("Data/Builders/API Call/Objects/UUID"),
        .headerSearchPath("Data/Builders/API Call/Presence"),
        .headerSearchPath("Data/Builders/API Call/Publish"),
        .headerSearchPath("Data/Builders/API Call/State"),
        .headerSearchPath("Data/Builders/API Call/Stream"),
        .headerSearchPath("Data/Builders/API Call/Subscribe"),
        .headerSearchPath("Data/Builders/API Call/Time"),
        .headerSearchPath("Data/Managers"),
        .headerSearchPath("Data/Models"),
        .headerSearchPath("Data/Service Objects"),
        .headerSearchPath("Data/Service Objects/App Context"),
        .headerSearchPath("Data/Service Objects/Channel Groups"),
        .headerSearchPath("Data/Service Objects/Error"),
        .headerSearchPath("Data/Service Objects/File Sharing"),
        .headerSearchPath("Data/Service Objects/Message Persistence"),
        .headerSearchPath("Data/Service Objects/Message Reaction"),
        .headerSearchPath("Data/Service Objects/Presence"),
        .headerSearchPath("Data/Service Objects/Publish"),
        .headerSearchPath("Data/Service Objects/Push Notification"),
        .headerSearchPath("Data/Service Objects/Signal"),
        .headerSearchPath("Data/Service Objects/Subscribe"),
        .headerSearchPath("Data/Service Objects/Time"),
        .headerSearchPath("Data/Transport"),
        .headerSearchPath("Misc"),
        .headerSearchPath("Misc/Categories"),
        .headerSearchPath("Misc/Helpers"),
        .headerSearchPath("Misc/Helpers/Notifications Payload"),
        .headerSearchPath("Misc/Helpers/Notifications Payload/APNS"),
        .headerSearchPath("Misc/Logger/Additional/Console"),
        .headerSearchPath("Misc/Logger/Additional/File"),
        .headerSearchPath("Misc/Logger/Core"),
        .headerSearchPath("Misc/Logger/Data"),
        .headerSearchPath("Misc/Protocols"),
        .headerSearchPath("Misc/Protocols/Serializer/JSON"),
        .headerSearchPath("Misc/Protocols/Serializer/Object"),
        .headerSearchPath("Modules/Crypto"),
        .headerSearchPath("Modules/Crypto/Cryptors/AES"),
        .headerSearchPath("Modules/Crypto/Data"),
        .headerSearchPath("Modules/Crypto/Header"),
        .headerSearchPath("Modules/Serializer/JSON"),
        .headerSearchPath("Modules/Serializer/Object"),
        .headerSearchPath("Modules/Serializer/Object/Categories"),
        .headerSearchPath("Modules/Serializer/Object/Models"),
        .headerSearchPath("Modules/Transport"),
        .headerSearchPath("Modules/Transport/Categories"),
        .headerSearchPath("Network"),
        .headerSearchPath("Network/Parsers"),
        .headerSearchPath("Network/Requests"),
        .headerSearchPath("Network/Requests/Channel Groups"),
        .headerSearchPath("Network/Requests/Files"),
        .headerSearchPath("Network/Requests/Message Persistence"),
        .headerSearchPath("Network/Requests/Message Reaction/Message"),
        .headerSearchPath("Network/Requests/Objects"),
        .headerSearchPath("Network/Requests/Objects/Channel"),
        .headerSearchPath("Network/Requests/Objects/Membership"),
        .headerSearchPath("Network/Requests/Objects/UUID"),
        .headerSearchPath("Network/Requests/Presence"),
        .headerSearchPath("Network/Requests/Publish"),
        .headerSearchPath("Network/Requests/Push Notifications"),
        .headerSearchPath("Network/Requests/Signal"),
        .headerSearchPath("Network/Requests/Subscribe"),
        .headerSearchPath("Network/Requests/Time"),
        .headerSearchPath("Network/Responses"),
        .headerSearchPath("Network/Responses/App Context"),
        .headerSearchPath("Network/Responses/Channel Groups"),
        .headerSearchPath("Network/Responses/Error"),
        .headerSearchPath("Network/Responses/File Sharing"),
        .headerSearchPath("Network/Responses/Message Persistence"),
        .headerSearchPath("Network/Responses/Message Reaction"),
        .headerSearchPath("Network/Responses/Presence"),
        .headerSearchPath("Network/Responses/Publish"),
        .headerSearchPath("Network/Responses/Push Notification"),
        .headerSearchPath("Network/Responses/Signal"),
        .headerSearchPath("Network/Responses/Subscribe"),
        .headerSearchPath("Network/Responses/Time"),
        .headerSearchPath("Network/Streams"),
        .headerSearchPath("Protocols/Transport"),
      ],
      linkerSettings: [.linkedLibrary("z")]
    )
  ],
  swiftLanguageVersions: [.v5]
)
