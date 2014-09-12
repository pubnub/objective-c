/**
 
 @author Sergey Mamontov
 @version 3.6.8
 @copyright © 2009-14 PubNub Inc.
 
 */

#import "PubNub+PAM.h"
#import "PNAccessRightOptions+Protected.h"
#import "NSObject+PNAdditions.h"
#import "PNServiceChannel.h"
#import "PubNub+Protected.h"
#import "PNNotifications.h"
#import "PNHelper.h"

#import "PNLogger+Protected.h"
#import "PNLoggerSymbols.h"


#pragma mark - Category private interface declaration

@interface PubNub (PAMPrivate)


#pragma mark - Instance methods

/**
 Extension of -changeAccessRightsForChannels:accessRights:clients:storeInHistory:forPeriod:withCompletionHandlingBlock:
 and allow specify whether handler block should be replaced or not.
 
 @param channels
 List of \b PNChannel instances for which access rights should be changed.
 
 @param accessRights
 Bitfield with mask from \b PNAccessRights which specify exact access rights configuration.
 
 @param clientsAuthorizationKeys
 \a NSArray of client identifiers for which access rights should be changed.
 
 @param accessPeriodDuration
 Duration during which access rights enabled. If set to \c 0 all access rights will be revoked.

 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 Handler block which is called by \b PubNub client when push notification enabling process state changes. Block pass two arguments:
 \c rightsCollection - \b PNAccessRightsCollection instance which hold resulting list of access rights represented in \b PNAccessRightsInformation instances;
 \c error - \b PNError instance which hold information about why access rights change process failed. Always
 check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)changeAccessRightsForChannels:(NSArray *)channels accessRights:(PNAccessRights)accessRights
                              clients:(NSArray *)clientsAuthorizationKeys forPeriod:(NSInteger)accessPeriodDuration
               reschedulingMethodCall:(BOOL)isMethodCallRescheduled
          withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 Postpone access rights change user request so it will be executed in future.
 
 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another request
 which has been issued earlier didn't completed yet.
 
 @param channels
 List of \b PNChannel instances on which client should change access rights.
 
 @param accessRights
 Bitfield with mask from \b PNAccessRights which specify exact access rights configuration.
 
 @param clientsAuthorizationKeys
 \a NSArray of client identifiers for which access rights should be changed.
 
 @param accessPeriodDuration
 Duration during which access rights enabled. If set to \c 0 all access rights will be revoked.

 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 Handler block which is called by \b PubNub client when access rights change process state changes. Block pass two arguments:
 \c rightsCollection - \b PNAccessRightsCollection instance which hold resulting list of access rights represented in \b PNAccessRightsInformation instances;
 \c error - \b PNError instance which hold information about why access rights change process failed. Always
 check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)postponeChangeAccessRightsForChannels:(NSArray *)channels accessRights:(PNAccessRights)accessRights
                                      clients:(NSArray *)clientsAuthorizationKeys forPeriod:(NSInteger)accessPeriodDuration
                       reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                  withCompletionHandlingBlock:(id)handlerBlock;

/**
 Final designated method which allow to audit access rights information depending on provided set of parameters.
 
 @param channels
 List of \b PNChannel instances for which client should audit access rights information.
 
 @param clientsAuthorizationKeys
 \a NSArray of client identifiers for which client should audit access rights information.

 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 Handler block which is called by \b PubNub client when access rights audition process state changes. Block pass two arguments:
 \c rightsCollection - \b PNAccessRightsCollection instance which hold resulting list of access rights represented in \b PNAccessRightsInformation instances;
 \c error - \b PNError instance which hold information about why access rights audition process failed. Always
 check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)auditAccessRightsForChannels:(NSArray *)channels clients:(NSArray *)clientsAuthorizationKeys
              reschedulingMethodCall:(BOOL)isMethodCallRescheduled
         withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;

/**
 Postpone access rights audit user request so it will be executed in future.
 
 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another request
 which has been issued earlier didn't completed yet.
 
 @param channels
 List of \b PNChannel instances for which client should audit access rights information.
 
 @param clientsAuthorizationKeys
 \a NSArray of client identifiers for which client should audit access rights information.

 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 Handler block which is called by \b PubNub client when access rights audition process state changes. Block pass two arguments:
 \c rightsCollection - \b PNAccessRightsCollection instance which hold resulting list of access rights represented in \b PNAccessRightsInformation instances;
 \c error - \b PNError instance which hold information about why access rights audition process failed. Always
 check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)postponeAuditAccessRightsForChannels:(NSArray *)channels clients:(NSArray *)clientsAuthorizationKeys
                      reschedulingMethodCall:(BOOL)isMethodCallRescheduled withCompletionHandlingBlock:(id)handlerBlock;


#pragma mark - Misc methods

/**
 This method will notify delegate about that access rights change failed with error.
 
 @param error
 Instance of \b PNError which describes what exactly happened and why this error occurred. \a 'error.associatedObject'
 contains reference on \b PNAccessRightOptions instance which will allow to review and identify what options \b PubNub client tried to apply.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)notifyDelegateAboutAccessRightsChangeFailedWithError:(PNError *)error;

/**
 This method will notify delegate about that access rights audit failed with error.
 
 @param error
 Instance of \b PNError which describes what exactly happened and why this error occurred. \a 'error.associatedObject'
 contains reference on \b PNAccessRightOptions instance which will allow to review and identify what options \b PubNub client tried to apply.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)notifyDelegateAboutAccessRightsAuditFailedWithError:(PNError *)error;

#pragma mark -


@end


#pragma mark - Category methods implementation

@implementation PubNub (PAM)


#pragma mark - Class (singleton) methods

+ (void)grantReadAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantReadAccessRightForApplicationAtPeriod:accessPeriodDuration andCompletionHandlingBlock:nil];
}

+ (void)grantReadAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                        andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:nil accessRights:PNReadAccessRight clients:nil forPeriod:accessPeriodDuration
            withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantWriteAccessRightForApplicationAtPeriod:accessPeriodDuration andCompletionHandlingBlock:nil];
}

+ (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                         andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:nil accessRights:PNWriteAccessRight clients:nil forPeriod:accessPeriodDuration
            withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantAllAccessRightsForApplicationAtPeriod:accessPeriodDuration andCompletionHandlingBlock:nil];
}

+ (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                        andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:nil accessRights:(PNReadAccessRight | PNWriteAccessRight) clients:nil
                              forPeriod:accessPeriodDuration withCompletionHandlingBlock:handlerBlock];
}

+ (void)revokeAccessRightsForApplication {
    
    [self revokeAccessRightsForApplicationWithCompletionHandlingBlock:nil];
}

+ (void)revokeAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:nil accessRights:PNNoAccessRights clients:nil forPeriod:0
            withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantReadAccessRightForChannel:channel forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self grantReadAccessRightForChannels:(channel ? @[channel] : nil) forPeriod:accessPeriodDuration
              withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey {
    
    [self grantReadAccessRightForChannel:channel forPeriod:accessPeriodDuration client:clientAuthorizationKey
             withCompletionHandlingBlock:nil];
}

+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self grantReadAccessRightForChannel:channel forPeriod:accessPeriodDuration
                                 clients:(clientAuthorizationKey ? @[clientAuthorizationKey] : nil)
             withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantReadAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantReadAccessRightForChannels:channels forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

+ (void)grantReadAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:channels accessRights:PNReadAccessRight clients:nil
                              forPeriod:accessPeriodDuration withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys {
    
    [self grantReadAccessRightForChannel:channel forPeriod:accessPeriodDuration clients:clientsAuthorizationKeys
             withCompletionHandlingBlock:nil];
    
}
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsForChannels:(channel ? @[channel] : nil) accessRights:PNReadAccessRight
                                clients:clientsAuthorizationKeys forPeriod:accessPeriodDuration
            withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantWriteAccessRightForChannel:channel forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self grantWriteAccessRightForChannels:(channel ? @[channel] : nil) forPeriod:accessPeriodDuration
               withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                 client:(NSString *)clientAuthorizationKey {
    
    [self grantWriteAccessRightForChannel:channel forPeriod:accessPeriodDuration client:clientAuthorizationKey
              withCompletionHandlingBlock:nil];
}

+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                 client:(NSString *)clientAuthorizationKey
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self grantWriteAccessRightForChannel:channel forPeriod:accessPeriodDuration
                                  clients:(clientAuthorizationKey ? @[clientAuthorizationKey] : nil)
              withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantWriteAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantWriteAccessRightForChannels:channels forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

+ (void)grantWriteAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
             withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsForChannels:channels accessRights:PNWriteAccessRight clients:nil
                              forPeriod:accessPeriodDuration withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                clients:(NSArray *)clientsAuthorizationKeys {
    
    [self grantWriteAccessRightForChannel:channel forPeriod:accessPeriodDuration clients:clientsAuthorizationKeys
              withCompletionHandlingBlock:nil];
}

+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                clients:(NSArray *)clientsAuthorizationKeys
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsForChannels:(channel ? @[channel] : nil) accessRights:PNWriteAccessRight
                                clients:clientsAuthorizationKeys forPeriod:accessPeriodDuration
            withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantAllAccessRightsForChannel:channel forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self grantAllAccessRightsForChannels:(channel ? @[channel] : nil) forPeriod:accessPeriodDuration
              withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey {
    
    [self grantAllAccessRightsForChannel:channel forPeriod:accessPeriodDuration client:clientAuthorizationKey
             withCompletionHandlingBlock:nil];
}

+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self grantAllAccessRightsForChannel:channel forPeriod:accessPeriodDuration
                                 clients:(clientAuthorizationKey ? @[clientAuthorizationKey] : nil)
             withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantAllAccessRightsForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantAllAccessRightsForChannels:channels forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

+ (void)grantAllAccessRightsForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsForChannels:channels accessRights:(PNReadAccessRight | PNWriteAccessRight)
                                clients:nil forPeriod:accessPeriodDuration withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys {
    
    [self grantAllAccessRightsForChannel:channel forPeriod:accessPeriodDuration clients:clientsAuthorizationKeys
             withCompletionHandlingBlock:nil];
}

+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsForChannels:(channel ? @[channel] : nil) accessRights:(PNReadAccessRight | PNWriteAccessRight)
                                clients:clientsAuthorizationKeys forPeriod:accessPeriodDuration
            withCompletionHandlingBlock:handlerBlock];
}

+ (void)revokeAccessRightsForChannel:(PNChannel *)channel {
    
    [self revokeAccessRightsForChannel:channel withCompletionHandlingBlock:nil];
}

+ (void)revokeAccessRightsForChannel:(PNChannel *)channel
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self revokeAccessRightsForChannels:(channel ? @[channel] : nil) withCompletionHandlingBlock:handlerBlock];
}

+ (void)revokeAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey {
    
    [self revokeAccessRightsForChannel:channel client:clientAuthorizationKey withCompletionHandlingBlock:nil];
}

+ (void)revokeAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self revokeAccessRightsForChannel:channel clients:(clientAuthorizationKey ? @[clientAuthorizationKey] : nil)
           withCompletionHandlingBlock:handlerBlock];
}

+ (void)revokeAccessRightsForChannels:(NSArray *)channels {
    
    [self revokeAccessRightsForChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)revokeAccessRightsForChannels:(NSArray *)channels
          withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsForChannels:channels accessRights:PNNoAccessRights clients:nil forPeriod:0
            withCompletionHandlingBlock:handlerBlock];
}

+ (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys {
    
    [self revokeAccessRightsForChannel:channel clients:clientsAuthorizationKeys withCompletionHandlingBlock:nil];
}

+ (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsForChannels:(channel ? @[channel] : nil) accessRights:PNNoAccessRights
                                clients:clientsAuthorizationKeys forPeriod:0 withCompletionHandlingBlock:handlerBlock];
}

+ (void)changeAccessRightsForChannels:(NSArray *)channels accessRights:(PNAccessRights)accessRights
                              clients:(NSArray *)clientsAuthorizationKeys forPeriod:(NSInteger)accessPeriodDuration
          withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {


    [[self sharedInstance] changeAccessRightsForChannels:channels accessRights:accessRights clients:clientsAuthorizationKeys
                                               forPeriod:accessPeriodDuration reschedulingMethodCall:NO
                             withCompletionHandlingBlock:handlerBlock];
}

+ (void)auditAccessRightsForApplication {
    
    [self auditAccessRightsForApplicationWithCompletionHandlingBlock:nil];
}

+ (void)auditAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [self auditAccessRightsForChannel:nil withCompletionHandlingBlock:handlerBlock];
}

+ (void)auditAccessRightsForChannel:(PNChannel *)channel {
    
    [self auditAccessRightsForChannel:nil withCompletionHandlingBlock:nil];
}

+ (void)auditAccessRightsForChannel:(PNChannel *)channel withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [self auditAccessRightsForChannels:(channel ? @[channel] : nil) withCompletionHandlingBlock:handlerBlock];
}

+ (void)auditAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey {
    
    [self auditAccessRightsForChannel:channel client:clientAuthorizationKey withCompletionHandlingBlock:nil];
}

+ (void)auditAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [self auditAccessRightsForChannel:channel clients:(clientAuthorizationKey ? @[clientAuthorizationKey] : nil)
          withCompletionHandlingBlock:handlerBlock];
}

+ (void)auditAccessRightsForChannels:(NSArray *)channels {
    
    [self auditAccessRightsForChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)auditAccessRightsForChannels:(NSArray *)channels
         withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [self auditAccessRightsForChannels:channels clients:nil withCompletionHandlingBlock:handlerBlock];
}

+ (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys {
    
    [self auditAccessRightsForChannel:channel clients:clientsAuthorizationKeys withCompletionHandlingBlock:nil];
}

+ (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [self auditAccessRightsForChannels:(channel ? @[channel] : nil) clients:clientsAuthorizationKeys
           withCompletionHandlingBlock:handlerBlock];
}

+ (void)auditAccessRightsForChannels:(NSArray *)channels clients:(NSArray *)clientsAuthorizationKeys
         withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {

    [[self sharedInstance] auditAccessRightsForChannels:channels
                                                clients:clientsAuthorizationKeys
                                 reschedulingMethodCall:NO
                            withCompletionHandlingBlock:handlerBlock];
}


#pragma mark - Instance methods

- (void)grantReadAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantReadAccessRightForApplicationAtPeriod:accessPeriodDuration andCompletionHandlingBlock:nil];
}

- (void)grantReadAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                        andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:nil accessRights:PNReadAccessRight clients:nil forPeriod:accessPeriodDuration
                 reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

- (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantWriteAccessRightForApplicationAtPeriod:accessPeriodDuration andCompletionHandlingBlock:nil];
}

- (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                         andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:nil accessRights:PNWriteAccessRight clients:nil forPeriod:accessPeriodDuration
                 reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

- (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantAllAccessRightsForApplicationAtPeriod:accessPeriodDuration andCompletionHandlingBlock:nil];
}

- (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                        andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:nil accessRights:(PNReadAccessRight | PNWriteAccessRight) clients:nil
                              forPeriod:accessPeriodDuration reschedulingMethodCall:NO
            withCompletionHandlingBlock:handlerBlock];
}

- (void)revokeAccessRightsForApplication {
    
    [self revokeAccessRightsForApplicationWithCompletionHandlingBlock:nil];
}

- (void)revokeAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:nil accessRights:PNNoAccessRights clients:nil forPeriod:0
                 reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

- (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantReadAccessRightForChannel:channel forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

- (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self grantReadAccessRightForChannels:(channel ? @[channel] : nil) forPeriod:accessPeriodDuration
              withCompletionHandlingBlock:handlerBlock];
}

- (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey {
    
    [self grantReadAccessRightForChannel:channel forPeriod:accessPeriodDuration client:clientAuthorizationKey
             withCompletionHandlingBlock:nil];
}

- (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self grantReadAccessRightForChannel:channel forPeriod:accessPeriodDuration
                                 clients:(clientAuthorizationKey ? @[clientAuthorizationKey] : nil)
             withCompletionHandlingBlock:handlerBlock];
}

- (void)grantReadAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantReadAccessRightForChannels:channels forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

- (void)grantReadAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:channels accessRights:PNReadAccessRight clients:nil
                              forPeriod:accessPeriodDuration reschedulingMethodCall:NO
            withCompletionHandlingBlock:handlerBlock];
}

- (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys {
    
    [self grantReadAccessRightForChannel:channel forPeriod:accessPeriodDuration clients:clientsAuthorizationKeys
             withCompletionHandlingBlock:nil];
}

- (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:(channel ? @[channel] : nil) accessRights:PNReadAccessRight
                                clients:clientsAuthorizationKeys forPeriod:accessPeriodDuration
                 reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

- (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantWriteAccessRightForChannel:channel forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

- (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self grantWriteAccessRightForChannels:(channel ? @[channel] : nil) forPeriod:accessPeriodDuration
               withCompletionHandlingBlock:handlerBlock];
}

- (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                 client:(NSString *)clientAuthorizationKey {
    
    [self grantWriteAccessRightForChannel:channel forPeriod:accessPeriodDuration client:clientAuthorizationKey
              withCompletionHandlingBlock:nil];
}

- (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                 client:(NSString *)clientAuthorizationKey
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self grantWriteAccessRightForChannel:channel forPeriod:accessPeriodDuration
                                  clients:(clientAuthorizationKey ? @[clientAuthorizationKey] : nil)
              withCompletionHandlingBlock:handlerBlock];
}

- (void)grantWriteAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantWriteAccessRightForChannels:channels forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

- (void)grantWriteAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
             withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:channels accessRights:PNWriteAccessRight clients:nil forPeriod:accessPeriodDuration
                 reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

- (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                clients:(NSArray *)clientsAuthorizationKeys {
    
    [self grantWriteAccessRightForChannel:channel forPeriod:accessPeriodDuration clients:clientsAuthorizationKeys
              withCompletionHandlingBlock:nil];
}

- (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                clients:(NSArray *)clientsAuthorizationKeys
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:(channel ? @[channel] : nil) accessRights:PNWriteAccessRight
                                clients:clientsAuthorizationKeys forPeriod:accessPeriodDuration
                 reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

- (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantAllAccessRightsForChannel:channel forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

- (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self grantAllAccessRightsForChannels:(channel ? @[channel] : nil) forPeriod:accessPeriodDuration
              withCompletionHandlingBlock:handlerBlock];
}

- (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey {
    
    [self grantAllAccessRightsForChannel:channel forPeriod:accessPeriodDuration client:clientAuthorizationKey
             withCompletionHandlingBlock:nil];
}

- (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self grantAllAccessRightsForChannel:channel forPeriod:accessPeriodDuration
                                 clients:(clientAuthorizationKey ? @[clientAuthorizationKey] : nil)
             withCompletionHandlingBlock:handlerBlock];
}

- (void)grantAllAccessRightsForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantAllAccessRightsForChannels:channels forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

- (void)grantAllAccessRightsForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:channels accessRights:(PNReadAccessRight | PNWriteAccessRight) clients:nil
                              forPeriod:accessPeriodDuration reschedulingMethodCall:NO
            withCompletionHandlingBlock:handlerBlock];
}

- (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys {
    
    [self grantAllAccessRightsForChannel:channel forPeriod:accessPeriodDuration clients:clientsAuthorizationKeys
             withCompletionHandlingBlock:nil];
}

- (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:(channel ? @[channel] : nil) accessRights:(PNReadAccessRight | PNWriteAccessRight)
                                clients:clientsAuthorizationKeys forPeriod:accessPeriodDuration reschedulingMethodCall:NO
            withCompletionHandlingBlock:handlerBlock];
}

- (void)revokeAccessRightsForChannel:(PNChannel *)channel {
    
    [self revokeAccessRightsForChannel:channel withCompletionHandlingBlock:nil];
}

- (void)revokeAccessRightsForChannel:(PNChannel *)channel
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self revokeAccessRightsForChannels:(channel ? @[channel] : nil) withCompletionHandlingBlock:handlerBlock];
}

- (void)revokeAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey {
    
    [self revokeAccessRightsForChannel:channel client:clientAuthorizationKey withCompletionHandlingBlock:nil];
}

- (void)revokeAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self revokeAccessRightsForChannel:channel clients:(clientAuthorizationKey ? @[clientAuthorizationKey] : nil)
           withCompletionHandlingBlock:handlerBlock];
}

- (void)revokeAccessRightsForChannels:(NSArray *)channels {
    
    [self revokeAccessRightsForChannels:channels withCompletionHandlingBlock:nil];
}

- (void)revokeAccessRightsForChannels:(NSArray *)channels
          withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:channels accessRights:PNNoAccessRights clients:nil forPeriod:0
                 reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

- (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys {
    
    [self revokeAccessRightsForChannel:channel clients:clientsAuthorizationKeys withCompletionHandlingBlock:nil];
}

- (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:(channel ? @[channel] : nil) accessRights:PNNoAccessRights
                                clients:clientsAuthorizationKeys forPeriod:0 reschedulingMethodCall:NO
            withCompletionHandlingBlock:handlerBlock];
}

- (void)changeAccessRightsForChannels:(NSArray *)channels accessRights:(PNAccessRights)accessRights
                              clients:(NSArray *)clientsAuthorizationKeys forPeriod:(NSInteger)accessPeriodDuration
               reschedulingMethodCall:(BOOL)isMethodCallRescheduled
          withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.accessRightsChangeAttempt, (channels ? channels : [NSNull null]),
                 (clientsAuthorizationKeys ? clientsAuthorizationKeys : [NSNull null]), @(accessRights), @(accessPeriodDuration),
                 [self humanReadableStateFrom:self.state]];
    }];
    
    // Initialize arrays in case if used specified \a 'nil' for \a 'channels' and/or \a 'clientsAuthorizationKeys'
    channels = channels ? channels : @[];
    clientsAuthorizationKeys = clientsAuthorizationKeys ? clientsAuthorizationKeys : @[];
    
    [self performAsyncLockingBlock:^{
        
        [self pn_dispatchAsynchronouslyBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsAccessRightsChangeObserver];
            }
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0 && [self.configuration.secretKey length]) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.changeAccessRights, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsAccessRightsChangeObserverWithBlock:handlerBlock];
                }
                
                [self.serviceChannel changeAccessRightsForChannels:channels accessRights:accessRights
                                                 authorizationKeys:clientsAuthorizationKeys forPeriod:accessPeriodDuration];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.accessRightsChangeImpossible, [self humanReadableStateFrom:self.state]];
                }];
                
                PNAccessRightOptions *options = [PNAccessRightOptions accessRightOptionsForApplication:self.configuration.subscriptionKey
                                                                                            withRights:accessRights
                                                                                              channels:channels
                                                                                               clients:clientsAuthorizationKeys
                                                                                          accessPeriod:accessPeriodDuration];
                if (![self.configuration.secretKey length]) {
                    
                    statusCode = kPNSecretKeyNotSpecifiedError;
                }
                PNError *accessRightChangeError = [PNError errorWithCode:statusCode];
                accessRightChangeError.associatedObject = options;
                
                [self notifyDelegateAboutAccessRightsChangeFailedWithError:accessRightChangeError];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    handlerBlock(nil, accessRightChangeError);
                }
            }
        }];
    }
           postponedExecutionBlock:^{
               
               [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                   
                   return @[PNLoggerSymbols.api.postponeAccessRightsChange, [self humanReadableStateFrom:self.state]];
               }];

               [self postponeChangeAccessRightsForChannels:channels accessRights:accessRights clients:clientsAuthorizationKeys
                                                 forPeriod:accessPeriodDuration reschedulingMethodCall:isMethodCallRescheduled
                               withCompletionHandlingBlock:handlerBlock];
           }];
}

- (void)postponeChangeAccessRightsForChannels:(NSArray *)channels accessRights:(PNAccessRights)accessRights
                                      clients:(NSArray *)clientsAuthorizationKeys forPeriod:(NSInteger)accessPeriodDuration
                       reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                  withCompletionHandlingBlock:(id)handlerBlock {
    
    SEL selector = @selector(changeAccessRightsForChannels:accessRights:clients:forPeriod:reschedulingMethodCall:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:selector forObject:self
            withParameters:@[channels, [NSNumber numberWithUnsignedLong:accessRights], clientsAuthorizationKeys,
                             [NSNumber numberWithInteger:accessPeriodDuration],
                             @(isMethodCallRescheduled), [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}

- (void)auditAccessRightsForApplication {
    
    [self auditAccessRightsForApplicationWithCompletionHandlingBlock:nil];
}

- (void)auditAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [self auditAccessRightsForChannel:nil withCompletionHandlingBlock:handlerBlock];
}

- (void)auditAccessRightsForChannel:(PNChannel *)channel {
    
    [self auditAccessRightsForChannel:channel withCompletionHandlingBlock:nil];
}

- (void)auditAccessRightsForChannel:(PNChannel *)channel
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [self auditAccessRightsForChannel:channel client:nil withCompletionHandlingBlock:handlerBlock];
}

- (void)auditAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey {
    
    [self auditAccessRightsForChannel:channel client:clientAuthorizationKey withCompletionHandlingBlock:nil];
}

- (void)auditAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [self auditAccessRightsForChannel:channel clients:(clientAuthorizationKey ? @[clientAuthorizationKey] : nil)
          withCompletionHandlingBlock:handlerBlock];
}

- (void)auditAccessRightsForChannels:(NSArray *)channels {
    
    [self auditAccessRightsForChannels:channels withCompletionHandlingBlock:nil];
}

- (void)auditAccessRightsForChannels:(NSArray *)channels
         withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {

    [self auditAccessRightsForChannels:channels
                               clients:nil
                reschedulingMethodCall:NO
           withCompletionHandlingBlock:handlerBlock];
}

- (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys {
    
    [self auditAccessRightsForChannel:channel clients:clientsAuthorizationKeys withCompletionHandlingBlock:nil];
}

- (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {

    [self auditAccessRightsForChannels:(channel ? @[channel] : nil)
                               clients:clientsAuthorizationKeys
                reschedulingMethodCall:NO
           withCompletionHandlingBlock:handlerBlock];
}

- (void)auditAccessRightsForChannels:(NSArray *)channels clients:(NSArray *)clientsAuthorizationKeys
              reschedulingMethodCall:(BOOL)isMethodCallRescheduled
         withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.accessRightsAuditAttempt, (channels ? channels : [NSNull null]),
                 (clientsAuthorizationKeys ? clientsAuthorizationKeys : [NSNull null]),
                 [self humanReadableStateFrom:self.state]];
    }];
    
    // Initialize arrays in case if used specified \a 'nil' for \a 'channels' and/or \a 'clientsAuthorizationKeys'
    channels = channels ? channels : @[];
    clientsAuthorizationKeys = (clientsAuthorizationKeys ? clientsAuthorizationKeys : @[]);
    
    [self performAsyncLockingBlock:^{
        
        [self pn_dispatchAsynchronouslyBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsAccessRightsAuditObserver];
            }
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0 && [self.configuration.secretKey length]) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.auditAccessRights, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsAccessRightsAuditObserverWithBlock:handlerBlock];
                }
                
                [self.serviceChannel auditAccessRightsForChannels:channels clients:clientsAuthorizationKeys];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.accessRightsAuditImpossible, [self humanReadableStateFrom:self.state]];
                }];
                
                PNAccessRightOptions *options = [PNAccessRightOptions accessRightOptionsForApplication:self.configuration.subscriptionKey
                                                                                            withRights:PNUnknownAccessRights
                                                                                              channels:channels
                                                                                               clients:clientsAuthorizationKeys
                                                                                          accessPeriod:0];
                if (![self.configuration.secretKey length]) {
                    
                    statusCode = kPNSecretKeyNotSpecifiedError;
                }
                PNError *accessRightAuditError = [PNError errorWithCode:statusCode];
                accessRightAuditError.associatedObject = options;
                
                [self notifyDelegateAboutAccessRightsAuditFailedWithError:accessRightAuditError];
                
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    handlerBlock(nil, accessRightAuditError);
                }
            }
        }];
    }
           postponedExecutionBlock:^{
               
               [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                   
                   return @[PNLoggerSymbols.api.postponeAccessRightsAudit, [self humanReadableStateFrom:self.state]];
               }];

               [self postponeAuditAccessRightsForChannels:channels clients:clientsAuthorizationKeys
                                   reschedulingMethodCall:isMethodCallRescheduled
                              withCompletionHandlingBlock:handlerBlock];
           }];
}

- (void)postponeAuditAccessRightsForChannels:(NSArray *)channels clients:(NSArray *)clientsAuthorizationKeys
                      reschedulingMethodCall:(BOOL)isMethodCallRescheduled withCompletionHandlingBlock:(id)handlerBlock {
    
    SEL selector = @selector(auditAccessRightsForChannels:clients:reschedulingMethodCall:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:selector forObject:self withParameters:@[channels, clientsAuthorizationKeys, @(isMethodCallRescheduled),
                                                                    [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}


#pragma mark - Misc methods

- (void)notifyDelegateAboutAccessRightsChangeFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.accessRightsChangeFailed, [self humanReadableStateFrom:self.state]];
        }];
        
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:accessRightsChangeDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [self.clientDelegate pubnubClient:self accessRightsChangeDidFailWithError:error];
            });
        }
        
        [self sendNotification:kPNClientAccessRightsChangeDidFailNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutAccessRightsAuditFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.accessRightsAuditFailed, [self humanReadableStateFrom:self.state]];
        }];
        
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:accessRightsAuditDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [self.clientDelegate pubnubClient:self accessRightsAuditDidFailWithError:error];
            });
        }
        
        [self sendNotification:kPNClientAccessRightsAuditDidFailNotification withObject:error];
    }
                                shouldStartNext:YES];
}


#pragma mark - Service channel delegate methods

- (void)serviceChannel:(PNServiceChannel *)channel didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.didChangeAccessRights, [self humanReadableStateFrom:self.state]];
        }];
        
        if ([self shouldChannelNotifyAboutEvent:channel]) {
            
            // Check whether delegate is able to handle access rights change event or not
            SEL selector = @selector(pubnubClient:didChangeAccessRights:);
            if ([self.clientDelegate respondsToSelector:selector]) {
                
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.clientDelegate performSelector:selector withObject:self withObject:accessRightsCollection];
                });
                #pragma clang diagnostic pop
            }
            
            [self sendNotification:kPNClientAccessRightsChangeDidCompleteNotification withObject:accessRightsCollection];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)channel accessRightsChangeDidFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutAccessRightsChangeFailedWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            PNAccessRightOptions *rightsInformation = (PNAccessRightOptions *)error.associatedObject;
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleAccessRightsChange, [self humanReadableStateFrom:self.state]];
            }];
            
            [self changeAccessRightsForChannels:rightsInformation.channels accessRights:rightsInformation.rights
                                        clients:rightsInformation.clientsAuthorizationKeys
                                      forPeriod:rightsInformation.accessPeriodDuration
                         reschedulingMethodCall:YES withCompletionHandlingBlock:nil];
        }];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.didAuditAccessRights, [self humanReadableStateFrom:self.state]];
        }];
        
        if ([self shouldChannelNotifyAboutEvent:channel]) {
            
            // Check whether delegate is able to handle access rights change event or not
            SEL selector = @selector(pubnubClient:didAuditAccessRights:);
            if ([self.clientDelegate respondsToSelector:selector]) {
                
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.clientDelegate performSelector:selector withObject:self withObject:accessRightsCollection];
                });
                #pragma clang diagnostic pop
            }
            
            [self sendNotification:kPNClientAccessRightsAuditDidCompleteNotification withObject:accessRightsCollection];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)channel accessRightsAuditDidFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutAccessRightsAuditFailedWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            PNAccessRightOptions *rightsInformation = (PNAccessRightOptions *)error.associatedObject;
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleAccessRightsAudit, [self humanReadableStateFrom:self.state]];
            }];

            [self auditAccessRightsForChannels:rightsInformation.channels clients:rightsInformation.clientsAuthorizationKeys
                        reschedulingMethodCall:YES withCompletionHandlingBlock:nil];
        }];
    }
}

#pragma mark -


@end
