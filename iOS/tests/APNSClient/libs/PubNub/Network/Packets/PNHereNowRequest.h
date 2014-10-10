//
//  PNHereNowRequest.h
// 
//
//  Created by moonlight on 1/22/13.
//
//


#import <Foundation/Foundation.h>
#import "PNBaseRequest.h"


#pragma mark Class forward

@class PNChannel;


#pragma mark - Public interface declaration

@interface PNHereNowRequest : PNBaseRequest


#pragma mark Class methods

+ (PNHereNowRequest *)whoNowRequestForChannels:(NSArray *)channels clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                                   clientState:(BOOL)shouldFetchClientState;


#pragma mark - Instance methods

- (id)initWithChannels:(NSArray *)channels clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
           clientState:(BOOL)shouldFetchClientState;

#pragma mark -


@end
