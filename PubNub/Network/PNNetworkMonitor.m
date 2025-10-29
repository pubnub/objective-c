#import <Network/Network.h>
#import "PubNub+CorePrivate.h"
#import "PNNetworkMonitor.h"


#pragma mark Private interface declaration

/// Network paths change monitor private extension.
@interface PNNetworkMonitor ()

#pragma mark - Properties

/// **PubNub** client for which network monitoring will be done.
@property(weak, nonatomic) PubNub *client;
@property(strong, nonatomic) dispatch_queue_t monitorQueue;
@property(strong, nonatomic) nw_path_monitor_t monitor;


#pragma mark - Initialization and Configuration

/// Initialize a network monitor for the **PubNub** client.
///
/// - Parameter client: **PubNub** client for which network monitoring will be done.
/// - Returns: Initialized network monitor instance.
- (instancetype)initWithClient:(PubNub *)client;

- (void)setupAndStartNetworkPathMonitor;


#pragma mark - Helpers

/// Transform network interface type enum field to string.
///
/// - Parameter type: One of `nw_interface_type_t` enum fields which should be stringified.
/// - Returns: Stringified interface type.
- (NSString *)stringFromInterfaceType:(nw_interface_type_t)type;

/// Transform network endpoint to string.
///
/// - Parameter endpoint: gateway endpoint which should be stringified.
/// - Returns: Stringified endpoint.
- (NSString *)stringFromEndpoint:(nw_endpoint_t)endpoint;

/// Transform network path status enum field to string.
///
/// - Parameters
/// - path: Network path that recently updated state.
/// - type: One of the `nw_path_status_t` enum fields, which should be stringified.
/// - Returns: Stringified path status.
- (NSString *)stringFromPath:(nw_path_t)path status:(nw_path_status_t)status;

/// Transform C-string with IPv4/IPv6 address to string
///
/// - Parameter address: C-string with IPv4/IPv6 address.
/// - Returns: Transformed C-string.
- (NSString *)stringFromAddressCString:(const char*)address;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNNetworkMonitor


#pragma mark - Initialization and Configuration

+ (instancetype)monitorForClient:(PubNub *)client {
    return [[self alloc] initWithClient:client];
}

- (instancetype)initWithClient:(PubNub *)client {
    if ((self = [super init])) {
        _client = client;
        
        [self setupAndStartNetworkPathMonitor];
    }
    
    return self;
}

- (void)setupAndStartNetworkPathMonitor {
    _monitorQueue = dispatch_queue_create("com.pubnub.network-monitor", DISPATCH_QUEUE_SERIAL);
    _monitor = nw_path_monitor_create();
    
    __weak __typeof(self) weakSelf = self;
    nw_path_monitor_set_update_handler(_monitor, ^(nw_path_t path) {
        NSMutableArray<NSString *> *interfaces = [NSMutableArray new];
        NSMutableArray<NSString *> *gateways = [NSMutableArray new];
        PNLLogger *logger = weakSelf.client.logger;
        if (!logger) return;
        
        NSMutableString *update = [NSMutableString stringWithFormat: @"[NWPath] Path state update:\n\t- Status: %@"
                                   "\n\t- Can route IPv4 traffic: %@\n\t- Can route IPv6 traffic: %@"
                                   "\n\t- Has configured DNS: %@\n\t- Uses interfaces in Low Data Mode: %@"
                                   "\n\t- Uses 'expensive' interface: %@",
                                   [weakSelf stringFromPath:path status:nw_path_get_status(path)],
                                   nw_path_has_ipv4(path) ? @"Yes" : @"No",
                                   nw_path_has_ipv6(path) ? @"Yes" : @"No",
                                   nw_path_has_dns(path) ? @"Yes" : @"No",
                                   nw_path_is_constrained(path) ? @"Yes" : @"No",
                                   nw_path_is_expensive(path) ? @"Yes" : @"No"];
        
        nw_path_enumerate_interfaces(path, ^bool(nw_interface_t interface) {
            NSString *interfaceType = [weakSelf stringFromInterfaceType:nw_interface_get_type(interface)];
            const char* interfaceName = nw_interface_get_name(interface);
            
            [interfaces addObject:[NSString stringWithFormat:@"\t\t- type=%@ name=%s",
                                   interfaceType, interfaceName]];
            return true;
        });
        
        nw_path_enumerate_gateways(path, ^bool(nw_endpoint_t endpoint) {
            [gateways addObject:[self stringFromEndpoint:endpoint]];
            return true;
        });
        
        if (interfaces.count) [update appendFormat:@"\n\t- Interfaces:\n%@", [interfaces componentsJoinedByString:@"\n"]];
        if (gateways.count) [update appendFormat:@"\n\t- Gateways:\n%@", [gateways componentsJoinedByString:@"\n"]];
        
        PNLogReachability(logger, @"%@", update);
    });
    
    nw_path_monitor_set_queue(_monitor, _monitorQueue);
    nw_path_monitor_start(_monitor);
}


#pragma mark - Lifecycle

- (void)invalidate {
    if (_monitor) {
        nw_path_monitor_cancel(_monitor);
        _monitor = nil;
    }
}


#pragma mark - Helpers

- (NSString *)stringFromInterfaceType:(nw_interface_type_t)type {
    if (type == nw_interface_type_wired) return @"Ethernet";
    if (type == nw_interface_type_wifi) return @"Wi-Fi";
    if (type == nw_interface_type_cellular) return @"Cellular";
    if (type == nw_interface_type_loopback) return @"Loopback";
    if (type == nw_interface_type_other) return @"Other";
    
    return @"Unknown";
}

- (NSString *)stringFromEndpoint:(nw_endpoint_t)endpoint {
    nw_endpoint_type_t type = nw_endpoint_get_type(endpoint);
    
    if (type == nw_endpoint_type_address) {
        char *addr = nw_endpoint_copy_address_string(endpoint);
        if (!addr) return @"\t\t- address";
        
        char *port = nw_endpoint_copy_port_string(endpoint);
        NSMutableString *address = [[self stringFromAddressCString:addr] mutableCopy];
        free(addr);
        
        if (port && strcmp(port, "0") != 0) {
            [address appendFormat:@":%s", port];
            free(port);
        }
        
        return [@"\t\t- address " stringByAppendingFormat:@"(%@)", address];
    }
    
    if (type == nw_endpoint_type_host) return @"\t\t- host";
    if (type == nw_endpoint_type_bonjour_service) return @"\t\t- Bonjour";
    if (type == nw_endpoint_type_url) return @"\t\t- url";
    
    return @"\t\t- invalid";
}

- (NSString *)stringFromPath:(nw_path_t)path status:(nw_path_status_t)status {
    if (status == nw_path_status_unsatisfied) {
        nw_path_unsatisfied_reason_t reason = nw_path_get_unsatisfied_reason(path);
        NSString *reasonString;
        
        if (reason == nw_path_unsatisfied_reason_cellular_denied) reasonString = @"user disabled cellular";
        else if (reason == nw_path_unsatisfied_reason_wifi_denied) reasonString = @"user disabled Wi-Fi";
        else if (reason == nw_path_unsatisfied_reason_local_network_denied) reasonString = @"user disabled local network";
        if (@available(iOS 17.0, macOS 14.0, *)) {
            if (!reasonString && reason == nw_path_unsatisfied_reason_vpn_inactive) reasonString = @"VPN not active";
        }
        
        return [NSString stringWithFormat:@"unsatisfied (%@)", reasonString ?: @"not available"];
    }
    if (status == nw_path_status_satisfiable) return @"satisfiable (currently no usable route; on-demand)";
    if (status == nw_path_status_satisfied) return @"satisfied (usable route to send and receive data)";
    
    return @"invalid";
}

- (NSString *)stringFromAddressCString:(const char*)address {
    if (!address || address[0] == '\0') return @"**redacted**";
    NSString *addr = [NSString stringWithUTF8String:address];
    
    // Try process as IPv4
    NSArray<NSString *> *addressComponents = [addr componentsSeparatedByString:@"."];
    if (addressComponents.count == 4) {
        NSCharacterSet *notDigit = NSCharacterSet.decimalDigitCharacterSet.invertedSet;
        BOOL validIPv4 = YES;
        
        for (NSString *component in addressComponents) {
            if (component.length == 0 || [component rangeOfCharacterFromSet:notDigit].location != NSNotFound) {
                validIPv4 = NO;
                break;
            }
        }
        
        if (validIPv4) return [NSString stringWithFormat:@"%@.%@.*.*", addressComponents[0], addressComponents[1]];
    }
    
    // Try process as IPv6
    addressComponents = [addr componentsSeparatedByString:@":"];
    if (addressComponents.count > 1) {
        NSString *first = addressComponents.firstObject ?: @"*";
        NSString *last = addressComponents.lastObject.length ?
            addressComponents.lastObject :
            (addressComponents.count >= 2 ? addressComponents[addressComponents.count - 2] : @"*");
        if (first.length == 0) first = @"*";
        if (last.length == 0) last = @"*";
        
        return [NSString stringWithFormat:@"%@:*:%@", first, last];
    }
    
    return @"**redacted**";
}


#pragma mark - Misc

- (void)dealloc {
    _client = nil;
}

#pragma mark -

@end
