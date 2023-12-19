#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import "PNPrivateStructures.h"
#import "PNKeychain+Private.h"
#import "PNKeychainStorage.h"
#import "PNDataStorage.h"
#if TARGET_OS_IOS
    #import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
    #import <IOKit/IOKitLib.h>
    #include <sys/socket.h>
    #include <sys/sysctl.h>
    #include <net/if.h>
    #include <net/if_dl.h>
#endif // TARGET_OS_OSX
#import "PNConfiguration+Private.h"
#import "PNConstants.h"


#pragma mark Static

/// Device `"identifier"` store key in in-memory or Keychain storage.
NSString * const kPNConfigurationDeviceIDKey = @"PNConfigurationDeviceID";

/// Configured user `identifier` store key in in-memory or Keychain storage.
NSString * const kPNConfigurationUserIDKey = @"PNConfigurationUUID";


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

/// **PubNub** client configuration wrapper private extension.
@interface PNConfiguration () <NSCopying>


#pragma mark - Information

@property (nonatomic, nullable, copy) NSString *authToken;
@property (nonatomic, copy) NSString *deviceID;


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


#pragma mark - Storage

/// Migrate previously stored client data in default storage to new one (identifier-based storage).
///
/// - Parameter identifier: Unique identifier of storage to which information should be moved from default storage.
- (void)migrateDefaultToStorageWithIdentifier:(NSString *)identifier;


#pragma mark - Helpers

/// Fetch unique device identifier from keychain or generate new one.
///
/// - Returns: Unique device identifier which depends on platform for which client has been compiled.
///
/// - Since: 4.0.2
- (nullable NSString *)uniqueDeviceIdentifier;

/// Extract unique identifier for current platform.
///
/// - Returns: Unique device identifier which depends on platform for which client has been compiled.
///
/// - Since: 4.1.1
- (nullable NSString *)generateUniqueDeviceIdentifier;

#if TARGET_OS_OSX
/// Try to fetch device serial number information.
///
/// - Returns: Serial number or `nil` in case if it has been lost (there is way for hardware to loose it).
///
/// - Since: 4.0.2
- (nullable NSString *)serialNumber;

/// Try to receive MAC address for any current interfaces.
///
/// - Returns: Network interface MAC address.
///
/// - Since: 4.0.2
- (nullable NSString *)macAddress;
#endif // TARGET_OS_OSX

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNConfiguration


#pragma mark - Information

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
        
        // Call position important, because it migrate stored UUID and device identifier from older storage.
        [self migrateDefaultToStorageWithIdentifier:publishKey ?: subscribeKey];
        
        self.userID = userID;
        _deviceID = [[self uniqueDeviceIdentifier] copy];
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
        _completeRequestsBeforeSuspension = kPNDefaultShouldCompleteRequestsBeforeSuspension;
#endif // TARGET_OS_IOS
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PNConfiguration *configuration = [[PNConfiguration allocWithZone:zone] init];
    configuration.deviceID = [self.deviceID copy];
    configuration.origin = [self.origin copy];
    configuration.publishKey = [self.publishKey copy];
    configuration.subscribeKey = [self.subscribeKey copy];
    configuration.authKey = [self.authKey copy];
    configuration.authToken = [self.authToken copy];
    configuration.userID = [self.userID copy];
    configuration.cryptoModule = self.cryptoModule;
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
#pragma clang diagnostic pop
    
    if (@available(macOS 10.10, iOS 8.0, *)) {
        configuration.applicationExtensionSharedGroupIdentifier = self.applicationExtensionSharedGroupIdentifier;
    }
    
    configuration.requestMessageCountThreshold = self.requestMessageCountThreshold;
    configuration.maximumMessagesCacheSize = self.maximumMessagesCacheSize;
#if TARGET_OS_IOS
    configuration.completeRequestsBeforeSuspension = self.shouldCompleteRequestsBeforeSuspension;
#endif // TARGET_OS_IOS
    
    return configuration;
}


#pragma mark - Storage

- (void)migrateDefaultToStorageWithIdentifier:(NSString *)identifier {
    id<PNKeyValueStorage> storage = [PNDataStorage persistentClientDataWithIdentifier:identifier];
    PNKeychain *defaultKeychain = PNKeychain.defaultKeychain;
    
    NSString *previousUUID = [defaultKeychain valueForKey:kPNConfigurationUserIDKey];
    
    if (previousUUID) {
        [storage syncStoreValue:previousUUID forKey:kPNConfigurationUserIDKey];
        [defaultKeychain removeValueForKey:kPNConfigurationUserIDKey];
        
        NSString *previousDeviceID = [defaultKeychain valueForKey:kPNConfigurationDeviceIDKey];
        [storage syncStoreValue:previousDeviceID forKey:kPNConfigurationDeviceIDKey];
        [defaultKeychain removeValueForKey:kPNConfigurationDeviceIDKey];
    }
    
    // Update access properties.
    if ([storage isKindOfClass:[PNKeychainStorage class]]) {
        PNKeychainStorage *keychainStorage = (PNKeychainStorage *)storage;
        NSArray<NSString *> *entryNames = @[
            kPNConfigurationUserIDKey,
            kPNConfigurationDeviceIDKey,
            kPNPublishSequenceDataKey
        ];
        
        [keychainStorage updateEntries:entryNames accessibilityTo:kSecAttrAccessibleAfterFirstUnlock];
    }
}


#pragma mark - Helpers

- (NSString *)uniqueDeviceIdentifier {
    NSString *storageIdentifier = self.publishKey ?: self.subscribeKey;
    id<PNKeyValueStorage> storage = [PNDataStorage persistentClientDataWithIdentifier:storageIdentifier];
    __block NSString *identifier = nil;
    
    [storage batchSyncAccessWithBlock:^{
        identifier = [storage valueForKey:kPNConfigurationDeviceIDKey];
        
        if (!identifier) {
            identifier = [self generateUniqueDeviceIdentifier];
            [storage storeValue:identifier forKey:kPNConfigurationDeviceIDKey];
        }
    }];
    
    return identifier;
}

- (NSString *)generateUniqueDeviceIdentifier {
    NSString *identifier = nil;
#if TARGET_OS_IOS
    identifier = UIDevice.currentDevice.identifierForVendor.UUIDString;
#elif TARGET_OS_OSX
    identifier = [self serialNumber] ?: [self macAddress];
#endif // TARGET_OS_OSX
    
    return identifier ?: [[NSUUID UUID].UUIDString copy];
}

#if TARGET_OS_OSX
- (NSString *)serialNumber {
    NSString *serialNumber = nil;
    io_service_t service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                       IOServiceMatching("IOPlatformExpertDevice"));
    
    if (service) {
        CFTypeRef cfSerialNumber = IORegistryEntryCreateCFProperty(service,
                                                                   CFSTR(kIOPlatformSerialNumberKey),
                                                                   kCFAllocatorDefault,
                                                                   0);
        
        if (cfSerialNumber) {
            serialNumber = [(__bridge NSString *)(cfSerialNumber) copy];
        }
        
        IOObjectRelease(service);
    }
    
    return serialNumber;
}

- (NSString *)macAddress {
    NSString *macAddress = nil;
    size_t length = 0;
    int mib[6] = {CTL_NET, AF_ROUTE, 0, AF_LINK, NET_RT_IFLIST, if_nametoindex("en0")};
    
    if (mib[5] != 0 && sysctl(mib, 6, NULL, &length, NULL, 0) >= 0 && length > 0) {
        NSMutableData *data = [NSMutableData dataWithLength:length];
        
        if (sysctl(mib, 6, [data mutableBytes], &length, NULL, 0) >= 0) {
            struct sockaddr_dl *address = ([data mutableBytes] + sizeof(struct if_msghdr));
            unsigned char *mac = (unsigned char *)LLADDR(address);
            macAddress = [[NSString alloc] initWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                          mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]];
        }
    }
    
    return macAddress;
}
#endif // TARGET_OS_OSX

#pragma mark -


@end
