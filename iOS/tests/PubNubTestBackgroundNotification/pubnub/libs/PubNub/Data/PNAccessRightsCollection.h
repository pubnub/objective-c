//
//  PNAccessRightsCollection.h
//  pubnub
//
//  Created by Sergey Mamontov on 11/13/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNChannelProtocol.h"


#pragma mark Class forward

@class PNAccessRightsInformation, PNChannel;


#pragma mark - Public interface declaration

@interface PNAccessRightsCollection : NSObject


#pragma mark - Properties

/**
 Stores information about access level for which this collection stores access rights information.
 */
@property (nonatomic, readonly, assign) PNAccessRightsLevel level;


#pragma mark - Instance methods

/**
 Fetch access rights for whole \a 'application' (global).

 @return \b PNAccessRightsInformation instance which will describe \a 'application' (global) access rights.

 @note In case if this collection represent non-\a application access level, \b PNAccessRightsInformation instance
 will be created for it and access rights will be set to 'PNUnknownAccessRights'.
 */
- (PNAccessRightsInformation *)accessRightsInformationForApplication;

/**
 Fetch access rights information for all channels.

 @return List of \b PNAccessRightsInformation instances each of which describe it's own channel access rights.
 */
- (NSArray *)accessRightsInformationForAllChannels;

/**
 @brief Fetch access rights information for all channel groups.
 
 @return List of \b PNAccessRightsInformation instances each of which describe it's own channel group access rights.
 
 @since 3.7.3
 */
- (NSArray *)accessRightsInformationForAllChannelGroups;

/**
 @brief Fetch access rights information for all channel group namespacs.
 
 @return List of \b PNAccessRightsInformation instances each of which describe it's own channel group namespace access
 rights.
 
 @since 3.7.3
 */
- (NSArray *)accessRightsInformationForAllChannelGroupNamespaces;

/**
 Fetch access rights information for specific \a 'channel'.

 @param channel
 \b PNChannel instance for which access information should be pulled out.

 @return \b PNAccessRightsInformation instance which will describe concrete channel access rights.

 @note If \b PNAccessRightsCollection instance represents \a 'user' access rights level,
 it can't provide information about higher levels (\a 'application' and \a 'channel' levels).

 @note In case if specified \c channel can't be found in this collection, \b PNAccessRightsInformation instance
 will be created for it and access rights will be computed basing on higher level information. In case if this
 collection represent non-\a application access level, computed values will be \a 'PNUnknownAccessRights'.

 @note During computation even higher access rights level may take part (for example for \a 'user' level can be used
 values from \a 'application' level if available).
 */
- (PNAccessRightsInformation *)accessRightsInformationForChannel:(PNChannel *)channel
  DEPRECATED_MSG_ATTRIBUTE(" Use '-accessRightsInformationFor:' method instead.");

/**
 @brief Fetch access rights information for specific \a 'channel-group'.
 
 @param object One of \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace instance for which access
               information should be pulled out.
 
 @return \b PNAccessRightsInformation instance which will describe concrete channel access rights.
 
 @note If \b PNAccessRightsCollection instance represents \a 'user' access rights level,
 it can't provide information about higher levels (\a 'application' and \a 'channel' levels).
 @note In case if specified \c object can't be found in this collection, \b PNAccessRightsInformation instance
 will be created for it and access rights will be computed basing on higher level information. In case if this
 collection represent non-\a application access level, computed values will be \a 'PNUnknownAccessRights'.
 @note During computation even higher access rights level may take part (for example for \a 'user' level can be used
 values from \a 'application' level if available).
 
 @since 3.7.3
 */
- (PNAccessRightsInformation *)accessRightsInformationFor:(id<PNChannelProtocol>)object;

/**
 Fetch access rights information for all users associalted with specified channel.
 
 @param channel
 \b PNChannel instance for which \a 'user' access rights should be fetched.
 
 @return List of \b PNAccessRightsInformation instances each of which describe it's own user access rights.
 */
- (NSArray *)accessRightsForClientsOnChannel:(PNChannel *)channel
  DEPRECATED_MSG_ATTRIBUTE(" Use '-accessRightsForClientsOn:' method instead.");

/**
 Fetch access rights information for all users associalted with specified channel or channel group.
 
 @param channel One of \b PNChannel or \b PNChannelGroup instance for which \a 'user' access rights should be fetched.
 
 @return List of \b PNAccessRightsInformation instances each of which describe it's own user access rights.
 
 @since 3.7.3
 */
- (NSArray *)accessRightsForClientsOn:(id<PNChannelProtocol>)object;

/**
 Fetch access rights information for all users.

 @return List of \b PNAccessRightsInformation instances each of which describe it's own user access rights.
 */
- (NSArray *)accessRightsInformationForAllClientAuthorizationKeys;

/**
 Fetch access rights information for specific user on all channels.

 @return List of \b PNAccessRightsInformation instances each of which describe it's own user access rights.
 */
- (NSArray *)accessRightsInformationForClientAuthorizationKey:(NSString *)clientAuthorizationKey;

/**
 Fetch access rights information for specific \a 'user' on concrete \a 'channel'.

 @param channel
 \b PNChannel instance at which client access rights should be checked.

 @param clientAuthorizationKey
 \a NSString instance which represent client's authorization key which has been used during access rights grant or
 for which access rights should be pulled out.

 @note In case if specified \c channel and / or \c clientAuthorizationKey can't be found in this collection,
 \b PNAccessRightsInformation instance will be created for them and  will be computed access rights will be computed
 basing on higher level information. In case if this collection represent non-\a application access level and requested
 \c channel access information can't be found, computed values will be \a 'PNUnknownAccessRights'. In case if this
 collection represent non-\a channel access level and requested \c clientAuthorizationKey access information can't be
 found, computed values will be \a 'PNUnknownAccessRights'.

 @note During computation even higher access rights level may take part (for example for \a 'user' level can be used
 values from \a 'application' level if available).
 */
- (PNAccessRightsInformation *)accessRightsInformationClientAuthorizationKey:(NSString *)clientAuthorizationKey
                                                                   onChannel:(PNChannel *)channel;

#pragma mark -


@end
