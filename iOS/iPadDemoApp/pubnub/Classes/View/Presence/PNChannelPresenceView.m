//
//  PNChannelPresenceView.m
//  pubnub
//
//  Created by Sergey Mamontov on 3/25/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelPresenceView.h"
#import "NSString+PNLocalization.h"
#import "NSObject+PNAddition.h"
#import "UIView+PNAddition.h"
#import "PNParticipantCell.h"
#import "PNPresenceHelper.h"
#import "PNObjectCell.h"
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
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *objectNameTextField;

/**
 @brief Reference on field which will hold channel group namespace name and allow to change it (in case if not 
 subscribed on it).
 
 @since 3.6.8
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *objectNamespaceTextField;

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
 Stores reference on table which will show list of channels.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *channelsList;

/**
 Stores reference on text view which will show user state for selected participant (if has been provided).
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextView *participantState;

@property (nonatomic, strong) NSString *objectName;
@property (nonatomic, strong) NSString *objectNamespace;

/**
 @brief Stores whether view has been loaded for channel group presence information and change
 
 @since 3.6.8
 */
@property (nonatomic, assign, getter = isChannelGroupPresenceInformation) BOOL channelGroupPresenceInformation;


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


#pragma mark - Class methods

+ (instancetype)viewFromNibForChannelGroup {
    
    // Swap method which should provide name for NIB file.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForChannelGroup)];
    
    PNChannelPresenceView *view = [self viewFromNib];
    view.channelGroupPresenceInformation = YES;
    
    // Swap method implementation back to restore original.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForChannelGroup)];
    
    
    return view;
}

+ (NSString *)viewNibNameForChannelGroup {
    
    return @"PNChannelGroupPresenceView";
}


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
    BOOL rquestButtonEnabled = ([self.objectName length] > 0);
    if (self.isChannelGroupPresenceInformation) {
        
        rquestButtonEnabled = ([self.objectName length] > 0 && [self.objectNamespace length] > 0);
    }
    self.requestButton.enabled = rquestButtonEnabled;
    self.participantsCountLabel.text = [NSString stringWithFormat:@"%d",
                                        (unsigned int)[self.presenceHelper numberOfParticipants]];
}

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNViewAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNViewDisappearAnimationDuration;
}

- (void)configureForObject:(id <PNChannelProtocol>)object {
    
    self.objectName = object.name;
    self.objectNameTextField.text = self.objectName;
    if (self.isChannelGroupPresenceInformation) {
        
        self.objectNamespace = ((PNChannelGroup *)object).nspace;
        self.objectNamespaceTextField.text = self.objectNamespace;
    }
    [self updateLayout];
}


#pragma mark - Handler methods

- (IBAction)handleRequestPaerticipantsButtonTap:(id)sender {
    
    [self.presenceHelper reset];
    [self.channelsList reloadData];
    [self.participantsList reloadData];
    [self completeUserInput];
    
    [self.presenceHelper configureForObject:self.objectName namespace:self.objectNamespace clientIdentifier:nil
                               channelGroup:self.isChannelGroupPresenceInformation
                           fetchIdentifiers:self.participantIdentifiersSwitch.isOn
                                 fetchState:self.participantStateSwitch.isOn];
    
    PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
    [progressAlertView show];
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [self.presenceHelper fetchPresenceInformationWithBlock:^(PNHereNow *presenceInformation, NSArray *channels, PNError *requestError) {
        
        [progressAlertView dismissWithAnimation:YES];
        PNAlertType type = (requestError ? PNAlertWarning : PNAlertSuccess);
        NSString *shortDescription = @"channelPresenceSuccessShortDescription";
        NSString *detailedDescription = nil;
        
        if (!requestError) {
            
            [weakSelf.participantsList reloadData];
            if (self.isChannelGroupPresenceInformation) {
                
                [weakSelf.channelsList reloadData];
            }
            [weakSelf updateLayout];
            
            detailedDescription = [NSString stringWithFormat:[@"channelPresenceSuccessDetailedDescription" localized],
                                   [channels valueForKey:@"name"]];
        }
        else {
            
            shortDescription = @"channelPresenceFailureShortDescription";
            
            PNChannel *channel = nil;
            switch (requestError.code) {
                case kPNAPIUnauthorizedAccessError:
                case kPNAPIAccessForbiddenError:
                case kPNAPINotAvailableOrNotEnabledError:
                    
                    channel = [requestError.associatedObject lastObject];
                    break;
                    
                default:
                    channel = requestError.associatedObject;
                    break;
            }
            detailedDescription = [NSString stringWithFormat:[@"channelPresenceFailureDetailedDescription" localized],
                                   channel.name, requestError.localizedFailureReason];
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
    fullString = [[fullString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([textField isEqual:self.objectNameTextField]) {
        
        self.objectName = fullString;
    }
    else {
        
        self.objectNamespace = fullString;
    }
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
    
    NSInteger numberOfRowsInSection = 0;
    if ([tableView isEqual:self.participantsList]) {
        
        numberOfRowsInSection = [[self.presenceHelper participants] count];
    }
    else {
        
        numberOfRowsInSection = [[self.presenceHelper channels] count];
    }
    
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *channelCellIdentifier = @"participantIdentifier";
    static NSString *participantCellIdentifier = @"participantCellIdentifier";
    NSString *targetCellIdentifier = channelCellIdentifier;
    Class cellClass = [PNObjectCell class];
    if ([tableView isEqual:self.participantsList]) {
        
        targetCellIdentifier = participantCellIdentifier;
        cellClass = [PNParticipantCell class];
    }
    id cell = [tableView dequeueReusableCellWithIdentifier:targetCellIdentifier];
    if (!cell) {
        
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:targetCellIdentifier];
        if ([targetCellIdentifier isEqualToString:channelCellIdentifier]) {
            
            ((PNObjectCell *)cell).showBadge = NO;
        }
    }
    if ([targetCellIdentifier isEqualToString:channelCellIdentifier]) {
        
        PNChannel *channel = [[self.presenceHelper channels] objectAtIndex:indexPath.row];
        [(PNObjectCell *)cell updateForObject:channel];
        if ([channel isEqual:self.presenceHelper.currentChannel]) {
            
            ((PNObjectCell *)cell).accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            
            ((PNObjectCell *)cell).accessoryType = UITableViewCellAccessoryNone;
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
        NSString *state = nil;
        if ([client stateForChannel:client.channel]) {
            
            NSError *stateSerializationError = nil;
            NSData *serializedStateData = [NSJSONSerialization dataWithJSONObject:[client stateForChannel:client.channel]
                                                                          options:NSJSONWritingPrettyPrinted
                                                                            error:&stateSerializationError];
            if (!stateSerializationError && serializedStateData) {
                
                state = [[NSString alloc] initWithData:serializedStateData encoding:NSUTF8StringEncoding];
            }
        }
        
        self.participantState.text = state;
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
