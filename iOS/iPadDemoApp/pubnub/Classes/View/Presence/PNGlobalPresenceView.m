//
//  PNGlobalPresenceView.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/2/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNGlobalPresenceView.h"
#import "NSString+PNLocalization.h"
#import "PNGlobalPresenceHelper.h"
#import "PNClientStateView.h"
#import "UIView+PNAddition.h"
#import "PNParticipantCell.h"
#import "PNChannelCell.h"
#import "PNAlertView.h"
#import "PNButton.h"


#pragma mark Static

static NSTimeInterval const kPNViewAppearAnimationDuration = 0.4f;
static NSTimeInterval const kPNViewDisappearAnimationDuration = 0.2f;


#pragma mark - Private interface declaration

@interface PNGlobalPresenceView () <UITableViewDelegate, UITableViewDataSource>


#pragma mark - Properties

/**
 Stores reference on table which should display list of channels which is active at this moment on user subscription key.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *channelsList;

/**
 Stores reference on label which is used to layout number of participants (overall).
 */
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *participantsCountLabel;

/**
 Stores reference on table which should display concrete channel's participants.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *participantsList;

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
 Stores reference on helper which will manage all required steps to handle and perform request.
 */
@property (nonatomic, strong) IBOutlet PNGlobalPresenceHelper *presenceHelper;


#pragma mark - Instance methods

- (void)updateLayout;


#pragma mark - Handler methods

- (IBAction)handleRequestPresenceButtonTap:(id)sender;
- (IBAction)handleChannelParticipantIdentifiersSwitchChange:(id)sender;
- (IBAction)handleCloseButtonTap:(id)sender;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNGlobalPresenceView


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];
    
    [self updateLayout];
}

- (void)updateLayout {
    
    self.participantStateSwitch.enabled = self.participantIdentifiersSwitch.isOn;
    if (!self.participantStateSwitch.isEnabled && self.participantStateSwitch.isOn) {
        
        [self.participantStateSwitch setOn:NO animated:YES];
    }
    
    self.participantsCountLabel.text = [NSString stringWithFormat:@"%d", (unsigned int)self.presenceHelper.numberOfParticipants];
}

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNViewAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNViewDisappearAnimationDuration;
}


#pragma mark - Handler methods

- (IBAction)handleRequestPresenceButtonTap:(id)sender {
    
    [self.presenceHelper reset];
    [self.channelsList reloadData];
    [self.participantsList reloadData];
    [self updateLayout];
    
    self.presenceHelper.fetchParticipantNames = self.participantIdentifiersSwitch.isOn;
    self.presenceHelper.fetchParticipantState = self.participantStateSwitch.isOn;
    
    PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
    [progressAlertView show];
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [self.presenceHelper fetchPresenceInformationWithBlock:^(NSArray *participants, PNChannel *channel, PNError *requestError) {
        
        [progressAlertView dismissWithAnimation:YES];
        
        PNAlertType type = (requestError ? PNAlertWarning : PNAlertSuccess);
        NSString *shortMessage = (requestError ? @"presenceFailureShortDescription" :
                                                 @"presenceSuccessShortDescription");
        NSString *detailedMessage = @"presenceSuccessDetailedDescription";
        if (requestError) {
            
            detailedMessage = [NSString stringWithFormat:[@"presenceFailureDetailedDescription" localized],
                               requestError.localizedFailureReason];
        }
        
        PNAlertView *view = [PNAlertView viewWithTitle:@"presenceAlertViewTitle" type:type shortMessage:shortMessage
                                       detailedMessage:detailedMessage cancelButtonTitle:@"confirmButtonTitle"
                                     otherButtonTitles:nil andEventHandlingBlock:nil];
        [view show];
        
        [weakSelf.channelsList reloadData];
        [weakSelf.participantsList reloadData];
        [weakSelf updateLayout];
    }];
}

- (IBAction)handleChannelParticipantIdentifiersSwitchChange:(id)sender {
    
    [self updateLayout];
}

- (IBAction)handleCloseButtonTap:(id)sender {
    
    [self dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
}


#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRowsInSection = 0;
    if ([tableView isEqual:self.channelsList]) {
        
        numberOfRowsInSection = [[self.presenceHelper channels] count];
    }
    else {
        
        numberOfRowsInSection = [[self.presenceHelper participants] count];
    }
    
    
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *channelCellIdentifier = @"channelCellIdentifier";
    static NSString *participantCellIdentifier = @"participantCellIdentifier";
    NSString *targetCellIdentifier = channelCellIdentifier;
    Class cellClass = [PNChannelCell class];
    if ([tableView isEqual:self.participantsList]) {
        
        targetCellIdentifier = participantCellIdentifier;
        cellClass = [PNParticipantCell class];
    }
    
    id cell = [tableView dequeueReusableCellWithIdentifier:nil];
    if (!cell) {
        
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:targetCellIdentifier];
        if ([targetCellIdentifier isEqualToString:channelCellIdentifier]) {
            
            ((PNChannelCell *)cell).showBadge = NO;
        }
    }
    if ([targetCellIdentifier isEqualToString:channelCellIdentifier]) {
        
        PNChannel *channel = [[self.presenceHelper channels] objectAtIndex:indexPath.row];
        [(PNChannelCell *)cell updateForChannel:channel];
        if ([channel isEqual:self.presenceHelper.currentChannel]) {
            
            ((PNChannelCell *)cell).accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            
            ((PNChannelCell *)cell).accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else {
        
        PNClient *client = [[self.presenceHelper participants] objectAtIndex:indexPath.row];
        [(PNParticipantCell *)cell updateForParticipant:client];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([tableView isEqual:self.participantsList]) {
        
        
        PNClient *client = [[self.presenceHelper participants] objectAtIndex:indexPath.row];
        
        if (![client isAnonymous]) {
            
            PNClientStateView *clientStateView = [PNClientStateView viewFromNibForViewing];
            [clientStateView configureFor:[self.presenceHelper currentChannel] clientIdentifier:client.identifier andState:client.data];
            [clientStateView showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
        }
    }
    else {
        
        PNChannel *channel = [[self.presenceHelper channels] objectAtIndex:indexPath.row];
        
        if ([self.presenceHelper.currentChannel isEqual:channel]) {
            
            self.presenceHelper.currentChannel = nil;
        }
        else {
            
            self.presenceHelper.currentChannel = channel;
        }
        
        [self.channelsList reloadData];
        [self.participantsList reloadData];
        [self updateLayout];
    }
}


#pragma mark -


@end
