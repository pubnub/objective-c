//
//  PNAccessRightsCollection+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 11/13/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNAccessRightsCollection.h"
#import "PNAccessRightOptions.h"


#pragma mark Private interface declaration

@interface PNAccessRightsCollection ()


#pragma mark - Properties

@property (nonatomic, assign) PNAccessRightsLevel level;

/**
 Stores application identifier key.
 */
@property (nonatomic, copy) NSString *applicationKey;

/**
 Stores \a 'application' access level access rights information.
 */
@property (nonatomic, strong) PNAccessRightsInformation *applicationAccessRightsInformation;

/**
 Stores dictionary of channel name - \b PNAccessRightsInformation instances pairs which represents access rights for
 \a 'channel' access level.
 */
@property (nonatomic, strong) NSMutableDictionary *channelsAccessRightsInformation;

/**
 Stores dictionary of client authorization key - \b PNAccessRightsInformation instances which represents access
 rights for \a 'user' access level.
 */
@property (nonatomic, strong) NSMutableDictionary *clientsAccessRightsInformation;


#pragma mark - Class methods

/**
 Retrieve reference on configured \b PNAccessRightsCollection instance.

 @param applicationKey
 \a NSString instance which allow to identify separate application instance which has been granted some access rights.

 @param level
 \a PNAccessRightsLevel structure field which describe access rights level for which this collection store data.

 @return \b PNAccessRightsCollection instance configured for specific application and access rights level.
 */
+ (PNAccessRightsCollection *)accessRightsCollectionForApplication:(NSString *)applicationKey
                                              andAccessRightsLevel:(PNAccessRightsLevel)level;


#pragma mark - Instance methods

/**
 Retrieve reference on initialized \b PNAccessRightsCollection instance.

 @param applicationKey
 \a NSString instance which allow to identify separate application instance which has been granted some access rights.

 @param level
 \a PNAccessRightsLevel structure field which describe access rights level for which this collection store data.

 @return \b PNAccessRightsCollection instance configured for specific application and access rights level.
 */
- (id)initWithApplication:(NSString *)applicationKey andAccessRightsLevel:(PNAccessRightsLevel)level;

/**
 @brief Filter parsed data and retrieve access rights information for all channel group objects (channel group and
 namespace)
 
 @return List of \b PNAccessRightsInformation instances each of which describe it's own channel group object access rights.
 
 @since 3.7.3
 */
- (NSArray *)accessRightsInformationForAllChannelGroupObjects;

/**
 @brief Filter parsed data and retrieve access rights information for all channel group objects (channel group and
 namespace)
 
 @param channelGroupObjectClass Reference on class against which all channel group objects should be filtered.
 
 @return List of \b PNAccessRightsInformation instances each of which describe it's own channel group objects access rights.
 
 @since 3.7.3
 */
- (NSArray *)accessRightsInformationForAllChannelGroupObjectsByClass:(Class)channelGroupObjectClass;

/**
 Assign specified information to the \a applicationAccessRightsInformation property.

 @param information
 \b PNAccessRightsInformation instance which represents \a 'application' access rights.

 @note Any channels which will be added using \a -storeChannelAccessRightsInformation: will be assigned to this
 application information.
 */
- (void)storeApplicationAccessRightsInformation:(PNAccessRightsInformation *)information;

/**
 Add provided \a 'channel' access rights information to the list in \a channelsAccessRightsInformation property.

 @note Any client which will be added using \a -storeClientAccessRightsInformation:forChannel: will be assigned to
 this channel information.
 */
- (void)storeChannelAccessRightsInformation:(PNAccessRightsInformation *)information;

/**
 Add provided \a 'user' access rights information to the list in \a clientsAccessRightsInformation property.
 */
- (void)storeClientAccessRightsInformation:(PNAccessRightsInformation *)information forChannel:(PNChannel *)channel;

/**
 Allow to correlate access rights entries with options which has been used to fetch / grant access rights information
 for specific object (object defined by set of options).

 @param options
 \b PNAccessRightOptions instance which describes object for which access rights has been changed or audited.

 @note Because of response optimisation, objects which doesn't has any access rights or rights has been revoked,
 won't be included into response from server. This method allow to make composition from server response and from
 objects requested by user, so as result we will have full picture.
 */
- (void)correlateAccessRightsWithOptions:(PNAccessRightOptions *)options;


#pragma mark - Misc methods

/**
 Allow to copy \a 'allowing' access rights from \a source access rights information into \a target access rights
 information.

 @param sourceAccessRightsInformation
 \b PNAccessRightsInformation instance from which \a 'allowing' access rights should be copied.

 @param targetAccessRightsInformation
 \b PNAccessRightsInformation instance into which \a 'allowing' access rights should be copied.

 @note This method used to override access rights information of lower layer with information from upper layer in
 case if they provide \a 'allowing' access rights at places where \c targetAccessRightsInformation doesn't allow them.
 */
- (void)populateAccessRightsFrom:(PNAccessRightsInformation *)sourceAccessRightsInformation
                              to:(PNAccessRightsInformation *)targetAccessRightsInformation;

#pragma mark -


@end
