//
//  PNClientStateView.m
//  pubnub
//
//  Created by Sergey Mamontov on 3/28/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNClientStateView.h"
#import "NSString+PNLocalization.h"
#import "NSObject+PNAddition.h"
#import "PNClientStateHelper.h"
#import "UIView+PNAddition.h"
#import "PNObjectCell.h"
#import "PNAlertView.h"
#import "PNButton.h"


#pragma mark Static

static NSTimeInterval const kPNViewAppearAnimationDuration = 0.4f;
static NSTimeInterval const kPNViewDisappearAnimationDuration = 0.2f;


#pragma mark - Private interface declaration

@interface PNClientStateView () <UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>


#pragma mark - Properties

/**
 Stores reference on client identifier which has been specified through client configuration.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *clientIdentifierTextField;

/**
 Reference on the table which will show list of channels on which client subscribed at this moment.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *channelsList;

/**
 Stores reference on channel name which should be used for client's state retrieval.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *channelNameTextField;

/**
 Reference on text view which is used for client's state layout.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextView *clientStateTextView;

/**
 Reference on button which will allow to perform get / set client state action (depending on view mode).
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *actionButton;

/**
 Stores reference on client state manipulation helper.
 */
@property (nonatomic, strong) IBOutlet PNClientStateHelper *stateHelper;

/**
 Allow to specify whether view allow state edition or not.
 */
@property (nonatomic, assign, getter = isStateEditingAllowed) BOOL stateEditingAllowed;


#pragma mark - Instance methods

- (void)updateLayout;


#pragma mark - Handler methods

- (IBAction)handleActionButtonTap:(id)sender;
- (IBAction)handleCloseButtonTap:(id)sender;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNClientStateView


#pragma mark - Class methods

+ (instancetype)viewFromNibForViewing {
    
    // Swap method which should provide name for NIB file.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForViewing)];
    
    PNClientStateView *view = [self viewFromNib];
    
    // Swap method implementation back to restore original.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForViewing)];
    
    return view;
}

+ (instancetype)viewFromNibForEditing {
    
    // Swap method which should provide name for NIB file.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForEditing)];
    
    PNClientStateView *view = [self viewFromNib];
    view.stateEditingAllowed = YES;
    
    // Swap method implementation back to restore original.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForEditing)];
    
    
    return view;
}

+ (NSString *)viewNibNameForViewing {
    
    return @"PNClientStateGetView";
}

+ (NSString *)viewNibNameForEditing {
    
    return @"PNClientStateSetView";
}


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class
    [super awakeFromNib];

    [self updateLayout];
}

- (void)configureFor:(PNChannel *)channel clientIdentifier:(NSString *)clientIdentifier andState:(NSDictionary *)clientState {
    
    self.channelNameTextField.text = channel.name;
    self.clientIdentifierTextField.text = clientIdentifier;
    self.stateHelper.channelName = channel.name;
    self.stateHelper.clientIdentifier = clientIdentifier;
    self.stateHelper.state = clientState;
    
    [self updateLayout];
}

- (void)updateLayout {
    
    BOOL isValidDataProvided = [self.stateHelper isValidChannelNameAdnIdentifier];
    if (self.isStateEditingAllowed && isValidDataProvided) {
        
        isValidDataProvided = [self.stateHelper isValidClientState];
    }
    self.actionButton.enabled = isValidDataProvided;
    self.clientStateTextView.editable = self.isStateEditingAllowed;
    
    
    NSString *clientState = nil;
    if (self.stateHelper.state) {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.stateHelper.state options:NSJSONWritingPrettyPrinted error:NULL];
        if (jsonData) {
            
            clientState = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    self.clientStateTextView.text = clientState;
}

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNViewAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNViewDisappearAnimationDuration;
}

- (void)setStateEditingAllowed:(BOOL)stateEditingAllowed {
    
    BOOL isStateChanged = _stateEditingAllowed != stateEditingAllowed;
    _stateEditingAllowed = stateEditingAllowed;
    self.stateHelper.stateEditingAllowed = stateEditingAllowed;
    
    if (isStateChanged) {
        
        [self updateLayout];
    }
}


#pragma mark - Handler methods

- (IBAction)handleActionButtonTap:(id)sender {
    
    [self completeUserInput];
    
    
    // Checking whether valid client state has been provided or not.
    if ([self.stateHelper isValidClientState] || !self.isStateEditingAllowed) {
    
        PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
        [progressAlertView show];
        
        __block __pn_desired_weak __typeof(self) weakSelf = self;
        [self.stateHelper performRequestWithBlock:^(PNClient *client, PNError *requestError) {
            
            [progressAlertView dismissWithAnimation:YES];
            
            PNAlertType type = (requestError ? PNAlertWarning : PNAlertSuccess);
            NSString *title = (self.isStateEditingAllowed ? @"stateUpdateAlertViewTitle" : @"stateRetrieveAlertViewTitle");
            NSString *shortDescription = nil;
            NSString *detailedDescription = nil;
            
            if (!requestError) {
                
                [weakSelf updateLayout];
                if (self.isStateEditingAllowed) {
                    
                    shortDescription = @"stateUpdateSuccessAlertViewShortDescription";
                    detailedDescription = [NSString stringWithFormat:[@"stateUpdateSuccessAlertViewDetailedDescription" localized],
                                           client.identifier, client.channel.name];
                }
                else {
                    
                    shortDescription = @"stateRetrieveSuccessAlertViewShortDescription";
                    detailedDescription = [NSString stringWithFormat:[@"stateRetrieveSuccessAlertViewDetailedDescription" localized],
                                           client.identifier, client.channel.name];
                }
            }
            else {
                
                if (self.isStateEditingAllowed) {
                    
                    shortDescription = @"stateUpdateFailureAlertViewShortDescription";
                    detailedDescription = [NSString stringWithFormat:[@"stateUpdateFailureAlertViewDetailedDescription" localized],
                                           client.identifier, client.channel.name, requestError.localizedFailureReason];
                }
                else {
                    
                    shortDescription = @"stateRetrieveFailureAlertViewShortDescription";
                    detailedDescription = [NSString stringWithFormat:[@"stateRetrieveFailureAlertViewDetailedDescription" localized],
                                           client.identifier, client.channel.name, requestError.localizedFailureReason];
                }
            }
                
            PNAlertView *alert = [PNAlertView viewWithTitle:title type:type shortMessage:shortDescription
                                            detailedMessage:detailedDescription cancelButtonTitle:@"confirmButtonTitle"
                                          otherButtonTitles:nil andEventHandlingBlock:NULL];
            [alert show];
        }];
    }
    else {
        
        [self.stateHelper resetWarnings];
        [self updateLayout];
        PNAlertView *alert = [PNAlertView viewWithTitle:@"malformedClientStateAlertViewTitle"
                                                   type:PNAlertWarning
                                           shortMessage:@"malformedClientStateAlertViewShortDescription"
                                        detailedMessage:@"malformedClientStateAlertViewDetailedDescription"
                                      cancelButtonTitle:[@"confirmButtonTitle" localized] otherButtonTitles:nil
                                  andEventHandlingBlock:NULL];
        [alert show];
    }
}

- (IBAction)handleCloseButtonTap:(id)sender {
    
    [self dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
}


#pragma mark - Helper delegate methods

- (void)clientStateDidChange {
    
    [self updateLayout];
}

- (void)handleUserInputCompleted {
    
    [self completeUserInput];
}


#pragma mark - UITextView delegate methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    self.stateHelper.editingState = YES;
    BOOL shouldHandleByDefault = YES;
    if ([text length] == 1) {
        
        if ([text isEqualToString:@"{"] || [text isEqualToString:@"\""]) {
            
            NSRange caretPosition = NSMakeRange(range.location, 0);
            NSMutableString *finalString = [NSMutableString stringWithString:text];
            
            shouldHandleByDefault = NO;
            caretPosition.location = caretPosition.location + 1;
            [finalString appendString:([text isEqualToString:@"{"] ? @"}" : @"\"")];
            textView.text = [textView.text stringByReplacingCharactersInRange:range withString:finalString];
            textView.selectedRange = caretPosition;
        }
    }
    
    
    return shouldHandleByDefault;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    [self completeUserInput];
    
    self.stateHelper.state = textView.text;
    self.stateHelper.editingState = NO;
    [self updateLayout];
}


#pragma mark - UITextField delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *targetText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:self.channelNameTextField]) {
        
        self.stateHelper.channelName = targetText;
    }
    else {
        
        self.stateHelper.clientIdentifier = targetText;
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
    
    return [[self.stateHelper existingChannels] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *channelCellIdentifier = @"channelCellIdentifier";
    PNObjectCell *cell = [tableView dequeueReusableCellWithIdentifier:channelCellIdentifier];
    if (!cell) {
        
        cell = [[PNObjectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:channelCellIdentifier];
        cell.showBadge = NO;
    }
    PNChannel *channel = [[self.stateHelper existingChannels] objectAtIndex:indexPath.row];
    [cell updateForObject:channel];
    
    if (self.isStateEditingAllowed) {
        
        if ([self.stateHelper.channelName isEqualToString:channel.name]) {
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PNChannel *channel = [[self.stateHelper existingChannels] objectAtIndex:indexPath.row];
    PNObjectCell *cell = (PNObjectCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (self.stateHelper.channelName && ![self.stateHelper.channelName isEqualToString:channel.name]) {
        
        self.stateHelper.state = nil;
    }
    
    if (self.isStateEditingAllowed) {
        
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            
            self.stateHelper.channelName = channel.name;
        }
        else {
            
            self.stateHelper.channelName = nil;
        }
        self.stateHelper.state = self.clientStateTextView.text;
    }
    else {
        
        self.stateHelper.channelName = channel.name;
        self.channelNameTextField.text = channel.name;
    }
    [self.channelsList reloadData];
    [self updateLayout];
}

#pragma mark -


@end
