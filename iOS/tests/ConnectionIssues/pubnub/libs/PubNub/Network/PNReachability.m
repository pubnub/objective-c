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
#import "NSObject+PNAdditions.h"
#import "PNResponseParser.h"
#import "PubNub+Protected.h"
#import "PNNetworkHelper.h"
#import "PNLoggerSymbols.h"
#import "PNConstants.h"
#import "PNResponse.h"
#import <netinet/in.h>
#import <arpa/inet.h>
#import "PNHelper.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub reachability must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Static

static int64_t const kPNReachabilityNetworkSwitchSimulationDelay = 2;


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

// Stores final network reachability status which is based on whether reachability was right about network availability or not
@property (nonatomic, assign) PNReachabilityStatus status;

// Stores network reachability status which was received from Reachability API callbacks/status refresh
@property (nonatomic, assign) PNReachabilityStatus reachabilityStatus;

// Stores network reachability status which was received from origin lookup sequence
@property (nonatomic, assign) PNReachabilityStatus lookupStatus;
@property (nonatomic, strong) NSString *currentWLANBSSID;
@property (nonatomic, strong) NSString *currentWLANSSID;

@property (nonatomic, pn_dispatch_property_ownership) dispatch_source_t originLookupTimer;


#pragma mark - Class methods

/**
 * Retrieve reference on created reachability instance with specific address
 */
+ (SCNetworkReachabilityRef)newReachabilityForWiFi:(BOOL)wifiReachability;


#pragma mark - Instance methods

- (BOOL)isSuspended;
- (BOOL)isServiceAvailable;

- (void)startServiceReachabilityMonitoring:(BOOL)shouldStopPrevious;

- (void)startOriginLookup;
- (void)startOriginLookup:(BOOL)shouldStopPrevious;
- (void)stopOriginLookup;

- (SCNetworkConnectionFlags)synchronousStatusFlags;

- (BOOL)isNetworkAddressChanged;
- (BOOL)isWiFiAccessPointChanged;
- (BOOL)isServiceAvailableForStatus:(PNReachabilityStatus)status;
- (BOOL)isInterfaceChangedFrom:(PNReachabilityStatus)originalState to:(PNReachabilityStatus)updatedState;


#pragma mark - Handler methods

- (void)handleOriginLookupTimer;
- (void)handleOriginLookupCompletionWithData:(NSData *)responseData response:(NSHTTPURLResponse *)response error:(NSError *)error;


#pragma mark - Misc methods

- (NSString *)humanReadableStatus:(PNReachabilityStatus)status;
- (NSString *)humanReadableInterfaceFromStatus:(PNReachabilityStatus)status;

#pragma mark -


@end


#pragma mark - Public interface methods

@implementation PNReachability


#pragma mark Synthesize

@synthesize status = _status;


#pragma mark - Class methods

+ (PNReachability *)serviceReachability {
    
    return [[self alloc] init];
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
        
        [self pn_setupPrivateSerialQueueWithIdentifier:@"reachability" andPriority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
        self.status = PNReachabilityStatusUnknown;
        self.reachabilityStatus = PNReachabilityStatusUnknown;
        self.lookupStatus = PNReachabilityStatusUnknown;
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
    BOOL isServiceReachable = [PNBitwiseHelper is:flags containsBit:kSCNetworkReachabilityFlagsReachable];
    if (isServiceReachable) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED
        status = [PNBitwiseHelper is:flags containsBit:kSCNetworkReachabilityFlagsIsWWAN] ? PNReachabilityStatusReachableViaCellular : status;
        if (status == PNReachabilityStatusReachableViaCellular && [PNBitwiseHelper is:flags containsBit:kSCNetworkReachabilityFlagsConnectionRequired]) {
            
            status = PNReachabilityStatusNotReachable;
        }
#endif
        if (status == PNReachabilityStatusUnknown || status == PNReachabilityStatusNotReachable) {

            if (status == PNReachabilityStatusNotReachable) {

                status = PNReachabilityStatusReachableViaWiFi;

                unsigned long flagsForCleanUp = (unsigned long)flags;
                
                [PNBitwiseHelper removeFrom:&flagsForCleanUp bits:kSCNetworkReachabilityFlagsReachable,
                 kSCNetworkReachabilityFlagsIsDirect, kSCNetworkReachabilityFlagsIsLocalAddress, BITS_LIST_TERMINATOR];
                flags = (SCNetworkReachabilityFlags)flagsForCleanUp;

                if (flags != 0) {

                    status = PNReachabilityStatusNotReachable;

                    // Check whether connection is down (required connection)
                    
                    if (![PNBitwiseHelper is:flags strictly:YES containsBits:kSCNetworkReachabilityFlagsConnectionRequired,
                          kSCNetworkReachabilityFlagsTransientConnection, BITS_LIST_TERMINATOR]) {
                        
                        if ([PNBitwiseHelper is:flags containsBit:kSCNetworkReachabilityFlagsConnectionRequired] ||
                            [PNBitwiseHelper is:flags containsBit:kSCNetworkReachabilityFlagsTransientConnection]) {

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

    [reachabilityMonitor pn_dispatchBlock:^{

        if (!reachabilityMonitor.isNotificationsSuspended) {

            [PNLogger logReachabilityMessageFrom:reachabilityMonitor withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.reachability.reachabilityFlagsChangedOnCallback, @(flags),
                        [reachabilityMonitor humanReadableStatus:status], @(available)];
            }];

            [reachabilityMonitor pn_dispatchBlock:^{

                // Make sure that delayed simulation won't fire after updated reachability information arrived and not set
                // connection state in non appropriate state
                reachabilityMonitor.simulatingNetworkSwitchEvent = NO;

                // Updating reachability information
                reachabilityMonitor.reachabilityFlags = flags;
                reachabilityMonitor.reachabilityStatus = status;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
                BOOL shouldSuspectWrongState = reachabilityMonitor.reachabilityStatus != PNReachabilityStatusReachableViaCellular;
#else
        BOOL shouldSuspectWrongState = YES;
#endif

                if (available && shouldSuspectWrongState) {

                    [reachabilityMonitor startOriginLookup];
                }

                if (!available || (available && !shouldSuspectWrongState)) {

                    if (!available) {

                        [reachabilityMonitor stopOriginLookup];
                    }

                    reachabilityMonitor.lookupStatus = status;
                }

                if (![reachabilityMonitor isServiceAvailableForStatus:status] ||
                        ([reachabilityMonitor isServiceAvailableForStatus:reachabilityMonitor.status] && [reachabilityMonitor isServiceAvailableForStatus:status])) {

                    reachabilityMonitor.status = status;
                }
                else {

                    [PNLogger logReachabilityMessageFrom:reachabilityMonitor withParametersFromBlock:^NSArray *{

                        return @[PNLoggerSymbols.reachability.reachabilityFlagsChangeIgnoredOnCallback,
                                [reachabilityMonitor humanReadableStatus:reachabilityMonitor.reachabilityStatus],
                                [reachabilityMonitor humanReadableStatus:reachabilityMonitor.lookupStatus], @(available)];
                    }];
                }
            }];
        }
        else {

            [PNLogger logReachabilityMessageFrom:reachabilityMonitor withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.reachability.reachabilityFlagsChangesWhileSuspendedOnCallback,
                        [reachabilityMonitor humanReadableStatus:status], @(available)];
            }];
        }
    }];
}

- (void)startServiceReachabilityMonitoring {

    [self startServiceReachabilityMonitoring:YES];
}

- (void)startServiceReachabilityMonitoring:(BOOL)shouldStopPrevious {

    [self pn_dispatchBlock:^{

        if (shouldStopPrevious) {

            [self stopServiceReachabilityMonitoring];
        }

        // Check whether origin (PubNub services host) is specified or not
        if (self.serviceOrigin != nil) {

            // Prepare and configure reachability monitor
            self.serviceReachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [self.serviceOrigin UTF8String]);

            SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
            if (SCNetworkReachabilitySetCallback(self.serviceReachability, PNReachabilityCallback, &context)) {

                // Schedule service reachability monitoring on private queue
                SCNetworkReachabilitySetDispatchQueue(self.serviceReachability, [self pn_privateQueue]);
            }


            if (shouldStopPrevious) {

                struct sockaddr_in addressIPv4;
                struct sockaddr_in6 addressIPv6;
                char *serverCString = (char *)[self.serviceOrigin UTF8String];
                if (inet_pton(AF_INET, serverCString, &addressIPv4) == 1 || inet_pton(AF_INET6, serverCString, &addressIPv6)) {

                    SCNetworkReachabilityFlags currentReachabilityStateFlags;
                    SCNetworkReachabilityGetFlags(self.serviceReachability, &currentReachabilityStateFlags);
                    self.reachabilityStatus = PNReachabilityStatusForFlags(currentReachabilityStateFlags);
                    self.status = self.reachabilityStatus;
                }
            }

            [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[(shouldStopPrevious ? PNLoggerSymbols.reachability.startReachabilityObservation :
                        PNLoggerSymbols.reachability.restartReachabilityObservation)];
            }];
        }
        else {

            [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.reachability.reachabilityObservationCantBeUsedWithOutOrigin];
            }];
        }
    }];
}

- (void)startOriginLookup {
    
    [self startOriginLookup:YES];
}

- (void)startOriginLookup:(BOOL)shouldStopPrevious {

    [self pn_dispatchBlock:^{

        if (shouldStopPrevious) {

            [self stopOriginLookup];
        }

        if (self.originLookupTimer == NULL) {

            dispatch_source_t timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,
                                                                   [self pn_privateQueue]);
            [PNDispatchHelper retain:timerSource];
            self.originLookupTimer = timerSource;

            __pn_desired_weak __typeof__(self) weakSelf = self;
            dispatch_source_set_event_handler(self.originLookupTimer, ^{
                
                __strong __typeof__(self) strongSelf = weakSelf;

                [strongSelf stopOriginLookup];
                [strongSelf handleOriginLookupTimer];
            });
            dispatch_source_set_cancel_handler(self.originLookupTimer, ^{
                
                __strong __typeof__(self) strongSelf = weakSelf;

                [PNDispatchHelper release:timerSource];
                strongSelf.originLookupTimer = NULL;
            });

            dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (kPNReachabilityOriginLookupInterval * NSEC_PER_SEC));
            dispatch_source_set_timer(self.originLookupTimer, start, (uint64_t) (kPNReachabilityOriginLookupInterval * NSEC_PER_SEC), NSEC_PER_SEC);
            dispatch_resume(self.originLookupTimer);
        }
    }];
}

- (void)stopOriginLookup {

    [self pn_dispatchBlock:^{

        if (self.originLookupTimer != NULL) {

            dispatch_source_cancel(self.originLookupTimer);
        }
    }];
}

- (void)restartServiceReachabilityMonitoring {

    [self pn_dispatchBlock:^{

        // Check whether reachability instance crated before destroy it
        if (self.serviceReachability) {

            SCNetworkReachabilitySetDispatchQueue(self.serviceReachability, NULL);
            CFRelease(_serviceReachability);
            _serviceReachability = NULL;

            [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.reachability.stopReachabilityObservation];
            }];
        }

        [self startServiceReachabilityMonitoring:NO];
    }];
}

- (void)stopServiceReachabilityMonitoring {

    [self pn_dispatchBlock:^{

        // Check whether reachability instance crated before destroy it
        if (self.serviceReachability) {

            SCNetworkReachabilityUnscheduleFromRunLoop(self.serviceReachability, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
            CFRelease(_serviceReachability);
            _serviceReachability = NULL;

            [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.reachability.stopReachabilityObservation];
            }];
        }

        // Make sure that simulation block won't be called after reachability observation has been disabled
        self.simulatingNetworkSwitchEvent = NO;


        // Clear cached connection information
        self.currentNetworkAddress = nil;

        // Clear cached WiFi information
        self.currentWLANSSID = nil;
        self.currentWLANBSSID = nil;

        // Reset reachability status
        self.reachabilityStatus = PNReachabilityStatusUnknown;
        self.status = PNReachabilityStatusUnknown;
    }];
}

- (void)suspend {

    // Make sure that simulation block won't be called after reachability observation has been suspended
    self.simulatingNetworkSwitchEvent = NO;

    // Check whether reachability instance crated before destroy it
    if (self.serviceReachability) {

        [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.reachability.suspendedReachabilityObservation];
        }];
        self.notificationsSuspended = YES;
        [self stopOriginLookup];
        
        self.reachabilityStatus = PNReachabilityStatusUnknown;
        self.lookupStatus = PNReachabilityStatusUnknown;
    }
}

- (void)checkSuspended:(void (^)(BOOL suspended))checkCompletionBlock {

    [self pn_dispatchBlock:^{

        checkCompletionBlock([self isSuspended]);
    }];
}

- (BOOL)isSuspended {

    return self.isNotificationsSuspended;
}

- (void)resume {

    [self pn_dispatchBlock:^{

        // Check whether reachability instance crated before destroy it
        if (self.serviceReachability && [self isSuspended]) {

            [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.reachability.resumedReachabilityObservation];
            }];
            self.notificationsSuspended = NO;
            [self startOriginLookup];
        }
    }];
}


#pragma mark - Handler methods

- (void)handleOriginLookupTimer {

    [self pn_dispatchBlock:^{

        // In case if reachability report that connection is available (not on cellular) we should launch additional lookup service which will
        // allow to check network state for sure
#if __IPHONE_OS_VERSION_MIN_REQUIRED
        BOOL shouldSuspectWrongState = self.reachabilityStatus != PNReachabilityStatusReachableViaCellular;
#else
    BOOL shouldSuspectWrongState = YES;
#endif

        // In case if server report that there is connection
        if ([self isServiceAvailableForStatus:self.reachabilityStatus] && shouldSuspectWrongState) {

            __block __pn_desired_weak __typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                __strong __typeof__(self) strongSelf = weakSelf;

                NSError *requestError;
                NSHTTPURLResponse *response;
                NSString *timeTokenRequestPath = [[PNNetworkHelper originLookupResourcePath] stringByReplacingOccurrencesOfString:@"(null)"
                                                                                                                       withString:@"pubsub.pubnub.com"];
                NSURLRequest *timeTokenRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:timeTokenRequestPath]
                                                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                   timeoutInterval:kPNReachabilityOriginLookupTimeout];
                NSData *downloadedTimeTokenData = [NSURLConnection sendSynchronousRequest:timeTokenRequest returningResponse:&response error:&requestError];

                dispatch_async([strongSelf pn_privateQueue], ^{

                    [strongSelf handleOriginLookupCompletionWithData:downloadedTimeTokenData
                                                            response:response error:requestError];
                });
            });
        }
    }];
}

- (void)handleOriginLookupCompletionWithData:(NSData *)responseData response:(NSHTTPURLResponse *)response error:(NSError *)error {

    // This method should be launched only from within it's private queue
    [self pn_scheduleOnPrivateQueueAssert];

    // In case if reachability report that connection is available (not on cellular) we should launch additional lookup service which will
    // allow to check network state for sure
#if __IPHONE_OS_VERSION_MIN_REQUIRED
    BOOL shouldSuspectWrongState = self.reachabilityStatus != PNReachabilityStatusReachableViaCellular;
#else
    BOOL shouldSuspectWrongState = YES;
#endif

    if(shouldSuspectWrongState && !self.isNotificationsSuspended) {
        
        // Make sure that delayed simulation won't fire after updated reachability information arrived and not set
        // connection state in non appropriate state
        self.simulatingNetworkSwitchEvent = NO;
        
        BOOL isConnectionAvailable = responseData != nil;
        
        if (error != nil) {
            
            switch (error.code) {
                    
                case NSURLErrorInternationalRoamingOff:
                case NSURLErrorNotConnectedToInternet:
                case NSURLErrorNetworkConnectionLost:
                case NSURLErrorResourceUnavailable:
                case NSURLErrorCannotConnectToHost:
                case NSURLErrorDNSLookupFailed:
                case NSURLErrorDataNotAllowed:
                case NSURLErrorCannotFindHost:
                case NSURLErrorCallIsActive:
                    {
                        [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

                            return @[PNLoggerSymbols.reachability.lookupFailedWithError, (error ? error : [NSNull null])];
                        }];
                        isConnectionAvailable = NO;
                    }
                    break;
                case NSURLErrorBadServerResponse:
                    {

                        [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

                            return @[PNLoggerSymbols.reachability.malformedLookupResponse];
                        }];
                    }
                    break;
                default:
                    break;
            }
        }
        else if (response.statusCode != 200 && response.statusCode != 302) {

            [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.reachability.unacceptableLookupResponseStatusCode, @(response.statusCode)];
            }];
            isConnectionAvailable = NO;
        }
        
        if (isConnectionAvailable) {
            
            PNResponse *timetokenResponse = [PNResponse responseWithContent:responseData size:[responseData length]
                                                                       code:response.statusCode lastResponseOnConnection:NO];
            PNResponseParser *parser = [PNResponseParser parserForResponse:timetokenResponse];
            
            isConnectionAvailable = [parser parsedData] != nil && ![[parser parsedData] isKindOfClass:[PNError class]];
        }

        if ([self isServiceAvailableForStatus:self.reachabilityStatus] && shouldSuspectWrongState) {
            
            [self startOriginLookup:NO];
        }
        
        // Check whether connection still available or not
        if (isConnectionAvailable) {
            
            BOOL wasDisconnectedBefore = (self.lookupStatus != PNReachabilityStatusUnknown && ![self isServiceAvailableForStatus:self.lookupStatus]) ||
                                         ![self isServiceAvailableForStatus:self.reachabilityStatus];
            self.lookupStatus = PNReachabilityStatusForFlags([self synchronousStatusFlags]);
            if (wasDisconnectedBefore) {

                [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

                    return @[PNLoggerSymbols.reachability.uplinkRestored, [self humanReadableInterfaceFromStatus:self.lookupStatus]];
                }];
            }
            
            // If after check reachability we find out that it has been changed from the moment of last reachability callback/refresh we trigger
            // overall reachability instance state update
            if (self.lookupStatus != self.reachabilityStatus || wasDisconnectedBefore) {
                
                self.status = self.lookupStatus;
            }
        }
        // Looks like "ping" request failed because of network, so we should check on whether reachability API thinks that there is
        // network connection around or not
        else if ([self isServiceAvailableForStatus:self.reachabilityStatus]) {
            
            if (self.lookupStatus != PNReachabilityStatusNotReachable) {

                [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

                    return @[PNLoggerSymbols.reachability.uplinkWentDown, [self humanReadableInterfaceFromStatus:self.reachabilityStatus]];
                }];
                self.lookupStatus = PNReachabilityStatusNotReachable;
                
                self.status = self.lookupStatus;
            }
            else {

                [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

                    return @[PNLoggerSymbols.reachability.uplinkStillDown, [self humanReadableInterfaceFromStatus:self.reachabilityStatus]];
                }];
            }
        }
        // Looks like both routes reported that there is no connection
        else if (self.lookupStatus != PNReachabilityStatusNotReachable) {

            [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.reachability.uplinkWentDown, [self humanReadableInterfaceFromStatus:self.reachabilityStatus]];
            }];
            
            self.lookupStatus = PNReachabilityStatusNotReachable;
        }
    }
    else if (self.isNotificationsSuspended) {

        [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.reachability.uplinkStateChangedDuringSuspension];
        }];
    }
}


#pragma mark - Misc methods

- (NSString *)humanReadableStatus:(PNReachabilityStatus)status {

    NSString *humanReadableStatus = @"";
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

    NSString *humanReadableInterface = @"";
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

- (SCNetworkConnectionFlags)synchronousStatusFlags {
    
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
    
    CFRelease(internetReachability);
    
    
    return reachabilityFlags;
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

- (void)checkServiceReachabilityChecked:(void (^)(BOOL checked))checkCompletionBlock {

    [self pn_dispatchBlock:^{

        if ([self isSuspended]) {

            [self resume];
        }

        if (checkCompletionBlock) {

            checkCompletionBlock(self.status != PNReachabilityStatusUnknown);
        }
    }];
}

- (void)checkServiceAvailable:(void (^)(BOOL available))checkCompletionBlock {

    [self pn_dispatchBlock:^{

        if (checkCompletionBlock) {

            checkCompletionBlock([self isServiceAvailable]);
        }
    }];
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

- (void)refreshReachabilityState:(void (^)(BOOL willGenerateReachabilityChangeEvent))refreshCompletionBlock {

    return [self refreshReachabilityStateWithEvent:NO andBlock:refreshCompletionBlock];
}

- (void)refreshReachabilityStateWithEvent:(BOOL)shouldGenerateReachabilityChangeEvent
                                 andBlock:(void (^)(BOOL willGenerateReachabilityChangeEvent))refreshCompletionBlock {

    [self pn_dispatchBlock:^{

        BOOL internalShouldGenerateReachabilityChangeEvent = shouldGenerateReachabilityChangeEvent;
        BOOL originallyShouldGenerateReachabilityChangeEvent = shouldGenerateReachabilityChangeEvent;
        BOOL isConnectionAvailabilityChanged = NO;

        if ([self isSuspended]) {

            [self resume];
        }


        PNReachabilityStatus oldStatus = _status;
        SCNetworkConnectionFlags reachabilityFlags = [self synchronousStatusFlags];
        self.reachabilityFlags = reachabilityFlags;


        PNReachabilityStatus updatedStatus = PNReachabilityStatusForFlags(reachabilityFlags);
        self.reachabilityStatus = updatedStatus;
        BOOL available = [self isServiceAvailableForStatus:updatedStatus];
        NSString *currentNetworkAddress = available ? [PNNetworkHelper networkAddress] : nil;
        if (!currentNetworkAddress) {

            currentNetworkAddress = @"'not assigned'";
        }

        // In case if reachability report that connection is available (not on cellular) we should launch additional lookup service which will
        // allow to check network state for sure
#if __IPHONE_OS_VERSION_MIN_REQUIRED
        BOOL shouldSuspectWrongState = updatedStatus != PNReachabilityStatusReachableViaCellular;
#else
    BOOL shouldSuspectWrongState = YES;
#endif

        if (![self isServiceAvailableForStatus:updatedStatus] ||
                ([self isServiceAvailableForStatus:self.status] && [self isServiceAvailableForStatus:updatedStatus])) {

            if (oldStatus != updatedStatus) {

                [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

                    return @[PNLoggerSymbols.reachability.reachabilityFlagsRefresh,
                            [self humanReadableStatus:oldStatus], [self humanReadableStatus:updatedStatus], @(available),
                            (currentNetworkAddress ? currentNetworkAddress : @"'not assigned'"), @(reachabilityFlags)];
                }];
            }

            if (self.isSimulatingNetworkSwitchEvent && [self isServiceAvailableForStatus:updatedStatus]) {

                internalShouldGenerateReachabilityChangeEvent = YES;
            }

            if ([self isServiceAvailableForStatus:oldStatus] != [self isServiceAvailableForStatus:updatedStatus]) {

                isConnectionAvailabilityChanged = YES;
                internalShouldGenerateReachabilityChangeEvent = YES;
            }

            // Make sure that delayed simulation won't fire after updated reachability information arrived and not set
            // connection state in non appropriate state
            self.simulatingNetworkSwitchEvent = NO;


            // Check whether reachability report that it is currently connected and was connected before
            // In case if device changed it's IP address while reside on same interface, we can't leave it w/o notification
            // of the rest part of application who is interested in reachability
            if (!internalShouldGenerateReachabilityChangeEvent && ![self isInterfaceChangedFrom:oldStatus to:updatedStatus] &&
                    [self isServiceAvailableForStatus:oldStatus] && [self isServiceAvailableForStatus:updatedStatus]) {

                internalShouldGenerateReachabilityChangeEvent = [self isNetworkAddressChanged];
            }

            // Check whether reachability interface has been changed. If interface changed, than this action can't be passed
            // w/o reachability event generation
            if (!internalShouldGenerateReachabilityChangeEvent && [self isInterfaceChangedFrom:oldStatus to:updatedStatus]) {

                isConnectionAvailabilityChanged = NO;
                internalShouldGenerateReachabilityChangeEvent = YES;
            }

            if (!isConnectionAvailabilityChanged) {

                if (!originallyShouldGenerateReachabilityChangeEvent && internalShouldGenerateReachabilityChangeEvent) {

                    [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

                        return @[PNLoggerSymbols.reachability.reachabilityForcedFlagsChangeOnRefresh, @(available),
                                (currentNetworkAddress ? currentNetworkAddress : @"'not assigned'"), @(reachabilityFlags)];
                    }];
                }
            }
            else {

                [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

                    return @[PNLoggerSymbols.reachability.reachabilityFlagsChangedOnRefresh, [self humanReadableStatus:updatedStatus],
                            @(available), (currentNetworkAddress ? currentNetworkAddress : @"'not assigned'"), @(reachabilityFlags)];
                }];
            }


            if (internalShouldGenerateReachabilityChangeEvent) {

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

                if ([self isServiceAvailableForStatus:updatedStatus] && shouldSuspectWrongState) {

                    [self startOriginLookup:NO];
                }

                [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

                    return @[PNLoggerSymbols.reachability.reachabilityFlagsChangedWithOutEventOnRefresh, @(available),
                            (currentNetworkAddress ? currentNetworkAddress : @"'not assigned'"), @(reachabilityFlags)];
                }];
            }
        }
        else {

            if ([self isServiceAvailableForStatus:updatedStatus] && shouldSuspectWrongState) {

                [self startOriginLookup:NO];
            }

            [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.reachability.reachabilityFlagsChangeIgnoredOnRefresh,
                        [self humanReadableStatus:self.reachabilityStatus], [self humanReadableStatus:self.lookupStatus],
                        @([self isServiceAvailableForStatus:self.lookupStatus])];
            }];
        }


        if (refreshCompletionBlock) {

            refreshCompletionBlock(internalShouldGenerateReachabilityChangeEvent && !isConnectionAvailabilityChanged);
        }
    }];
}

- (void)updateReachabilityFromError:(PNError *)error {

    [self pn_dispatchBlock:^{
        
        // Check whether service was available before error arrived or not
        if ([self isServiceAvailable]) {
            
            switch (error.code) {
                    
                case kPNClientConnectionFailedOnInternetFailureError:
                case kPNClientConnectionClosedOnInternetFailureError:
                case kPNRequestExecutionFailedOnInternetFailureError:
                    
                    self.reachabilityStatus = PNReachabilityStatusNotReachable;
                    self.status = PNReachabilityStatusNotReachable;
                    break;
                default:
                    break;
            }
        }
    }];
}


#pragma mark - Memory management

- (void)dealloc {
    
    [self pn_ignorePrivateQueueRequirement];
    
    // Clean up
    [self stopOriginLookup];
    [self stopServiceReachabilityMonitoring];
    [self pn_destroyPrivateDispatchQueue];
}

- (PNReachabilityStatus)status {
    
    // In case if reachability report that connection is available (not on cellular) we should launch additional lookup service which will
    // allow to check network state for sure
#if __IPHONE_OS_VERSION_MIN_REQUIRED
    BOOL shouldSuspectWrongState = self.reachabilityStatus != PNReachabilityStatusReachableViaCellular;
#else
    BOOL shouldSuspectWrongState = YES;
#endif
    
    PNReachabilityStatus status = self.reachabilityStatus;
    if (status != PNReachabilityStatusNotReachable) {
        
        if (self.lookupStatus != PNReachabilityStatusUnknown && self.reachabilityStatus != PNReachabilityStatusUnknown && shouldSuspectWrongState) {
            
            // In case if reachability results from origin lookup is different from those, which was received by reachability callback/refresh than
            // lookup reachability status will have bigger weight in final reachability status value
            if (self.lookupStatus != self.reachabilityStatus) {
                
                status = self.lookupStatus;
            }
        }
    }
    
    
    return status;
}

- (void)setStatus:(PNReachabilityStatus)status {
    
    [self pn_dispatchBlock:^{
        
        // Retrieved changed values (old/new)
        PNReachabilityStatus oldStatus = _status;
        PNReachabilityStatus newStatus = status;
        _status = status;
        
        // Checking whether service reachability really changed or not
        if(oldStatus != newStatus) {
            
            if (newStatus != PNReachabilityStatusUnknown) {
                
                BOOL isSimulationNetworkSwitchRequired = NO;
                if (!self.isSimulatingNetworkSwitchEvent) {
                    
                    // In case if reachability report that connection is available (not on cellular) we should launch additional lookup service which will
                    // allow to check network state for sure
#if __IPHONE_OS_VERSION_MIN_REQUIRED
                    BOOL shouldSuspectWrongState = newStatus != PNReachabilityStatusReachableViaCellular;
#else
                    BOOL shouldSuspectWrongState = YES;
#endif
                    if ([self isServiceAvailableForStatus:newStatus] && shouldSuspectWrongState) {
                        
                        [self startOriginLookup:NO];
                    }
                    
                    
                    BOOL available = [self isServiceAvailableForStatus:newStatus];
                    NSString *currentNetworkAddress = available ? [PNNetworkHelper networkAddress] : nil;
                    if (!currentNetworkAddress) {
                        
                        currentNetworkAddress = @"'not assigned'";
                    }
                    
                    if (![self isInterfaceChangedFrom:oldStatus to:newStatus] &&
                        [self isServiceAvailableForStatus:oldStatus] && [self isServiceAvailableForStatus:newStatus]) {
                        
                        isSimulationNetworkSwitchRequired = [self isNetworkAddressChanged];
                        if (isSimulationNetworkSwitchRequired) {
                            
                            [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{
                                
                                return @[PNLoggerSymbols.reachability.reachabilityNetworkAddressChangedOnSet,
                                         (self.currentNetworkAddress ? self.currentNetworkAddress : @"'not assigned'"),
                                         (currentNetworkAddress ? currentNetworkAddress : @"'not assigned'"),
                                         @(available), @(self.reachabilityFlags)];
                            }];
                        }
                        else if (newStatus == PNReachabilityStatusReachableViaWiFi) {
                            
                            isSimulationNetworkSwitchRequired = [self isWiFiAccessPointChanged];
                            
                            NSString *updatedWLANSSID = [PNNetworkHelper WLANServiceSetIdentifier];
                            if (isSimulationNetworkSwitchRequired) {
                                
                                [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{
                                    
                                    return @[PNLoggerSymbols.reachability.reachabilityHotspotChangedOnSet,
                                             (self.currentWLANSSID ? self.currentWLANSSID : [NSNull null]),
                                             (updatedWLANSSID ? updatedWLANSSID : [NSNull null]), @(available),
                                             @(self.reachabilityFlags)];
                                }];
                            }
                        }
                    }
                    
                    if (!isSimulationNetworkSwitchRequired && [self isInterfaceChangedFrom:oldStatus to:newStatus]) {
                        
                        isSimulationNetworkSwitchRequired = YES;
                        
                        [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{
                            
                            return @[PNLoggerSymbols.reachability.reachabilityInterfaceChangedOnSet,
                                     [self humanReadableInterfaceFromStatus:oldStatus], [self humanReadableInterfaceFromStatus:newStatus],
                                     @(available), (currentNetworkAddress ? currentNetworkAddress : @"'not assigned'"),
                                     @(self.reachabilityFlags)];
                        }];
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
                    
                    [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.reachability.reachabilityForcedFlagsChangeOnSet, @(available),
                                 (self.currentNetworkAddress ? self.currentNetworkAddress : @"'not assigned'"), @(self.reachabilityFlags)];
                    }];
                    
                    // Simulate disconnected event (disconnected from previous interface, WiFi point or old IP address)
                    isServiceConnected = NO;
                    self.currentNetworkAddress = nil;
                    PNReachabilityStatus originalReachabilityStatus = self.reachabilityStatus;
                    self.reachabilityStatus = PNReachabilityStatusNotReachable;
                    _status = self.reachabilityStatus;
                    self.simulatingNetworkSwitchEvent = YES;
                    
                    __block __pn_desired_weak __typeof(self) weakSelf = self;
                    int64_t delayInSeconds = kPNReachabilityNetworkSwitchSimulationDelay;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, [self pn_privateQueue], ^(void) {
                        
                        __strong __typeof__(self) strongSelf = weakSelf;
                        
                        // Check whether there is no new events arrived while simulated network change event
                        if (strongSelf.isSimulatingNetworkSwitchEvent) {
                            
                            [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{
                                
                                return @[PNLoggerSymbols.reachability.reachabilityFlagsChangeEventGeneratedOnSet, @(available),
                                         (strongSelf.currentNetworkAddress ? strongSelf.currentNetworkAddress : @"'not assigned'"),
                                         @(strongSelf.reachabilityFlags)];
                            }];
                            
                            strongSelf.simulatingNetworkSwitchEvent = NO;
                            strongSelf.reachabilityStatus = originalReachabilityStatus;
                            strongSelf.status = newStatus;
                        }
                    });
                }
                else {
                    
                    [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.reachability.reachabilityFlagsChangedOnSet, [self humanReadableStatus:newStatus],
                                 @([self isServiceAvailable]), (self.currentNetworkAddress ? self.currentNetworkAddress : @"'not assigned'"),
                                 @(self.reachabilityFlags)];
                    }];
                }
                
                if (self.reachabilityChangeHandleBlock) {
                    
                    self.reachabilityChangeHandleBlock(isServiceConnected);
                }
            }
            else if (_serviceReachability){
                
                [PNLogger logReachabilityMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.reachability.unknownReachabilityFlagsOnSet,
                             [self humanReadableStatus:newStatus], [self humanReadableStatus:oldStatus],
                             @([self isServiceAvailable]), (self.currentNetworkAddress ? self.currentNetworkAddress : @"'not assigned'"),
                             @(self.reachabilityFlags)];
                }];
                
                // Reset reachability status to old
                self.reachabilityStatus = oldStatus;
                _status = self.reachabilityStatus;
            }
        }
    }];
}

#pragma mark -


@end
