//
//  PNAutoMessager.m
//  pubnub
//
//  Created by Vadim Osovets on 8/10/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNAutoMessager.h"
#import "PNDataManager.h"
#import "PNAlertView.h"

#import "NSString+PNLocalization.h"

static double const kPNActionRetryDelayOnPAMError = 15.0f;
static double const kTimeIntervalBetweenMessages = 0.7f;

@implementation PNAutoMessager {
    NSTimer *_sendMessageTimer;
}

+ (instancetype)sharedManager {
    static id manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    
    return manager;
}

#pragma mark - Functionality

- (void)start {
    
    if (_sendMessageTimer == nil) {
    
        _sendMessageTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeIntervalBetweenMessages
                                                         target:self
                                                       selector:@selector(send)
                                                       userInfo:nil repeats:YES];
    }
}

- (void)stop {
    [_sendMessageTimer invalidate];
    _sendMessageTimer = nil;
}

#pragma mark - Private

- (void)send {
    NSString *message = [NSString stringWithFormat:@"%@", [NSDate new]];
    
    [self sendMessage:message];
}

- (void)sendMessage:(NSString *)message {
    
    if (self.presendMessageBlock != NULL) {
        self.presendMessageBlock(message);
    }
    
    [PubNub sendMessage:message toChannel:[PNDataManager sharedInstance].currentChannel
    withCompletionBlock:^(PNMessageState state, id object) {
        
        if (state == PNMessageSendingError) {
            
            NSString *cancelButtonTitle = nil;
            NSString *detailedDescription = [NSString stringWithFormat:[@"messageSendGeneralErrorAlertViewDetailedDescription" localized],
                                             [PNDataManager sharedInstance].currentChannel.name, [((PNError *)object) localizedFailureReason]];
            
            if (((PNError *)object).code == kPNAPIAccessForbiddenError) {
                
                detailedDescription = [NSString stringWithFormat:[@"messageSendPAMErrorAlertViewDetailedDescription" localized],
                                       [PNDataManager sharedInstance].currentChannel.name, (int)kPNActionRetryDelayOnPAMError];
                
                cancelButtonTitle = @"cancelButtonTitle";
            }
            
            PNAlertView *alertView = [PNAlertView viewWithTitle:@"messageSendAlertViewTitle" type:PNAlertWarning
                                                   shortMessage:@"messageSendErrorAlertViewShortDescription"
                                                detailedMessage:detailedDescription cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:@[@"confirmButtonTitle"] andEventHandlingBlock:^(PNAlertView *view, NSUInteger buttonIndex) {
                                                  
                                                  if ([view cancelButtonIndex] == buttonIndex) {
                                                      // TODO: implement righ behavior
                                                  }
                                              }];
            [alertView show];
            [self stop];
            
            if (((PNError *)object).code == kPNAPIAccessForbiddenError) {
                
                double delayInSeconds = kPNActionRetryDelayOnPAMError;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        
                        [alertView dismissWithClickedButtonIndex:([alertView cancelButtonIndex] + 1) animated:YES];
                        
                        [self sendMessage:message];
                });
            }
        }
    }];
}

@end
