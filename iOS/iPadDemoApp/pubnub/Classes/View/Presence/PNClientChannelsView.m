//
//  PNClientChannelsView.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/2/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNClientChannelsView.h"
#import "NSString+PNLocalization.h"
#import "PNClientChannelsHelper.h"
#import "PNClientStateView.h"
#import "UIView+PNAddition.h"
#import "PNChannelCell.h"
#import "PNAlertView.h"
#import "PNButton.h"


#pragma mark Static

static NSTimeInterval const kPNViewAppearAnimationDuration = 0.4f;
static NSTimeInterval const kPNViewDisappearAnimationDuration = 0.2f;


#pragma mark - Private interface declaration

@interface PNClientChannelsView () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>


#pragma mark - Properties

/**
 Stores reference on table which is used to layout list of channels on which client subscribed at this moment.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *channelsList;

/**
 Stores reference on text field which is used for client identifier input.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *clientIdentifier;

@property (nonatomic, pn_desired_weak) IBOutlet PNButton *requestButton;

@property (nonatomic, strong) IBOutlet PNClientChannelsHelper *clientChannelsHelper;


#pragma mark - Instance methods

- (void)prepareData;
- (void)prepareLayout;
- (void)updateLayout;


#pragma mark - Handler methods

- (IBAction)handleRequestButtonTap:(id)sender;
- (IBAction)handleCloseButtonTap:(id)sender;

#pragma mark -


@end



#pragma mark - Public interface implementation

@implementation PNClientChannelsView


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];

    [self prepareData];
    [self prepareLayout];
}

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNViewAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNViewDisappearAnimationDuration;
}

- (void)prepareData {
    
    self.clientChannelsHelper.clientIdentifier = [PubNub clientIdentifier];
}

- (void)prepareLayout {
    
    self.clientIdentifier.text = self.clientChannelsHelper.clientIdentifier;
    
    [self updateLayout];
}

- (void)updateLayout {
    
    self.requestButton.enabled = [self.clientChannelsHelper isAbleToProcessRequest];
}


#pragma mark - Handler methods

- (IBAction)handleRequestButtonTap:(id)sender {
    
    [self completeUserInput];
    PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
    [progressAlertView show];
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [self.clientChannelsHelper performRequestWithBlock:^(NSString *clientIdentifier, NSArray *channels, PNError *requestError) {
        
        [progressAlertView dismissWithAnimation:YES];
        
        PNAlertType type = (requestError ? PNAlertWarning : PNAlertSuccess);
        NSString *shortMessage = (requestError ? @"clientChannelsFailureAlertViewShortDescription" :
                                                 @"clientChannelsSuccessAlertViewShortDescription");
        NSString *detailedMessage = [NSString stringWithFormat:[@"clientChannelsSuccessAlertViewDetailedDescription" localized],
                                     weakSelf.clientChannelsHelper.clientIdentifier];
        if (!requestError) {
            
            detailedMessage = [NSString stringWithFormat:[@"clientChannelsFailureAlertViewDetailedDescription" localized],
                               weakSelf.clientChannelsHelper.clientIdentifier, requestError.localizedFailureReason];
        }
        
        PNAlertView *view = [PNAlertView viewWithTitle:@"clientChannelsAlertViewTitle" type:type shortMessage:shortMessage
                                       detailedMessage:detailedMessage cancelButtonTitle:@"confirmButtonTitle"
                                     otherButtonTitles:nil andEventHandlingBlock:nil];
        [view show];
        [weakSelf.channelsList reloadData];
        [weakSelf updateLayout];
    }];
}

- (IBAction)handleCloseButtonTap:(id)sender {
  
    [self dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
}


#pragma mark - UITextField delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    self.clientChannelsHelper.clientIdentifier = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self updateLayout];
    
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self completeUserInput];
    
    return YES;
}


#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.clientChannelsHelper channels] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"channelCellIdentifier";
    PNChannelCell *cell = (PNChannelCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        
        cell = [[PNChannelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.showBadge = NO;
    }
    PNChannel *channel = [[self.clientChannelsHelper channels] objectAtIndex:indexPath.row];
    [cell updateForChannel:channel];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PNChannel *channel = [[self.clientChannelsHelper channels] objectAtIndex:indexPath.row];
    
    PNClientStateView *stateView = [PNClientStateView viewFromNibForViewing];
    [stateView configureFor:channel clientIdentifier:self.clientChannelsHelper.clientIdentifier andState:nil];
    [stateView showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
}

#pragma mark -


@end
