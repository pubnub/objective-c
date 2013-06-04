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
#import "PNMacro.h"


#pragma mark Structures

typedef enum _PNReachabilityStatus {
    
    // PubNub services reachability wasn't tested
    // yet
    PNReachabilityStatusUnknown,
    
    // PubNub services can't be reached at this moment
    // (looks like network/internet failure occurred)
    PNReachabilityStatusNotReachable,

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    // PubNub service is reachable over cellular channel
    // (EDGE or 3G)
    PNReachabilityStatusReachableViaCellular,
#endif
    
    // PubNub services is available over WiFi
    PNReachabilityStatusReachableViaWiFi
} PNReachabilityStatus;


#pragma mark Private interface methods

@interface PNReachability ()


#pragma mark - Properties

@property (nonatomic, assign) SCNetworkConnectionFlags reachabilityFlags;
@property (nonatomic, assign) PNReachabilityStatus status;
@property (nonatomic, assign) SCNetworkReachabilityRef serviceReachability;


#pragma mark - Class methods

/**
 * Retrieve reference on created reachability instance with specific address
 */
+ (SCNetworkReachabilityRef)newReachabilityForWiFi:(BOOL)wifiReachability;


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
    address.sin_len = sizeof(address);
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
 * Helper methods for reachability status flags convertion into
 * human-readable version
 */
static PNReachabilityStatus PNReachabilityStatusForFlags(SCNetworkReachabilityFlags flags);
PNReachabilityStatus PNReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    
    PNReachabilityStatus status = PNReachabilityStatusUnknown;
    
    
    // Check whether service origin can be reached with
    // current network configuration or not
    BOOL isServiceReachable = ((flags&kSCNetworkReachabilityFlagsReachable) != 0);
    
    // Check whether service origin can be reached right
    // now or connection is required (device can connect
    // for cellular/WiFi network)
    BOOL requiresConnection = ((flags&kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    
    
    // Check whether service can be reached right not or not
    if (isServiceReachable && !requiresConnection) {
        
        status = PNReachabilityStatusReachableViaWiFi;
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED
        // Check whether service origin can be reached over
        // cellular channel of hand-held devices or not
        if ((flags&kSCNetworkReachabilityFlagsIsWWAN) != 0) {
            
            status = PNReachabilityStatusReachableViaCellular;
        }
#endif
    }
    else {
        
        status = PNReachabilityStatusNotReachable;
    }
    
    
    return status;
}

/**
 * This is reachability callback method which will be called by
 * system network subsystem each time when it notice that remote
 * service changed it's reachability state
 */
static void PNReachabilityCallback(SCNetworkReachabilityRef reachability, SCNetworkReachabilityFlags flags, void *info);
void PNReachabilityCallback(SCNetworkReachabilityRef reachability, SCNetworkReachabilityFlags flags, void *info) {
    
    // Verify that reachability callback was called for correct client
    NSCAssert([(__bridge NSObject *)info isKindOfClass:[PNReachability class]],
              @"Wrong instance has been sent as reachability observer");
    
    
    // Retrieve reference on reachability monitor and update it's state
    PNReachability *reachabilityMonitor = (__bridge PNReachability *)info;
    reachabilityMonitor.reachabilityFlags = flags;
    reachabilityMonitor.status = PNReachabilityStatusForFlags(reachabilityMonitor.reachabilityFlags);
}

- (void)startServiceReachabilityMonitoring {
    
    [self stopServiceReachabilityMonitoring];
    
    
    // Check whether origin (PubNub services host) is specified or not
    NSString *originHost = [PubNub sharedInstance].configuration.origin;
    if (originHost == nil) {
        
        return;
    }
    
    
    // Prepare and configure reachability monitor
    self.serviceReachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [originHost UTF8String]);
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
    if(SCNetworkReachabilitySetCallback(self.serviceReachability, PNReachabilityCallback, &context)) {
        
        // Schedule service reachability monitoring on current runloop with
        // common mode (prevent from blocking by other tasks)
        SCNetworkReachabilityScheduleWithRunLoop(self.serviceReachability, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    }
    
    
    struct sockaddr_in addressIPv4;
    struct sockaddr_in6 addressIPv6;
    char *serverCString = (char *)[originHost UTF8String];
    if (inet_pton(AF_INET, serverCString, &addressIPv4) == 1 || inet_pton(AF_INET6, serverCString, &addressIPv6)) {
        
        SCNetworkReachabilityFlags currentReachabilityStateFlags;
        SCNetworkReachabilityGetFlags(self.serviceReachability, &currentReachabilityStateFlags);
        self.status = PNReachabilityStatusForFlags(currentReachabilityStateFlags);
    }


    PNLog(PNLogGeneralLevel, self, @"START REACHABILITY OBSERVATION");
}

- (void)stopServiceReachabilityMonitoring {
    
    // Check whether reachability instance crated
    // before destroy it
    if (self.serviceReachability) {
        
        SCNetworkReachabilityUnscheduleFromRunLoop(self.serviceReachability, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFRelease(_serviceReachability);
        _serviceReachability = NULL;
    }
    
    
    // Reset reachability status
    self.status = PNReachabilityStatusUnknown;


    PNLog(PNLogGeneralLevel, self, @"STOP REACHABILITY OBSERVATION");
}

#pragma mark - Misc methods

- (BOOL)isServiceReachabilityChecked {
    
    return self.status != PNReachabilityStatusUnknown;
}

- (BOOL)isServiceAvailable {

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    return (self.status == PNReachabilityStatusReachableViaCellular ||
            self.status == PNReachabilityStatusReachableViaWiFi);
#else

    return self.status == PNReachabilityStatusReachableViaWiFi;
#endif
}

- (void)refreshReachabilityState {
    
    SCNetworkConnectionFlags reachabilityFlags;
    SCNetworkReachabilityRef internerReachability = [[self class] newReachabilityForWiFi:NO];
    SCNetworkReachabilityGetFlags(internerReachability, &reachabilityFlags);
    PNReachabilityStatus reachabilityStatus = PNReachabilityStatusForFlags(reachabilityFlags);
    if (reachabilityStatus == PNReachabilityStatusUnknown || reachabilityStatus == PNReachabilityStatusNotReachable) {
        
        SCNetworkReachabilityRef wifiReachability = [[self class] newReachabilityForWiFi:YES];
        SCNetworkReachabilityGetFlags(wifiReachability, &reachabilityFlags);
        CFRelease(wifiReachability);
    }
        
    self.reachabilityFlags = reachabilityFlags;
    CFRelease(internerReachability);
    
    
    _status = PNReachabilityStatusForFlags(self.reachabilityFlags);
}

- (void)updateReachabilityFromError:(PNError *)error {

    if ([self isServiceAvailable]) {

        switch (error.code) {

            case kPNClientConnectionFailedOnInternetFailureError:
            case kPNClientConnectionClosedOnInternetFailureError:
            case kPNRequestExecutionFailedOnInternetFailureError:

                self.status = PNReachabilityStatusNotReachable;
                break;
        }
    }
}


#pragma mark - Memory management

- (void)dealloc {
    
    // Clean up
    [self stopServiceReachabilityMonitoring];
}

#pragma mark -

- (void)setStatus:(PNReachabilityStatus)status {
    
    // Retrieved changed values (old/new)
    PNReachabilityStatus oldStatus = _status;
    _status = status;
    PNReachabilityStatus newStatus = _status;
    
    // Checking whether service reachability
    // really changed or not
    if(oldStatus != newStatus) {
        
        if (newStatus != PNReachabilityStatusUnknown) {
            
            PNLog(PNLogReachabilityLevel, self, @" PubNub services reachability changed [CONNECTED? %@]", [self isServiceAvailable]?@"YES":@"NO");
            
            if (self.reachabilityChangeHandleBlock) {
                
                self.reachabilityChangeHandleBlock([self isServiceAvailable]);
            }
        }
        else {
            
            // Reset reachability status to old
            _status = oldStatus;
        }
    }
}


@end
