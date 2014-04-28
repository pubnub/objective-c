//
//  PNAccessRightOptions+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 11/3/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//


#import "PNAccessRightOptions.h"



#pragma mark Private interface declaration

@interface PNAccessRightOptions ()


#pragma mark - Properties

@property (nonatomic, assign) PNAccessRightsLevel level;
@property (nonatomic, assign) PNAccessRights rights;
@property (nonatomic, copy) NSString *applicationKey;
@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, strong) NSArray *clientsAuthorizationKeys;
@property (nonatomic, assign) NSUInteger accessPeriodDuration;


#pragma mark - Class methods

/**
 Construct data object which will be used for requests and requests option identification (in case of errors).

 @param applicationKey
 This is application identifier which is used along with all PAM API to identify concrete application and set of
 access rights for it.

 @param rights
 This is bit mask which describe what exactly access rights has been granted: PNUnknownAccessRights,
 PNReadAccessRight, PNWriteAccessRight, PNNoAccessRights.

 @param channels
 This is a set of \b PNChannel instances for which request has been done. Depending on the needs,
 there may be no channels at all (in this case options created for \a 'application' level).

 @param clientsAuthorizationKeys
 This is a set on string which allow identify concrete user and grant / provide corresponding access rights for him.

 @param accessPeriodDuration
 This is period for which \c rights are valid. After it ends, access rights will be revoked.

 @return reference on initialized \b PNAccessRightOptions instance which will allow to identify and review
 request options.
 */
+ (PNAccessRightOptions *)accessRightOptionsForApplication:(NSString *)applicationKey withRights:(PNAccessRights)rights
                                                  channels:(NSArray *)channels clients:(NSArray *)clientsAuthorizationKeys
                                              accessPeriod:(NSInteger)accessPeriodDuration;


#pragma mark - Instance methods

/**
 Initialize data object which will be used for requests and requests option identification (in case of errors).

 @param applicationKey
 This is application identifier which is used along with all PAM API to identify concrete application and set of
 access rights for it.

 @param rights
 This is bit mask which describe what exactly access rights has been granted: PNUnknownAccessRights,
 PNReadAccessRight, PNWriteAccessRight, PNNoAccessRights.

 @param channels
 This is a set of \b PNChannel instances for which request has been done. Depending on the needs,
 there may be no channels at all (in this case options created for \a 'application' level).

 @param clientsAuthorizationKeys
 This is a set on string which allow identify concrete user and grant / provide corresponding access rights for him.

 @param accessPeriodDuration
 This is period for which \c rights are valid. After it ends, access rights will be revoked.

 @return reference on initialized \b PNAccessRightOptions instance which will allow to identify and review
 request options.
 */
- (id)initWithApplication:(NSString *)applicationKey withRights:(PNAccessRights)rights channels:(NSArray *)channels
                  clients:(NSArray *)clientsAuthorizationKeys accessPeriod:(NSInteger)accessPeriodDuration;

#pragma mark -


@end
