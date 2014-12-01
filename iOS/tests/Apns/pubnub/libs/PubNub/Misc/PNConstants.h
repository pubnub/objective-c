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
static NSString * const kPNLibraryVersion = @"3.7.3";

#if __IPHONE_OS_VERSION_MIN_REQUIRED
static NSString * const kPNClientName = @"ObjC-iOS";
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
static NSString * const kPNClientName = @"ObjC-MacOS";
#endif


#pragma mark - Request constants

// Stores reference on PubNub service domain
static NSString * const kPNServiceMainDomain = @"pubnub.com";
static NSString * const kPNDefaultOriginHost = @"pubsub.pubnub.com";
static BOOL const kPNSecureConnectionByDefault = YES;
static BOOL const kPNShouldAutoReconnectClientByDefault = YES;
static BOOL const kPNShouldReduceSecurityLevelOnErrorByDefault = YES;
static BOOL const kPNCanIgnoreSecureConnectionRequirementByDefault = NO;

// Stores how many times request can be rescheduled because of stream errors
static NSUInteger const kPNRequestMaximumRetryCount = 3;

// Stores how much times client will try to resubscribe on channels with new identifier before report that subscription
// failed
static NSUInteger const kPNClientIdentifierUpdateRetryCount = 3;

/**
 This value will be used for heartbeat timer to calculate interval (how many seconds will be subtracted from
 specified heartbeat timeout).
 */
static int const kPNHeartbeatRequestTimeoutOffset = 3;

/**
 Default heartbeat timeout which will be used in case if used specified incorrect value.
 */
static int const kPNDefaultHeartbeatTimeout = 5;

/**
 Maximum heartbeat interval which can be used.
 */
static int const kPNMaximumHeartbeatTimeout = 300;

/**
 Minimum heartbeat interval which can be used.
 */
static int const kPNMinimumHeartbeatTimeout = 5;

// This interval is used by timer which is triggered in specified time interval to help reachability determine real connection state by sending
// small request to the target server
static NSTimeInterval const kPNReachabilityOriginLookupInterval = 10.0f;
static NSTimeInterval const kPNReachabilityOriginLookupTimeout = 5.0f;

// This is the channel which is used by latency meter to measure network latency (prefix from unique client session will be added)
static NSString * const kPNLatencyMeterChannel = @"ltm";


#pragma mark Static

/**
 Used for \b PNClient instances in case if client identifier is unknown.
 */
extern NSString * const kPNAnonymousParticipantIdentifier;

#endif // PNConstants_h
