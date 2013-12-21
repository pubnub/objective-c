//
//  PNTimeTokenRequest.m
//  pubnub
//
//  This request object is used to describe
//  server time token retrival request which will
//  be scheduled on requests queue and executed
//  as soon as possible.
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNTimeTokenRequest.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "PNConstants.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub time token must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Public interface methods

@implementation PNTimeTokenRequest


#pragma mark - Instance methods

- (id)init {

    // Check whether initializarion successful or not
    if((self = [super init])) {

        self.sendingByUserRequest = YES;
    }


    return self;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.timeTokenCallback;
}

- (NSString *)resourcePath {
    
    return [NSString stringWithFormat:@"%@/time/%@_%@%@",
            kPNRequestAPIVersionPrefix,
            [self callbackMethodName],
            self.shortIdentifier,
            ([self authorizationField]?[NSString stringWithFormat:@"?%@", [self authorizationField]]:@"")];
}

#pragma mark -


@end
