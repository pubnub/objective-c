//
//  PNAccessRightsChangeDelegate.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/3/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNChangeAccessRightsView, PNChannel;


#pragma mark - Protocol delcaration

@protocol PNAccessRightsChangeDelegate <NSObject>


@required

#pragma mark - Grant delegate methods

/**
 Grant \a 'read' access right on \a 'application' access level.
 
 @param accessRightsChangeView
 \b PNChangeAccessRightsView instance of the view from which event arrived to the delegate.
 
 @param period
 Specify period for which access rights should be granted.
 
 @param handleBlock
 \b PubNub client will pull this block as soon as access rights audition will be completed. The block accept two parameters:
 \c collection is \b PNAccessRightsCollection instance which contains list of \b PNAccessRightsInformation instances describing particular object access rights; \c error is \b PNError instance which describe what exactly went wrong during request. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)grantApplicationReadRight:(PNChangeAccessRightsView *)accessRightsChangeView forPeriod:(NSUInteger)period
                 withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock;

/**
 Grant \a 'write' access right on \a 'application' access level.
 
 @param accessRightsChangeView
 \b PNChangeAccessRightsView instance of the view from which event arrived to the delegate.
 
 @param period
 Specify period for which access rights should be granted.
 
 @param handleBlock
 \b PubNub client will pull this block as soon as access rights audition will be completed. The block accept two parameters:
 \c collection is \b PNAccessRightsCollection instance which contains list of \b PNAccessRightsInformation instances describing particular object access rights; \c error is \b PNError instance which describe what exactly went wrong during request. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)grantApplicationWriteRight:(PNChangeAccessRightsView *)accessRightsChangeView forPeriod:(NSUInteger)period
                  withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock;

/**
 Grant \a 'all' access right on \a 'application' access level.
 
 @param accessRightsChangeView
 \b PNChangeAccessRightsView instance of the view from which event arrived to the delegate.
 
 @param period
 Specify period for which access rights should be granted.
 
 @param handleBlock
 \b PubNub client will pull this block as soon as access rights audition will be completed. The block accept two parameters:
 \c collection is \b PNAccessRightsCollection instance which contains list of \b PNAccessRightsInformation instances describing particular object access rights; \c error is \b PNError instance which describe what exactly went wrong during request. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)grantApplicationAllRights:(PNChangeAccessRightsView *)accessRightsChangeView forPeriod:(NSUInteger)period
                 withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock;

/**
 Grant \a 'read' access right \a 'channel' access level.
 
 @param channels
 List of \b PNChannel instances which identify channel for which \b PubNub client should change access rights configuration.
 
 @param period
 Specify period for which access rights should be granted.
 
 @param accessRightsChangeView
 \b PNChangeAccessRightsView instance of the view from which event arrived to the delegate.
 
 @param handleBlock
 \b PubNub client will pull this block as soon as access rights audition will be completed. The block accept two parameters:
 \c collection is \b PNAccessRightsCollection instance which contains list of \b PNAccessRightsInformation instances describing particular object access rights; \c error is \b PNError instance which describe what exactly went wrong during request. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)grantReadRightToChannels:(NSArray *)channels forPeriod:(NSUInteger)period fromView:(PNChangeAccessRightsView *)accessRightsChangeView
                withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock;

/**
 Grant \a 'write' access right on \a 'channel' access level.
 
 @param channels
 List of \b PNChannel instances which identify channel for which \b PubNub client should change access rights configuration.
 
 @param period
 Specify period for which access rights should be granted.
 
 @param accessRightsChangeView
 \b PNChangeAccessRightsView instance of the view from which event arrived to the delegate.
 
 @param handleBlock
 \b PubNub client will pull this block as soon as access rights audition will be completed. The block accept two parameters:
 \c collection is \b PNAccessRightsCollection instance which contains list of \b PNAccessRightsInformation instances describing particular object access rights; \c error is \b PNError instance which describe what exactly went wrong during request. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)grantWriteRightToChannels:(NSArray *)channels forPeriod:(NSUInteger)period fromView:(PNChangeAccessRightsView *)accessRightsChangeView
                 withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock;

/**
 Grant \a 'all' access right on \a 'channel' access level.
 
 @param channels
 List of \b PNChannel instances which identify channel for which \b PubNub client should change access rights configuration.
 
 @param period
 Specify period for which access rights should be granted.
 
 @param accessRightsChangeView
 \b PNChangeAccessRightsView instance of the view from which event arrived to the delegate.
 
 @param handleBlock
 \b PubNub client will pull this block as soon as access rights audition will be completed. The block accept two parameters:
 \c collection is \b PNAccessRightsCollection instance which contains list of \b PNAccessRightsInformation instances describing particular object access rights; \c error is \b PNError instance which describe what exactly went wrong during request. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)grantAllRightsToChannels:(NSArray *)channels forPeriod:(NSUInteger)period fromView:(PNChangeAccessRightsView *)accessRightsChangeView
                withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock;

/**
 Grant \a 'read' access right on \a 'user' access level for specific channel.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights configuration.
 
 @param clientsAuthorizationKeys
 List of \b NSString instances which identify client for which \b PubNub client should change access rights on specific channel.
 
 @param period
 Specify period for which access rights should be granted.
 
 @param accessRightsChangeView
 \b PNChangeAccessRightsView instance of the view from which event arrived to the delegate.
 
 @param handleBlock
 \b PubNub client will pull this block as soon as access rights audition will be completed. The block accept two parameters:
 \c collection is \b PNAccessRightsCollection instance which contains list of \b PNAccessRightsInformation instances describing particular object access rights; \c error is \b PNError instance which describe what exactly went wrong during request. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)grantReadRightToChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys forPeriod:(NSUInteger)period
                       fromView:(PNChangeAccessRightsView *)accessRightsChangeView withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock;

/**
 Grant \a 'write' access right on \a 'user' access level for specific channel.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights configuration.
 
 @param clientsAuthorizationKeys
 List of \b NSString instances which identify client for which \b PubNub client should change access rights on specific channel.
 
 @param period
 Specify period for which access rights should be granted.
 
 @param accessRightsChangeView
 \b PNChangeAccessRightsView instance of the view from which event arrived to the delegate.
 
 @param handleBlock
 \b PubNub client will pull this block as soon as access rights audition will be completed. The block accept two parameters:
 \c collection is \b PNAccessRightsCollection instance which contains list of \b PNAccessRightsInformation instances describing particular object access rights; \c error is \b PNError instance which describe what exactly went wrong during request. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)grantWriteRightToChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys forPeriod:(NSUInteger)period
                        fromView:(PNChangeAccessRightsView *)accessRightsChangeView withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock;

/**
 Grant \a 'all' access right on \a 'application' access level.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights configuration.
 
 @param clientsAuthorizationKeys
 List of \b NSString instances which identify client for which \b PubNub client should change access rights on specific channel.
 
 @param period
 Specify period for which access rights should be granted.
 
 @param accessRightsChangeView
 \b PNChangeAccessRightsView instance of the view from which event arrived to the delegate.
 
 @param handleBlock
 \b PubNub client will pull this block as soon as access rights audition will be completed. The block accept two parameters:
 \c collection is \b PNAccessRightsCollection instance which contains list of \b PNAccessRightsInformation instances describing particular object access rights; \c error is \b PNError instance which describe what exactly went wrong during request. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)grantAllRightsToChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys forPeriod:(NSUInteger)period
                       fromView:(PNChangeAccessRightsView *)accessRightsChangeView withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock;


#pragma mark - Revoke delegate methods
/**
 Revoke \a 'all' access right on \a 'application' access level.
 
 @param accessRightsChangeView
 \b PNChangeAccessRightsView instance of the view from which event arrived to the delegate.
 
 @param handleBlock
 \b PubNub client will pull this block as soon as access rights audition will be completed. The block accept two parameters:
 \c collection is \b PNAccessRightsCollection instance which contains list of \b PNAccessRightsInformation instances describing particular object access rights; \c error is \b PNError instance which describe what exactly went wrong during request. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)revokeApplicationAccessRights:(PNChangeAccessRightsView *)accessRightsChangeView withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock;

/**
 Revoke \a 'all' access right on \a 'channel' access level.
 
 @param channels
 List of \b PNChannel instances which identify channel for which \b PubNub client should revoke access rights configuration.
 
 @param accessRightsChangeView
 \b PNChangeAccessRightsView instance of the view from which event arrived to the delegate.
 
 @param handleBlock
 \b PubNub client will pull this block as soon as access rights audition will be completed. The block accept two parameters:
 \c collection is \b PNAccessRightsCollection instance which contains list of \b PNAccessRightsInformation instances describing particular object access rights; \c error is \b PNError instance which describe what exactly went wrong during request. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)revokeAccessRightsFromChannels:(NSArray *)channels fromView:(PNChangeAccessRightsView *)accessRightsChangeView
                      withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock;

/**
 Revoke \a 'all' access right on \a 'application' access level.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights configuration.
 
 @param clientsAuthorizationKeys
 List of \b NSString instances which identify client for which \b PubNub client should revoke access rights on specific channel.
 
 @param accessRightsChangeView
 \b PNChangeAccessRightsView instance of the view from which event arrived to the delegate.
 
 @param handleBlock
 \b PubNub client will pull this block as soon as access rights audition will be completed. The block accept two parameters:
 \c collection is \b PNAccessRightsCollection instance which contains list of \b PNAccessRightsInformation instances describing particular object access rights; \c error is \b PNError instance which describe what exactly went wrong during request. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)revokeAccessRightsFromChannel:(PNChannel *)channel forClients:(NSArray *)clientsAuthorizationKeys fromView:(PNChangeAccessRightsView *)accessRightsChangeView
                     withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock;

#pragma mark -


@end
