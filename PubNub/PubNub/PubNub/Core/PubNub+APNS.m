/**
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-14 PubNub Inc.
 
 */

#import "PubNub+APNS.h"
#import "PNPushNotificationsEnabledChannelsRequest.h"
#import "PNPushNotificationsStateChangeRequest.h"
#import "PNPushNotificationsRemoveRequest.h"
#import "NSObject+PNAdditions.h"
#import "PNServiceChannel.h"
#import "PubNub+Protected.h"
#import "PNNotifications.h"
#import "PNHelper.h"

#import "PNLogger+Protected.h"
#import "PNLoggerSymbols.h"


#pragma mark - Category private interface declaration

@interface PubNub (APNSPrivate)


#pragma mark - Instance methods

/**
 @brief Extension of -enablePushNotificationsOnChannels:withDevicePushToken:andCompletionHandlingBlock:
        and allow specify whether handler block should be replaced or not.

 @param channels      Array of \b PNChannel instances for which push notification should be enabled.
 @param pushToken     Device push token which is used to identify push notification recipient.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which is called when push notification enabling state changed. The
                      block takes two arguments: \c channels - list of channels for which push
                      notification enabling state changed; \c error - error because of which push
                      notification enabling failed. Always check \a error.code to find out what
                      caused error (check PNErrorCodes header file and use \a -localizedDescription /
                      \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human
                      readable description for error).
 */
- (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                 rescheduledCallbackToken:(NSString *)callbackToken
               andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock;

/**
 @brief Postpone push notification enabling user request so it will be executed in future.

 @note  Postpone can be because of few cases: \b PubNub client is in connecting or initial
        connection state; another request which has been issued earlier didn't completed yet.

 @param channels      List of \b PNChannel instances on which client should enable push
                      notifications.
 @param pushToken     \a NSData instance which represent device push token for which list of push
                      notification enabled channels should be changed.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  Handler block which is called by \b PubNub client when push notification
                      enabling process state changes. Block pass two arguments: \c channels - list
                      of \b PNChannel instances for which push notification enabling process changes
                      state; \c error - \b PNError instance which hold information about why push
                      notification enabling process failed. Always check \a error.code to find out
                      what caused error (check PNErrorCodes header file and use
                      \a -localizedDescription / \a -localizedFailureReason and
                      \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)postponeEnablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                         rescheduledCallbackToken:(NSString *)callbackToken
                       andCompletionHandlingBlock:(id)handlerBlock;

/**
 @brief Extension of -disablePushNotificationsOnChannels:withDevicePushToken:andCompletionHandlingBlock:
        and allow specify whether handler block should be replaced or not.

 @param channels      Array of \b PNChannel instances for which push notification should be
                      disabled.
 @param pushToken     Device push token which previously has been used to register for messages
                      observation via Apple Push Notifications.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which is called when push notification disabling state changed. The
                      block takes two arguments: \c channels - list of channels for which push
                      notification disabling state changed; \c error - error because of which push
                      notification disabling failed. Always check \a error.code to find out what
                      caused error (check PNErrorCodes header file and use \a -localizedDescription /
                      \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human
                      readable description for error).
 */
- (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                  rescheduledCallbackToken:(NSString *)callbackToken
                andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock;

/**
 @brief Postpone push notification disabling user request so it will be executed in future.

 @note  Postpone can be because of few cases: \b PubNub client is in connecting or initial
        connection state; another request which has been issued earlier didn't completed yet.

 @param channels      List of \b PNChannel instances on which client should disable push
                      notifications.
 @param pushToken     \a NSData instance which represent device push token for which list of push
                      notification enabled channels should be changed.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  Handler block which is called by \b PubNub client when push notification
                      disabling process state changes. Block pass two arguments: \c channels - list
                      of \b PNChannel instances for which push notification disabling process
                      changes state; \c error - \b PNError instance which hold information about why
                      push notification disabling process failed. Always check \a error.code to find
                      out what caused error (check PNErrorCodes header file and use
                      \a -localizedDescription / \a -localizedFailureReason and
                      \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)postponeDisablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                          rescheduledCallbackToken:(NSString *)callbackToken
                        andCompletionHandlingBlock:(id)handlerBlock;

/**
 @brief Extension of -disablePushNotificationsOnChannels:withDevicePushToken:andCompletionHandlingBlock:
        and allow specify whether handler block should be replaced or not.

 @param pushToken     Device push token which previously has been used to register for messages
                      observation via Apple Push Notifications.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which is called when push notification disabling state changed. The
                      block takes one argument: \c error - error because of which push notification
                      disabling failed. Always check \a error.code to find out what caused error
                      (check PNErrorCodes header file and use \a -localizedDescription /
                      \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human
                      readable description for error).
 */
- (void)removeAllPushNotificationsForDevicePushToken:(NSData *)pushToken rescheduledCallbackToken:(NSString *)callbackToken
                         withCompletionHandlingBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock;

/**
 @brief Postpone push notification remove user request so it will be executed in future.

 @note  Postpone can be because of few cases: \b PubNub client is in connecting or initial
        connection state; another request which has been issued earlier didn't completed yet.

 @param pushToken     \a NSData instance which represent device push token for which list of push
                      notification enabled channels should be changed.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  Handler block which is called by \b PubNub client when push notification
                      removal process state changes. Block pass one argument: \c error - \b PNError
                      instance which hold information about why push notification removal process
                      failed. Always check \a error.code to find out what caused error (check
                      PNErrorCodes header file and use \a -localizedDescription /
                      \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human
                      readable description for error).
 */
- (void)postponeRemoveAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                                    rescheduledCallbackToken:(NSString *)callbackToken
                                 withCompletionHandlingBlock:(id)handlerBlock;

/**
 @brief Extension of -disablePushNotificationsOnChannels:withDevicePushToken:andCompletionHandlingBlock:
        and allow specify whether handler block should be replaced or not.

 @param pushToken     Device push token which previously has been used to register for messages
                      observation via Apple Push Notifications.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which is called when push notification disabling state changed. The
                      block takes two arguments: \c channels - return list of channels for which
                      push notification has been enabled with specified device push token;
                      \c error - error because of push notification enabled channels fetch failed.
                      Always check \a error.code to find out what caused error (check PNErrorCodes
                      header file and use \a -localizedDescription / \a -localizedFailureReason and
                      \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)requestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                        rescheduledCallbackToken:(NSString *)callbackToken
                                     withCompletionHandlingBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock;

/**
 @brief Postpone push notification enabled channels audit user request so it will be executed in
        future.
 
 @note  Postpone can be because of few cases: \b PubNub client is in connecting or initial
        connection state; another request which has been issued earlier didn't completed yet.
 
 @param pushToken     \a NSData instance which represent device push token for which list of push
                      notification enabled channels should be retrieved.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  Handler block which is called by \b PubNub client when push notification
                      enabling channels audit process state changes. Block pass two arguments:
                      \c channels - list of \b PNChannel instances for which push notification has
                      been enabled; \c error - \b PNError instance which hold information about why
                      push notification enabled channels audit process failed. Always check
                      \a error.code to find out what caused error (check PNErrorCodes header file
                      and use \a -localizedDescription / \a -localizedFailureReason and
                      \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)postponeRequestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                                rescheduledCallbackToken:(NSString *)callbackToken
                                             withCompletionHandlingBlock:(id)handlerBlock;


#pragma mark - Misc methods

/**
 @brief This method will notify delegate about that push notification enabling failed with error.
 
 @param error         \b PNError instance which hold information about what exactly went wrong
                      during push notification enabling process.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 */
- (void)notifyDelegateAboutPushNotificationsEnableFailedWithError:(PNError *)error
                                                 andCallbackToken:(NSString *)callbackToken;

/**
 @brief This method will notify delegate about that push notification disabling failed with error.
 
 @param error         \b PNError instance which hold information about what exactly went wrong
                      during push notification disabling process.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 */
- (void)notifyDelegateAboutPushNotificationsDisableFailedWithError:(PNError *)error
                                                  andCallbackToken:(NSString *)callbackToken;

/**
 @brief This method will notify delegate about that push notification removal from all channels
        failed because of error.
 
 @param error         \b PNError instance which hold information about what exactly went wrong
                      during push notification removal process.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 */
- (void)notifyDelegateAboutPushNotificationsRemoveFailedWithError:(PNError *)error
                                                 andCallbackToken:(NSString *)callbackToken;

/**
 @brief This method will notify delegate about that push notification enabled channels list
        retrieval request failed with error.
 
 @param error         \b PNError instance which hold information about what exactly went wrong
                      during push notification audit process.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 */
- (void)notifyDelegateAboutPushNotificationsEnabledChannelsFailedWithError:(PNError *)error
                                                          andCallbackToken:(NSString *)callbackToken;

#pragma mark -


@end


#pragma mark - Category methods implementation

@implementation PubNub (APNS)


#pragma mark - Class (singleton) methods

+ (void)enablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken {
    
    [self enablePushNotificationsOnChannel:channel withDevicePushToken:pushToken
                andCompletionHandlingBlock:nil];
}

+ (void)enablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken
              andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {
    
    [self enablePushNotificationsOnChannels:(channel ? @[channel] : nil) withDevicePushToken:pushToken
                 andCompletionHandlingBlock:handlerBlock];
}

+ (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken {
    
    [self enablePushNotificationsOnChannels:channels withDevicePushToken:pushToken
                 andCompletionHandlingBlock:nil];
}

+ (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
               andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {
    
    [[self sharedInstance] enablePushNotificationsOnChannels:channels withDevicePushToken:pushToken
                                  andCompletionHandlingBlock:handlerBlock];
}

+ (void)disablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken {
    
    [self disablePushNotificationsOnChannel:channel withDevicePushToken:pushToken
                 andCompletionHandlingBlock:nil];
}

+ (void)disablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken
               andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {
    
    [self disablePushNotificationsOnChannels:(channel ? @[channel] : nil) withDevicePushToken:pushToken
                  andCompletionHandlingBlock:handlerBlock];
}

+ (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken {
    
    [self disablePushNotificationsOnChannels:channels withDevicePushToken:pushToken
                  andCompletionHandlingBlock:nil];
}

+ (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {
    
    [[self sharedInstance] disablePushNotificationsOnChannels:channels withDevicePushToken:pushToken
                                   andCompletionHandlingBlock:handlerBlock];
}

+ (void)removeAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                         withCompletionHandlingBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock {
    
    [[self sharedInstance] removeAllPushNotificationsForDevicePushToken:pushToken
                                            withCompletionHandlingBlock:handlerBlock];
}

+ (void)requestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                     withCompletionHandlingBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock {
    
    [[self sharedInstance] requestPushNotificationEnabledChannelsForDevicePushToken:pushToken
                                                        withCompletionHandlingBlock:handlerBlock];
}


#pragma mark - Instance methods

- (void)enablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken {
    
    [self enablePushNotificationsOnChannel:channel withDevicePushToken:pushToken
                andCompletionHandlingBlock:nil];
}

- (void)enablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken
              andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {
    
    [self enablePushNotificationsOnChannels:(channel ? @[channel] : nil) withDevicePushToken:pushToken
                 andCompletionHandlingBlock:handlerBlock];
}

- (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken {
    
    [self enablePushNotificationsOnChannels:channels withDevicePushToken:pushToken
                 andCompletionHandlingBlock:nil];
}

- (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
               andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {

    [self enablePushNotificationsOnChannels:channels withDevicePushToken:pushToken
                   rescheduledCallbackToken:nil andCompletionHandlingBlock:handlerBlock];
}

- (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                 rescheduledCallbackToken:(NSString *)callbackToken
               andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {

    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.pushNotificationsEnableAttempt,
                     (channels ? channels : [NSNull null]), (pushToken ? pushToken : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self   performAsyncLockingBlock:^{

            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0 && pushToken != nil) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.enablingPushNotifications,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNPushNotificationsStateChangeRequest *request;
                request = [PNPushNotificationsStateChangeRequest requestWithDevicePushToken:pushToken
                                                                                    toState:PNPushNotificationsState.enable
                                                                                forChannels:channels];
                if (handlerBlock && !callbackToken) {

                    [self.observationCenter addClientAsPushNotificationsEnableObserverWithToken:request.shortIdentifier
                                                                                       andBlock:handlerBlock];
                }
                else if (callbackToken) {

                    [self.observationCenter changeClientCallbackToken:callbackToken
                                                                   to:request.shortIdentifier];
                }

                [self sendRequest:request shouldObserveProcessing:YES];
            }
                // Looks like client can't send request because of some reasons
            else {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.pushNotificationEnablingImpossible,
                            [self humanReadableStateFrom:self.state]];
                }];

                if (pushToken == nil) {

                    statusCode = kPNDevicePushTokenIsEmptyError;
                }
                PNError *stateChangeError = [PNError errorWithCode:statusCode];
                stateChangeError.associatedObject = channels;

                [self notifyDelegateAboutPushNotificationsEnableFailedWithError:stateChangeError
                                                               andCallbackToken:callbackToken];


                if (handlerBlock && !callbackToken) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        handlerBlock(channels, stateChangeError);
                    });
                }
            }
        }        postponedExecutionBlock:^{

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.postponePushNotificationEnabling,
                        [self humanReadableStateFrom:self.state]];
            }];

            [self postponeEnablePushNotificationsOnChannels:channels withDevicePushToken:pushToken
                                   rescheduledCallbackToken:callbackToken
                                 andCompletionHandlingBlock:handlerBlock];
        } burstExecutionLockingOperation:NO];
    }];
}

- (void)postponeEnablePushNotificationsOnChannels:(NSArray *)channels
                              withDevicePushToken:(NSData *)pushToken
                         rescheduledCallbackToken:(NSString *)callbackToken
                       andCompletionHandlingBlock:(id)handlerBlock {
    
    SEL selector = @selector(enablePushNotificationsOnChannels:withDevicePushToken:rescheduledCallbackToken:andCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:selector forObject:self
            withParameters:@[channels, [PNHelper nilifyIfNotSet:pushToken],
                             [PNHelper nilifyIfNotSet:callbackToken],
                             [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:(callbackToken != nil) burstExecutionLock:NO];
}

- (void)disablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken {
    
    [self disablePushNotificationsOnChannel:channel withDevicePushToken:pushToken
                 andCompletionHandlingBlock:nil];
}

- (void)disablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken
               andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {
    
    [self disablePushNotificationsOnChannels:(channel ? @[channel] : nil) withDevicePushToken:pushToken
                  andCompletionHandlingBlock:handlerBlock];
}

- (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken {
    
    [self disablePushNotificationsOnChannels:channels withDevicePushToken:pushToken
                  andCompletionHandlingBlock:nil];
}

- (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {

    [self disablePushNotificationsOnChannels:channels withDevicePushToken:pushToken
                    rescheduledCallbackToken:nil andCompletionHandlingBlock:handlerBlock];
}

- (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                  rescheduledCallbackToken:(NSString *)callbackToken
                andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {

    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.pushNotificationsDisableAttempt,
                     (channels ? channels : [NSNull null]), (pushToken ? pushToken : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self   performAsyncLockingBlock:^{

            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0 && pushToken != nil) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.disablingPushNotifications,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNPushNotificationsStateChangeRequest *request;
                request = [PNPushNotificationsStateChangeRequest requestWithDevicePushToken:pushToken
                                                                                    toState:PNPushNotificationsState.disable
                                                                                forChannels:channels];
                if (handlerBlock && !callbackToken) {

                    [self.observationCenter addClientAsPushNotificationsDisableObserverWithToken:request.shortIdentifier
                                                                                        andBlock:handlerBlock];
                }
                else if (callbackToken) {

                    [self.observationCenter changeClientCallbackToken:callbackToken
                                                                   to:request.shortIdentifier];
                }

                [self sendRequest:request shouldObserveProcessing:YES];
            }
                // Looks like client can't send request because of some reasons
            else {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.pushNotificationDisablingImpossible,
                            [self humanReadableStateFrom:self.state]];
                }];

                if (pushToken == nil) {

                    statusCode = kPNDevicePushTokenIsEmptyError;
                }

                PNError *stateChangeError = [PNError errorWithCode:statusCode];
                stateChangeError.associatedObject = channels;

                [self notifyDelegateAboutPushNotificationsDisableFailedWithError:stateChangeError
                                                                andCallbackToken:callbackToken];

                if (handlerBlock && !callbackToken) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        handlerBlock(channels, stateChangeError);
                    });
                }
            }
        }        postponedExecutionBlock:^{

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.postponePushNotificationDisabling,
                        [self humanReadableStateFrom:self.state]];
            }];

            [self postponeDisablePushNotificationsOnChannels:channels
                                         withDevicePushToken:pushToken
                                    rescheduledCallbackToken:callbackToken
                                  andCompletionHandlingBlock:handlerBlock];
        } burstExecutionLockingOperation:NO];
    }];
}

- (void)postponeDisablePushNotificationsOnChannels:(NSArray *)channels
                               withDevicePushToken:(NSData *)pushToken
                          rescheduledCallbackToken:(NSString *)callbackToken
                        andCompletionHandlingBlock:(id)handlerBlock {
    
    SEL selector = @selector(disablePushNotificationsOnChannels:withDevicePushToken:rescheduledCallbackToken:andCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:selector forObject:self
            withParameters:@[channels, [PNHelper nilifyIfNotSet:pushToken],
                             [PNHelper nilifyIfNotSet:callbackToken],
                             [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:(callbackToken != nil) burstExecutionLock:NO];
}

- (void)removeAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                         withCompletionHandlingBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock {

    [self removeAllPushNotificationsForDevicePushToken:pushToken rescheduledCallbackToken:nil
                           withCompletionHandlingBlock:handlerBlock];
}

- (void)removeAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                            rescheduledCallbackToken:(NSString *)callbackToken
                         withCompletionHandlingBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock {

    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.pushNotificationsRemovalAttempt,
                     (pushToken ? pushToken : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self   performAsyncLockingBlock:^{

            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0 && pushToken != nil) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.removePushNotifications, [self humanReadableStateFrom:self.state]];
                }];

                PNPushNotificationsRemoveRequest *request = [PNPushNotificationsRemoveRequest requestWithDevicePushToken:pushToken];
                if (handlerBlock && !callbackToken) {

                    [self.observationCenter addClientAsPushNotificationsRemoveObserverWithToken:request.shortIdentifier
                                                                                       andBlock:handlerBlock];
                }
                else if (callbackToken) {

                    [self.observationCenter changeClientCallbackToken:callbackToken
                                                                   to:request.shortIdentifier];
                }

                [self sendRequest:request shouldObserveProcessing:YES];
            }
                // Looks like client can't send request because of some reasons
            else {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.pushNotificationRemovalImpossible,
                            [self humanReadableStateFrom:self.state]];
                }];

                if (pushToken == nil) {

                    statusCode = kPNDevicePushTokenIsEmptyError;
                }

                PNError *removalError = [PNError errorWithCode:statusCode];
                [self notifyDelegateAboutPushNotificationsRemoveFailedWithError:removalError
                                                               andCallbackToken:callbackToken];

                if (handlerBlock && !callbackToken) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        handlerBlock(removalError);
                    });
                }
            }
        }        postponedExecutionBlock:^{

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.postponePushNotificationRemoval,
                        [self humanReadableStateFrom:self.state]];
            }];

            [self postponeRemoveAllPushNotificationsForDevicePushToken:pushToken
                                              rescheduledCallbackToken:callbackToken
                                           withCompletionHandlingBlock:handlerBlock];
        } burstExecutionLockingOperation:NO];
    }];
}

- (void)postponeRemoveAllPushNotificationsForDevicePushToken:(NSData *)pushToken rescheduledCallbackToken:(NSString *)callbackToken
                                 withCompletionHandlingBlock:(id)handlerBlock {
    
    SEL selector = @selector(removeAllPushNotificationsForDevicePushToken:rescheduledCallbackToken:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:selector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:pushToken], [PNHelper nilifyIfNotSet:callbackToken],
                             [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:(callbackToken != nil) burstExecutionLock:NO];
}

- (void)requestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                     withCompletionHandlingBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock {

    [self requestPushNotificationEnabledChannelsForDevicePushToken:pushToken
                                          rescheduledCallbackToken:nil
                                       withCompletionHandlingBlock:handlerBlock];
}

- (void)requestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                        rescheduledCallbackToken:(NSString *)callbackToken
                                     withCompletionHandlingBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock {

    [self pn_dispatchBlock:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.pushNotificationsAuditAttempt,
                     (pushToken ? pushToken : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];

        [self   performAsyncLockingBlock:^{

            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0 && pushToken != nil) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.auditPushNotifications,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNPushNotificationsEnabledChannelsRequest *request = [PNPushNotificationsEnabledChannelsRequest requestWithDevicePushToken:pushToken];
                if (handlerBlock && !callbackToken) {

                    [self.observationCenter addClientAsPushNotificationsEnabledChannelsObserverWithToken:request.shortIdentifier
                                                                                                andBlock:handlerBlock];
                }
                else if (callbackToken) {

                    [self.observationCenter changeClientCallbackToken:callbackToken
                                                                   to:request.shortIdentifier];
                }

                [self sendRequest:request shouldObserveProcessing:YES];
            }
                // Looks like client can't send request because of some reasons
            else {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.pushNotificationAuditImpossible,
                            [self humanReadableStateFrom:self.state]];
                }];

                if (pushToken == nil) {

                    statusCode = kPNDevicePushTokenIsEmptyError;
                }

                PNError *listRetrieveError = [PNError errorWithCode:statusCode];

                [self notifyDelegateAboutPushNotificationsEnabledChannelsFailedWithError:listRetrieveError
                                                                        andCallbackToken:callbackToken];

                if (handlerBlock && !callbackToken) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        handlerBlock(nil, listRetrieveError);
                    });
                }
            }
        }        postponedExecutionBlock:^{

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.postponePushNotificationAudit,
                        [self humanReadableStateFrom:self.state]];
            }];

            [self postponeRequestPushNotificationEnabledChannelsForDevicePushToken:pushToken
                                                          rescheduledCallbackToken:callbackToken
                                                       withCompletionHandlingBlock:handlerBlock];
        } burstExecutionLockingOperation:NO];
    }];
}

- (void)postponeRequestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                                rescheduledCallbackToken:(NSString *)callbackToken
                                             withCompletionHandlingBlock:(id)handlerBlock {
    
    SEL selector = @selector(requestPushNotificationEnabledChannelsForDevicePushToken:rescheduledCallbackToken:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:selector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:pushToken], [PNHelper nilifyIfNotSet:callbackToken],
                             [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:(callbackToken != nil) burstExecutionLock:NO];
}


#pragma mark - Misc methods

- (void)notifyDelegateAboutPushNotificationsEnableFailedWithError:(PNError *)error
                                                 andCallbackToken:(NSString *)callbackToken {
    
    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.api.pushNotificationEnablingFailed,
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate is able to handle push notification enabling error or not
        SEL selector = @selector(pubnubClient:pushNotificationEnableDidFailWithError:);
        if ([self.clientDelegate respondsToSelector:selector]) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            dispatch_async(dispatch_get_main_queue(), ^{

                [self.clientDelegate performSelector:selector withObject:self withObject:error];
            });
#pragma clang diagnostic pop
        }


        [self sendNotification:kPNClientPushNotificationEnableDidFailNotification withObject:error
              andCallbackToken:callbackToken];
    }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
}

- (void)notifyDelegateAboutPushNotificationsDisableFailedWithError:(PNError *)error
                                                  andCallbackToken:(NSString *)callbackToken {
    
    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.api.pushNotificationDisablingFailed,
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate is able to handle push notification enabling error or not
        SEL selector = @selector(pubnubClient:pushNotificationDisableDidFailWithError:);
        if ([self.clientDelegate respondsToSelector:selector]) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            dispatch_async(dispatch_get_main_queue(), ^{

                [self.clientDelegate performSelector:selector withObject:self withObject:error];
            });
#pragma clang diagnostic pop
        }

        [self sendNotification:kPNClientPushNotificationDisableDidFailNotification withObject:error
              andCallbackToken:callbackToken];
    }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
}

- (void)notifyDelegateAboutPushNotificationsRemoveFailedWithError:(PNError *)error
                                                 andCallbackToken:(NSString *)callbackToken {
    
    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.api.pushNotificationRemovalFailed,
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate is able to handle push notifications removal error or not
        SEL selector = @selector(pubnubClient:pushNotificationsRemoveFromChannelsDidFailWithError:);
        if ([self.clientDelegate respondsToSelector:selector]) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            dispatch_async(dispatch_get_main_queue(), ^{

                [self.clientDelegate performSelector:selector withObject:self withObject:error];
            });
#pragma clang diagnostic pop
        }

        [self sendNotification:kPNClientPushNotificationRemoveDidFailNotification withObject:error
              andCallbackToken:callbackToken];
    }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
}

- (void)notifyDelegateAboutPushNotificationsEnabledChannelsFailedWithError:(PNError *)error
                                                          andCallbackToken:(NSString *)callbackToken {
    
    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.api.pushNotificationAuditFailed,
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate is able to handle push notifications removal error or not
        SEL selector = @selector(pubnubClient:pushNotificationEnabledChannelsReceiveDidFailWithError:);
        if ([self.clientDelegate respondsToSelector:selector]) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            dispatch_async(dispatch_get_main_queue(), ^{

                [self.clientDelegate performSelector:selector withObject:self withObject:error];
            });
#pragma clang diagnostic pop
        }

        [self sendNotification:kPNClientPushNotificationChannelsRetrieveDidFailNotification
                    withObject:error andCallbackToken:callbackToken];
    }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
}


#pragma mark - Service channel delegate methods

- (void)                serviceChannel:(PNServiceChannel *)channel
  didEnablePushNotificationsOnChannels:(NSArray *)channels
                             onRequest:(PNBaseRequest *)request {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.didEnablePushNotifications,
                     [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            // Check whether delegate is able to handle push notification enabled event or not
            SEL selector = @selector(pubnubClient:didEnablePushNotificationsOnChannels:);
            if ([self.clientDelegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate performSelector:selector withObject:self
                                              withObject:channels];
                });
                #pragma clang diagnostic pop
            }

            [self sendNotification:kPNClientPushNotificationEnableDidCompleteNotification
                        withObject:channels andCallbackToken:request.shortIdentifier];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
    }];
}

- (void)                    serviceChannel:(PNServiceChannel *)channel
  didFailPushNotificationEnableForChannels:(NSArray *)channels
                                 withError:(PNError *)error forRequest:(PNBaseRequest *)request {

    NSString *callbackToken = request.shortIdentifier;
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [error replaceAssociatedObject:channels];
        [self notifyDelegateAboutPushNotificationsEnableFailedWithError:error
                                                       andCallbackToken:callbackToken];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            NSData *devicePushToken = (NSData *)error.associatedObject;
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.reschedulePushNotificationEnable,
                         [self humanReadableStateFrom:self.state]];
            }];

            [self enablePushNotificationsOnChannels:channels withDevicePushToken:devicePushToken
                           rescheduledCallbackToken:callbackToken andCompletionHandlingBlock:nil];
        }];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didDisablePushNotificationsOnChannels:(NSArray *)channels
             onRequest:(PNBaseRequest *)request {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.didDisablePushNotifications,
                     [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            // Check whether delegate is able to handle push notification disable event or not
            SEL selector = @selector(pubnubClient:didDisablePushNotificationsOnChannels:);
            if ([self.clientDelegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate performSelector:selector withObject:self
                                              withObject:channels];
                });
                #pragma clang diagnostic pop
            }

            [self sendNotification:kPNClientPushNotificationDisableDidCompleteNotification
                        withObject:channels andCallbackToken:request.shortIdentifier];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel didFailPushNotificationDisableForChannels:(NSArray *)channels
             withError:(PNError *)error forRequest:(PNBaseRequest *)request {

    NSString *callbackToken = request.shortIdentifier;
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [error replaceAssociatedObject:channels];
        [self notifyDelegateAboutPushNotificationsDisableFailedWithError:error
                                                        andCallbackToken:callbackToken];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            NSData *devicePushToken = (NSData *)error.associatedObject;
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.reschedulePushNotificationDisable,
                         [self humanReadableStateFrom:self.state]];
            }];

            [self disablePushNotificationsOnChannels:channels withDevicePushToken:devicePushToken
                            rescheduledCallbackToken:callbackToken andCompletionHandlingBlock:nil];
        }];
    }
}

- (void)serviceChannelDidRemovePushNotifications:(PNServiceChannel *)channel
                                       onRequest:(PNBaseRequest *)request {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.didRemovePushNotifications,
                     [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            // Check whether delegate is able to handle successful push notification removal from
            // all channels or not
            SEL selector = @selector(pubnubClientDidRemovePushNotifications:);
            if ([self.clientDelegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate performSelector:selector withObject:self];
                });
                #pragma clang diagnostic pop
            }

            [self sendNotification:kPNClientPushNotificationRemoveDidCompleteNotification
                        withObject:nil andCallbackToken:request.shortIdentifier];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
    }];
}

- (void)                   serviceChannel:(PNServiceChannel *)channel
  didFailPushNotificationsRemoveWithError:(PNError *)error
                               forRequest:(PNBaseRequest *)request {

    NSString *callbackToken = request.shortIdentifier;
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutPushNotificationsRemoveFailedWithError:error
                                                       andCallbackToken:callbackToken];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            NSData *devicePushToken = (NSData *)error.associatedObject;
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.reschedulePushNotificationRemove,
                         [self humanReadableStateFrom:self.state]];
            }];

            [self removeAllPushNotificationsForDevicePushToken:devicePushToken
                                      rescheduledCallbackToken:callbackToken
                                   withCompletionHandlingBlock:nil];
        }];
    }
}

- (void)                      serviceChannel:(PNServiceChannel *)channel
  didReceivePushNotificationsEnabledChannels:(NSArray *)channels
                                   onRequest:(PNBaseRequest *)request {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.didAuditPushNotifications,
                     [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            // Check whether delegate is able to handle push notification enabled
            // channels retrieval or not
            SEL selector = @selector(pubnubClient:didReceivePushNotificationEnabledChannels:);
            if ([self.clientDelegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate performSelector:selector withObject:self
                                              withObject:channels];
                });
                #pragma clang diagnostic pop
            }

            [self sendNotification:kPNClientPushNotificationChannelsRetrieveDidCompleteNotification
                        withObject:channels andCallbackToken:request.shortIdentifier];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
    }];
}

- (void)                                  serviceChannel:(PNServiceChannel *)channel
  didFailPushNotificationEnabledChannelsReceiveWithError:(PNError *)error
                                              forRequest:(PNBaseRequest *)request {

    NSString *callbackToken = request.shortIdentifier;
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutPushNotificationsEnabledChannelsFailedWithError:error
                                                                andCallbackToken:callbackToken];
    }
    else {

        [self rescheduleMethodCall:^{

            NSData *devicePushToken = (NSData *)error.associatedObject;

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.api.reschedulePushNotificationAudit,
                         [self humanReadableStateFrom:self.state]];
            }];

            [self requestPushNotificationEnabledChannelsForDevicePushToken:devicePushToken
                                                  rescheduledCallbackToken:callbackToken
                                               withCompletionHandlingBlock:nil];
        }];
    }
}

#pragma mark -


@end
