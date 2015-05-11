/**
 @brief Global client constants declared here.

 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import <Foundation/Foundation.h>


#ifndef PNConstants_h
#define PNConstants_h

static NSString * const kPNDefaultOrigin = @"pubsub.pubnub.com";
static NSString * const kPNDefaultPublishKey = @"demo";
static NSString * const kPNDefaultSubscribeKey = @"demo";

static NSTimeInterval const kPNDefaultSubscribeRequestTimeout = 10.0f;
static NSTimeInterval const kPNDefaultNonSubscribeRequestTimeout = 10.0f;

static BOOL const kPNDefaultShouldUseSecureConnection = YES;
static BOOL const kPNDefaultCanFallbackToInsecureConnection = NO;
static BOOL const kPNDefaultShouldRestoreSubscription = YES;
static BOOL const kPNDefaultShouldTryCatchUpOnSubscriptionRestore = YES;

#endif // PNConstants_h
