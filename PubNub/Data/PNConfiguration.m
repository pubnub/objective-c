/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import <UIKit/UIKit.h>
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
#import <IOKit/IOKitLib.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#endif // __MAC_OS_X_VERSION_MIN_REQUIRED
#import "PNConfiguration+Private.h"
#import "PNConstants.h"


#pragma mark Protected interface declaration

@interface PNConfiguration () <NSCopying>


#pragma mark - Initialization and Configuration

@property (nonatomic, copy) NSString *deviceID;

/**
 @brief  Initialize configuration instance using minimal required data.
 
 @param publishKey   Key which allow client to use data push API.
 @param subscribeKey Key which allow client to subscribe on live feeds pushed from \b PubNub 
                     service.
 
 @return Configured and ready to se configuration instance.
 
 @since 4.0
 */
- (instancetype)initWithPublishKey:(NSString *)publishKey
                      subscribeKey:(NSString *)subscribeKey NS_DESIGNATED_INITIALIZER;


#pragma mark - Misc

/**
 @brief  Extract unique identifier for current platform.
 
 @return UIDevice identifierForVendor for Mac's serial number.
 
 @since 4.0.2
 */
- (NSString *)uniqueDeviceIdentifier;

#if __MAC_OS_X_VERSION_MIN_REQUIRED
/**
 @brief  Try to fetch device serial number information.
 
 @return Serial number or \c nil in case if it has been lost (there is way for hardware to loose 
         it).
 
 @since 4.0.2
 */
- (NSString *)serialNumber;

/**
 @brief  Try to receive MAC address for any current interfaces.
 
 @return Network interface MAC address.
 
 @since 4.0.2
 */
- (NSString *)macAddress;
#endif

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNConfiguration


#pragma mark - Initialization and Configuration

+ (instancetype)configurationWithPublishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey {
    
    NSParameterAssert(publishKey);
    NSParameterAssert(subscribeKey);
    
    return [[self alloc] initWithPublishKey:publishKey subscribeKey:subscribeKey];
}

- (instancetype)initWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey {
    
    // Check whether initialization successful or not.
    if ((self = [super init])) {
        
        _deviceID = [[self uniqueDeviceIdentifier] copy];
        // In case if we client used from tests environment configuration should use specified
        // device identifier.
        if (NSClassFromString(@"XCTestExpectation")) {
            
            _deviceID = @"3650F534-FC54-4EE8-884C-EF1B83188BB7";
        }
        _origin = [kPNDefaultOrigin copy];
        _publishKey = [publishKey copy];
        _subscribeKey = [subscribeKey copy];
        _uuid = [[[NSUUID UUID] UUIDString] copy];
        _subscribeMaximumIdleTime = kPNDefaultSubscribeMaximumIdleTime;
        _nonSubscribeRequestTimeout = kPNDefaultNonSubscribeRequestTimeout;
        _TLSEnabled = kPNDefaultIsTLSEnabled;
        _keepTimeTokenOnListChange = kPNDefaultShouldKeepTimeTokenOnListChange;
        _restoreSubscription = kPNDefaultShouldRestoreSubscription;
        _catchUpOnSubscriptionRestore = kPNDefaultShouldTryCatchUpOnSubscriptionRestore;
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
    configuration.TLSEnabled = self.isTLSEnabled;
    configuration.keepTimeTokenOnListChange = self.shouldKeepTimeTokenOnListChange;
    configuration.restoreSubscription = self.shouldRestoreSubscription;
    configuration.catchUpOnSubscriptionRestore = self.shouldTryCatchUpOnSubscriptionRestore;
    
    return configuration;
}


#pragma mark - Misc

- (NSString *)uniqueDeviceIdentifier {
#if __IPHONE_OS_VERSION_MIN_REQUIRED
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
    return ([self serialNumber]?: [self macAddress]);
#endif
}

#if __MAC_OS_X_VERSION_MIN_REQUIRED
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
#endif

#pragma mark -


@end
