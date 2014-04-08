//
//  PNAccessRightsHelper.h
//  pubnub
//
//  Created by Sergey Mamontov on 4/6/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNInputFormView.h"


#pragma mark Structures

/**
 Enum represent list of modes for which view can operate.
 */
typedef enum _PNAccessRightsHelperMode {
    
    PNAccessRightsHelperUnknownMode,
    PNAccessRightsHelperApplicationMode,
    PNAccessRightsHelperChannelMode,
    PNAccessRightsHelperUserMode
} PNAccessRightsHelperMode;

struct PNAccessRightsDataKeysStruct {
    
    __unsafe_unretained NSString *sectionName;
    __unsafe_unretained NSString *sectionData;
    __unsafe_unretained NSString *entrieData;
    __unsafe_unretained NSString *entrieShouldIndent;
};

extern struct PNAccessRightsDataKeysStruct PNAccessRightsDataKeys;


#pragma mark - Public interface declaration

@interface PNAccessRightsHelper : NSObject


#pragma mark - Properties

/**
 Stores reference on target mode in which current view should operate.
 */
@property (nonatomic, readonly, assign) PNAccessRightsHelperMode operationMode;

/**
 Stores reference on access right application duration which should be set.
 */
@property (nonatomic, assign) NSInteger accessRightsApplicationDuration;

/**
 Stores reference on name of the channel for which user's access rights should be changed / audited.
 */
@property (nonatomic, copy) NSString *channelName;

/**
 Stores information about which access rights should be provided during access rights modification.
 */
@property (nonatomic, assign, getter = shouldAllowRead) BOOL allowRead;
@property (nonatomic, assign, getter = shouldAllowWrite) BOOL allowWrite;

/**
 Stores whether request should be processed as access rights audition.
 */
@property (nonatomic, readonly, assign, getter = isAuditingAccessRights) BOOL auditingAccessRights;

/**
 Stores whether requests should be processed in context of rights revoke or not.
 */
@property (nonatomic, readonly, assign, getter = isRevokingAccessRights) BOOL revokingAccessRights;


#pragma mark - Instance methods

/**
 Add object which will be used in future for access rights manipulation.
 
 @param object
 It can be \b NSString (for \c user mode) or \b PNChannel instance (for \c channel mode).
 */
- (void)addObject:(id)object;

/**
 Remove object which will be used in future for access rights manipulation.
 
 @param object
 It can be \b NSString (for \c user mode) or \b PNChannel instance (for \c channel mode).
 */
- (void)removeObject:(id)object;

/**
 Initial helper configuration.
 
 @param mode
 Target helper mode which will be used for internal state calculation.
 
 @param shouldAuditAccessRights
 Whether helper should operate in access rights audition mode or not.
 
 @param shouldRevokeAccessRights
 Whether helper should revoke access rights from objects which is specified in \c mode property.
 */
- (void)configureForMode:(PNAccessRightsHelperMode)mode forAccessRightsAudition:(BOOL)shouldAuditAccessRights
    orAccessRightsRevoke:(BOOL)shouldRevokeAccessRights;

/**
 Checking whether helper has all required data for request processing or not.
 */
- (BOOL)isAbleToChangeAccessRights;

/**
 Process access right manipulation request.
 
 @param handlerBlock
 Block which is used during request processinf stages and pass only one parameter: request error (if some).
 */
- (void)performRequestWithBlock:(void(^)(NSError *))handlerBlock;

/**
 Checking whether helper will perform any requests with specified object or not.
 
 @param object
 Reference on instance against which check should be performed.
 
 @return \c YES if helper added this object for processing.
 */
- (BOOL)willManipulateWith:(id)object;

/**
 Return list which contains information as for access rights for concrete context.
 
 @return List of \b NSDictionary instances which include \b PNAccessRightsInformation instance and name of the section.
 */
- (NSArray *)accessRights;

/**
 Data which has been provided by user during request configuration.
 
 @return List of \b NSString or \b PNChannel instances (depends on operation mode).
 */
- (NSArray *)userData;

/**
 List of channels on which \b PubNub subscribed at this moment and they can be used during access rights manipulation on 
 user level.
 
 @return List of \b PNChannel instances.
 */
- (NSArray *)channels;

#pragma mark -


@end
