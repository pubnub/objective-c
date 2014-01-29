//
//  PNReachability+Test.m
//  pubnubTestBackground
//
//  Created by Valentin Tuller on 1/29/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNReachability+Test.h"


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

@interface PNReachability (Test)

@property (nonatomic, assign) PNReachabilityStatus reachabilityStatus;
@property (nonatomic, assign) PNReachabilityStatus status;
@property (nonatomic, assign) PNReachabilityStatus lookupStatus;


@end

@implementation PNReachability (Test)

-(PNReachability*)init {
    if((self = [super init])) {

        self.status = PNReachabilityStatusUnknown;
        self.reachabilityStatus = PNReachabilityStatusUnknown;
        self.lookupStatus = PNReachabilityStatusUnknown;
		[self addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew) context:NULL];
    }

    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	NSLog(@"observeValueForKeyPath %@,\n %@.\nself.isSuspended %d", keyPath, change, self.isSuspended);
	if( self.isSuspended == YES )
		[self performSelector: @selector(selectorErrorChangedStatus)];
//	[super observeValueForKeyPath:keyPath
//						 ofObject:object change:change
//						  context:context];
}


@end
