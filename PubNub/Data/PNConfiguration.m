#import "PNConfiguration+Private.h"
#import <Foundation/Foundation.h>
#import "PNPrivateStructures.h"
#import "PNConstants.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// **PubNub** client configuration wrapper private extension.
@interface PNConfiguration () <NSCopying>


#pragma mark - Properties

@property(copy, nullable, nonatomic) NSString *filterExpression;
@property(copy, nullable, nonatomic) NSString *authToken;
@property(copy, nonatomic) NSString *deviceID
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with next major update. Unique value will "
                             "be generated for each PubNub client instance.");


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

- (NSString *)uuid {
    return self.userID;
}

- (void)setUUID:(NSString *)uuid {
    [self setUserID:uuid];
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
                                       uuid:(NSString *)uuid {
    return [self configurationWithPublishKey:publishKey subscribeKey:subscribeKey userID:uuid];
}

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
        
        self.userID = userID;
        _deviceID = [NSUUID UUID].UUIDString;
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
#if TARGET_OS_IOS
        _completeRequestsBeforeSuspension = YES;
#endif // TARGET_OS_IOS
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PNConfiguration *configuration = [[PNConfiguration allocWithZone:zone] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    configuration.deviceID = [self.deviceID copy];
#pragma clang diagnostic pop
    configuration.origin = [self.origin copy];
    configuration.publishKey = [self.publishKey copy];
    configuration.subscribeKey = [self.subscribeKey copy];
    configuration.authKey = [self.authKey copy];
    configuration.authToken = [self.authToken copy];
    configuration.userID = [self.userID copy];
    configuration.cryptoModule = self.cryptoModule;
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
    configuration.cryptoModule = self.cryptoModule;
    configuration.requestRetry = [self.requestRetry copy];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    configuration.cipherKey = self.cipherKey;
    configuration.useRandomInitializationVector = self.shouldUseRandomInitializationVector;
    configuration.applicationExtensionSharedGroupIdentifier = self.applicationExtensionSharedGroupIdentifier;
#if TARGET_OS_IOS
    configuration.completeRequestsBeforeSuspension = self.shouldCompleteRequestsBeforeSuspension;
#endif // TARGET_OS_IOS
#pragma clang diagnostic pop
    configuration.requestMessageCountThreshold = self.requestMessageCountThreshold;
    configuration.maximumMessagesCacheSize = self.maximumMessagesCacheSize;

    return configuration;
}

#pragma mark -


@end
