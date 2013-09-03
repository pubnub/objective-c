//
//  PNReachability.m
//  pubnub
//
//  This class helps PubNub client to monitor
//  PubNub services reachability.
//  WARNING: It is designed only for internal
//           PubNub client library usage.
//
//
//  Created by Sergey Mamontov on 12/7/12.
//
//

#import "PNReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "PubNub+Protected.h"
#import <netinet/in.h>
#import <arpa/inet.h>


// ARC check
#if !__has_feature(objc_arc)
#error PubNub reachability must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Static

static int64_t const kPNReachabilityNetworkSwitchSimulationDelay = 1;


#pragma mark Structures

typedef enum _PNReachabilityStatus {
    
    // PubNub services reachability wasn't tested yet
    PNReachabilityStatusUnknown,
    
    // PubNub services can't be reached at this moment (looks like network/internet failure occurred)
    PNReachabilityStatusNotReachable,

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    // PubNub service is reachable over cellular channel (EDGE or 3G)
    PNReachabilityStatusReachableViaCellular,
#endif
    
    // PubNub services is available over WiFi
    PNReachabilityStatusReachableViaWiFi
} PNReachabilityStatus;


#pragma mark Private interface methods

@interface PNReachability ()


#pragma mark - Properties

@property (nonatomic, assign, getter = isNotificationsSuspended) BOOL notificationsSuspended;

// When reachability detects switch between WiFi <-> Cellular interfaces, it won't report that
@property (nonatomic, assign, getter = isSimulatingNetworkSwitchEvent) BOOL simulatingNetworkSwitchEvent;

@property (nonatomic, assign) SCNetworkReachabilityRef serviceReachability;
@property (nonatomic, assign) SCNetworkConnectionFlags reachabilityFlags;
@property (nonatomic, strong) NSString *currentNetworkAddress;
@property (nonatomic, assign) PNReachabilityStatus status;
@property (nonatomic, strong) NSString *currentWLANBSSID;
@property (nonatomic, strong) NSString *currentWLANSSID;


#pragma mark - Class methods

/**
 * Retrieve reference on created reachability instance with specific address
 */
+ (SCNetworkReachabilityRef)newReachabilityForWiFi:(BOOL)wifiReachability;


#pragma mark - Instance methods

- (BOOL)isNetworkAddressChanged;
- (BOOL)isWiFiAccessPointChanged;
- (BOOL)isServiceAvailableForStatus:(PNReachabilityStatus)status;
- (BOOL)isInterfaceChangedFrom:(PNReachabilityStatus)originalState to:(PNReachabilityStatus)updatedState;


#pragma mark - Misc methods

- (NSString *)humanReadableStatus:(PNReachabilityStatus)status;
- (NSString *)humanReadableInterfaceFromStatus:(PNReachabilityStatus)status;

#pragma mark -


@end


#pragma mark - Public interface methods

@implementation PNReachability


#pragma mark - Class methods

+ (PNReachability *)serviceReachability {
    
    return [[[self class] alloc] init];
}

+ (SCNetworkReachabilityRef)newReachabilityForWiFi:(BOOL)wifiReachability {
    
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = (__uint8_t)sizeof(address);
    address.sin_family = AF_INET;
    
    if (wifiReachability) {
        
        address.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    }
    
    
    return SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&address);
}


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization was successful or not
    if((self = [super init])) {
        
        self.status = PNReachabilityStatusUnknown;
    }
    
    return self;
}


#pragma mark - Monitor activity management methods

/**
 * Helper methods for reachability status flags conversion into human-readable version
 */
static PNReachabilityStatus PNReachabilityStatusForFlags(SCNetworkReachabilityFlags flags);
PNReachabilityStatus PNReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    
    PNReachabilityStatus status = PNReachabilityStatusNotReachable;
    BOOL isServiceReachable = PNBitIsOn(flags, kSCNetworkReachabilityFlagsReachable);
    if (isServiceReachable) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED
        status = PNBitIsOn(flags, kSCNetworkReachabilityFlagsIsWWAN) ? PNReachabilityStatusReachableViaCellular : status;
        if (status == PNReachabilityStatusReachableViaCellular && PNBitIsOn(flags, kSCNetworkReachabilityFlagsConnectionRequired)) {
            
            status = PNReachabilityStatusNotReachable;
        }
#endif
        if (status == PNReachabilityStatusUnknown || status == PNReachabilityStatusNotReachable) {

            if (status == PNReachabilityStatusNotReachable) {

                status = PNReachabilityStatusReachableViaWiFi;

                unsigned int flagsForCleanUp = (unsigned int)flags;
                PNBitsOff(&flagsForCleanUp, kSCNetworkReachabilityFlagsReachable, kSCNetworkReachabilityFlagsIsDirect,
                                            kSCNetworkReachabilityFlagsIsLocalAddress, BITS_LIST_TERMINATOR);
                flags = (SCNetworkReachabilityFlags)flagsForCleanUp;

                if (flags != 0) {

                    status = PNReachabilityStatusNotReachable;

                    // Check whether connection is down (required connection)
                    if (!PNBitStrictIsOn(flags, (kSCNetworkReachabilityFlagsConnectionRequired |
                                                 kSCNetworkReachabilityFlagsTransientConnection))) {

                        if (PNBitIsOn(flags, kSCNetworkReachabilityFlagsConnectionRequired) ||
                            PNBitIsOn(flags, kSCNetworkReachabilityFlagsTransientConnection)) {

                            status = PNReachabilityStatusReachableViaWiFi;
                        }
                    }
                }
            }
            else {

                status = PNReachabilityStatusNotReachable;
            }
        }
    }
    
    
    return status;
}

/**
 * This is reachability callback method which will be called by system network subsystem each time when it notice
 * that remote service changed it's reachability state
 */
static void PNReachabilityCallback(SCNetworkReachabilityRef reachability, SCNetworkReachabilityFlags flags, void *info);
void PNReachabilityCallback(SCNetworkReachabilityRef reachability __unused, SCNetworkReachabilityFlags flags, void *info) {
    
    // Verify that reachability callback was called for correct client
    NSCAssert([(__bridge NSObject *)info isKindOfClass:[PNReachability class]],
              @"Wrong instance has been sent as reachability observer");

    // Retrieve reference on reachability monitor and update it's state
    PNReachability *reachabilityMonitor = (__bridge PNReachability *)info;

    // Make reachability flags human-readable
    PNReachabilityStatus status = PNReachabilityStatusForFlags(flags);
    BOOL available = [reachabilityMonitor isServiceAvailableForStatus:status];

    if (!reachabilityMonitor.isNotificationsSuspended) {

        PNLog(PNLogReachabilityLevel, reachabilityMonitor, @"{CALLBACK} PubNub services reachability flags changes: "
              "%d (%@) [CONNECTED? %@]", flags, [reachabilityMonitor humanReadableStatus:status], available ? @"YES" : @"NO");

        // Make sure that delayed simulation won't fire after updated reachability information arrived and not set
        // connection state in non appropriate state
        reachabilityMonitor.simulatingNetworkSwitchEvent = NO;

        // Updating reachability information
        reachabilityMonitor.reachabilityFlags = flags;
        reachabilityMonitor.status = status;
    }
    else {

        PNLog(PNLogReachabilityLevel, reachabilityMonitor, @"{CALLBACK} PubNub services reachability changed while "
              "suspended (%@) [CONNECTED? %@]", [reachabilityMonitor humanReadableStatus:status], available ? @"YES" : @"NO");
    }
}

- (void)startServiceReachabilityMonitoring {

    [self stopServiceReachabilityMonitoring];


    // Check whether origin (PubNub services host) is specified or not
    NSString *originHost = [PubNub sharedInstance].configuration.origin;
    if (originHost != nil) {

        // Prepare and configure reachability monitor
        self.serviceReachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [originHost UTF8String]);

        SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
        if (SCNetworkReachabilitySetCallback(self.serviceReachability, PNReachabilityCallback, &context)) {

            // Schedule service reachability monitoring on current runloop with
            // common mode (prevent from blocking by other tasks)
            SCNetworkReachabilityScheduleWithRunLoop(self.serviceReachability,
                                                     CFRunLoopGetCurrent(),
                                                     kCFRunLoopCommonModes);
        }


        struct sockaddr_in addressIPv4;
        struct sockaddr_in6 addressIPv6;
        char *serverCString = (char *)[originHost UTF8String];
        if (inet_pton(AF_INET, serverCString, &addressIPv4) == 1 || inet_pton(AF_INET6, serverCString, &addressIPv6)) {

            SCNetworkReachabilityFlags currentReachabilityStateFlags;
            SCNetworkReachabilityGetFlags(self.serviceReachability, &currentReachabilityStateFlags);
            self.status = PNReachabilityStatusForFlags(currentReachabilityStateFlags);
        }

        PNLog(PNLogReachabilityLevel, self, @"START REACHABILITY OBSERVATION");
    }
    else {

        PNLog(PNLogReachabilityLevel, self, @"REACHABILITY OBSERVATION IS IMPOSSIBLE W/O ORIGIN");
    }
}

- (void)stopServiceReachabilityMonitoring {

    // Check whether reachability instance crated before destroy it
    if (self.serviceReachability) {
        
        SCNetworkReachabilityUnscheduleFromRunLoop(self.serviceReachability, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFRelease(_serviceReachability);
        _serviceReachability = NULL;


        PNLog(PNLogGeneralLevel, self, @"STOP REACHABILITY OBSERVATION");
    }

    // Make sure that simulation block won't be called after reachability observation has been disabled
    self.simulatingNetworkSwitchEvent = NO;


    // Clear cached connection information
    self.currentNetworkAddress = nil;

    // Clear cached WiFi information
    self.currentWLANSSID = nil;
    self.currentWLANBSSID = nil;
    
    // Reset reachability status
    self.status = PNReachabilityStatusUnknown;
}

- (void)suspend {

    // Make sure that simulation block won't be called after reachability observation has been suspended
    self.simulatingNetworkSwitchEvent = NO;

    // Check whether reachability instance crated before destroy it
    if (self.serviceReachability) {

        PNLog(PNLogReachabilityLevel, self, @" SUSPENDED");
        self.notificationsSuspended = YES;
    }
}

- (BOOL)isSuspended {

    return self.isNotificationsSuspended;
}

- (void)resume {

    // Check whether reachability instance crated before destroy it
    if (self.serviceReachability) {

        PNLog(PNLogReachabilityLevel, self, @" RESUMED");
        self.notificationsSuspended = NO;
    }
}


#pragma mark - Misc methods

- (NSString *)humanReadableStatus:(PNReachabilityStatus)status {

    NSString *humanReadableStatus = nil;
    switch (status) {

        case PNReachabilityStatusUnknown:

            humanReadableStatus = @"'unknown'";
            break;

        case PNReachabilityStatusNotReachable:

            humanReadableStatus = @"'not reachable'";
            break;
#if __IPHONE_OS_VERSION_MIN_REQUIRED
        case PNReachabilityStatusReachableViaCellular:

            humanReadableStatus = @"'reachable via cellular'";
            break;
#endif
        case PNReachabilityStatusReachableViaWiFi:

            humanReadableStatus = @"'reachable via WiFi'";
            break;
    }


    return humanReadableStatus;
}

- (NSString *)humanReadableInterfaceFromStatus:(PNReachabilityStatus)status {

    NSString *humanReadableInterface = nil;
    switch (status) {

        case PNReachabilityStatusUnknown:

            humanReadableInterface = @"'unknown'";
            break;

        case PNReachabilityStatusNotReachable:

            humanReadableInterface = @"'none'";
            break;
#if __IPHONE_OS_VERSION_MIN_REQUIRED
        case PNReachabilityStatusReachableViaCellular:

            humanReadableInterface = @"'cellular'";
            break;
#endif
        case PNReachabilityStatusReachableViaWiFi:

            humanReadableInterface = @"'WiFi'";
            break;
    }


    return humanReadableInterface;
}

- (BOOL)isNetworkAddressChanged {

    BOOL isNetworkAddressChanged = NO;
    NSString *currentNetworkAddress = [PNNetworkHelper networkAddress];

    // Check whether device changed it's network address or not
    if (self.currentNetworkAddress != nil && currentNetworkAddress != nil) {


        isNetworkAddressChanged = ![self.currentNetworkAddress isEqualToString:currentNetworkAddress];
    }


    return isNetworkAddressChanged;
}

- (BOOL)isWiFiAccessPointChanged {

    BOOL isNetworkWiFiChanged = NO;

    NSString *updatedWLANBSSID = [PNNetworkHelper WLANBasicServiceSetIdentifier];
    if (self.currentWLANBSSID) {

        isNetworkWiFiChanged = ![self.currentWLANBSSID isEqualToString:updatedWLANBSSID];
    }


    return isNetworkWiFiChanged;
}

- (BOOL)isServiceReachabilityChecked {
    
    return self.status != PNReachabilityStatusUnknown;
}

- (BOOL)isServiceAvailable {

    return [self isServiceAvailableForStatus:self.status];
}

- (BOOL)isServiceAvailableForStatus:(PNReachabilityStatus)status {

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    return (status == PNReachabilityStatusReachableViaCellular ||
            status == PNReachabilityStatusReachableViaWiFi);
#else

    return status == PNReachabilityStatusReachableViaWiFi;
#endif
}

- (BOOL)isInterfaceChangedFrom:(PNReachabilityStatus)originalState to:(PNReachabilityStatus)updatedState {

    BOOL isInterfaceChanged = NO;

    if (originalState != PNReachabilityStatusUnknown && originalState != PNReachabilityStatusNotReachable &&
        updatedState != PNReachabilityStatusUnknown && updatedState != PNReachabilityStatusNotReachable &&
        originalState != updatedState) {

        isInterfaceChanged = YES;
    }


    return isInterfaceChanged;
}

- (BOOL)refreshReachabilityState {

    return [self refreshReachabilityStateWithEvent:NO];
}

- (BOOL)refreshReachabilityStateWithEvent:(BOOL)shouldGenerateReachabilityChangeEvent {
    
    BOOL originallyShouldGenerateReachabilityChangeEvent = shouldGenerateReachabilityChangeEvent;

    if ([self isSuspended]) {

        [self resume];
    }


    PNReachabilityStatus oldStatus = _status;
    SCNetworkConnectionFlags reachabilityFlags;

    // Fetch cellular data reachability status
    SCNetworkReachabilityRef internetReachability = [[self class] newReachabilityForWiFi:NO];
    SCNetworkReachabilityGetFlags(internetReachability, &reachabilityFlags);
    PNReachabilityStatus reachabilityStatus = PNReachabilityStatusForFlags(reachabilityFlags);
    if (reachabilityStatus == PNReachabilityStatusUnknown || reachabilityStatus == PNReachabilityStatusNotReachable) {

        // Fetch WiFi reachability status
        SCNetworkReachabilityRef wifiReachability = [[self class] newReachabilityForWiFi:YES];
        SCNetworkReachabilityGetFlags(wifiReachability, &reachabilityFlags);
        CFRelease(wifiReachability);
    }

    self.reachabilityFlags = reachabilityFlags;
    CFRelease(internetReachability);


    PNReachabilityStatus updatedStatus = PNReachabilityStatusForFlags(reachabilityFlags);
    BOOL available = [self isServiceAvailableForStatus:updatedStatus];
    NSString *currentNetworkAddress = available ? [PNNetworkHelper networkAddress] : nil;
    if (!currentNetworkAddress) {

        currentNetworkAddress = @"'not assigned'";
    }

    if (oldStatus != updatedStatus) {

        PNLog(PNLogReachabilityLevel, self, @"{REFRESH} PubNub service reachability refresing it state: %@ / %@ "
              "[CONNECTED? %@ | NETWORK ADDRESS: %@](FLAGS: %d)", [self humanReadableStatus:oldStatus],
              [self humanReadableStatus:updatedStatus], available ? @"YES" : @"NO", currentNetworkAddress,
              reachabilityFlags);
    }

    if (self.isSimulatingNetworkSwitchEvent && [self isServiceAvailableForStatus:updatedStatus]) {

        shouldGenerateReachabilityChangeEvent = YES;
    }

    // Make sure that delayed simulation won't fire after updated reachability information arrived and not set
    // connection state in non appropriate state
    self.simulatingNetworkSwitchEvent = NO;


    // Check whether reachability report that it is currently connected and was connected before
    // In case if device changed it's IP address while reside on same interface, we can't leave it w/o notification
    // of the rest part of application who is interested in reachability
    if (!shouldGenerateReachabilityChangeEvent && ![self isInterfaceChangedFrom:oldStatus to:updatedStatus] &&
        [self isServiceAvailableForStatus:oldStatus] && [self isServiceAvailableForStatus:updatedStatus]) {

        shouldGenerateReachabilityChangeEvent = [self isNetworkAddressChanged];
    }

    // Check whether reachability interface has been changed. If interface changed, than this action can't be passed
    // w/o reachability event generation
    if (!shouldGenerateReachabilityChangeEvent && [self isInterfaceChangedFrom:oldStatus to:updatedStatus]) {

        shouldGenerateReachabilityChangeEvent = YES;
    }

    if (!originallyShouldGenerateReachabilityChangeEvent && shouldGenerateReachabilityChangeEvent) {

        PNLog(PNLogReachabilityLevel, self, @"{REFRESH} PubNub service reachability forced to generate 'change event' "
              "[CONNECTED? %@ | NETWORK ADDRESS: %@](FLAGS: %d)", available ? @"YES" : @"NO", currentNetworkAddress,
              reachabilityFlags);
    }


    if (shouldGenerateReachabilityChangeEvent) {

        self.status = updatedStatus;
    }
    else {

        if ([self isServiceAvailableForStatus:updatedStatus]) {

            self.currentNetworkAddress = [PNNetworkHelper networkAddress];
        }
        else {

            self.currentNetworkAddress = nil;
        }

        if (updatedStatus == PNReachabilityStatusReachableViaWiFi) {

            self.currentWLANSSID = [PNNetworkHelper WLANServiceSetIdentifier];
            self.currentWLANBSSID = [PNNetworkHelper WLANBasicServiceSetIdentifier];
        }
        else {

            // Clear cached WiFi information
            self.currentWLANSSID = nil;
            self.currentWLANBSSID = nil;
        }

        _status = updatedStatus;
    }


    return shouldGenerateReachabilityChangeEvent;
}

- (void)updateReachabilityFromError:(PNError *)error {

    // Check whether service was available before error arrived or not
    if ([self isServiceAvailable]) {

        switch (error.code) {

            case kPNClientConnectionFailedOnInternetFailureError:
            case kPNClientConnectionClosedOnInternetFailureError:
            case kPNRequestExecutionFailedOnInternetFailureError:

                self.status = PNReachabilityStatusNotReachable;
                break;
            default:
                break;
        }
    }
}


#pragma mark - Memory management

- (void)dealloc {
    
    // Clean up
    [self stopServiceReachabilityMonitoring];
}

- (void)setStatus:(PNReachabilityStatus)status {
    
    // Retrieved changed values (old/new)
    PNReachabilityStatus oldStatus = _status;
    PNReachabilityStatus newStatus = status;
    _status = status;
    
    // Checking whether service reachability really changed or not
    if(oldStatus != newStatus) {

        if (newStatus != PNReachabilityStatusUnknown) {

            BOOL isSimulationNetworkSwitchRequired = NO;
            if (!self.isSimulatingNetworkSwitchEvent) {

                BOOL available = [self isServiceAvailableForStatus:newStatus];
                NSString *currentNetworkAddress = available ? [PNNetworkHelper networkAddress] : nil;
                if (!currentNetworkAddress) {

                    currentNetworkAddress = @"'not assigned'";
                }

                if (![self isInterfaceChangedFrom:oldStatus to:newStatus] &&
                    [self isServiceAvailableForStatus:oldStatus] && [self isServiceAvailableForStatus:newStatus]) {

                    isSimulationNetworkSwitchRequired = [self isNetworkAddressChanged];
                    if (isSimulationNetworkSwitchRequired) {

                        PNLog(PNLogReachabilityLevel, self, @" PubNub services reachability report network address changed: '%@' "
                              "/ '%@' [CONNECTED? %@](FLAGS: %d)", self.currentNetworkAddress, currentNetworkAddress,
                              available ? @"YES" : @"NO", self.reachabilityFlags);
                    }
                    else if (newStatus == PNReachabilityStatusReachableViaWiFi) {

                        isSimulationNetworkSwitchRequired = [self isWiFiAccessPointChanged];

                        NSString *updatedWLANSSID = [PNNetworkHelper WLANServiceSetIdentifier];
                        if (isSimulationNetworkSwitchRequired) {

                            PNLog(PNLogReachabilityLevel, self, @" PubNub services reachability report switch to another WiFi: "
                                  "'%@' / '%@' [CONNECTED? %@](FLAGS: %d)", self.currentWLANSSID, updatedWLANSSID,
                                  available ? @"YES" : @"NO", self.reachabilityFlags);
                        }
                    }
                }

                if (!isSimulationNetworkSwitchRequired && [self isInterfaceChangedFrom:oldStatus to:newStatus]) {

                    isSimulationNetworkSwitchRequired = YES;

                    PNLog(PNLogReachabilityLevel, self, @"{REFRESH} PubNub services reachability noticed interface changed from "
                          "%@ to %@ [CONNECTED? %@ | NETWORK ADDRESS: %@](FLAGS: %d)",
                          [self humanReadableInterfaceFromStatus:oldStatus], [self humanReadableInterfaceFromStatus:newStatus],
                          available ? @"YES" : @"NO", currentNetworkAddress, self.reachabilityFlags);
                }
            }

            self.currentNetworkAddress = [PNNetworkHelper networkAddress];


            // In case if reachability reported that it is available on wifi
            if (newStatus == PNReachabilityStatusReachableViaWiFi) {

                self.currentWLANSSID = [PNNetworkHelper WLANServiceSetIdentifier];
                self.currentWLANBSSID = [PNNetworkHelper WLANBasicServiceSetIdentifier];
            }
            else {

                // Clear cached WiFi information
                self.currentWLANSSID = nil;
                self.currentWLANBSSID = nil;
            }


            BOOL isServiceConnected = [self isServiceAvailable];

            // Check whether reachability should be forced to update it's state to disconnected and then update state
            // after some delay or not
            if (isSimulationNetworkSwitchRequired) {

                BOOL available = [self isServiceAvailableForStatus:newStatus];
                PNLog(PNLogReachabilityLevel, self, @"{SETTER} PubNub service reachability forced to generate 'change "
                      "event' [CONNECTED? %@ | NETWORK ADDRESS: %@](FLAGS: %d)", available ? @"YES" : @"NO",
                      self.currentNetworkAddress ? self.currentNetworkAddress : @"'not assigned'",
                      self.reachabilityFlags);

                // Simulate disconnected event (disconnected from previous interface, WiFi point or old IP address)
                isServiceConnected = NO;
                _status = PNReachabilityStatusNotReachable;
                self.simulatingNetworkSwitchEvent = YES;

                __block __pn_desired_weak __typeof(self) weakSelf = self;
                int64_t delayInSeconds = kPNReachabilityNetworkSwitchSimulationDelay;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

                    // Check whether there is no new events arrived while simulated network change event
                    if (weakSelf.isSimulatingNetworkSwitchEvent) {

                        PNLog(PNLogReachabilityLevel, self, @"{FORCED} PubNub service reachability generated "
                              "'change event' [CONNECTED? %@ | NETWORK ADDRESS: %@](FLAGS: %d)",
                              available ? @"YES" : @"NO",
                              weakSelf.currentNetworkAddress ? weakSelf.currentNetworkAddress : @"'not assigned'",
                              weakSelf.reachabilityFlags);

                        weakSelf.simulatingNetworkSwitchEvent = NO;
                        weakSelf.status = newStatus;
                    }
                });
            }
            else {

                PNLog(PNLogReachabilityLevel, self, @"{SETTER} PubNub services reachability changed to: %@ "
                      "[CONNECTED? %@ | NETWORK ADDRESS: %@](FLAGS: %d)", [self humanReadableStatus:newStatus],
                      [self isServiceAvailable] ? @"YES" : @"NO",
                      self.currentNetworkAddress ? self.currentNetworkAddress : @"'not assigned'",
                      self.reachabilityFlags);
            }

            if (self.reachabilityChangeHandleBlock) {

                self.reachabilityChangeHandleBlock(isServiceConnected);
            }
        }
        else {

            PNLog(PNLogReachabilityLevel, self, @"{SETTER} PubNub services reachability got strange state: %@"
                  ". Fallback to the previous: %@ [CONNECTED? %@ | NETWORK ADDRESS: %@](FLAGS: %d)",
                  [self humanReadableStatus:newStatus], [self humanReadableStatus:oldStatus],
                  [self isServiceAvailable] ? @"YES" : @"NO",
                  self.currentNetworkAddress ? self.currentNetworkAddress : @"'not assigned'",
                  self.reachabilityFlags);
            
            // Reset reachability status to old
            _status = oldStatus;
        }
    }
}

#pragma mark -


@end
