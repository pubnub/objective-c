#import "PNConfiguration+Private.h"
#import "PNRequestRetryConfiguration+Private.h"
#import "PNCryptoModule+Private.h"
#import "PNPrivateStructures.h"
#import "PNConstants.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// **PubNub** client configuration wrapper private extension.
@interface PNConfiguration () <NSCopying>


#pragma mark - Properties

/// String representation of filtering expression which should be applied to decide which updates should reach client.
///
/// > Warning: If your filter expression is malformed, ``PNEventsListener`` won't receive any messages and presence
/// events from service (only error status).
@property(copy, nullable, nonatomic) NSString *filterExpression;

/// Token which is used along with every request to **PubNub** service to identify client user.
///
/// **PubNub** service provide **PAM** (PubNub Access Manager) functionality which allow to specify access rights to
/// access **PubNub** service with provided `publishKey` and `subscribeKey` keys.
/// Access can be limited to concrete users. **PAM** system use this key to check whether client user has rights to
/// access to required service or not.
///
/// > Important: If `authToken` is set if till be used instead of `authKey`.
///
/// This property not set by default.
@property(copy, nullable, nonatomic) NSString *authToken;


#pragma mark - Initialization and Configuration

/// Initialize **PubNub** configuration wrapper instance.
///
/// - Throws: Exception in case if `userID` is empty string.
///
/// - Parameters:
///   - publishKey: Key which is used to push data / state to the **PubNub** network.
///   - subscribeKey: Key which is used to fetch data / state from the **PubNub** network.
///   - userID: Unique client identifier used to identify concrete client user from another which currently use
///   **PubNub** services.
/// - Returns: Initialized **PubNub** configuration wrapper instance.
- (instancetype)initWithPublishKey:(NSString *)publishKey
                      subscribeKey:(NSString *)subscribeKey
                            userID:(NSString *)userID;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNConfiguration


#pragma mark - Properties

- (void)setPresenceHeartbeatValue:(NSInteger)presenceHeartbeatValue {
  _presenceHeartbeatValue = presenceHeartbeatValue < 20 ? 20 : MIN(presenceHeartbeatValue, 300);
  _presenceHeartbeatInterval = (NSInteger)(_presenceHeartbeatValue * 0.5f) - 1;
}

- (void)setUserID:(NSString *)userID {
    if (!userID || [userID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        NSDictionary *errorInformation = @{
            NSLocalizedFailureReasonErrorKey: @"PubNub client doesn't generate UUID.",
            NSLocalizedRecoverySuggestionErrorKey: @"Specify own 'uuid' using PNConfiguration constructor."
        };

        @throw [NSException exceptionWithName:@"PNUnacceptableParametersInput"
                                       reason:@"identifier not set"
                                     userInfo:errorInformation];
    }

    _userID = [userID copy];
}


#pragma mark - Initialization and Configuration

+ (instancetype)configurationWithPublishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey
                                     userID:(NSString *)userID {
    NSParameterAssert(publishKey);
    NSParameterAssert(subscribeKey);

    return [[self alloc] initWithPublishKey:publishKey subscribeKey:subscribeKey userID:userID];
}

- (instancetype)initWithPublishKey:(NSString *)publishKey
                      subscribeKey:(NSString *)subscribeKey
                            userID:(NSString *)userID {
    if ((self = [super init])) {
        _origin = [kPNDefaultOrigin copy];
        _publishKey = [publishKey copy];
        _subscribeKey = [subscribeKey copy];
        _logLevel = PNNoneLogLevel;
        
        self.userID = userID;
        _subscribeMaximumIdleTime = kPNDefaultSubscribeMaximumIdleTime;
        _nonSubscribeRequestTimeout = kPNDefaultNonSubscribeRequestTimeout;
        _TLSEnabled = kPNDefaultIsTLSEnabled;
        _heartbeatNotificationOptions = kPNDefaultHeartbeatNotificationOptions;
        _suppressLeaveEvents = kPNDefaultShouldSuppressLeaveEvents;
        _managePresenceListManually = kPNDefaultShouldManagePresenceListManually;
        _keepTimeTokenOnListChange = kPNDefaultShouldKeepTimeTokenOnListChange;
        _catchUpOnSubscriptionRestore = kPNDefaultShouldTryCatchUpOnSubscriptionRestore;
        _useRandomInitializationVector = kPNDefaultUseRandomInitializationVector;
        _requestMessageCountThreshold = kPNDefaultRequestMessageCountThreshold;
        _fileMessagePublishRetryLimit = kPNDefaultFileMessagePublishRetryLimit;
        _maximumMessagesCacheSize = kPNDefaultMaximumMessagesCacheSize;
        
        PNRequestRetryConfiguration *retryConfiguration;
        retryConfiguration = [PNRequestRetryConfiguration configurationWithExponentialDelayExcludingEndpoints:
                              PNMessageSendEndpoint,
                              PNPresenceEndpoint,
                              PNFilesEndpoint,
                              PNMessageStorageEndpoint,
                              PNChannelGroupsEndpoint,
                              PNDevicePushNotificationsEndpoint,
                              PNAppContextEndpoint,
                              PNMessageReactionsEndpoint, 0];
        _requestRetry = retryConfiguration;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PNConfiguration *configuration = [[PNConfiguration allocWithZone:zone] init];
    configuration.origin = [self.origin copy];
    configuration.publishKey = [self.publishKey copy];
    configuration.subscribeKey = [self.subscribeKey copy];
    configuration.authKey = [self.authKey copy];
    configuration.authToken = [self.authToken copy];
    configuration.userID = [self.userID copy];
    configuration.cryptoModule = self.cryptoModule;
    configuration.logLevel = self.logLevel;
    configuration.loggers = self.loggers;
    configuration.filterExpression = [self.filterExpression copy];
    configuration.subscribeMaximumIdleTime = self.subscribeMaximumIdleTime;
    configuration.nonSubscribeRequestTimeout = self.nonSubscribeRequestTimeout;
    configuration->_presenceHeartbeatValue = self.presenceHeartbeatValue;
    configuration.presenceHeartbeatInterval = self.presenceHeartbeatInterval;
    configuration.heartbeatNotificationOptions = self.heartbeatNotificationOptions;
    configuration.managePresenceListManually = self.shouldManagePresenceListManually;
    configuration.suppressLeaveEvents = self.shouldSuppressLeaveEvents;
    configuration.TLSEnabled = self.isTLSEnabled;
    configuration.keepTimeTokenOnListChange = self.shouldKeepTimeTokenOnListChange;
    configuration.catchUpOnSubscriptionRestore = self.shouldTryCatchUpOnSubscriptionRestore;
    configuration.fileMessagePublishRetryLimit = self.fileMessagePublishRetryLimit;
    configuration.requestRetry = [self.requestRetry copy];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    configuration.cipherKey = self.cipherKey;
    configuration.useRandomInitializationVector = self.shouldUseRandomInitializationVector;
#pragma clang diagnostic pop
    configuration.requestMessageCountThreshold = self.requestMessageCountThreshold;
    configuration.maximumMessagesCacheSize = self.maximumMessagesCacheSize;

    return configuration;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableArray *hbNotificationOptions = [NSMutableArray new];
    if ((self.heartbeatNotificationOptions & PNHeartbeatNotifyAll) == PNHeartbeatNotifyAll) {
        [hbNotificationOptions addObjectsFromArray:@[@"failure", @"success"]];
    } else {
        if ((self.heartbeatNotificationOptions & PNHeartbeatNotifyFailure) == PNHeartbeatNotifyFailure)
            [hbNotificationOptions addObject:@"failure"];
        if ((self.heartbeatNotificationOptions & PNHeartbeatNotifySuccess) == PNHeartbeatNotifySuccess)
            [hbNotificationOptions addObject:@"success"];
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"origin": self.origin ?: @"missing",
        @"publishKey": self.publishKey ?: @"not set",
        @"subscribeKey": self.subscribeKey ?: @"not set",
        @"userID": self.userID ?: @"missing",
        @"subscribeMaximumIdleTime": @(self.subscribeMaximumIdleTime),
        @"nonSubscribeRequestTimeout": @(self.nonSubscribeRequestTimeout),
        @"presenceHeartbeatValue": @(self.presenceHeartbeatValue),
        @"presenceHeartbeatInterval": @(self.presenceHeartbeatInterval),
        @"managePresenceListManually": self.shouldManagePresenceListManually ? @"YES" : @"NO",
        @"suppressLeaveEvents": self.shouldSuppressLeaveEvents ? @"YES" : @"NO",
        @"TLSEnabled": self.isTLSEnabled ? @"YES" : @"NO",
        @"keepTimeTokenOnListChange": self.shouldKeepTimeTokenOnListChange ? @"YES" : @"NO",
        @"catchUpOnSubscriptionRestore": self.shouldTryCatchUpOnSubscriptionRestore ? @"YES" : @"NO",
        @"fileMessagePublishRetryLimit": @(self.fileMessagePublishRetryLimit),
        @"requestMessageCountThreshold": @(self.requestMessageCountThreshold),
        @"maximumMessagesCacheSize": @(self.maximumMessagesCacheSize)
    }];
    
    if (hbNotificationOptions.count) dictionary[@"heartbeatNotificationOptions"] = hbNotificationOptions;
    if (self.requestRetry) dictionary[@"requestRetry"] = [self.requestRetry dictionaryRepresentation];
    if (self.cryptoModule) {
        if ([self.cryptoModule respondsToSelector:@selector(dictionaryRepresentation)])
            dictionary[@"cryptoModule"] = [self.cryptoModule performSelector:@selector(dictionaryRepresentation)];
        else dictionary[@"cryptoModule"] = NSStringFromClass(self.cryptoModule.class);
    }
    if (self.filterExpression) dictionary[@"filterExpression"] = self.filterExpression;
    if (self.authKey) dictionary[@"authKey"] = self.authKey;
    
    return dictionary;
}

#pragma mark -


@end
