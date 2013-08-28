//
//  UIDevice+PNAdditions.m
//  pubnub
//
//  Category was created to add few useful
//  methods.
//
//  Created by Sergey Mamontov on 01/29/13.
//
//

#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import "UIDevice+PNAdditions.h"
#import <arpa/inet.h>
#import <ifaddrs.h>

#include <net/if.h>


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

// Stores reference on default IP address which means that
// interface is not really connected
static char * const kPNNetworkDefaultAddress = "0.0.0.0";


#pragma mark Public interface methods

@implementation UIDevice (PNAdditions)


#pragma mark - Instance methods

- (NSString *)networkAddress {

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
                unsigned int interfaceStateFlags = (unsigned int)((struct sockaddr_in*)interface->ifa_flags);
                BOOL isActive = !(interfaceStateFlags & IFF_LOOPBACK);
                
                if (isActive) {
                    
                    NSString *interfaceNameString = [NSString stringWithUTF8String:interfaceName];
                    
                    if ([interfaceNameString hasPrefix:kPNNetworkWirelessCableInterfaceName] ||
                        [interfaceNameString hasPrefix:kPNNetworkCellularInterfaceName]) {
                        
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

#pragma mark -

@end
#endif
