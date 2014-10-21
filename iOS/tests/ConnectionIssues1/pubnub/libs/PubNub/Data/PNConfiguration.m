//
//  PNConfiguration.m
//  pubnub
//
//  This class allow to configure PubNub
//  base class with required set of parameters.
//
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#import "PNConfiguration.h"
#import "PNDefaultConfiguration.h"
#import "PNConstants.h"
#import "PNHelper.h"
#import "PNLogger.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub configuration must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNConfiguration () <NSCopying>


#pragma mark - Properties

// Stores reference on services host name
@property (nonatomic, copy) NSString *origin;

// Stores reference on original origin host address
// (this property is used when DNS killer is required)
@property (nonatomic, copy) NSString *realOrigin;

// Stores reference on keys which is required
// to establish connection and send packets to it
@property (nonatomic, copy) NSString *publishKey;
@property (nonatomic, copy) NSString *subscriptionKey;
@property (nonatomic, copy) NSString *secretKey;


#pragma mark - Instance methods


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
 
 @param shouldApplyOnReceiver
 If set to \c YES then receiver information will be updated w/o copy creation.
 
 @return New instance which is based on original instance with changed options as specified in parameters.
 */
- (PNConfiguration *)updatedConfigurationWithOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey
                                       subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey
                                          cipherKey:(NSString *)cipherKey authorizationKey:(NSString *)authorizationKey
                                       applyInPlace:(BOOL)shouldApplyOnReceiver;

#pragma mark -


@end


#pragma mark - Public interface methods

@implementation PNConfiguration


#pragma mark - Class methods

+ (PNConfiguration *)defaultConfiguration {
    
    return [self configurationForOrigin:kPNOriginHost publishKey:kPNPublishKey subscribeKey:kPNSubscriptionKey
                              secretKey:kPNSecretKey cipherKey:kPNCipherKey];
}

+ (PNConfiguration *)configurationWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey
                                       secretKey:(NSString *)secretKey {
    
    return [self configurationWithPublishKey:publishKey subscribeKey:subscribeKey secretKey:secretKey
                            authorizationKey:kPNAuthorizationKey];
}

+ (PNConfiguration *)configurationWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey
                                       secretKey:(NSString *)secretKey authorizationKey:(NSString *)authorizationKey {
    
    return [self configurationForOrigin:kPNDefaultOriginHost publishKey:publishKey subscribeKey:subscribeKey
                              secretKey:secretKey authorizationKey:authorizationKey];
}

+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey {
    
    return [self configurationForOrigin:originHostName publishKey:publishKey subscribeKey:subscribeKey
                              secretKey:secretKey cipherKey:kPNCipherKey authorizationKey:kPNAuthorizationKey];
}

+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey
                           authorizationKey:(NSString *)authorizationKey {

    return [self configurationForOrigin:originHostName publishKey:publishKey subscribeKey:subscribeKey
                                  secretKey:secretKey cipherKey:kPNCipherKey authorizationKey:authorizationKey];
}

+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey
                                  cipherKey:(NSString *)cipherKey {
    
    return [self configurationForOrigin:originHostName publishKey:publishKey subscribeKey:subscribeKey secretKey:secretKey
                              cipherKey:cipherKey authorizationKey:kPNAuthorizationKey];
}

+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey
                                  cipherKey:(NSString *)cipherKey authorizationKey:(NSString *)authorizationKey {

    return [[[self class] alloc] initWithOrigin:originHostName publishKey:publishKey subscribeKey:subscribeKey
                                      secretKey:secretKey cipherKey:cipherKey authorizationKey:authorizationKey];
}


#pragma mark - Instance methods

- (id)initWithOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey
           secretKey:(NSString *)secretKey cipherKey:(NSString *)cipherKey {

    return [self initWithOrigin:originHostName publishKey:publishKey subscribeKey:subscribeKey secretKey:secretKey
                      cipherKey:cipherKey authorizationKey:kPNAuthorizationKey];
}

- (id)initWithOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey
           secretKey:(NSString *)secretKey cipherKey:(NSString *)cipherKey authorizationKey:(NSString *)authorizationKey {
    
    // Checking whether initialization was successful or not
    if((self = [super init])) {
        
        self.origin = ([originHostName length] > 0 ? originHostName : kPNDefaultOriginHost);
        self.realOrigin = self.origin;
        self.publishKey = (publishKey ? publishKey : @"");
        self.subscriptionKey = (subscribeKey ? subscribeKey:@"");
        self.secretKey = (secretKey ? secretKey : nil);
        self.cipherKey = (cipherKey ? cipherKey : @"");
        self.authorizationKey = (authorizationKey ? authorizationKey : @"");
        self.useSecureConnection = kPNSecureConnectionRequired;
        self.autoReconnectClient = kPNShouldAutoReconnectClient;
        self.keepTimeTokenOnChannelsListChange = kPNShouldKeepTimeTokenOnChannelsListChange;
        self.reduceSecurityLevelOnError = kPNShouldReduceSecurityLevelOnError;
        self.ignoreSecureConnectionRequirement = kPNCanIgnoreSecureConnectionRequirement;
        self.resubscribeOnConnectionRestore = kPNShouldResubscribeOnConnectionRestore;
        self.restoreSubscriptionFromLastTimeToken = kPNShouldRestoreSubscriptionFromLastTimeToken;
        self.acceptCompressedResponse = kPNShouldAcceptCompressedResponse;
        self.nonSubscriptionRequestTimeout = kPNNonSubscriptionRequestTimeout;
        self.subscriptionRequestTimeout = kPNSubscriptionRequestTimeout;
        self.presenceHeartbeatTimeout = kPNPresenceHeartbeatTimeout;
        self.presenceHeartbeatInterval = MAX(self.presenceHeartbeatTimeout - kPNHeartbeatRequestTimeoutOffset,
                                             kPNPresenceHeartbeatInterval);
    }
    
    
    return self;
}

- (PNConfiguration *)updatedConfigurationWithOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey
                                       subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey
                                          cipherKey:(NSString *)cipherKey authorizationKey:(NSString *)authorizationKey {
    
    return [self updatedConfigurationWithOrigin:originHostName publishKey:publishKey subscribeKey:subscribeKey
                                      secretKey:secretKey cipherKey:cipherKey authorizationKey:authorizationKey
                                   applyInPlace:NO];
}

- (PNConfiguration *)updatedConfigurationWithOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey
                                       subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey
                                          cipherKey:(NSString *)cipherKey authorizationKey:(NSString *)authorizationKey
                                       applyInPlace:(BOOL)shouldApplyOnReceiver {
    
    PNConfiguration *updatedConfiguration = (shouldApplyOnReceiver ? self : [self copy]);
    updatedConfiguration.origin = ([originHostName length] > 0 ? originHostName : kPNDefaultOriginHost);
    updatedConfiguration.realOrigin = self.origin;
    updatedConfiguration.publishKey = (publishKey ? publishKey : @"");
    updatedConfiguration.subscriptionKey = (subscribeKey ? subscribeKey:@"");
    updatedConfiguration.secretKey = (secretKey ? secretKey : nil);
    updatedConfiguration.cipherKey = (cipherKey ? cipherKey : @"");
    updatedConfiguration.authorizationKey = (authorizationKey ? authorizationKey : @"");
    
    
    return updatedConfiguration;
}

- (id)copyWithZone:(NSZone *)zone {
    
    PNConfiguration *configuration = [[[self class] allocWithZone:zone] init];
    [configuration migrateConfigurationFrom:self];
    
    
    return configuration;
}

- (BOOL)requiresConnectionResetWithConfiguration:(PNConfiguration *)configuration {

    BOOL shouldReset = NO;


    if (configuration != nil && [configuration isValid]) {

        // Checking whether critical configuration information has been changed or not
        if ((self.shouldUseSecureConnection != configuration.shouldUseSecureConnection) ||
            ![self.origin isEqualToString:configuration.origin] || ![self.authorizationKey isEqualToString:configuration.authorizationKey] ||
            self.presenceHeartbeatTimeout != configuration.presenceHeartbeatTimeout) {

            shouldReset = YES;
        }
    }

    return shouldReset;
}

- (void)migrateConfigurationFrom:(PNConfiguration *)configuration {
    
    [self updatedConfigurationWithOrigin:configuration.origin publishKey:configuration.publishKey
                            subscribeKey:configuration.subscriptionKey secretKey:configuration.secretKey
                               cipherKey:configuration.cipherKey authorizationKey:configuration.authorizationKey
                            applyInPlace:YES];
    
    self.useSecureConnection = configuration.shouldUseSecureConnection;
    self.autoReconnectClient = configuration.shouldAutoReconnectClient;
    self.keepTimeTokenOnChannelsListChange = configuration.shouldKeepTimeTokenOnChannelsListChange;
    self.reduceSecurityLevelOnError = configuration.shouldReduceSecurityLevelOnError;
    self.ignoreSecureConnectionRequirement = configuration.canIgnoreSecureConnectionRequirement;
    self.resubscribeOnConnectionRestore = configuration.shouldResubscribeOnConnectionRestore;
    self.restoreSubscriptionFromLastTimeToken = configuration.shouldRestoreSubscriptionFromLastTimeToken;
    self.acceptCompressedResponse = configuration.shouldAcceptCompressedResponse;
    self.nonSubscriptionRequestTimeout = configuration.nonSubscriptionRequestTimeout;
    self.subscriptionRequestTimeout = configuration.subscriptionRequestTimeout;
    self.presenceHeartbeatTimeout = configuration.presenceHeartbeatTimeout;
    self.presenceHeartbeatInterval = configuration.presenceHeartbeatInterval;
}

- (BOOL)isEqual:(PNConfiguration *)configuration {
    
    BOOL isEqual = configuration != nil;
    if (isEqual && (self.origin || configuration.origin)) {
        
        isEqual = [self.origin isEqualToString:configuration.origin];
    }
    if (isEqual && (self.publishKey || configuration.publishKey)) {
        
        isEqual = [self.publishKey isEqualToString:configuration.publishKey];
    }
    if (isEqual && (self.subscriptionKey || configuration.subscriptionKey)) {
        
        isEqual = [self.subscriptionKey isEqualToString:configuration.subscriptionKey];
    }
    if (isEqual && (self.secretKey || configuration.secretKey)) {
        
        isEqual = [self.secretKey isEqualToString:configuration.secretKey];
    }
    if (isEqual && (self.cipherKey || configuration.cipherKey)) {
        
        isEqual = [self.cipherKey isEqualToString:configuration.cipherKey];
    }
    if (isEqual && (self.authorizationKey || configuration.authorizationKey)) {
        
        isEqual = [self.authorizationKey isEqualToString:configuration.authorizationKey];
    }
    isEqual = (isEqual ? (self.presenceHeartbeatTimeout == configuration.presenceHeartbeatTimeout) : isEqual);
    isEqual = (isEqual ? (self.presenceHeartbeatInterval == configuration.presenceHeartbeatInterval) : isEqual);
    isEqual = (isEqual ? (self.nonSubscriptionRequestTimeout == configuration.nonSubscriptionRequestTimeout) : isEqual);
    isEqual = (isEqual ? (self.subscriptionRequestTimeout == configuration.subscriptionRequestTimeout) : isEqual);
    isEqual = (isEqual ? (self.shouldKeepTimeTokenOnChannelsListChange == configuration.shouldKeepTimeTokenOnChannelsListChange) : isEqual);
    isEqual = (isEqual ? (self.shouldResubscribeOnConnectionRestore == configuration.shouldResubscribeOnConnectionRestore) : isEqual);
    isEqual = (isEqual ? (self.shouldRestoreSubscriptionFromLastTimeToken == configuration.shouldRestoreSubscriptionFromLastTimeToken) : isEqual);
    isEqual = (isEqual ? (self.canIgnoreSecureConnectionRequirement == configuration.canIgnoreSecureConnectionRequirement) : isEqual);
    isEqual = (isEqual ? (self.shouldReduceSecurityLevelOnError == configuration.shouldReduceSecurityLevelOnError) : isEqual);
    isEqual = (isEqual ? (self.shouldUseSecureConnection == configuration.shouldUseSecureConnection) : isEqual);
    isEqual = (isEqual ? (self.shouldAutoReconnectClient == configuration.shouldAutoReconnectClient) : isEqual);
    isEqual = (isEqual ? (self.shouldAcceptCompressedResponse == configuration.shouldAcceptCompressedResponse) : isEqual);
    
    
    return isEqual;
}

- (void)setPresenceExpirationTimeout:(NSTimeInterval)presenceExpirationTimeout {
    
    _presenceExpirationTimeout = MAX(kPNMinimumHeartbeatTimeout, MIN(kPNMaximumHeartbeatTimeout, presenceExpirationTimeout));
}

- (void)setPresenceHeartbeatTimeout:(int)presenceHeartbeatTimeout {
    
    _presenceHeartbeatTimeout = MIN(kPNMaximumHeartbeatTimeout, presenceHeartbeatTimeout);
    if ([self presenceHeartbeatTimeout] <= 0 && _presenceExpirationTimeout > 0) {
        
        [self setPresenceHeartbeatInterval:_presenceHeartbeatTimeout];
    }
}

- (void)setPresenceHeartbeatInterval:(int)presenceHeartbeatInterval {
    
    if (self.presenceHeartbeatTimeout > 0 && (presenceHeartbeatInterval >= kPNMaximumHeartbeatTimeout ||
                                              presenceHeartbeatInterval >= self.presenceHeartbeatTimeout)) {
        
        presenceHeartbeatInterval = self.presenceHeartbeatTimeout - kPNHeartbeatRequestTimeoutOffset;
    }
    else if (presenceHeartbeatInterval <= (kPNMinimumHeartbeatTimeout - kPNHeartbeatRequestTimeoutOffset)) {
        
        presenceHeartbeatInterval = kPNMinimumHeartbeatTimeout - kPNHeartbeatRequestTimeoutOffset;
    }
    
    
    _presenceHeartbeatInterval = presenceHeartbeatInterval;
}

- (BOOL)shouldKillDNSCache {
    
    return ![self.origin isEqualToString:self.realOrigin];
}

- (void)shouldKillDNSCache:(BOOL)shouldKillDNSCache {

    if (shouldKillDNSCache) {

        NSString *subDomain = [self.realOrigin stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",
                                                                                     kPNServiceMainDomain]
                                                                         withString:@""];

        self.origin = [NSString stringWithFormat:@"%@-%ld.%@", subDomain, (long)[PNHelper randomInteger],
                        kPNServiceMainDomain];
    }
    else {

        self.origin = self.realOrigin;
    }
}

- (BOOL)isValid {
    
    return ([self.publishKey length] > 0 || [self.subscriptionKey length] > 0);
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"\n(%p) Configuration for: %@ (secured: %@)\n"
                                       "Publish key (optional for read-only application): %@\n"
                                       "Subscription key (optional for write-only application): %@\n"
                                       "Secret key (required for PAM): %@\n"
                                       "Cipher key (optional): %@\n"
                                       "Authorization key: %@",
            self, self.origin, (self.shouldUseSecureConnection ? @"YES" : @"NO"), (([self.publishKey length] > 0) ? self.publishKey : @"-missing-"),
            (([self.subscriptionKey length] > 0) ? self.subscriptionKey : @"-missing-"), (([self.secretKey length] > 0) ? self.secretKey : @"-missing-"),
            (([self.cipherKey length] > 0) ? self.cipherKey : @"-no encription key-"), (([self.authorizationKey length] > 0) ? self.authorizationKey : @"-missing-")];
}

#pragma mark -


@end
