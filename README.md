# PubNub 4.0b for iOS 7+

### Changes from 3.x
* Removed support for iOS 6 and earlier
* Removed support for JSONKit
* Removed custom connection, request, logging, and reachability logic, replacing with NSURLSession, DDLog, and AFNetworking libraries
* Simplified serialization/deserialization threading logic
* Removed support for blocking, syncronous calls (all calls are now async)
* Simplified usability by enforcing completion block pattern -- client no longer supports Singleton, Delegate, Observer, Notifications response patterns
* Replaced configuration class with setter configuration pattern
* Consolidated instance method names

## Installing

* Create a new project in Xcode as you would normally.
* Open a terminal window, and $ cd into your project directory.
* Create a Podfile. This can be done by running
```
touch Podfile
```

* Open your Podfile.
* Populate it with:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'
pod 'AFNetworking', '~> 2.5'
pod 'CocoaLumberjack'
```

* Run:
 ```
 pod install
 ```

* Open the MyApp.xcworkspace that was created. This should be the file you use everyday to create your app.
