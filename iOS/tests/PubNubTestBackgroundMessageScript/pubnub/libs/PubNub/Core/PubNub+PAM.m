/**
 
 @author Sergey Mamontov
 @version 3.7.0
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
 Extension of -changeAccessRightsFor:accessRights:clients:storeInHistory:onPeriod:withCompletionHandlingBlock:
 and allow specify whether handler block should be replaced or not.
 
 @param channelObjects           List of objects (which conforms to \b PNChannelProtocol data feed object protocol) for
                                 which access rights should be changed
 @param accessRights             Bit field which allow to specify set of options. Bit options specified in 
                                 \c PNAccessRights
 @param clientsAuthorizationKeys \a NSArray of client identifiers for which access rights should be changed.
 @param accessPeriodDuration     Duration in minutes during which provided access rights should be applied on specified
                                 objects.
 @param isMethodCallRescheduled  In case if value set to \c YES it will mean that method call has been rescheduled and 
                                 probably there is no handler block which client should use for observation notification.
 @param handlerBlock             Handler block which is called by \b PubNub client when push notification enabling 
                                 process state changes. Block pass two arguments: \c rightsCollection -
                                 \b PNAccessRightsCollection instance which hold resulting list of access rights 
                                 represented in \b PNAccessRightsInformation instances; \c error - \b PNError instance 
                                 which hold information about why access rights change process failed. Always check
                                 \a error.code to find out what caused error (check PNErrorCodes header file and use 
                                 \a -localizedDescription / \a -localizedFailureReason and 
                                 \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)changeAccessRightsFor:(NSArray *)channelObjects accessRights:(PNAccessRights)accessRights
                      clients:(NSArray *)clientsAuthorizationKeys onPeriod:(NSInteger)accessPeriodDuration
       reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 Postpone access rights change user request so it will be executed in future.
 
 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another request
 which has been issued earlier didn't completed yet.
 
 @param channelObjects           List of objects (which conforms to \b PNChannelProtocol data feed object protocol) for
                                 which access rights should be changed
 @param accessRights             Bit field which allow to specify set of options. Bit options specified in 
                                 \c PNAccessRights
 @param clientsAuthorizationKeys \a NSArray of client identifiers for which access rights should be changed.
 @param accessPeriodDuration     Duration in minutes during which provided access rights should be applied on specified
                                 objects.
 @param isMethodCallRescheduled  In case if value set to \c YES it will mean that method call has been rescheduled and 
                                 probably there is no handler block which client should use for observation notification.
 @param handlerBlock             Handler block which is called by \b PubNub client when push notification enabling 
                                 process state changes. Block pass two arguments: \c rightsCollection -
                                 \b PNAccessRightsCollection instance which hold resulting list of access rights 
                                 represented in \b PNAccessRightsInformation instances; \c error - \b PNError instance 
                                 which hold information about why access rights change process failed. Always check
                                 \a error.code to find out what caused error (check PNErrorCodes header file and use 
                                 \a -localizedDescription / \a -localizedFailureReason and 
                                 \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)postponeChangeAccessRightsFor:(NSArray *)channelObjects accessRights:(PNAccessRights)accessRights
                              clients:(NSArray *)clientsAuthorizationKeys onPeriod:(NSInteger)accessPeriodDuration
               reschedulingMethodCall:(BOOL)isMethodCallRescheduled withCompletionHandlingBlock:(id)handlerBlock;

/**
 Final designated method which allow to audit access rights information depending on provided set of parameters.
 
 @param channelObjects
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
- (void)auditAccessRightsFor:(NSArray *)channelObjects clients:(NSArray *)clientsAuthorizationKeys
      reschedulingMethodCall:(BOOL)isMethodCallRescheduled
 withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;

/**
 Postpone access rights audit user request so it will be executed in future.
 
 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another request
 which has been issued earlier didn't completed yet.
 
 @param channelObjects
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
- (void)postponeAuditAccessRightsFor:(NSArray *)channelObjects clients:(NSArray *)clientsAuthorizationKeys
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
    
    [self changeApplicationAccessRightsTo:PNReadAccessRight onPeriod:accessPeriodDuration
               andCompletionHandlingBlock:handlerBlock];
}

+ (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantWriteAccessRightForApplicationAtPeriod:accessPeriodDuration andCompletionHandlingBlock:nil];
}

+ (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                         andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeApplicationAccessRightsTo:PNWriteAccessRight onPeriod:accessPeriodDuration
               andCompletionHandlingBlock:handlerBlock];
}

+ (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantAllAccessRightsForApplicationAtPeriod:accessPeriodDuration andCompletionHandlingBlock:nil];
}

+ (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                        andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeApplicationAccessRightsTo:PNAllAccessRights onPeriod:accessPeriodDuration
               andCompletionHandlingBlock:handlerBlock];
}

+ (void)revokeAccessRightsForApplication {
    
    [self revokeAccessRightsForApplicationWithCompletionHandlingBlock:nil];
}

+ (void)revokeAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeApplicationAccessRightsTo:PNNoAccessRights onPeriod:-1 andCompletionHandlingBlock:handlerBlock];
}

+ (void)changeApplicationAccessRightsTo:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration {
    
    [self changeApplicationAccessRightsTo:accessRights onPeriod:accessPeriodDuration
               andCompletionHandlingBlock:nil];
}

+ (void)changeApplicationAccessRightsTo:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration
             andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsFor:nil accessRights:accessRights clients:nil onPeriod:accessPeriodDuration
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

    [self changeAccessRightsFor:channels to:PNReadAccessRight onPeriod:accessPeriodDuration
    withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys {
    
    [self grantReadAccessRightForChannel:channel forPeriod:accessPeriodDuration clients:clientsAuthorizationKeys
             withCompletionHandlingBlock:nil];
    
}
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsForClients:clientsAuthorizationKeys object:channel to:PNReadAccessRight
                              onPeriod:accessPeriodDuration withCompletionHandlingBlock:handlerBlock];
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
    
    [self changeAccessRightsFor:channels to:PNWriteAccessRight onPeriod:accessPeriodDuration
    withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                clients:(NSArray *)clientsAuthorizationKeys {
    
    [self grantWriteAccessRightForChannel:channel forPeriod:accessPeriodDuration clients:clientsAuthorizationKeys
              withCompletionHandlingBlock:nil];
}

+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                clients:(NSArray *)clientsAuthorizationKeys
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsForClients:clientsAuthorizationKeys object:channel to:PNWriteAccessRight
                              onPeriod:accessPeriodDuration withCompletionHandlingBlock:handlerBlock];
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
    
    [self changeAccessRightsFor:channels to:PNAllAccessRights onPeriod:accessPeriodDuration
    withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys {
    
    [self grantAllAccessRightsForChannel:channel forPeriod:accessPeriodDuration clients:clientsAuthorizationKeys
             withCompletionHandlingBlock:nil];
}

+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsForClients:clientsAuthorizationKeys object:channel to:PNAllAccessRights
                              onPeriod:accessPeriodDuration withCompletionHandlingBlock:handlerBlock];
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
    
    [self changeAccessRightsFor:channels to:PNNoAccessRights onPeriod:-1 withCompletionHandlingBlock:handlerBlock];
}

+ (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys {
    
    [self revokeAccessRightsForChannel:channel clients:clientsAuthorizationKeys withCompletionHandlingBlock:nil];
}

+ (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsForClients:clientsAuthorizationKeys object:channel to:PNNoAccessRights onPeriod:-1
           withCompletionHandlingBlock:handlerBlock];
}

+ (void)changeAccessRightsFor:(NSArray *)channelObjects to:(PNAccessRights)accessRights
                     onPeriod:(NSInteger)accessPeriodDuration {
    
    [self changeAccessRightsFor:channelObjects to:accessRights onPeriod:accessPeriodDuration
    withCompletionHandlingBlock:nil];
}

+ (void)changeAccessRightsFor:(NSArray *)channelObjects to:(PNAccessRights)accessRights
                     onPeriod:(NSInteger)accessPeriodDuration
  withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsFor:channelObjects accessRights:accessRights clients:nil onPeriod:accessPeriodDuration
    withCompletionHandlingBlock:handlerBlock];
}

+ (void)changeAccessRightsForClients:(NSArray *)clientsAuthorizationKeys object:(id <PNChannelProtocol>)object
                                  to:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration {
    
    [self changeAccessRightsForClients:clientsAuthorizationKeys object:object to:accessRights
                              onPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

+ (void)changeAccessRightsForClients:(NSArray *)clientsAuthorizationKeys object:(id <PNChannelProtocol>)object
                                  to:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsFor:(object ? @[object] : nil) accessRights:accessRights clients:clientsAuthorizationKeys
                       onPeriod:accessPeriodDuration withCompletionHandlingBlock:handlerBlock];
}

+ (void)changeAccessRightsFor:(NSArray *)channelObjects accessRights:(PNAccessRights)accessRights
                      clients:(NSArray *)clientsAuthorizationKeys onPeriod:(NSInteger)accessPeriodDuration
  withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [[self sharedInstance] changeAccessRightsFor:channelObjects accessRights:accessRights
                                         clients:clientsAuthorizationKeys onPeriod:accessPeriodDuration
                          reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

+ (void)auditAccessRightsForApplication {
    
    [self auditAccessRightsForApplicationWithCompletionHandlingBlock:nil];
}

+ (void)auditAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [self auditAccessRightsFor:nil withCompletionHandlingBlock:handlerBlock];
}

+ (void)auditAccessRightsForChannel:(PNChannel *)channel {
    
    [self auditAccessRightsForChannel:nil withCompletionHandlingBlock:nil];
}

+ (void)auditAccessRightsForChannel:(PNChannel *)channel
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
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
    
    [self auditAccessRightsFor:channels withCompletionHandlingBlock:handlerBlock];
}

+ (void)auditAccessRightsFor:(NSArray *)channelObjects {
    
    [self auditAccessRightsFor:channelObjects withCompletionHandlingBlock:nil];
}

+ (void) auditAccessRightsFor:(NSArray *)channelObjects
  withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [[self sharedInstance] auditAccessRightsFor:channelObjects clients:nil
                         reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

+ (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys {
    
    [self auditAccessRightsForChannel:channel clients:clientsAuthorizationKeys withCompletionHandlingBlock:nil];
}

+ (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [self auditAccessRightsFor:channel clients:clientsAuthorizationKeys withCompletionHandlingBlock:handlerBlock];
}

+ (void)auditAccessRightsFor:(id <PNChannelProtocol>)object clients:(NSArray *)clientsAuthorizationKeys {
    
    [self auditAccessRightsFor:object clients:clientsAuthorizationKeys withCompletionHandlingBlock:nil];
}

+ (void) auditAccessRightsFor:(id <PNChannelProtocol>)object clients:(NSArray *)clientsAuthorizationKeys
  withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock  {
    
    [[self sharedInstance] auditAccessRightsFor:(object ? @[object] : nil) clients:clientsAuthorizationKeys
                         reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}


#pragma mark - Instance methods

- (void)grantReadAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantReadAccessRightForApplicationAtPeriod:accessPeriodDuration andCompletionHandlingBlock:nil];
}

- (void)grantReadAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                        andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeApplicationAccessRightsTo:PNReadAccessRight onPeriod:accessPeriodDuration
               andCompletionHandlingBlock:handlerBlock];
}

- (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantWriteAccessRightForApplicationAtPeriod:accessPeriodDuration andCompletionHandlingBlock:nil];
}

- (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                         andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeApplicationAccessRightsTo:PNWriteAccessRight onPeriod:accessPeriodDuration
               andCompletionHandlingBlock:handlerBlock];
}

- (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration {
    
    [self grantAllAccessRightsForApplicationAtPeriod:accessPeriodDuration andCompletionHandlingBlock:nil];
}

- (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                        andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeApplicationAccessRightsTo:PNAllAccessRights onPeriod:accessPeriodDuration
               andCompletionHandlingBlock:handlerBlock];
}

- (void)revokeAccessRightsForApplication {
    
    [self revokeAccessRightsForApplicationWithCompletionHandlingBlock:nil];
}

- (void)revokeAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeApplicationAccessRightsTo:PNNoAccessRights onPeriod:0 andCompletionHandlingBlock:handlerBlock];
}

- (void)changeApplicationAccessRightsTo:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration {
    
    [self changeApplicationAccessRightsTo:accessRights onPeriod:accessPeriodDuration andCompletionHandlingBlock:nil];
}

- (void)changeApplicationAccessRightsTo:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration
             andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsFor:nil accessRights:accessRights clients:nil onPeriod:0 reschedulingMethodCall:NO
    withCompletionHandlingBlock:handlerBlock];
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

    [self changeAccessRightsFor:channels to:PNReadAccessRight onPeriod:accessPeriodDuration
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
    
    [self changeAccessRightsForClients:clientsAuthorizationKeys object:channel to:PNReadAccessRight
                              onPeriod:accessPeriodDuration withCompletionHandlingBlock:handlerBlock];
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
    
    [self changeAccessRightsFor:channels to:PNWriteAccessRight onPeriod:accessPeriodDuration
    withCompletionHandlingBlock:handlerBlock];
}

- (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                clients:(NSArray *)clientsAuthorizationKeys {
    
    [self grantWriteAccessRightForChannel:channel forPeriod:accessPeriodDuration clients:clientsAuthorizationKeys
              withCompletionHandlingBlock:nil];
}

- (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                clients:(NSArray *)clientsAuthorizationKeys
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsForClients:clientsAuthorizationKeys object:channel to:PNWriteAccessRight
                              onPeriod:accessPeriodDuration withCompletionHandlingBlock:handlerBlock];
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
    
    [self changeAccessRightsFor:channels to:PNAllAccessRights onPeriod:accessPeriodDuration
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
    
    [self changeAccessRightsForClients:clientsAuthorizationKeys object:channel to:PNAllAccessRights
                              onPeriod:accessPeriodDuration withCompletionHandlingBlock:handlerBlock];
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
    
    [self changeAccessRightsFor:channels to:PNNoAccessRights onPeriod:-1 withCompletionHandlingBlock:handlerBlock];
}

- (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys {
    
    [self revokeAccessRightsForChannel:channel clients:clientsAuthorizationKeys withCompletionHandlingBlock:nil];
}

- (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsForClients:clientsAuthorizationKeys object:channel to:PNNoAccessRights onPeriod:-1
           withCompletionHandlingBlock:handlerBlock];
}

- (void)changeAccessRightsFor:(NSArray *)channelObjects to:(PNAccessRights)accessRights
                            onPeriod:(NSInteger)accessPeriodDuration {
    
    [self changeAccessRightsFor:channelObjects to:accessRights onPeriod:accessPeriodDuration
    withCompletionHandlingBlock:nil];
}

- (void)changeAccessRightsFor:(NSArray *)channelObjects to:(PNAccessRights)accessRights
                     onPeriod:(NSInteger)accessPeriodDuration
  withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsFor:channelObjects accessRights:accessRights clients:nil onPeriod:accessPeriodDuration
         reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

- (void)changeAccessRightsForClients:(NSArray *)clientsAuthorizationKeys object:(id <PNChannelProtocol>)object
                                  to:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration {
    
    [self changeAccessRightsForClients:clientsAuthorizationKeys object:object to:accessRights
                             onPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

- (void)changeAccessRightsForClients:(NSArray *)clientsAuthorizationKeys object:(id <PNChannelProtocol>)object
                                  to:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self changeAccessRightsFor:(object ? @[object] : nil) accessRights:accessRights clients:clientsAuthorizationKeys
                       onPeriod:accessPeriodDuration reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

- (void)changeAccessRightsFor:(NSArray *)channelObjects accessRights:(PNAccessRights)accessRights
                      clients:(NSArray *)clientsAuthorizationKeys onPeriod:(NSInteger)accessPeriodDuration
       reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.accessRightsChangeAttempt, (channelObjects ? channelObjects : [NSNull null]),
                     (clientsAuthorizationKeys ? clientsAuthorizationKeys : [NSNull null]), @(accessRights), @(accessPeriodDuration),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        // Initialize arrays in case if used specified \a 'nil' for \a 'channels' and/or \a 'clientsAuthorizationKeys'
        NSArray *objects = (channelObjects ? channelObjects : @[]);
        NSArray *authorizationKeys = (clientsAuthorizationKeys ? clientsAuthorizationKeys : @[]);
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsAccessRightsChangeObserver];
            }
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0 && [self.configuration.secretKey length]) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.changeAccessRights, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsAccessRightsChangeObserverWithBlock:handlerBlock];
                }
                
                [self.serviceChannel changeAccessRightsFor:objects accessRights:accessRights
                                         authorizationKeys:authorizationKeys onPeriod:accessPeriodDuration];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.accessRightsChangeImpossible, [self humanReadableStateFrom:self.state]];
                }];
                
                PNAccessRightOptions *options = [PNAccessRightOptions accessRightOptionsForApplication:self.configuration.subscriptionKey
                                                                                            withRights:accessRights
                                                                                              channels:objects
                                                                                               clients:authorizationKeys
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
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponeAccessRightsChange, [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeChangeAccessRightsFor:objects accessRights:accessRights
                                               clients:authorizationKeys onPeriod:accessPeriodDuration
                                reschedulingMethodCall:isMethodCallRescheduled withCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeChangeAccessRightsFor:(NSArray *)channelObjects accessRights:(PNAccessRights)accessRights
                              clients:(NSArray *)clientsAuthorizationKeys onPeriod:(NSInteger)accessPeriodDuration
               reschedulingMethodCall:(BOOL)isMethodCallRescheduled withCompletionHandlingBlock:(id)handlerBlock {
    
    SEL selector = @selector(changeAccessRightsFor:accessRights:clients:onPeriod:reschedulingMethodCall:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:selector forObject:self
            withParameters:@[channelObjects, [NSNumber numberWithUnsignedLong:accessRights], clientsAuthorizationKeys,
                             [NSNumber numberWithInteger:accessPeriodDuration],
                             @(isMethodCallRescheduled), [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}

- (void)auditAccessRightsForApplication {
    
    [self auditAccessRightsForApplicationWithCompletionHandlingBlock:nil];
}

- (void)auditAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [self auditAccessRightsFor:nil withCompletionHandlingBlock:handlerBlock];
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

    [self auditAccessRightsFor:channels withCompletionHandlingBlock:handlerBlock];
}

- (void)auditAccessRightsFor:(NSArray *)channelObjects {
    
    [self auditAccessRightsFor:channelObjects withCompletionHandlingBlock:nil];
}

- (void) auditAccessRightsFor:(NSArray *)channelObjects
  withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [self auditAccessRightsFor:channelObjects clients:nil reschedulingMethodCall:NO
   withCompletionHandlingBlock:handlerBlock];
}

- (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys {
    
    [self auditAccessRightsForChannel:channel clients:clientsAuthorizationKeys withCompletionHandlingBlock:nil];
}

- (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [self auditAccessRightsFor:channel clients:clientsAuthorizationKeys withCompletionHandlingBlock:handlerBlock];
}

- (void)auditAccessRightsFor:(id <PNChannelProtocol>)object clients:(NSArray *)clientsAuthorizationKeys {
    
    [self auditAccessRightsFor:object clients:clientsAuthorizationKeys withCompletionHandlingBlock:nil];
}

- (void)auditAccessRightsFor:(id <PNChannelProtocol>)object clients:(NSArray *)clientsAuthorizationKeys
 withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [self auditAccessRightsFor:(object ? @[object] : nil) clients:clientsAuthorizationKeys reschedulingMethodCall:NO
   withCompletionHandlingBlock:handlerBlock];
}

- (void)auditAccessRightsFor:(NSArray *)channelObjects clients:(NSArray *)clientsAuthorizationKeys
      reschedulingMethodCall:(BOOL)isMethodCallRescheduled
 withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.accessRightsAuditAttempt, (channelObjects ? channelObjects : [NSNull null]),
                     (clientsAuthorizationKeys ? clientsAuthorizationKeys : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        // Initialize arrays in case if used specified \a 'nil' for \a 'channels' and/or \a 'clientsAuthorizationKeys'
        NSArray *objects = (channelObjects ? channelObjects : @[]);
        NSArray *authorizationKeys = (clientsAuthorizationKeys ? clientsAuthorizationKeys : @[]);
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsAccessRightsAuditObserver];
            }
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0 && [self.configuration.secretKey length]) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.auditAccessRights, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsAccessRightsAuditObserverWithBlock:handlerBlock];
                }
                
                [self.serviceChannel auditAccessRightsFor:objects clients:authorizationKeys];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.accessRightsAuditImpossible, [self humanReadableStateFrom:self.state]];
                }];
                
                PNAccessRightOptions *options = [PNAccessRightOptions accessRightOptionsForApplication:self.configuration.subscriptionKey
                                                                                            withRights:PNUnknownAccessRights
                                                                                              channels:objects
                                                                                               clients:authorizationKeys
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
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponeAccessRightsAudit, [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeAuditAccessRightsFor:objects clients:authorizationKeys
                               reschedulingMethodCall:isMethodCallRescheduled withCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeAuditAccessRightsFor:(NSArray *)channelObjects clients:(NSArray *)clientsAuthorizationKeys
              reschedulingMethodCall:(BOOL)isMethodCallRescheduled withCompletionHandlingBlock:(id)handlerBlock {
    
    SEL selector = @selector(auditAccessRightsFor:clients:reschedulingMethodCall:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:selector forObject:self
            withParameters:@[channelObjects, clientsAuthorizationKeys, @(isMethodCallRescheduled),
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

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.didChangeAccessRights, [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

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
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }
                                    shouldStartNext:YES];
    }];
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
            
            [self changeAccessRightsFor:rightsInformation.channels accessRights:rightsInformation.rights
                                clients:rightsInformation.clientsAuthorizationKeys
                               onPeriod:rightsInformation.accessPeriodDuration reschedulingMethodCall:YES
            withCompletionHandlingBlock:nil];
        }];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.didAuditAccessRights, [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

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
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }
                                    shouldStartNext:YES];
    }];
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

            [self auditAccessRightsFor:rightsInformation.channels clients:rightsInformation.clientsAuthorizationKeys
                reschedulingMethodCall:YES withCompletionHandlingBlock:nil];
        }];
    }
}

#pragma mark -


@end
