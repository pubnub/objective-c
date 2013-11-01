//
//  PNReachability+Time.m
//  pubnub
//
//  Created by Valentin Tuller on 10/30/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNReachability+Time.h"

@implementation PNReachability (Time)

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


- (SCNetworkConnectionFlags)synchronousStatusFlags {
    NSLog(@"synchronousStatusFlags start");
	NSDate *start = [NSDate date];
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
	NSTimeInterval interval = -[start timeIntervalSinceNow];
    NSLog(@"synchronousStatusFlags finish, %f", interval);
	if( interval > 1.0 )
		[self performSelector: @selector(errorSelectorReachability)];

    return reachabilityFlags;
}

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

                unsigned long flagsForCleanUp = (unsigned long)flags;
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

@end
