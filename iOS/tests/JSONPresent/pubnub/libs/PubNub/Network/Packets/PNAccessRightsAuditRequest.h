//
//  PNAccessRightsAuditRequest.h
//  pubnub
//
//  Created by Sergey Mamontov on 11/9/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//


#import "PNBaseRequest.h"


#pragma mark Class forward

@class PNAccessRightOptions;


#pragma mark - Public interface declaration

@interface PNAccessRightsAuditRequest : PNBaseRequest


#pragma mark - Properties

/**
 Stores reference on access rights option object which describe options which has been used for request.
 */
@property (nonatomic, readonly, strong) PNAccessRightOptions *accessRightOptions;


#pragma mark - Class methods

/**
 Construct and return request which allow to audit object access rights (object defined by set of parameters).

 @param channels
 Array ot \b PNChannel instances for which audition should be performed.

 @param clientsAccessKeys
 Array of \a NSString instances which describes scope of clients authorization keys for which audition should be
 performed.

 @note There possible three configuration for audition request: \a 'application' (there is no values in \a 'channels'
 and \a 'clientsAccessKeys' parameters), \a 'channel' (there is only one value in \a 'clientsAccessKeys' parameter or
 if there is no values, than request can be done for multiple channels) and \a 'user' (there is only one \a 'channel'
 parameter, than request can be done for multiple client authorization keys).

 @return instance of \b PNAccessRightsAuditRequest
 */
+ (PNAccessRightsAuditRequest *)accessRightsAuditRequestForChannels:(NSArray *)channels
                                                         andClients:(NSArray *)clientsAccessKeys;


#pragma mark - Instance methods

/**
 Initialize and return request which allow to audit object access rights (object defined by set of parameters).

 @param channels
 Array ot \b PNChannel instances for which audition should be performed.

 @param clientsAccessKeys
 Array of \a NSString instances which describes scope of clients authorization keys for which audition should be
 performed.

 @note There possible three configuration for audition request: \a 'application' (there is no values in \a 'channels'
 and \a 'clientsAccessKeys' parameters), \a 'channel' (there is only one value in \a 'clientsAccessKeys' parameter or
 if there is no values, than request can be done for multiple channels) and \a 'user' (there is only one \a 'channel'
 parameter, than request can be done for multiple client authorization keys).

 @return instance of \b PNAccessRightsAuditRequest
 */
- (id)initWithChannels:(NSArray *)channels andClients:(NSArray *)clientsAccessKeys;

#pragma mark -


@end
