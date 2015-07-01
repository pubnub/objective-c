/**
 @brief Global client constants declared here.

 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import <Foundation/Foundation.h>


#ifndef PNConstants_h
#define PNConstants_h

#pragma mark General information constants

// Stores client library version number
static NSString * const kPNLibraryVersion = @"4.0.2";

// Stores information about SDK codebase
static NSString * const kPNBranchName = @"master";
static NSString * const kPNCommit = @"bb6a0016c4ec61a7815da5ca00bde6860d92a56e";

#if __IPHONE_OS_VERSION_MIN_REQUIRED
static NSString * const kPNClientName = @"ObjC-iOS";
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
static NSString * const kPNClientName = @"ObjC-MacOS";
#endif // __MAC_OS_X_VERSION_MIN_REQUIRED


#pragma mark - Default client configuration

static NSString * const kPNDefaultOrigin = @"pubsub.pubnub.com";

static NSTimeInterval const kPNDefaultSubscribeMaximumIdleTime = 310.0f;
static NSTimeInterval const kPNDefaultNonSubscribeRequestTimeout = 10.0f;

static BOOL const kPNDefaultIsTLSEnabled = YES;
static BOOL const kPNDefaultShouldKeepTimeTokenOnListChange = YES;
static BOOL const kPNDefaultShouldRestoreSubscription = YES;
static BOOL const kPNDefaultShouldTryCatchUpOnSubscriptionRestore = YES;

#endif // PNConstants_h
