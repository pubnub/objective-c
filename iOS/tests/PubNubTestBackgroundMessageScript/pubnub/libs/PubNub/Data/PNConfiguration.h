//
//  PNConfiguration.h
//  pubnub
//
//  This class allow to configure PubNub
//  base class with required set of parameters.
//
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#import <Foundation/Foundation.h>


@interface PNConfiguration : NSObject


#pragma mark Properties

// Stores reference on services host name
@property (nonatomic, readonly, copy) NSString *origin;

// Stores reference on keys which is required
// to establish connection and send packets to it
@property (nonatomic, readonly, copy) NSString *publishKey;
@property (nonatomic, readonly, copy) NSString *subscriptionKey;
@property (nonatomic, readonly, copy) NSString *secretKey;
@property (nonatomic, copy) NSString *cipherKey;

// Stores reference on authorization key which is used for
// request authorization
@property (nonatomic, copy) NSString *authorizationKey;

// Stores timeout which is used for non-subscription
// requests to report that request failed
@property (nonatomic, assign) NSTimeInterval nonSubscriptionRequestTimeout;

// Stores timeout which is used for subscription requests to report that request failed
@property (nonatomic, assign) NSTimeInterval subscriptionRequestTimeout;

/**
 Stores whether connection should be restored if it failed in previous session or not.
 */
@property (nonatomic, assign, getter = shouldAutoReconnectClient) BOOL autoReconnectClient;

/**
 Stores whether \b PubNub client should during subscription on additional channel use last time token or require new
 onw from server.
 */
@property (nonatomic, assign, getter = shouldKeepTimeTokenOnChannelsListChange) BOOL keepTimeTokenOnChannelsListChange;

/**
 Stores whether client should restore subscription on channels after connection has been restored or not.
 */
@property (nonatomic, assign, getter = shouldResubscribeOnConnectionRestore) BOOL resubscribeOnConnectionRestore;

/**
 Stores whether client should restore subscription on channel with last time token or should use "0" time token
 for initial subscription.
 */
@property (nonatomic, assign, getter = shouldRestoreSubscriptionFromLastTimeToken) BOOL restoreSubscriptionFromLastTimeToken;

/**
 Stores whether connection should be established with SSL support or not.
 */
@property (nonatomic, assign, getter = shouldUseSecureConnection) BOOL useSecureConnection;

/**
 Stores whether SSL security rules should be lowered when connection error occurs or not.
 */
@property (nonatomic, assign, getter = shouldReduceSecurityLevelOnError) BOOL reduceSecurityLevelOnError;

/**
 Stores whether client can ignore security requirements and connection using plain HTTP connection in case of SSL
 error.
 */
@property (nonatomic, assign, getter = canIgnoreSecureConnectionRequirement) BOOL ignoreSecureConnectionRequirement;

// Stores whether client should accept GZIP responses
// from remote origin or not
@property (nonatomic, assign, getter = shouldAcceptCompressedResponse) BOOL acceptCompressedResponse;

/**
 Stores timeout which is used by server to kick inactive clients (by UUID).
 
 @warning Property will be completely removed before feature release.
 */
@property (nonatomic, assign) NSTimeInterval presenceExpirationTimeout DEPRECATED_MSG_ATTRIBUTE(" Use 'presenceHeartbeatTimeout' instead.");

/**
 Stores timeout which is used by server to kick inactive clients (by UUID).
 */
@property (nonatomic, assign) int presenceHeartbeatTimeout;

/**
 Stores interval at which heartbeat request should be sent by client.
 */
@property (nonatomic, assign) int presenceHeartbeatInterval;


#pragma mark - Class methods

/**
 * Retrieve reference on default configuration
 * which is initiated with values from 
 * PNDefaultConfiguration.h header file
 */
+ (PNConfiguration *)defaultConfiguration;

/**
 Retrieve reference on lightweight configuration which require only few parameters from user.
 */
+ (PNConfiguration *)configurationWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey
                                       secretKey:(NSString *)secretKey;
+ (PNConfiguration *)configurationWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey
                                       secretKey:(NSString *)secretKey authorizationKey:(NSString *)authorizationKey;
+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey;
+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey
                           authorizationKey:(NSString *)authorizationKey;

/**
 Retrieve reference on configuration with full set of options specified by user.
 */
+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey
                                  cipherKey:(NSString *)cipherKey;
+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey
                                  cipherKey:(NSString *)cipherKey authorizationKey:(NSString *)authorizationKey;


#pragma mark - Instance methods

/**
 * Initialize configuration instance with specified
 * set of parameters
 */
- (id)initWithOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey
           secretKey:(NSString *)secretKey cipherKey:(NSString *)cipherKey;
- (id)initWithOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey
           secretKey:(NSString *)secretKey cipherKey:(NSString *)cipherKey authorizationKey:(NSString *)authorizationKey;

/**
 Construct new configuration based on provided instance with new values. This method is useful if only magor settings should be changed
 (excpet state flags and time outs).
 
 @param originHostName
 Updated origin address which should be assigned to the configuration. If \c 'nil' is passed, previous value will be used.
 
 @param publishKey
 Updated publish key which will be used with message posting API.
 
 @param subscribeKey
 Updated subscribe key which will be used with subscription API to receive messages from \b PubNub service.
 
 @param secretKey
 Updated secret key which will be used along with PAM API to sign access rights manipulation requests.
 
 @param cipherKey
 Updated cipher key which will be automatically used by \b PubNub client to encrypt messages which is sent with publish API.
 
 @param authorizationKey
 Updated authorization key which is important for PAM enabled keys, so \b PubNub service will recognize client which connects
 and what he can do.
 
 @return New instance which is based on original instance with changed options as specified in parameters.
 */
- (PNConfiguration *)updatedConfigurationWithOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey
                                       subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey
                                          cipherKey:(NSString *)cipherKey authorizationKey:(NSString *)authorizationKey;

#pragma mark -


@end
