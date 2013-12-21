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

// Stores timeout which is used for subscription
// requests to report that request failed
@property (nonatomic, assign) NSTimeInterval subscriptionRequestTimeout;

// Stores whether client should restore subscription on channels after connection
// has been restored or not
@property (nonatomic, assign, getter = shouldResubscribeOnConnectionRestore) BOOL resubscribeOnConnectionRestore;

// Stores whether client should restore subscription on channel with last time token
// or should use "0" time token for initial subscription
@property (nonatomic, assign, getter = shouldRestoreSubscriptionFromLastTimeToken) BOOL restoreSubscriptionFromLastTimeToken;

// Stores whether client can ignore security
// requirements and connection using plain HTTP
// connection in case of SSL error
@property (nonatomic, assign, getter = canIgnoreSecureConnectionRequirement) BOOL ignoreSecureConnectionRequirement;

// Stores whether SSL security rules should be
// lowered when connection error occurs or not
@property (nonatomic, assign, getter = shouldReduceSecurityLevelOnError) BOOL reduceSecurityLevelOnError;

// Stores whether connection should be established
// with SSL support or not
@property (nonatomic, assign, getter = shouldUseSecureConnection) BOOL useSecureConnection;

// Stores whether connection should be restored
// if it failed in previous session or not
@property (nonatomic, assign, getter = shouldAutoReconnectClient) BOOL autoReconnectClient;

// Stores whether client should accept GZIP responses
// from remote origin or not
@property (nonatomic, assign, getter = shouldAcceptCompressedResponse) BOOL acceptCompressedResponse;


#pragma mark - Class methods

/**
 * Retrieve reference on default configuration
 * which is initiated with values from 
 * PNDefaultConfiguration.h header file
 */
+ (PNConfiguration *)defaultConfiguration;

/**
 * Retrieve reference on lightweight configuration which
 * require only few parameters from user
 */
+ (PNConfiguration *)configurationWithPublishKey:(NSString *)publishKey
                                    subscribeKey:(NSString *)subscribeKey
                                       secretKey:(NSString *)secretKey;
+ (PNConfiguration *)configurationWithPublishKey:(NSString *)publishKey
                                    subscribeKey:(NSString *)subscribeKey
                                       secretKey:(NSString *)secretKey
                                authorizationKey:(NSString *)authorizationKey;
+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName
                                 publishKey:(NSString *)publishKey 
                               subscribeKey:(NSString *)subscribeKey
                                  secretKey:(NSString *)secretKey;
+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName
                                 publishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey
                                  secretKey:(NSString *)secretKey
                           authorizationKey:(NSString *)authorizationKey;

/**
 * Retrieve reference on configuration with full
 * set of options specified by user
 */
+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName
                                 publishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey
                                  secretKey:(NSString *)secretKey
                                  cipherKey:(NSString *)cipherKey;
+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName
                                 publishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey
                                  secretKey:(NSString *)secretKey
                                  cipherKey:(NSString *)cipherKey
                           authorizationKey:(NSString *)authorizationKey;


#pragma mark - Instance methods

/**
 * Initialize configuration instance with specified
 * set of parameters
 */
- (id)initWithOrigin:(NSString *)originHostName
          publishKey:(NSString *)publishKey
        subscribeKey:(NSString *)subscribeKey
           secretKey:(NSString *)secretKey
           cipherKey:(NSString *)cipherKey;
- (id)initWithOrigin:(NSString *)originHostName
          publishKey:(NSString *)publishKey
        subscribeKey:(NSString *)subscribeKey
           secretKey:(NSString *)secretKey
           cipherKey:(NSString *)cipherKey
    authorizationKey:(NSString *)authorizationKey;

#pragma mark -


@end
