//
//  PNAccessRightsAuditionDelegate.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/1/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNAuditAccessRightsView, PNChannel;


#pragma mark - Protocol declaration

@protocol PNAccessRightsAuditionDelegate <NSObject>


@required

/**
 As delegate to send request which will pull out current access rights settings for whole application.
 
 @param accessRightsView
 \b PNAuditAccessRightsView instance of the view from which event arrived to the delegate.
 
 @param handleBlock
 \b PubNub client will pull this block as soon as access rights audition will be completed. The block accept two parameters:
 \c collection is \b PNAccessRightsCollection instance which contains list of \b PNAccessRightsInformation instances describing particular object access rights; \c error is \b PNError instance which describe what exactly went wrong during request. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)auditAccessRightsForApplication:(PNAuditAccessRightsView *)accessRightsView withHandlerBlock:(PNClientChannelAccessRightsAuditBlock)handleBlock;

/**
 As delegate to send request which will pull out current access rights settings for set of channels.
 
 @param channels
 List of \b PNChannel instances which identify channel for which \b PubNub client should pull our access rights configuration.
 
 @param accessRightsView
 \b PNAuditAccessRightsView instance of the view from which event arrived to the delegate.
 
 @param handleBlock
 \b PubNub client will pull this block as soon as access rights audition will be completed. The block accept two parameters:
 \c collection is \b PNAccessRightsCollection instance which contains list of \b PNAccessRightsInformation instances describing particular object access rights; \c error is \b PNError instance which describe what exactly went wrong during request. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)auditAccessRightsForChannels:(NSArray *)channels fromAccessRightsView:(PNAuditAccessRightsView *)accessRightsView
                    withHandlerBlock:(PNClientChannelAccessRightsAuditBlock)handleBlock;

/**
 As delegate to send request which will pull out current access rights settings for set of clients on specific channel.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should pull our access rights configuration.
 
 @param clientsAuthorizationKeys
 List of \b NSString instances for which access rights should be fetched for specified channel.
 
 @param accessRightsView
 \b PNAuditAccessRightsView instance of the view from which event arrived to the delegate.
 
 @param handleBlock
 \b PubNub client will pull this block as soon as access rights audition will be completed. The block accept two parameters:
 \c collection is \b PNAccessRightsCollection instance which contains list of \b PNAccessRightsInformation instances describing particular object access rights; \c error is \b PNError instance which describe what exactly went wrong during request. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys fromAccessRightsView:(PNAuditAccessRightsView *)accessRightsView
                   withHandlerBlock:(PNClientChannelAccessRightsAuditBlock)handleBlock;

#pragma mark -


@end
