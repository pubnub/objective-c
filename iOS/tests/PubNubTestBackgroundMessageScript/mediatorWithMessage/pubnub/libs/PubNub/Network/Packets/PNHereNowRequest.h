//
//  PNHereNowRequest.h
// 
//
//  Created by moonlight on 1/22/13.
//
//


#import <Foundation/Foundation.h>
#import "PNBaseRequest.h"


@interface PNHereNowRequest : PNBaseRequest


#pragma mark Class methods

<<<<<<< HEAD
+ (PNHereNowRequest *)whoNowRequestForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                                  clientState:(BOOL)shouldFetchClientState;
=======
+ (PNHereNowRequest *)whoNowRequestForChannel:(PNChannel *)channel;
>>>>>>> fix-pt65153600


#pragma mark - Instance methods

<<<<<<< HEAD
- (id)initWithChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
          clientState:(BOOL)shouldFetchClientState;
=======
- (id)initWithChannel:(PNChannel *)channel;
>>>>>>> fix-pt65153600

#pragma mark -


@end
