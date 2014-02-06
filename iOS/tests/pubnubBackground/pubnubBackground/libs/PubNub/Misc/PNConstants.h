//
//  PNConstants.h
//  pubnub
//
//  This header is used to store set of
//  PubNub constants which will be used
//  all other the library.
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#ifndef PNConstants_h
#define PNConstants_h


#pragma mark General information constants

// Stores client library version number
static NSString * const kPNClientVersion = @"3.5.5";

#if __IPHONE_OS_VERSION_MIN_REQUIRED
static NSString * const kPNClientName = @"Obj-C-iOS";
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
static NSString * const kPNClientName = @"Obj-C-MacOS";
#endif


#pragma mark - Request constants

// Stores reference on PubNub service domain
static NSString * const kPNServiceMainDomain = @"pubnub.com";

#if __IPHONE_OS_VERSION_MIN_REQUIRED
static NSString * const kPNDefaultOriginHost = @"ios.pubnub.com";
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
static NSString * const kPNDefaultOriginHost = @"macos.pubnub.com";
#endif
static BOOL const kPNSecureConnectionByDefault = YES;
static BOOL const kPNShouldAutoReconnectClientByDefault = YES;
static BOOL const kPNShouldReduceSecurityLevelOnErrorByDefault = YES;
static BOOL const kPNCanIgnoreSecureConnectionRequirementByDefault = NO;

// Stores how many times request can be rescheduled because of stream errors
static NSUInteger const kPNRequestMaximumRetryCount = 3;

// This interval is used by timer which is triggered in specified time interval to help reachability determine real connection state by sending
// small request to the target server
static NSTimeInterval const kPNReachabilityOriginLookupInterval = 10.0f;
static NSTimeInterval const kPNReachabilityOriginLookupTimeout = 5.0f;

// This is the channel which is used by latency meter to measure network latency (prefix from unique client session will be added)
static NSString * const kPNLatencyMeterChannel = @"ltm";

#endif // PNConstants_h
