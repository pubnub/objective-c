/**
 @brief Global client constants declared here.

 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import <Foundation/Foundation.h>
#import "PNStructures.h"


#ifndef PNConstants_h
#define PNConstants_h

#pragma mark General information constants

// Stores client library version number
static NSString * const kPNLibraryVersion = @"4.4.1";

// Stores information about SDK codebase
static NSString * const kPNCommit = @"91a5176363d10d9e0c121e93aff23dce61a0f8e9";

#if TARGET_OS_WATCH
    static NSString * const kPNClientName = @"ObjC-watchOS";
#elif __IPHONE_OS_VERSION_MIN_REQUIRED
    static NSString * const kPNClientName = @"ObjC-iOS";
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
    static NSString * const kPNClientName = @"ObjC-MacOS";
#endif // __MAC_OS_X_VERSION_MIN_REQUIRED


#pragma mark - Default client configuration

static NSString * const kPNDefaultOrigin = @"pubsub.pubnub.com";

static NSTimeInterval const kPNDefaultSubscribeMaximumIdleTime = 310.0f;
static NSTimeInterval const kPNDefaultNonSubscribeRequestTimeout = 10.0f;

static BOOL const kPNDefaultIsTLSEnabled = YES;
static PNHeartbeatNotificationOptions const kPNDefaultHeartbeatNotificationOptions = PNHeartbeatNotifyFailure;
static BOOL const kPNDefaultShouldKeepTimeTokenOnListChange = YES;
static BOOL const kPNDefaultShouldRestoreSubscription = YES;
static BOOL const kPNDefaultShouldTryCatchUpOnSubscriptionRestore = YES;

#endif // PNConstants_h
