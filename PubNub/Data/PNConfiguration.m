/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import <Foundation/Foundation.h>
#if TARGET_OS_IOS
    #import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
    #import <IOKit/IOKitLib.h>
    #include <sys/socket.h>
    #include <sys/sysctl.h>
    #include <net/if.h>
    #include <net/if_dl.h>
#endif // TARGET_OS_OSX
#import "PNConfiguration.h"
#import "PNConstants.h"
#import "PNKeychain.h"


#pragma mark Static

/**
 @brief  Stores reference on key under which device ID will be stored persistently.
 */
static NSString * const kPNConfigurationDeviceIDKey = @"PNConfigurationDeviceID";

NSString * const kPNConfigurationUUIDKey = @"PNConfigurationUUID";


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface PNConfiguration () <NSCopying>


#pragma mark - Initialization and Configuration

@property (nonatomic, copy) NSString *deviceID;

/**
 @brief  Initialize configuration instance using minimal required data.
 
 @param publishKey   Key which allow client to use data push API.
 @param subscribeKey Key which allow client to subscribe on live feeds pushed from \b PubNub service.
 
 @return Configured and ready to se configuration instance.
 
 @since 4.0
 */
- (instancetype)initWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey;


#pragma mark - Misc

/**
 @brief      Fetch unique user identifier from keychain or generate new one.
 @discussion This value updates with every client configuration (if different from previous one). If user 
             doesn't provide custom \c uuid during client configuration, client will generate and store new 
             unique value which will be re-used during next client configuration (if not provided custom 
             \c uuid).
 
 @return Unique user identifier.
 */
- (NSString *)uniqueUserIdentifier;

/**
 @brief  Fetch unique device idenrifier from keychain or generate new one.
 
 @return Unique device identifier which depends on platform for which client has been compiled.
 
 @since 4.0.2
 */
- (nullable NSString *)uniqueDeviceIdentifier;

/**
 @brief  Extract unique identifier for current platform.
 
 @return Unique device identifier which depends on platform for which client has been compiled.
 
 @since 4.1.1
 */
- (nullable NSString *)generateUniqueDeviceIdentifier;

#if TARGET_OS_OSX
/**
 @brief  Try to fetch device serial number information.
 
 @return Serial number or \c nil in case if it has been lost (there is way for hardware to loose it).
 
 @since 4.0.2
 */
- (nullable NSString *)serialNumber;

/**
 @brief  Try to receive MAC address for any current interfaces.
 
 @return Network interface MAC address.
 
 @since 4.0.2
 */
- (nullable NSString *)macAddress;
#endif // TARGET_OS_OSX

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNConfiguration


#pragma mark - Information

- (void)setPresenceHeartbeatValue:(NSInteger)presenceHeartbeatValue {
    
    _presenceHeartbeatValue = presenceHeartbeatValue;
    if (self.presenceHeartbeatInterval == 0) { 
        
        _presenceHeartbeatInterval = (NSInteger)(_presenceHeartbeatValue * 0.5f) - 1;
    }
}


#pragma mark - Initialization and Configuration

+ (instancetype)configurationWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey {
    
    NSParameterAssert(publishKey);
    NSParameterAssert(subscribeKey);
    
    return [[self alloc] initWithPublishKey:publishKey subscribeKey:subscribeKey];
}

- (instancetype)initWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey {
    
    // Check whether initialization successful or not.
    if ((self = [super init])) {
        
        _deviceID = [[self uniqueDeviceIdentifier] copy];
        // In case if we client used from tests environment configuration should use specified
        // device and instance identifier.
        if (NSClassFromString(@"XCTestExpectation")) {
            
            _deviceID = [@"3650F534-FC54-4EE8-884C-EF1B83188BB7" copy];
        }
        _origin = [kPNDefaultOrigin copy];
        _publishKey = [publishKey copy];
        _subscribeKey = [subscribeKey copy];
        _uuid = [[self uniqueUserIdentifier] copy];
        _subscribeMaximumIdleTime = kPNDefaultSubscribeMaximumIdleTime;
        _nonSubscribeRequestTimeout = kPNDefaultNonSubscribeRequestTimeout;
        _TLSEnabled = kPNDefaultIsTLSEnabled;
        _heartbeatNotificationOptions = kPNDefaultHeartbeatNotificationOptions;
        _suppressLeaveEvents = kPNDefaultShouldSuppressLeaveEvents;
        _managePresenceListManually = kPNDefaultShouldManagePresenceListManually;
        _keepTimeTokenOnListChange = kPNDefaultShouldKeepTimeTokenOnListChange;
        _catchUpOnSubscriptionRestore = kPNDefaultShouldTryCatchUpOnSubscriptionRestore;
        _requestMessageCountThreshold = kPNDefaultRequestMessageCountThreshold;
        _maximumMessagesCacheSize = kPNDefaultMaximumMessagesCacheSize;
#if TARGET_OS_IOS
        _completeRequestsBeforeSuspension = kPNDefaultShouldCompleteRequestsBeforeSuspension;
#endif // TARGET_OS_IOS
        _stripMobilePayload = kPNDefaultShouldStripMobilePayload;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    
    PNConfiguration *configuration = [[PNConfiguration allocWithZone:zone] init];
    configuration.deviceID = self.deviceID;
    configuration.origin = self.origin;
    configuration.publishKey = self.publishKey;
    configuration.subscribeKey = self.subscribeKey;
    configuration.authKey = self.authKey;
    configuration.uuid = self.uuid;
    configuration.cipherKey = self.cipherKey;
    configuration.subscribeMaximumIdleTime = self.subscribeMaximumIdleTime;
    configuration.nonSubscribeRequestTimeout = self.nonSubscribeRequestTimeout;
    configuration.presenceHeartbeatValue = self.presenceHeartbeatValue;
    configuration.presenceHeartbeatInterval = self.presenceHeartbeatInterval;
    configuration.heartbeatNotificationOptions = self.heartbeatNotificationOptions;
    configuration.managePresenceListManually = self.shouldManagePresenceListManually;
    configuration.suppressLeaveEvents = self.shouldSuppressLeaveEvents;
    configuration.TLSEnabled = self.isTLSEnabled;
    configuration.keepTimeTokenOnListChange = self.shouldKeepTimeTokenOnListChange;
    configuration.catchUpOnSubscriptionRestore = self.shouldTryCatchUpOnSubscriptionRestore;
    if (@available(macOS 10.10, iOS 8.0, *)) {
        configuration.applicationExtensionSharedGroupIdentifier = self.applicationExtensionSharedGroupIdentifier;
    }
    configuration.requestMessageCountThreshold = self.requestMessageCountThreshold;
    configuration.maximumMessagesCacheSize = self.maximumMessagesCacheSize;
#if TARGET_OS_IOS
    configuration.completeRequestsBeforeSuspension = self.shouldCompleteRequestsBeforeSuspension;
#endif // TARGET_OS_IOS
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    configuration.stripMobilePayload = self.shouldStripMobilePayload;
#pragma clang diagnostic pop
    
    return configuration;
}


#pragma mark - Misc

- (NSString *)uniqueUserIdentifier {
    
    __block NSString *identifier = nil;
    [PNKeychain valueForKey:kPNConfigurationUUIDKey withCompletionBlock:^(id value) {
        
        if (!value) {
            
            identifier = [@"pn-" stringByAppendingString:[[NSUUID UUID] UUIDString]];
            [PNKeychain storeValue:identifier forKey:kPNConfigurationUUIDKey
               withCompletionBlock:NULL];
        }
        else { identifier = value; }
    }];
    
    return identifier;
}

- (NSString *)uniqueDeviceIdentifier {
    
    __block NSString *identifier = nil;
    [PNKeychain valueForKey:kPNConfigurationDeviceIDKey withCompletionBlock:^(id value) {
        
        if (!value) {
            
            identifier = [self generateUniqueDeviceIdentifier];
            [PNKeychain storeValue:identifier forKey:kPNConfigurationDeviceIDKey
               withCompletionBlock:NULL];
        }
        else { identifier = value; }
    }];
    
    return identifier;
}

- (NSString *)generateUniqueDeviceIdentifier {
    
    NSString *identifier = nil;
#if TARGET_OS_IOS
    identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
#elif TARGET_OS_OSX
    identifier = ([self serialNumber]?: [self macAddress]);
#endif // TARGET_OS_OSX
    
    return (identifier?: [[[NSUUID UUID] UUIDString] copy]);
}

#if TARGET_OS_OSX
- (NSString *)serialNumber {
    
    NSString *serialNumber = nil;
    io_service_t service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                       IOServiceMatching("IOPlatformExpertDevice"));
    if (service) {
        
        CFTypeRef cfSerialNumber = IORegistryEntryCreateCFProperty(service, CFSTR(kIOPlatformSerialNumberKey),
                                                                   kCFAllocatorDefault, 0);
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
