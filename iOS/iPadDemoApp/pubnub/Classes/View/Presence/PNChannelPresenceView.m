//
//  PNChannelPresenceView.m
//  pubnub
//
//  Created by Sergey Mamontov on 3/25/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelPresenceView.h"
#import "NSString+PNLocalization.h"
#import "UIView+PNAddition.h"
#import "PNParticipantCell.h"
#import "PNPresenceHelper.h"
#import "PNAlertView.h"
#import "PNButton.h"


#pragma mark Static

static NSTimeInterval const kPNViewAppearAnimationDuration = 0.4f;
static NSTimeInterval const kPNViewDisappearAnimationDuration = 0.2f;


#pragma mark - Private interface declaration

@interface PNChannelPresenceView () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>


#pragma mark - Properties

@property (nonatomic, strong) IBOutlet PNPresenceHelper *presenceHelper;

/**
 Stores reference on button which allow user to request list of participants for specified channel.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *requestButton;

/**
 Stores reference on text field which allow user to input name of the channel for which presence information should
 be processed.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *channelNameTextField;

/**
 Stores reference on label which will show how many people subscribed on channel.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *participantsCountLabel;

/**
 Stores reference on switch which allow to specify whether request should fetch only number of participants or
 their identifiers as well.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *participantIdentifiersSwitch;

/**
 Stores reference on switch which allow to specify whether request should fetch client state information or not.
 
 @note This switch work only if user specified that he would like to receive participant identifiers.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *participantStateSwitch;

/**
 Stores reference on table which will show list of participants.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *participantsList;

/**
 Stores reference on text view which will show user state for selected participant (if has been provided).
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextView *participantState;

@property (nonatomic, strong) NSString *channelName;


#pragma mark - Instance methods

- (void)updateLayout;


#pragma mark - Handler methods

- (IBAction)handleRequestPaerticipantsButtonTap:(id)sender;
- (IBAction)handleChannelParticipantIdentifiersSwitchChange:(id)sender;
- (IBAction)handleCloseButtonTap:(id)sender;

#pragma mark -


@end


#pragma mark - Public interface declaration

@implementation PNChannelPresenceView


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward methods call to the super class.
    [super awakeFromNib];

    [self updateLayout];
}

- (void)updateLayout {
    
    self.participantStateSwitch.enabled = self.participantIdentifiersSwitch.isOn;
    if (!self.participantStateSwitch.isEnabled && self.participantStateSwitch.isOn) {
        
        [self.participantStateSwitch setOn:NO animated:YES];
    }
    self.requestButton.enabled = [self.channelName length] > 0;
    self.participantsCountLabel.text = [NSString stringWithFormat:@"%d", [[self.presenceHelper data] count]];
}

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNViewAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNViewDisappearAnimationDuration;
}

- (void)configureForChannel:(PNChannel *)channel {
    
    self.channelName = channel.name;
    self.channelNameTextField.text = self.channelName;
    [self updateLayout];
}


#pragma mark - Handler methods

- (IBAction)handleRequestPaerticipantsButtonTap:(id)sender {
    
    [self completeUserInput];
    [self.presenceHelper configureForChannel:self.channelName clientIdentifier:nil
                            fetchIdentifiers:self.participantIdentifiersSwitch.isOn
                                  fetchState:self.participantStateSwitch.isOn];
    
    PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
    [progressAlertView show];
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [self.presenceHelper fetchPresenceInformationWithBlock:^(NSArray *participants, PNChannel *channel, PNError *requestError) {
        
        [progressAlertView dismissWithAnimation:YES];
        PNAlertType type = (requestError ? PNAlertWarning : PNAlertSuccess);
        NSString *shortDescription = @"channelPresenceSuccessShortDescription";
        NSString *detailedDescription = nil;
        
        if (!requestError) {
            
            weakSelf.participantsCountLabel.text = [NSString stringWithFormat:@"%d", [[weakSelf.presenceHelper data] count]];
            [weakSelf.participantsList reloadData];
            [weakSelf updateLayout];
            
            detailedDescription = [NSString stringWithFormat:[@"channelPresenceSuccessDetailedDescription" localized],
                                   ((PNChannel *)requestError.associatedObject).name];
        }
        else {
            
            shortDescription = @"channelPresenceFailureShortDescription";
            
            detailedDescription = [NSString stringWithFormat:[@"channelPresenceFailureDetailedDescription" localized],
                                   ((PNChannel *)requestError.associatedObject).name,
                                   requestError.localizedFailureReason];
        }
        
        PNAlertView *alertView = [PNAlertView viewWithTitle:@"channelPresenceAlertViewTitle" type:type
                                               shortMessage:shortDescription detailedMessage:detailedDescription
                                          cancelButtonTitle:nil otherButtonTitles:nil andEventHandlingBlock:NULL];
        [alertView show];
    }];
}

- (void)handleChannelParticipantIdentifiersSwitchChange:(id)sender {
  
    [self updateLayout];
}

- (IBAction)handleCloseButtonTap:(id)sender {
    
    [self dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
}


#pragma mark - UITextfield delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *fullString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.channelName = [[fullString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [self updateLayout];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self completeUserInput];
    [self updateLayout];
    
    return YES;
}


#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.presenceHelper data] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"participantIdentifier";
    PNParticipantCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        
        cell = [[PNParticipantCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell updateForParticipant:[[self.presenceHelper data] objectAtIndex:indexPath.row]];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PNClient *client = [[self.presenceHelper data] objectAtIndex:indexPath.row];
    NSString *state = nil;
    if (client.data) {
        
        NSError *stateSerializationError = nil;
        NSData *serializedStateData = [NSJSONSerialization dataWithJSONObject:client.data options:NSJSONWritingPrettyPrinted
                                                                        error:&stateSerializationError];
        if (!stateSerializationError && serializedStateData) {
            
            state = [[NSString alloc] initWithData:serializedStateData encoding:NSUTF8StringEncoding];
        }
    }
    
    self.participantState.text = state;
}

#pragma mark -


@end
