//
//  PNDefaultConfiguration.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#ifndef PNDefaultConfiguration_h
#define PNDefaultConfiguration_h

// Stores reference on host URL which is used to access PubNub services
<<<<<<< HEAD
static NSString * const kPNOriginHost = @"presence-beta.pubnub.com";

// Stores reference on keys which is required to establish connection and send packets to it
static NSString * const kPNPublishKey = @"pub-c-c9b0fe21-4ae1-433b-b766-62667cee65ef";
static NSString * const kPNSubscriptionKey = @"sub-c-d91ee366-9dbd-11e3-a759-02ee2ddab7fe";
static NSString * const kPNSecretKey = @"sec-c-ZDUxZGEyNmItZjY4Ny00MjJmLWE0MjQtZTQyMDM0NTY2MDVk";
=======
static NSString * const kPNOriginHost = @"pubsub.pubnub.com";

// Stores reference on keys which is required to establish connection and send packets to it
static NSString * const kPNPublishKey = @"demo";
static NSString * const kPNSubscriptionKey = @"demo";
static NSString * const kPNSecretKey = nil;
>>>>>>> fix-pt65153600
static NSString * const kPNCipherKey = nil;
static NSString * const kPNAuthorizationKey = nil;
static BOOL const kPNSecureConnectionRequired = YES;
static BOOL const kPNShouldAutoReconnectClient = YES;
<<<<<<< HEAD
static BOOL const kPNShouldKeepTimeTokenOnChannelsListChange = YES;
=======
>>>>>>> fix-pt65153600
static BOOL const kPNShouldResubscribeOnConnectionRestore = YES;
static BOOL const kPNShouldRestoreSubscriptionFromLastTimeToken = YES;
static BOOL const kPNShouldAcceptCompressedResponse = YES;

static NSTimeInterval const kPNConnectionIdleTimeout = 310.0f;
static NSTimeInterval const kPNNonSubscriptionRequestTimeout = 10.0f;
static NSTimeInterval const kPNSubscriptionRequestTimeout = 10.0f;

<<<<<<< HEAD
/**
 This value used by server to identify when it should kick subscribed user (UUID during \b PubNub configuration) by
 timeout.

 Default value is set to \b 0.0 which mean that server will timeout client by default inactivity timeout (depend on
 server configuration and conditions).
 
 @warning Property will be completely removed before feature release.
 */
static NSTimeInterval const kPNPresenceExpirationTimeout = 0.0f;

/**
 This value used by server to identify when it should kick subscribed user (UUID during \b PubNub configuration) by
 timeout.
 
 Default value is set to \b 0 which mean that server will timeout client by default inactivity timeout (depend on
 server configuration and conditions).
 */
static int const kPNPresenceHeartbeatTimeout = 200;

/**
 This interval is used by client to send heartbeat requests with specified 'heartbeat timeout' value.
 
 @note If this value will be bigger then allowed maximum (\b 300 seconds) or same or larger then specified heartbeat 
 timeout value, it will be reset to default value.
 */
static int const kPNPresenceHeartbeatInterval = 200;

=======
>>>>>>> fix-pt65153600
// This flag tells whether client should reduce SSL rules when connecting to remote origin because of connection
// error (which probably caused by SSL certificate validation error) If set to YES,
// client will try to preserve SSL security but will use not so strict rules as for remote origin SSL certificate
static BOOL const kPNShouldReduceSecurityLevelOnError = YES;

// This flag tells whether client can discard security option and connect using plain HTTP connection or not. This
// option will be used only if client will fail to connect with specified security rules.
static BOOL const kPNCanIgnoreSecureConnectionRequirement = YES;


#endif // PNDefaultConfiguration_h
