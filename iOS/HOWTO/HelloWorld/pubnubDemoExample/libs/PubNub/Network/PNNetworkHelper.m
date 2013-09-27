//
//  PNNetworkHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 8/29/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//


#import "PNNetworkHelper.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "PNBaseRequest+Protected.h"
#import "PNTimeTokenRequest.h"
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <net/if.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    #import <SystemConfiguration/CaptiveNetwork.h>
#else
    #if MAC_OS_X_VERSION_MIN_REQUIRED >= 1060

        #import <CoreWLAN/CoreWLAN.h>

        #ifndef _CORE_WLAN_INTERFACE_H_
            #error PubNub library must be linked agains CoreWLAN framework
        #endif
    #endif
#endif


// ARC check
#if !__has_feature(objc_arc)
#error PubNub device category must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Static

// Stores reference on WiFi/LAN interface name
static NSString * const kPNNetworkWirelessCableInterfaceName = @"en";

// Store reference on 3G/EDGE interface name
static NSString * const kPNNetworkCellularInterfaceName = @"pdp_ip";

// Stores reference on default IP address which means that interface is not really connected
static char * const kPNNetworkDefaultAddress = "0.0.0.0";

#if __IPHONE_OS_VERSION_MIN_REQUIRED
static NSString * kPNWLANBasicServiceSetIdentifierKey = @"BSSID";
static NSString * kPNWLANServiceSetIdentifierKey = @"SSID";
#endif


#pragma mark - Private interface declaration

@interface PNNetworkHelper ()


#pragma mark - Class methods

#pragma mark - WLAN information methods

/**
 * Depending on platform on which library is launched, this method may return NSDictionary for iOS and CWInterface
 * instance in case of Mac OS library
 */
+ (id)fetchWLANInformation;


#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNNetworkHelper


#pragma mark - Class methods

#pragma mark - General methods

+ (NSString *)networkAddress {

    // Initial setup
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *interface = NULL;

    // Retrieving list of interfaces
    if (getifaddrs(&interfaces) == 0) {

        interface = interfaces;
        while (interface != NULL) {

            // Checking whether found network interface or not
            sa_family_t family = interface->ifa_addr->sa_family;
            if (family == AF_INET || family == AF_INET6) {

                char *interfaceName = interface->ifa_name;
                char *interfaceAddress = inet_ntoa(((struct sockaddr_in*)interface->ifa_addr)->sin_addr);
                unsigned int interfaceStateFlags = interface->ifa_flags;
                BOOL isActive = !(interfaceStateFlags & IFF_LOOPBACK);

                if (isActive) {

                    NSString *interfaceNameString = [NSString stringWithUTF8String:interfaceName];

                    if ([interfaceNameString hasPrefix:kPNNetworkWirelessCableInterfaceName] ||
                        [interfaceNameString hasPrefix:kPNNetworkCellularInterfaceName]) {

                        // Check on whether interface has assigned address or not
                        if (strcmp(interfaceAddress, kPNNetworkDefaultAddress) != 0) {

                            address = [NSString stringWithUTF8String:interfaceAddress];

                            break;
                        }

                    }
                }
            }

            interface = interface->ifa_next;
        }
    }

    freeifaddrs(interfaces);


    return address;
}

+ (NSString *)originLookupResourcePath {
    
    return [[PNTimeTokenRequest new] requestPath];
}


#pragma mark - WLAN information methods

+ (id)fetchWLANInformation {

    id information = nil;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    NSArray *interfaces = CFBridgingRelease(CNCopySupportedInterfaces());

    NSDictionary *interfaceInformation = nil;

    // Iterate over list of available interfaces
    for (NSString *interfaceName in interfaces) {

        interfaceInformation = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));

        // Check whether interface contain some information or not
        if (interfaceInformation && [interfaceInformation count]) {

            break;
        }
    }

    information = interfaceInformation;
#else
    #if MAC_OS_X_VERSION_MIN_REQUIRED >= 1060
        information = [CWInterface interface];
    #endif
#endif

    return information;
}

+ (NSString *)WLANBasicServiceSetIdentifier {

    NSString *WLANBSSID = nil;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    WLANBSSID = [[self fetchWLANInformation] valueForKey:kPNWLANBasicServiceSetIdentifierKey];

    // If testing on simulator, there is no WiFi BSSID available, because computer's LAN / WiFi connection is used
    if ([WLANBSSID isKindOfClass:[NSNumber class]]) {

        WLANBSSID = @"si:mu:la:to:r0";
    }
#else
    #if MAC_OS_X_VERSION_MIN_REQUIRED >= 1060
        WLANBSSID = ((CWInterface *)[self fetchWLANInformation]).bssid;
    #endif
#endif


    return WLANBSSID;
}

+ (NSString *)WLANServiceSetIdentifier {

    NSString *WLANSSID = nil;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    WLANSSID = [[self fetchWLANInformation] valueForKey:kPNWLANServiceSetIdentifierKey];
#else
    #if MAC_OS_X_VERSION_MIN_REQUIRED >= 1060
        WLANSSID = ((CWInterface *)[self fetchWLANInformation]).ssid;
    #endif
#endif


    return WLANSSID;
}

#pragma mark -


@end
