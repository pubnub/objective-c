//
//  PNChangeAccessRightsRequest.h
//  pubnub
//
//  Created by Sergey Mamontov on 10/23/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//


#import "PNBaseRequest.h"
#import "PNStructures.h"


#pragma mark Class forward

@class PNAccessRightOptions, PNChannel;


#pragma mark - Public interface declaration

@interface PNChangeAccessRightsRequest : PNBaseRequest


#pragma mark - Properties

/**
 Stores reference on access rights option object which describe options which has been used for request.
 */
@property (nonatomic, readonly, strong) PNAccessRightOptions *accessRightOptions;


#pragma mark - Class methods

+ (PNChangeAccessRightsRequest *)changeAccessRightsRequestForChannels:(NSArray *)channels
                                                         accessRights:(PNAccessRights)accessRights
                                                              clients:(NSArray *)clientsAuthorizationKey
                                                            forPeriod:(NSInteger)accessPeriod;


#pragma mark - Instance methods

- (id)initWithChannels:(NSArray *)channels accessRights:(PNAccessRights)accessRights
               clients:(NSArray *)clientsAuthorizationKey period:(NSInteger)accessPeriod;

#pragma mark -


@end
