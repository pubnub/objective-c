//
//  PNSubscribeView.m
//  pubnub
//
//  Created by Sergey Mamontov on 2/28/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNSubscribeView.h"
#import "PNChannelInformationDelegate.h"
#import "PNChannelInformationView.h"
#import "NSString+PNLocalization.h"
#import "PNSubscriptionHelper.h"
#import "UIScreen+PNAddition.h"
#import "UIView+PNAddition.h"
#import "PNChannelCell.h"
#import "PNAlertView.h"
#import "PNButton.h"


#pragma mark Static

static NSTimeInterval const kPNViewAppearAnimationDuration = 0.4f;
static NSTimeInterval const kPNViewDisappearAnimationDuration = 0.2f;


#pragma mark - Private interface declaration

@interface PNSubscribeView () <PNChannelInformationDelegate, UITableViewDelegate, UITableViewDataSource>


#pragma mark - Properties

@property (nonatomic, pn_desired_weak) IBOutlet PNButton *subscribeButton;

/**
 Stores reference on helper which will track channels and their data.
 */
@property (nonatomic, strong) IBOutlet PNSubscriptionHelper *subscribeHelper;

/**
 Stores reference on sthe table which is used to layout list of channels on which client should subscribe.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *channelsList;


#pragma mark - Instance methods

- (void)updateLayout;


#pragma mark - Handler methods

- (IBAction)handleChannelAddButtonTap:(id)sender;
- (IBAction)handleSubscribeButtonTap:(id)sender;
- (IBAction)handleCloseButtonTap:(id)sender;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNSubscribeView


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class
    [super awakeFromNib];

    [self updateLayout];
}


#pragma mark - Instance methods

- (void)updateLayout {
    
    self.subscribeButton.enabled = [[self.subscribeHelper channelsForSubscription] count] > 0;
}

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNViewAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNViewDisappearAnimationDuration;
}


#pragma mark - Handler methods

- (IBAction)handleChannelAddButtonTap:(id)sender {
    
    PNChannelInformationView *information = [PNChannelInformationView viewFromNib];
    information.delegate = self;
    information.allowEditing = YES;
    [information showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
}

- (IBAction)handleSubscribeButtonTap:(id)sender {
    
    PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
    [progressAlertView show];
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [PubNub subscribeOnChannels:[self.subscribeHelper channelsForSubscription] withClientState:[self.subscribeHelper channelsState]
     andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
         
         if (state == PNSubscriptionProcessSubscribedState || subscriptionError) {
             
             [progressAlertView dismissWithAnimation:YES];
             
             PNAlertType type = subscriptionError ? PNAlertWarning : PNAlertSuccess;
             NSString *title = @"subscribeAlertViewTitle";
             NSString *shortDescription = subscriptionError ? @"subscribeFailureAlertViewShortDescription" : @"subscribeSuccessAlertViewShortDescription";
             NSString *detailedDescription = [NSString stringWithFormat:[@"subscribeSuccessAlertViewDetailedDescription" localized],
                                              [[channels valueForKey:@"name"] componentsJoinedByString:@", "]];
             if (subscriptionError) {
                 
                 detailedDescription = [NSString stringWithFormat:[@"subscribeFailureAlertViewDetailedDescription" localized],
                                                  [[channels valueForKey:@"name"] componentsJoinedByString:@", "],
                                                  subscriptionError.localizedFailureReason];
             }
             
             PNAlertView *alertView = [PNAlertView viewWithTitle:title type:type shortMessage:shortDescription
                                                 detailedMessage:detailedDescription cancelButtonTitle:nil
                                               otherButtonTitles:nil andEventHandlingBlock:^(PNAlertView *view, NSUInteger buttonIndex) {
                                                   
                                                   if (!subscriptionError) {
                                                       
                                                       [weakSelf.subscribeHelper reset];
                                                       [weakSelf.channelsList reloadData];
                                                       [weakSelf updateLayout];
                                                   }
                                               }];
             [alertView show];
         }
     }];
}

- (IBAction)handleCloseButtonTap:(id)sender {
    
    [self dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
}


#pragma mark - Channel information delegate methods

- (void)channelInformation:(PNChannelInformationView *)informationView didEndEditingChanne:(PNChannel *)channel
                 withState:(NSDictionary *)channelState andPresenceObservation:(BOOL)shouldObserverPresence {
    
    [informationView dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
    [self.subscribeHelper addChannel:channel withState:channelState andPresenceObservation:shouldObserverPresence];
    
    // CHecking whether provided channel has been added or not.
    if (![[self.subscribeHelper channelsForSubscription] containsObject:channel]) {
        
        PNAlertView *alertView = [PNAlertView viewWithTitle:@"subscribeAlertViewTitle" type:PNAlertSuccess
                                               shortMessage:@"subscribeSuccessAlertViewShortDescription"
                                            detailedMessage:[NSString stringWithFormat:[@"subscribeSuccessAlertViewDetailedDescription" localized],
                                                             channel.name]
                                          cancelButtonTitle:nil otherButtonTitles:nil
                                      andEventHandlingBlock:^(PNAlertView *view, NSUInteger buttonIndex) {
                                          
                                              [self.subscribeHelper reset];
                                              [self updateLayout];
                                          }];
        [alertView show];
    }
    else {
        
        [self.channelsList reloadData];
        [self updateLayout];
    }
}


#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.subscribeHelper channelsForSubscription] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"channelCellIdentifier";
    PNChannelCell *cell = (PNChannelCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        
        cell = [[PNChannelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.showBadge = NO;
    }
    [cell updateForChannel:[[self.subscribeHelper channelsForSubscription] objectAtIndex:indexPath.row]];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    PNChannel *channel = [[self.subscribeHelper channelsForSubscription] objectAtIndex:indexPath.row];
    if (channel) {
        
        NSDictionary *channelState = [self.subscribeHelper stateForChannel:channel];
        
        PNChannelInformationView *information = [PNChannelInformationView viewFromNib];
        [information configureForChannel:channel withState:channelState
                  andPresenceObservation:[self.subscribeHelper shouldObserverPresenceForChannel:channel]];
        information.delegate = self;
        information.allowEditing = NO;
        [information showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        PNChannel *channel = [[self.subscribeHelper channelsForSubscription] objectAtIndex:indexPath.row];
        if (channel) {
            
            [self.subscribeHelper removeChannel:channel];
            [self updateLayout];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark -


@end
