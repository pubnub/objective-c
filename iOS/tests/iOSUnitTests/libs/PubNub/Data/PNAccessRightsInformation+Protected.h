//
//  PNAccessRightsInformation+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 11/3/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//


#import "PNAccessRightsInformation.h"


#pragma mark Private interface declaration

@interface PNAccessRightsInformation ()


#pragma mark - Properties

@property (nonatomic, assign) PNAccessRightsLevel level;
@property (nonatomic, assign) PNAccessRights rights;
@property (nonatomic, copy) NSString *subscriptionKey;
@property (nonatomic, strong) PNChannel *channel;
@property (nonatomic, strong) id <PNChannelProtocol> object;
@property (nonatomic, copy) NSString *authorizationKey;
@property (nonatomic, assign) NSUInteger accessPeriodDuration;


#pragma mark - Class methods

/**
 Construct data object which will be used to represent access rights with specified set of options.

 @code
 @endcode
 Depending on access rights level there maybe no \c channel or \c authorizationKey.

 @param level
 Access rights level: PNApplicationAccessRightsLevel, PNChannelAccessRightsLevel, PNUserAccessRightsLevel.
 This is level for which access rights has been granted or retrieved.

 @param rights
 This is bit mask which describe what exactly access rights has been granted: PNUnknownAccessRights,
 PNReadAccessRight, PNWriteAccessRight, PNNoAccessRights.

 @param subscriptionKey
 This is the key which identify application for which access rights has been granted.

 @param channel
 If \c level is set to \a PNChannelAccessRightsLevel or \a PNUserAccessRightsLevel this parameter will
 contain concrete channel for which access rights has been granted / retrieved.

 @param authorizationKey
 If \c level is set to \a PNUserAccessRightsLevel this parameter will contain authorization key which will allow
 to identify concrete user.

 @param accessPeriodDuration
 This is period for which \c rights are valid. After it ends, access rights will be revoked.

 @return reference on initialized \b PNAccessRightsInformation instance which will allow to identify and review
 access rights information.
 */
+ (PNAccessRightsInformation *)accessRightsInformationForLevel:(PNAccessRightsLevel)level rights:(PNAccessRights)rights
                                                applicationKey:(NSString *)subscriptionKey forChannel:(PNChannel *)channel
                                                        client:(NSString *)clientAuthorizationKey
                                                  accessPeriod:(NSUInteger)accessPeriodDuration;

/**
 Allow extract list of access right information for specific access level.

 @param accessRightsLevel
 Access rights level which should be retrieved from specified list.

 @param accessRightsInformation
 Array of \b PNAccessRightsInformation instances which should be filtered to find list of items with corresponding
 access right level.
 */
+ (NSArray *)accessRightsInformationForLevel:(PNAccessRightsLevel)accessRightsLevel fromList:(NSArray *)accessRightsInformation;


#pragma mark - Instance methods

/**
 Initialize data object which will be used to represent access rights with specified set of options.

 @code
 @endcode
 Depending on access rights level there maybe no \c channel or \c authorizationKey.

 @param level
 Access rights level: PNApplicationAccessRightsLevel, PNChannelAccessRightsLevel, PNUserAccessRightsLevel.
 This is level for which access rights has been granted or retrieved.

 @param rights
 This is bit mask which describe what exactly access rights has been granted: PNUnknownAccessRights,
 PNReadAccessRight, PNWriteAccessRight, PNNoAccessRights.

 @param subscriptionKey
 This is the key which identify application for which access rights has been granted.

 @param channel
 If \c level is set to \a PNChannelAccessRightsLevel or \a PNUserAccessRightsLevel this parameter will
 contain concrete channel for which access rights has been granted / retrieved.

 @param authorizationKey
 If \c level is set to \a PNUserAccessRightsLevel this parameter will contain authorization key which will allow
 to identify concrete user.

 @param accessPeriodDuration
 This is period for which \c rights are valid. After it ends, access rights will be revoked.

 @return reference on initialized \b PNAccessRightsInformation instance which will allow to identify and review
 access rights information.
 */
- (id)initWithAccessLevel:(PNAccessRightsLevel)level rights:(PNAccessRights)rights
           applicationKey:(NSString *)subscriptionKey channel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
             accessPeriod:(NSUInteger)accessPeriodDuration;

#pragma mark -


@end
