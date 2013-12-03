//
//  PNAuditAccessRightsHelper.h
//  pubnub
//
//  Created by Sergey Mamontov on 11/27/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface PNAccessRightsHelper : NSObject


#pragma mark - Properties

@property (nonatomic, pn_desired_weak) IBOutlet id<UITableViewDataSource> delegate;
@property (nonatomic, copy) NSString *targetChannel;


#pragma mark - Instance methods

/**
 Feed helper with new access rights collection to show latest information about access rights.
 
 @param collection
 \b PNAccessRightsCollection instance which hold \b PNAccessRightsInformation instances to describe every particular object access rights (object defined by set of options).
 */
- (void)updateWithAccessRightsCollectionInformation:(PNAccessRightsCollection *)collection;

/**
 Update helper mode to the new access level. Basing on current access rights level corresponding changes will be performed.
 
 @param accessRightsLevel
 One of \b PNAccessRightsLevel enum fields wich will point to the desirted access rights level.
 */
- (void)updateAccessRightsLevel:(PNAccessRightsLevel)accessRightsLevel;

/**
 Add specified object to the set of objects for which data should be fetched in future or shown at this moment.
 
 @param targetObject
 Object identifier which should be added to the list.
 */
- (void)addTargetObject:(NSString *)targetObject;

/**
 Fetch target objects for which data should be fetched.
 
 @return list of \b NSString instances which identify concrete object.
 */
- (NSArray *)targetObjects;

/**
 Return whether helper has enough data to send required request (required set determined by access rights level).
 
 @return \c YES if there is enough data for request.
 */
- (BOOL)canSendRequest;

#pragma mark -


@end
