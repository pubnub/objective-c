//
//  PNMainViewController.m
//  pubnub
//
//  Created by Sergey Mamontov on 2/25/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNMainViewController.h"
#import "PNPushNotificationStateChangeView.h"
#import "PNPushNotificationsAuditView.h"
#import "PNPresenceObservationView.h"
#import "PNAccessRightsView.h"
#import "NSString+PNLocalization.h"
#import "PNConfigurationDelegate.h"
#import "PNChannelRegistryView.h"
#import "PNChannelPresenceView.h"
#import "PNGlobalPresenceView.h"
#import "PNClientChannelsView.h"
#import "PNChannelHistoryView.h"
#import "PNConfigurationView.h"
#import "UIView+PNAddition.h"
#import "PNUnsubscribeView.h"
#import "PNClientStateView.h"
#import "PNInformationView.h"
#import "PNSubscribeView.h"
#import "PNObjectCell.h"
#import "PNConsoleView.h"
#import "PNDataManager.h"
#import "PNAlertView.h"
#import "PNTableView.h"
#import "PNButton.h"
#import "PNAutoMessager.h"

// Don't use this import, because it is private PubNub API
#import "PNConfiguration+Protected.h"


#pragma mark Static

static double const kPNActionRetryDelayOnPAMError = 15.0f;


#pragma mark - Private interface declaration

@interface PNMainViewController () <PNConfigurationDelegate, UITableViewDelegate, UITableViewDataSource,
                                                    UITextFieldDelegate>


#pragma mark - Properties

/**
 Stores reference on console which will print out all messages which has been sent.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNConsoleView *consoleView;

/**
 Stores reference on table view which is used for channels layout.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNTableView *channelsTableView;

@property (nonatomic, pn_desired_weak) IBOutlet PNButton *sendButton;
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *clearButton;

@property (nonatomic, pn_desired_weak) IBOutlet UITextField *messageInputField;

/**
 Stores reference on list of channels for which client should retry subscription.
 */
@property (nonatomic, strong) NSArray *channelsForRetry;

/**
 Stores reference no message which should be resent
 */
@property (nonatomic, strong) NSString *messageForRetry;


#pragma mark - Instance methods

/**
 Perform initial interface preparation so it will be ready to be seen by user.
 */
- (void)prepareInterface;

- (void)showEmptyDevicePushTokenError;


#pragma mark - Handler methods

- (IBAction)handleSendMessageButtonTap:(id)sender;
- (IBAction)handleClearButtonTap:(id)sender;
- (IBAction)handleSubscribeButtonTap:(id)sender;
- (void)handleSettingsButtonTap:(id)sender;
- (void)handleInformationButtonTap:(id)sender;
- (void)handleDisconnectButtonTap:(id)sender;


#pragma mark - Misc methods

/**
 * Update subscribed channels list except current
 */
- (void)updateVisibleChannelsList;

- (void)highlightCurrentChannel;

/**
 * Updating message sending interface according to current
 * application state:
 * - enable if client is connected at least to one channel
 *   and inputted message
 * - disable in other case
 */
- (void)updateMessageSendingInterfaceWithMessage:(NSString *)message;

#pragma mark -


@end



#pragma mark - Public interface implementation

@implementation PNMainViewController


#pragma mark - Instance methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    // Check whether initialization has been completed or not
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) {
            
            self.wantsFullScreenLayout = YES;
        }
    }
    
    
    return self;
}

- (void)viewDidLoad {
    
    // Forward to the super class to complete all intializations
    [super viewDidLoad];
    
    [self prepareInterface];
    
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    
    [[PNObservationCenter defaultCenter] addPresenceEventObserver:self
                                                        withBlock:^(PNPresenceEvent *event) {
                                                            
                                                            [weakSelf updateVisibleChannelsList];
                                                            [weakSelf highlightCurrentChannel];
                                                        }];
    
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                         withBlock:^(PNMessage *message) {
                                                             
                                                             [weakSelf updateVisibleChannelsList];
                                                             [weakSelf highlightCurrentChannel];
                                                         }];
    
    
    [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:weakSelf
                                                                 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels,
                                                                                     PNError *subscriptionError) {
                                                                     
                                                                     switch (state) {
                                                                             
                                                                         case PNSubscriptionProcessNotSubscribedState:
                                                                             
                                                                             if (subscriptionError.code == kPNAPIAccessForbiddenError) {
                                                                                 
                                                                                 [[PNDataManager sharedInstance] clearChatHistory];
                                                                                 [[PNDataManager sharedInstance] clearChannels];
                                                                             }
                                                                             break;
                                                                         default:
                                                                             break;
                                                                     }
                                                                 }];
    
    
    // Subscribe on data manager properties change
    [[PNDataManager sharedInstance] addObserver:self forKeyPath:@"currentChannel" options:NSKeyValueObservingOptionNew
                                        context:nil];
    [[PNDataManager sharedInstance] addObserver:self forKeyPath:@"currentChannelChat" options:NSKeyValueObservingOptionNew
                                        context:nil];
    [[PNDataManager sharedInstance] addObserver:self forKeyPath:@"subscribedChannelsList" options:NSKeyValueObservingOptionNew
                                        context:nil];
    
    // initialize auto messager
    
    [[PNAutoMessager sharedManager] setPresendMessageBlock:^(NSString *message) {
        _messageInputField.text = message;
    }];
}

/**
 Perform initial interface preparation so it will be ready to be seen by user.
 */
- (void)prepareInterface {
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    [self updateMessageSendingInterfaceWithMessage:nil];
}

- (void)showEmptyDevicePushTokenError {
    
    PNAlertView *alertView = [PNAlertView viewWithTitle:@"pushNotificationEmptyTokenAlertViewTitle" type:PNAlertWarning
                                           shortMessage:@"pushNotificationEmptyTokenAlertViewShortDescription"
                                        detailedMessage:@"pushNotificationEmptyTokenAlertViewDetailedDescription" cancelButtonTitle:nil
                                      otherButtonTitles:nil andEventHandlingBlock:NULL];
    [alertView show];
}


#pragma mark - Handler methods

- (void)addChannelGroupChannels:(id)sender {
    
    [[PNChannelRegistryView viewFromNibForChannelGroupChannelsAdd] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                          animated:YES];
}

- (void)removeChannelGroupChannels:(id)sender {
    
    [[PNChannelRegistryView viewFromNibForChannelGroupChannelsRemove] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                             animated:YES];
}

- (void)fetchChannelGroupChannels:(id)sender {
    
    [[PNChannelRegistryView viewFromNibForChannelGroupChannelsAudit] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                            animated:YES];
}

- (void)removeChannelGroup:(id)sender {
    
    [[PNChannelRegistryView viewFromNibForChannelGroupRemove] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                     animated:YES];
}

- (void)fetchChannelGroups:(id)sender {
    
    [[PNChannelRegistryView viewFromNibForChannelGroupAudit] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                    animated:YES];
}

- (void)removeChannelGroupNamespace:(id)sender {
    
    [[PNChannelRegistryView viewFromNibForNamespaceRemove] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                  animated:YES];
}

- (void)fetchChannelGroupNamespaces:(id)sender {
    
    [[PNChannelRegistryView viewFromNibForNamespaceAudit] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                 animated:YES];
}

- (void)globalParticipantsList:(id)sender {
    
    [[PNGlobalPresenceView viewFromNib] showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
}

- (void)channelParticipantsList:(id)sender {
    
    [[PNChannelPresenceView viewFromNib] showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
}

- (void)channelGroupParticipantsList:(id)sender {
    
    [[PNChannelPresenceView viewFromNibForChannelGroup] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                               animated:YES];
}

- (void)clientChannelsList:(id)sender {
    
    [[PNClientChannelsView viewFromNib] showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
}

- (void)fetchFullHistory:(id)sender {
    
    [[PNChannelHistoryView viewFromNibForFullChannelHistory] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                    animated:YES];
}

- (void)fetchHistory:(id)sender {
    
    [[PNChannelHistoryView viewFromNibForChannelHistory] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                animated:YES];
}

- (void)grantApplicationAccessRights:(id)sender {
    
    [[PNAccessRightsView viewFromNibForApplicationGrant] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                animated:YES];
}

- (void)grantChannelAccessRights:(id)sender {
    
    [[PNAccessRightsView viewFromNibForChannelGrant] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                            animated:YES];
}

- (void)grantChannelGroupAccessRights:(id)sender {
    
    [[PNAccessRightsView viewFromNibForChannelGroupGrant] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                 animated:YES];
}

- (void)grantUserAccessRightsOnChannel:(id)sender {
    
    [[PNAccessRightsView viewFromNibForUserGrantOnChannel] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                  animated:YES];
}

- (void)grantUserAccessRightsOnChannelGroup:(id)sender {
    
    [[PNAccessRightsView viewFromNibForUserGrantOnChannelGroup] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                       animated:YES];
}

- (void)revokeApplicationAccessRights:(id)sender {
    
    [[PNAccessRightsView viewFromNibForApplicationRevoke] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                 animated:YES];
}

- (void)revokeChannelAccessRights:(id)sender {
    
    [[PNAccessRightsView viewFromNibForChannelRevoke] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                             animated:YES];
}

- (void)revokeChannelGroupAccessRights:(id)sender {
    
    [[PNAccessRightsView viewFromNibForChannelGroupRevoke] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                  animated:YES];
}

- (void)revokeUserAccessRightsOnChannel:(id)sender {
    
    [[PNAccessRightsView viewFromNibForUserRevokeOnChannel] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                   animated:YES];
}

- (void)revokeUserAccessRightsOnChannelGroup:(id)sender {
    
    [[PNAccessRightsView viewFromNibForUserRevokeOnChannelGroup] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                        animated:YES];
}

- (void)auditApplicationAccessRights:(id)sender {
    
    [[PNAccessRightsView viewFromNibForApplicationAudit] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                animated:YES];
}

- (void)auditChannelAccessRights:(id)sender {
    
    [[PNAccessRightsView viewFromNibForChannelAudit] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                            animated:YES];
}

- (void)auditChannelGroupAccessRights:(id)sender {
    
    [[PNAccessRightsView viewFromNibForChannelGroupAudit] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                 animated:YES];
}

- (void)auditUserAccessRightsOnChannel:(id)sender {
    
    [[PNAccessRightsView viewFromNibForUserAuditOnChannel] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                  animated:YES];
}

- (void)auditUserAccessRightsOnChannelGroup:(id)sender {
    
    [[PNAccessRightsView viewFromNibForUserAuditOnChannelGroup] showWithOptions:PNViewAnimationOptionTransitionFadeIn
                                                                       animated:YES];
}

- (void)enablePushNotifications:(id)sender {
    
    if ([PNDataManager sharedInstance].devicePushToken) {
        
        PNPushNotificationStateChangeView *pushNotificationView = [PNPushNotificationStateChangeView viewFromNibForEnabling];
        [pushNotificationView showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
    }
    else {
        
        [self showEmptyDevicePushTokenError];
    }
}

- (void)disablePushNotifications:(id)sender {
    
    if ([PNDataManager sharedInstance].devicePushToken) {
        
        PNPushNotificationStateChangeView *pushNotificationView = [PNPushNotificationStateChangeView viewFromNibForDisabling];
        [pushNotificationView showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
    }
    else {
        
        [self showEmptyDevicePushTokenError];
    }
}

- (void)removePushNotifications:(id)sender {
    
    if ([PNDataManager sharedInstance].devicePushToken) {
        
        PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
        [progressAlertView show];
        
        void(^auditHandlerBlock)(NSArray *, PNError *) = ^(NSArray *channels, PNError *auditRequestError){
            
            if (!auditRequestError) {
                
                if ([channels count]) {
                    
                    void(^disableHandlerBlock)(PNError *) = ^(PNError *disableRequestError){
                        
                        [progressAlertView dismissWithAnimation:YES];
                        
                        PNAlertType type = (disableRequestError ? PNAlertWarning : PNAlertSuccess);
                        NSString *shortMessage = (disableRequestError ? @"pushNotificationRemovalFailureAlertViewShortDescription" :
                                                                        @"pushNotificationRemovalSuccessAlertViewShortDescription");
                        NSString *detailedDescription = @"pushNotificationRemovalSuccessAlertViewDetailedDescription";
                        
                        if (disableRequestError) {
                            
                            detailedDescription = [NSString stringWithFormat:[@"pushNotificationRemovalFailureAlertViewDetailedDescription" localized],
                                                   disableRequestError.localizedFailureReason];
                        }
                        
                        PNAlertView *removalAlertView = [PNAlertView viewWithTitle:@"pushNotificationRemovalAlertViewTitle"
                                                                              type:type shortMessage:shortMessage
                                                                   detailedMessage:detailedDescription cancelButtonTitle:nil
                                                                 otherButtonTitles:nil andEventHandlingBlock:NULL];
                        [removalAlertView show];
                    };
                    
                    [PubNub removeAllPushNotificationsForDevicePushToken:[PNDataManager sharedInstance].devicePushToken
                                             withCompletionHandlingBlock:disableHandlerBlock];
                }
                else {
                    
                    [progressAlertView dismissWithAnimation:YES];
                    
                    PNAlertView *removalAlertView = [PNAlertView viewWithTitle:@"pushNotificationRemovalAlertViewTitle"
                                                                          type:PNAlertSuccess
                                                                  shortMessage:@"pushNotificationRemovalSuccessAlertViewShortDescription"
                                                               detailedMessage:@"pushNotificationRemovalSuccessAlertViewDetailedDescription"
                                                             cancelButtonTitle:nil otherButtonTitles:nil andEventHandlingBlock:NULL];
                    [removalAlertView show];
                }
            }
            else {
                
                [progressAlertView dismissWithAnimation:YES];
                
                NSString *detailedDescription = [NSString stringWithFormat:[@"pushNotificationAuditFailureAlertViewDetailedDescription" localized],
                                                 auditRequestError.localizedFailureReason];
                PNAlertView *auditionErrorView = [PNAlertView viewWithTitle:@"pushNotificationAuditAlertViewTitle"
                                                                       type:PNAlertWarning shortMessage:@"pushNotificationAuditSuccessAlertViewShortDescription"
                                                            detailedMessage:detailedDescription cancelButtonTitle:nil
                                                          otherButtonTitles:nil andEventHandlingBlock:NULL];
                [auditionErrorView show];
            }
        };
        [PubNub requestPushNotificationEnabledChannelsForDevicePushToken:[PNDataManager sharedInstance].devicePushToken
                                             withCompletionHandlingBlock:auditHandlerBlock];
    }
    else {
        
        [self showEmptyDevicePushTokenError];
    }
}

- (void)auditPushNotifications:(id)sender {
    
    if ([PNDataManager sharedInstance].devicePushToken) {
        
        PNPushNotificationsAuditView *pushNotificationView = [PNPushNotificationsAuditView viewFromNib];
        [pushNotificationView showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
    }
    else {
        
        [self showEmptyDevicePushTokenError];
    }
}

- (void)subscribe:(id)sender {
    
    PNSubscribeView *subscribe = [PNSubscribeView viewFromNib];
    [subscribe showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
}

- (void)unsubscribe:(id)sender {
    
    PNUnsubscribeView *unsubscribe = [PNUnsubscribeView viewFromNib];
    [unsubscribe showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
}

- (void)getClientState:(id)sender {
    
    PNClientStateView *stateView = [PNClientStateView viewFromNibForViewing];
    [stateView configureFor:nil clientIdentifier:[PubNub clientIdentifier] andState:nil];
    [stateView showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
}

- (void)setClientState:(id)sender {
    
    PNClientStateView *stateView = [PNClientStateView viewFromNibForEditing];
    [stateView configureFor:nil clientIdentifier:[PubNub clientIdentifier] andState:nil];
    [stateView showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
}

- (void)enablePresenceObservation:(id)sender {
    
    PNPresenceObservationView *presenceView = [PNPresenceObservationView viewFromNibForEnabling];
    [presenceView showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
}

- (void)disablePresenceObservation:(id)sender {
    
    PNPresenceObservationView *presenceView = [PNPresenceObservationView viewFromNibForDisabling];
    [presenceView showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
}

- (void)enableAutoMessaging:(id)sender {
    [[PNAutoMessager sharedManager] start];
}

- (void)disableAutoMessaging:(id)sender {
    [[PNAutoMessager sharedManager] stop];
}

- (IBAction)handleSendMessageButtonTap:(id)sender {
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    NSString *message = self.messageInputField.text;
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
                                                      
                                                      self.channelsForRetry = nil;
                                                      self.messageForRetry = nil;
                                                  }
                                              }];
            [alertView show];
            
            if (((PNError *)object).code == kPNAPIAccessForbiddenError) {
                
                weakSelf.messageForRetry = message;
                double delayInSeconds = kPNActionRetryDelayOnPAMError;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    if (weakSelf.messageForRetry) {
                        
                        [alertView dismissWithClickedButtonIndex:([alertView cancelButtonIndex] + 1) animated:YES];
                        weakSelf.messageInputField.text = weakSelf.messageForRetry;
                        [weakSelf handleSendMessageButtonTap:nil];
                        weakSelf.messageForRetry = nil;
                    }
                });
            }
        }
    }];
    self.messageInputField.text = nil;
    [self updateMessageSendingInterfaceWithMessage:nil];
    [self.view endEditing:YES];
}

- (IBAction)handleClearButtonTap:(id)sender {
    
    self.messageInputField.text = nil;
    [self updateMessageSendingInterfaceWithMessage:nil];
    [[PNDataManager sharedInstance] clearChatHistory];
}

- (IBAction)handleSubscribeButtonTap:(id)sender {
    
    [self subscribe:sender];
}

- (void)handleSettingsButtonTap:(id)sender {
    
    PNConfigurationView *configuration = [PNConfigurationView configurationViewWithDelegate:self
                                                                           andConfiguration:[PNDataManager sharedInstance].configuration];
    [configuration showWithOptions:PNViewAnimationOptionTransitionFromTop animated:YES ];
}

- (void)timeToken:(id)sender {
    
    PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
    [progressAlertView show];
    
    [PubNub requestServerTimeTokenWithCompletionBlock:^(NSNumber *timeToken, PNError *requestError) {
        
        [progressAlertView dismissWithAnimation:YES];
        
        PNAlertType type = requestError ? PNAlertWarning : PNAlertSuccess;
        NSString *title = requestError ? @"Request did fail" : @"Request completed";
        NSString *shortDescription = requestError ? @"Time token rquest failed." : @"Time token request successful.";
        NSString *detailedDescription = [NSString stringWithFormat:@"PubNub client successfully retrieved time token:\n%@",
                                         timeToken];
        if (requestError) {
            
            detailedDescription = [NSString stringWithFormat:@"PubNub client did fail to retrieved time token.\nReason: %@",
                                   requestError.localizedFailureReason];
        }
        
        PNAlertView *alertView = [PNAlertView viewWithTitle:title type:type shortMessage:shortDescription
                                            detailedMessage:detailedDescription cancelButtonTitle:nil
                                          otherButtonTitles:nil andEventHandlingBlock:NULL];
        [alertView show];
    }];
}



- (void)handleInformationButtonTap:(id)sender {
    
    PNInformationView *informationView = [PNInformationView viewFromNib];
    [informationView showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
}

- (void)handleDisconnectButtonTap:(id)sender {
    
    [PubNub disconnect];
    
    [[PNObservationCenter defaultCenter] removeChannelParticipantsListProcessingObserver:self];
    [[PNObservationCenter defaultCenter] removeTimeTokenReceivingObserver:self];
    [[PNObservationCenter defaultCenter] removeClientConnectionStateObserver:self];
    [[PNObservationCenter defaultCenter] removeChannelParticipantsListProcessingObserver:self];
    [[PNObservationCenter defaultCenter] removePresenceEventObserver:self];
    [[PNObservationCenter defaultCenter] removeMessageReceiveObserver:self];
    [[PNObservationCenter defaultCenter] removePresenceEventObserver:self];
    [[PNDataManager sharedInstance] removeObserver:self forKeyPath:@"currentChannel"];
    [[PNDataManager sharedInstance] removeObserver:self forKeyPath:@"currentChannelChat"];
    [[PNDataManager sharedInstance] removeObserver:self forKeyPath:@"subscribedChannelsList"];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    
    BOOL shouldUpdateChat = NO;
    
    // Check whether current category changed or not
    if ([keyPath isEqualToString:@"currentChannel"]) {
        
        [self updateVisibleChannelsList];
        [self highlightCurrentChannel];
        
        shouldUpdateChat = YES;
        
        self.messageInputField.text = nil;
        [self updateMessageSendingInterfaceWithMessage:nil];
    }
    // Looks like list of channels changed
    else if ([keyPath isEqualToString:@"subscribedChannelsList"]){
        
        [self.channelsTableView reloadData];
        
        if ([[PubNub subscribedObjectsList] count]) {
            
            PNChannel *currentChannel = [[PNDataManager sharedInstance] currentChannel];
            
            if (currentChannel != nil) {
                
                [self highlightCurrentChannel];
            }
        }
    }
    else if ([keyPath isEqualToString:@"currentChannelChat"]){
        
        shouldUpdateChat = YES;
    }
    
    if (shouldUpdateChat) {
        
        [self.consoleView setOutputTo:[PNDataManager sharedInstance].currentChannelChat];
        
        CGRect targetRect = self.consoleView.bounds;
        targetRect.origin.y = self.consoleView.contentSize.height - targetRect.size.height;
        if (targetRect.size.height < self.consoleView.contentSize.height) {
            
            [self.consoleView flashScrollIndicators];
        }
        
        [self.consoleView scrollRectToVisible:targetRect animated:YES];
    }
}


#pragma mark - Misc methods

- (void)updateVisibleChannelsList {
    
    NSArray *channels = [[PNDataManager sharedInstance] subscribedChannelsList];
    NSArray *visibleCells = [self.channelsTableView visibleCells];
    [visibleCells enumerateObjectsUsingBlock:^(PNObjectCell *cell, NSUInteger cellIdx, BOOL *cellsEnumeratorStop) {
        
        [cell updateForObject:[channels objectAtIndex:cellIdx]];
    }];
}

- (void)highlightCurrentChannel {
    
    PNChannel *currentChannel = [[PNDataManager sharedInstance] currentChannel];
    NSInteger channelIdx = [[[PNDataManager sharedInstance] subscribedChannelsList] indexOfObject:currentChannel];
    NSIndexPath *currentChannelPath = [NSIndexPath indexPathForRow:channelIdx inSection:0];
    [self.channelsTableView selectRowAtIndexPath:currentChannelPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)updateMessageSendingInterfaceWithMessage:(NSString *)message {
    
    BOOL isSubscribed = [[PNDataManager sharedInstance].subscribedChannelsList count] > 0;
    BOOL isChannelSelected = [PNDataManager sharedInstance].currentChannel != nil;
    BOOL isChannelGroupSelected = (isChannelSelected && [PNDataManager sharedInstance].currentChannel.isChannelGroup);
    BOOL isEmptyMessage = message == nil || [message pn_isEmpty];
    
    if (!isChannelSelected) {
        
        self.messageInputField.placeholder = @"Select channel on right side to be able send messages.";
    }
    else if (isChannelGroupSelected) {
        
        self.messageInputField.placeholder = @"Messages can't be sent into channel group.";
    }
    else {
        
        self.messageInputField.placeholder = nil;
    }
    
    self.sendButton.enabled = isSubscribed && !isEmptyMessage && isChannelSelected && !isChannelGroupSelected;
    self.messageInputField.enabled = isSubscribed && isChannelSelected && !isChannelGroupSelected;
}


#pragma mark - PNConfiguraiton delegate methods

- (void)configurationChangeDidComplete:(PNConfiguration *)updatedConfiguration {
   
    // Checking whether configuration update will require hard reset (this functionality maybe will be moved to public
    // PubNub API).
    if ([[PubNub configuration] requiresConnectionResetWithConfiguration:updatedConfiguration]) {
        
        [[PNDataManager sharedInstance] clearChatHistory];
        [[PNDataManager sharedInstance] clearChannels];
    }
    [PNDataManager sharedInstance].configuration = updatedConfiguration;
    [PubNub setConfiguration:[PNDataManager sharedInstance].configuration];
}


#pragma mark - UItextField delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *inputtedMessage = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self updateMessageSendingInterfaceWithMessage:inputtedMessage];
    
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.view endEditing:YES];
    if (self.sendButton.isEnabled) {
        
        [self handleSendMessageButtonTap:self.sendButton];
    }
    
    
    return YES;
}


#pragma mark - UItableView delegate methods

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return @"Unsubscribe";
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.channelsTableView isEqual:tableView]?indexPath:nil;
}

/**
 * UITableView by calling this method notify delegate about that user selected
 * one of table rows
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Check whether user selected item from table with channels list or not
    if ([self.channelsTableView isEqual:tableView]) {
        
        // Update current channel in data modelmanager
        PNChannel *channel = [[PNDataManager sharedInstance].subscribedChannelsList objectAtIndex:indexPath.row];
        [PNDataManager sharedInstance].currentChannel = channel;
    }
}


#pragma mark UITableView data source delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[PNDataManager sharedInstance].subscribedChannelsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *channelCellIdentifier = @"channelCell";
    PNObjectCell *cell = (PNObjectCell *)[tableView dequeueReusableCellWithIdentifier:channelCellIdentifier];
    
    if(!cell) {
        
        // Create new cell instance copy
        cell = [[PNObjectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:channelCellIdentifier];
    }
    PNChannel *channel = [[PNDataManager sharedInstance].subscribedChannelsList objectAtIndex:indexPath.row];
    [(PNObjectCell *)cell updateForObject:channel];
    ((UITableViewCell *)cell).selected = [channel.name isEqualToString:[[PNDataManager sharedInstance] currentChannel].name];
    
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        PNChannel *channel = [[PNDataManager sharedInstance].subscribedChannelsList objectAtIndex:indexPath.row];
        if ([channel isEqual:[PNDataManager sharedInstance].currentChannel]) {
            
            [PNDataManager sharedInstance].currentChannel = nil;
        }

        [PubNub unsubscribeFrom:@[channel]];
    }
}

#pragma mark -


@end
