//
//  PNChannelRegistryHelper.h
//  pubnub
//
//  Created by Sergey Mamontov on 10/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Structures

/**
 Enum represent list of modes for which view can operate.
 */
typedef enum _PNChannelRegistryHelperMode {
    
    PNChannelRegistryHelperUnknownMode,
    PNChannelRegistryHelperGroupAuditMode,
    PNChannelRegistryHelperGroupRemoveMode,
    PNChannelRegistryHelperGroupChannelsAddMode,
    PNChannelRegistryHelperGroupChannelsRemoveMode,
    PNChannelRegistryHelperGroupChannelsAuditMode,
    PNChannelRegistryHelperNamespaceRemoveMode,
    PNChannelRegistryHelperNamespaceAuditMode
} PNChannelRegistryHelperMode;


#pragma mark - Public interface declaration

@interface PNChannelRegistryHelper : NSObject


#pragma mark - Properties

/**
 Stores reference on target mode in which current view should operate.
 */
@property (nonatomic, assign) PNChannelRegistryHelperMode operationMode;

/**
 @brief Stores reference on name of channel group for which request should be done.
 */
@property (nonatomic, copy) NSString *channelGroupName;

/**
 @brief Stores reference on name of namespace for which request should be done.
 */
@property (nonatomic, copy) NSString *namespaceName;


#pragma mark - Instance methods

/**
 @brief Depending on configuration check whether audit requests can be done or not.
 
 @return \c YES in case if all required information received from user to perform request.
 */
- (BOOL)isAblePerformAuditRequest;

/**
 @brief Depending on configuration check whether state / content modify request can be done or not.
 
 @return \c YES in case if all required information received from user to perform request.
 */
- (BOOL)isAblePerformModifyRequest;

/**
 Process channel registry data fetch request.
 
 @param handlerBlock Block which is used during request processing stages and pass only one parameter: request error
 (if some).
 */
- (void)performDataFetchRequestWithBlock:(void(^)(NSError *))handlerBlock;

/**
 Process channel registry data manipulation request.
 
 @param handlerBlock Block which is used during request processing stages and pass only one parameter: request error
 (if some).
 */
- (void)performDataModifyRequestWithBlock:(void(^)(NSError *))handlerBlock;

/**
 @brief Check whether helper configured to perform removal from one of possible objects: namespace, channel group or
 channel group channels.
 
 @return \c YES in case if helper should perform removal operations.
 */
- (BOOL)isObjectRemove;

/**
 @brief Check whether helper configured to perform one of possible object's audition: namespace list, channel group list
 or channels list inside of group
 
 @return \c YES in case if helper configured for audition actions.
 */
- (BOOL)isObjectAudition;

/**
 @brief Check whether helper configured to work with namespace instances.
 
 @return \c YES in case if helper should manage namespace based operations.
 */
- (BOOL)workingWithNamespace;

/**
 @brief Check whether helper configured to work with channel group instances.
 
 @return \c YES in case if helper should manage channel group based operations.
 */
- (BOOL)workingWithChannelGroup;

/**
 @brief Check whether helper configured to work with channel group channels instances.
 
 @return \c YES in case if helper should manage channel group channels based operations.
 */
- (BOOL)workingWithChannelGroupChannels;

/**
 @brief Store user-generated / fetched object inside for future usage in request.
 
 @param object \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace instance which should be stored inside of
               helper.
 */
- (void)addObject:(id<PNChannelProtocol>)object;

/**
 @brief Remove user-generated / fetched object from interbal storage.
 
 @param object \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace instance which should be stored inside of
               helper.
 */
- (void)removeObject:(id<PNChannelProtocol>)object;

/**
 @brief Check whether specified object will be used during request processing or not
 
 @param object \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace instance against which check should be done
 
 @return \c YES in case if object has been added to the storage by user earlier.
 */
- (BOOL)willManipulateWith:(id<PNChannelProtocol>)object;

/**
 @brief Data for layout.
 
 @return List of entries which should be shown to the user.
 */
- (NSArray *)representationData;

#pragma mark -


@end
