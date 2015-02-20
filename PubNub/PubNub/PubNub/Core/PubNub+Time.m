//
//  PubNub+Time.m
//  pubnub
//
//  Created by Sergey Mamontov on 9/3/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PubNub+Time.h"
#import "NSObject+PNAdditions.h"
#import "PNTimeTokenRequest.h"
#import "PNServiceChannel.h"
#import "PubNub+Protected.h"
#import "PNNotifications.h"
#import "PNHelper.h"

#import "PNLogger+Protected.h"
#import "PNLoggerSymbols.h"


#pragma mark - Category private interface declaration

@interface PubNub (TimePrivate)


#pragma mark - Instance methods

/**
 @brief Final designated method which allow to server time token information depending on provided set of parameters.

 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 */
- (void)requestServerTimeTokenRescheduledCallbackToken:(NSString *)callbackToken
                                   withCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success;

/**
 @brief Postpone server time fetch user request so it will be executed in future.
 
 @note  Postpone can be because of few cases: \b PubNub client is in connecting or initial
        connection state; another request which has been issued earlier didn't completed yet.

 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handleBlock   Handler block which is called by \b PubNub client when client's state fetching
                      process state changes. Block pass two arguments: \c timeToken - \a NSNumber
                      which represent server's time token information; \c error - \b PNError
                      instance which hold information about why server's time token fetching process
                      failed. Always check \a error.code to find out what caused error (check
                      PNErrorCodes header file and use \a -localizedDescription /
                      \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human
                      readable description for error).
 */
- (void)postponeRequestServerTimeTokenRescheduledCallbackToken:(NSString *)callbackToken
                                           withCompletionBlock:(id)success;


#pragma mark - Misc methods

/**
 @brief This method will notify delegate about that time token retrieval failed because of error
 
 @note  Always check \a error.code to find out what caused error (check PNErrorCodes header file and
        use \a -localizedDescription / \a -localizedFailureReason and
        \a -localizedRecoverySuggestion to get human readable description for error).
 
 @param error         Instance of \b PNError which describes what exactly happened and why this
                      error occurred.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 */
- (void)notifyDelegateAboutTimeTokenRetrievalFailWithError:(PNError *)error
                                          andCallbackToken:(NSString *)callbackToken;

#pragma mark -


@end


#pragma mark - Category methods implementation

@implementation PubNub (Time)


#pragma mark - Class (singleton) methods

+ (void)requestServerTimeToken {
    
    [self requestServerTimeTokenWithCompletionBlock:nil];
}

+ (void)requestServerTimeTokenWithCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success {
    
    [[self sharedInstance] requestServerTimeTokenWithCompletionBlock:success];
}


#pragma mark - Instance methods

- (void)requestServerTimeToken {
    
    [self requestServerTimeTokenWithCompletionBlock:nil];
}

- (void)requestServerTimeTokenWithCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success {

    [self requestServerTimeTokenRescheduledCallbackToken:nil withCompletionBlock:success];
}

- (void)requestServerTimeTokenRescheduledCallbackToken:(NSString *)callbackToken
                                   withCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success {

    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.timeTokenFetchAttempt,
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self   performAsyncLockingBlock:^{

            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.fetchingTimeToken,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNTimeTokenRequest *request = [PNTimeTokenRequest new];
                if (success && !callbackToken) {

                    [self.observationCenter addClientAsTimeTokenReceivingObserverWithToken:request.shortIdentifier
                                                                                  andBlock:success];
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

                    return @[PNLoggerSymbols.api.timeTokenFetchImpossible,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNError *timeTokenError = [PNError errorWithCode:statusCode];

                [self notifyDelegateAboutTimeTokenRetrievalFailWithError:timeTokenError
                                                        andCallbackToken:callbackToken];

                if (success && !callbackToken) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        success(nil, timeTokenError);
                    });
                }
            }
        }        postponedExecutionBlock:^{

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.postponeTimeTokenFetch,
                        [self humanReadableStateFrom:self.state]];
            }];

            [self postponeRequestServerTimeTokenRescheduledCallbackToken:callbackToken
                                                     withCompletionBlock:success];
        } burstExecutionLockingOperation:NO];
    }];
}

- (void)postponeRequestServerTimeTokenRescheduledCallbackToken:(NSString *)callbackToken
                                           withCompletionBlock:(id)success {
    
    id successCopy = (success ? [success copy] : nil);
    [self postponeSelector:@selector(requestServerTimeTokenRescheduledCallbackToken:withCompletionBlock:)
                 forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:callbackToken],
                             [PNHelper nilifyIfNotSet:successCopy]]
                outOfOrder:(callbackToken != nil) burstExecutionLock:NO];
}

#pragma mark - Misc methods

- (void)notifyDelegateAboutTimeTokenRetrievalFailWithError:(PNError *)error
                                          andCallbackToken:(NSString *)callbackToken {
    
    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.api.timeTokenRetrieveFailed,
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate is able to handle time token retrieval error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:timeTokenReceiveDidFailWithError:)]) {

            dispatch_async(dispatch_get_main_queue(), ^{

                [self.clientDelegate performSelector:@selector(pubnubClient:timeTokenReceiveDidFailWithError:)
                                          withObject:self withObject:error];
            });
        }

        [self sendNotification:kPNClientDidFailTimeTokenReceiveNotification withObject:error
              andCallbackToken:callbackToken];
    }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
}


#pragma mark - Service channel delegate methods

- (void)serviceChannel:(PNServiceChannel *)channel didReceiveTimeToken:(NSNumber *)timeToken
             onRequest:(PNBaseRequest *)request {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.didReceiveTimeToken,
                     [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            // Check whether delegate can handle time token retrieval or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didReceiveTimeToken:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate performSelector:@selector(pubnubClient:didReceiveTimeToken:)
                                              withObject:self withObject:timeToken];
                });
            }

            [self sendNotification:kPNClientDidReceiveTimeTokenNotification withObject:timeToken
                  andCallbackToken:request.shortIdentifier];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel receiveTimeTokenDidFailWithError:(PNError *)error
            forRequest:(PNBaseRequest *)request {

    NSString *callbackToken = request.shortIdentifier;
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutTimeTokenRetrievalFailWithError:error
                                                andCallbackToken:callbackToken];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleTimeTokenRequest,
                         [self humanReadableStateFrom:self.state]];
            }];

            [self requestServerTimeTokenRescheduledCallbackToken:callbackToken
                                             withCompletionBlock:nil];
        }];
    }
}

#pragma mark -


@end
