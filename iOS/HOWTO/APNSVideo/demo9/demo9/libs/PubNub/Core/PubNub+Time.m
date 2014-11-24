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
 Final designated method which allow to server time token information depending on provided set of parameters.

 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 */
- (void)requestServerTimeTokenReschedulingMethodCall:(BOOL)isMethodCallRescheduled
                                 withCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success;

/**
 Postpone server time fetch user request so it will be executed in future.
 
 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another request
 which has been issued earlier didn't completed yet.
 
 @param handleBlock
 Handler block which is called by \b PubNub client when client's state fetching process state changes. Block pass two arguments:
 \c timeToken - \a NSNumber which represent server's time token information;
 \c error - \b PNError instance which hold information about why server's time token fetching process failed. Always check
 \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)postponeRequestServerTimeTokenReschedulingMethodCall:(BOOL)isMethodCallRescheduled
                                         withCompletionBlock:(id)success;


#pragma mark - Misc methods

/**
 * This method will notify delegate about that time token retrieval failed because of error
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @param error
 Instance of \b PNError which describes what exactly happened and why this error occurred. \a 'error.associatedObject'
 contains reference on \b PNAccessRightOptions instance which will allow to review and identify what options \b PubNub client tried to apply.
 */
- (void)notifyDelegateAboutTimeTokenRetrievalFailWithError:(PNError *)error;

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

    [self requestServerTimeTokenReschedulingMethodCall:NO withCompletionBlock:success];
}

- (void)requestServerTimeTokenReschedulingMethodCall:(BOOL)isMethodCallRescheduled
                                 withCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success {

    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.timeTokenFetchAttempt, [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsTimeTokenReceivingObserver];
            }
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.fetchingTimeToken, [self humanReadableStateFrom:self.state]];
                }];
                
                if (success && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsTimeTokenReceivingObserverWithCallbackBlock:success];
                }
                
                [self sendRequest:[PNTimeTokenRequest new] shouldObserveProcessing:YES];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.timeTokenFetchImpossible, [self humanReadableStateFrom:self.state]];
                }];
                
                PNError *timeTokenError = [PNError errorWithCode:statusCode];
                
                [self notifyDelegateAboutTimeTokenRetrievalFailWithError:timeTokenError];
                
                
                if (success && !isMethodCallRescheduled) {
                    
                    success(nil, timeTokenError);
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponeTimeTokenFetch, [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeRequestServerTimeTokenReschedulingMethodCall:isMethodCallRescheduled withCompletionBlock:success];
               }];
    }];
}

- (void)postponeRequestServerTimeTokenReschedulingMethodCall:(BOOL)isMethodCallRescheduled
                                         withCompletionBlock:(id)success {
    
    id successCopy = (success ? [success copy] : nil);
    [self postponeSelector:@selector(requestServerTimeTokenReschedulingMethodCall:withCompletionBlock:) forObject:self
            withParameters:@[@(isMethodCallRescheduled), [PNHelper nilifyIfNotSet:successCopy]]
                outOfOrder:isMethodCallRescheduled];
}

#pragma mark - Misc methods

- (void)notifyDelegateAboutTimeTokenRetrievalFailWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.timeTokenRetrieveFailed, [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate is able to handle time token retrieval error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:timeTokenReceiveDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [self.clientDelegate performSelector:@selector(pubnubClient:timeTokenReceiveDidFailWithError:) withObject:self
                                          withObject:error];
            });
        }
        
        [self sendNotification:kPNClientDidFailTimeTokenReceiveNotification withObject:error];
    }
                                shouldStartNext:YES];
}


#pragma mark - Service channel delegate methods

- (void)serviceChannel:(PNServiceChannel *)channel didReceiveTimeToken:(NSNumber *)timeToken {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.didReceiveTimeToken, [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            // Check whether delegate can handle time token retrieval or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didReceiveTimeToken:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate performSelector:@selector(pubnubClient:didReceiveTimeToken:) withObject:self
                                              withObject:timeToken];
                });
            }

            [self sendNotification:kPNClientDidReceiveTimeTokenNotification withObject:timeToken];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }
                                    shouldStartNext:YES];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel receiveTimeTokenDidFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutTimeTokenRetrievalFailWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleTimeTokenRequest, [self humanReadableStateFrom:self.state]];
            }];
            
            [self requestServerTimeTokenReschedulingMethodCall:YES withCompletionBlock:nil];
        }];
    }
}

#pragma mark -


@end
