/**
 @brief Global client constants declared here.

 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import <Foundation/Foundation.h>
#import "PNStructures.h"


#ifndef PNConstants_h
#define PNConstants_h

#pragma mark General information constants

// Stores client library version number
static NSString * const kPNLibraryVersion = @"4.6.1";

// Stores information about SDK codebase
static NSString * const kPNCommit = @"9087df2275ed28971c96694afe7f229678c7f8df";

/**
 @brief  Stores reference on unique identifier which is used to identify \b PubNub client among other 
         \b PubNub products.
 
 @since 4.5.0
 */
static NSString * const kPNClientIdentifier = @"com.pubnub.pubnub-objc";

#if TARGET_OS_IOS
    static NSString * const kPNClientName = @"ObjC-iOS";
#elif TARGET_OS_WATCH
    static NSString * const kPNClientName = @"ObjC-watchOS";
#elif TARGET_OS_TV
    static NSString * const kPNClientName = @"ObjC-tvOS";
#elif TARGET_OS_OSX
    static NSString * const kPNClientName = @"ObjC-macOS";
#endif // TARGET_OS_OSX


#pragma mark - Default client configuration

static NSString * const kPNDefaultOrigin = @"ps.pndsn.com";

static NSTimeInterval const kPNDefaultSubscribeMaximumIdleTime = 310.0f;
static NSTimeInterval const kPNDefaultNonSubscribeRequestTimeout = 10.0f;

static BOOL const kPNDefaultIsTLSEnabled = YES;
static PNHeartbeatNotificationOptions const kPNDefaultHeartbeatNotificationOptions = PNHeartbeatNotifyFailure;
static BOOL const kPNDefaultShouldKeepTimeTokenOnListChange = YES;
static BOOL const kPNDefaultShouldTryCatchUpOnSubscriptionRestore = YES;
static BOOL const kPNDefaultRequestMessageCountThreshold = 0;
static BOOL const kPNDefaultMaximumMessagesCacheSize = 100;
#if TARGET_OS_IOS
static BOOL const kPNDefaultShouldCompleteRequestsBeforeSuspension = YES;
#endif // TARGET_OS_IOS
static BOOL const kPNDefaultShouldStripMobilePayload = YES;

#endif // PNConstants_h
