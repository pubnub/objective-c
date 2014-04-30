//
//  PNAccessRightsView.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/6/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNAccessRightsView.h"
#import "PNAccessRightsInformationCell.h"
#import "PNClientIdentifierAddDelegate.h"
#import "PNChannelInformationDelegate.h"
#import "PNClientIdentifierAddView.h"
#import "PNChannelInformationView.h"
#import "NSString+PNLocalization.h"
#import "PNAccessRightsHelper.h"
#import "NSObject+PNAddition.h"
#import "UIView+PNAddition.h"
#import "PNChannelCell.h"
#import "PNTableView.h"
#import "PNAlertView.h"
#import "PNButton.h"


#pragma mark Static

static NSTimeInterval const kPNViewAppearAnimationDuration = 0.4f;
static NSTimeInterval const kPNViewDisappearAnimationDuration = 0.2f;


#pragma mark - Private interface declaration

@interface PNAccessRightsView () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource,
                                  UIPickerViewDelegate, UIPopoverControllerDelegate, UITextFieldDelegate,
                                  PNChannelInformationDelegate, PNClientIdentifierAddDelegate>


#pragma mark - Properties

/**
 Stores reference on view header title label.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *headerLabel;

/**
 Stores reference on label which is used to describe process.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *accessRightsProcessDescriptionLabel;

/**
 Stores reference on action button which can be used by user to modify access rights.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *actionButton;

/**
 Stores reference on view which show user provided data.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UIView *userProvidedDataView;
@property (nonatomic, pn_desired_weak) IBOutlet UIView *additionalUserProvidedDataView;

/**
 Stores reference on table which will show list of access rights informatino entries.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNTableView *accessRightsList;

/**
 Stores reference on table which will show list of channels with which helper is able to operate.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNTableView *channelsList;

/**
 Stores reference on table which will show list of user provided data.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNTableView *userProvidedDataList;

/**
 Stores reference on view which provide ability to manipulate target object access rights.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UIView *accessRightsManipulationView;

/**
 Stores reference on switches which allow to change read / write access right state.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *readRightsSwitch;
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *writeRightsSwitch;

/**
 Stores reference on text field which will accept name of the channel for which user access rights manipulation should
 be performed.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *channelNameInputTextField;

/**
 Stores reference on text field which will accept input for maximum access rights application duration.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *accessRightsApplicationDuration;

/**
 Stores reference on view which show informatino about access rights.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UIView *accessRightsInformationView;

/**
 Stores reference on helper which will handle and process all user input and requests.
 */
@property (nonatomic, strong) IBOutlet PNAccessRightsHelper *accessRightsHelper;

/**
 Stores reference on popover view which hold required content.
 */
@property (nonatomic, strong) UIPopoverController *pickerPopoverController;

/**
 Stores whether initial interface layout has been performed or not.
 */
@property (nonatomic, assign, getter = isLayoutPrepared) BOOL layoutPrepared;


#pragma mark - Instance methods

- (void)prepareLayout;
- (void)updateLayout;
- (void)updateLayoutForAccessRightsInformation:(PNAccessRightsInformation *)information;

/**
 Prepare and show popover which will show picker for access rights duration.
 */
- (void)showPopover;


#pragma mark - Handler methods

- (IBAction)handleDataAdditionButtonTap:(id)sender;
- (IBAction)handleActionButtonTap:(id)sender;
- (IBAction)handleCloseButtonTap:(id)sender;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNAccessRightsView


#pragma mark - Class methods

+ (instancetype)viewFrromNibForAccessRightsInformation:(PNAccessRightsInformation *)information {
    
    PNAccessRightsView *view = nil;
    switch (information.level) {
        case PNApplicationAccessRightsLevel:
            
            view = [self viewFromNibForApplicationGrant];
            break;
        case PNChannelAccessRightsLevel:
            
            view = [self viewFromNibForChannelGrant];
            break;
        case PNUserAccessRightsLevel:
            
            view = [self viewFromNibForUserGrant];
            break;
    }
    [view updateLayoutForAccessRightsInformation:information];
    
    
    return view;
}

+ (instancetype)viewFromNibForApplicationAudit {
    
    __block PNAccessRightsView *view = nil;
    [self temporarilySwizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForApplication)
              duringBlockExecution:^{
                  
                  view = [self viewFromNib];
                  [view.accessRightsHelper configureForMode:PNAccessRightsHelperApplicationMode
                                    forAccessRightsAudition:YES orAccessRightsRevoke:NO];
                  [view updateLayout];
              }];
    
    
    return view;
}

+ (instancetype)viewFromNibForApplicationGrant {
    
    __block PNAccessRightsView *view = nil;
    [self temporarilySwizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForApplication)
              duringBlockExecution:^{
                  
                  view = [self viewFromNib];
                  [view.accessRightsHelper configureForMode:PNAccessRightsHelperApplicationMode
                                    forAccessRightsAudition:NO orAccessRightsRevoke:NO];
                  [view updateLayout];
              }];
    
    
    return view;
}

+ (instancetype)viewFromNibForApplicationRevoke {
    
    __block PNAccessRightsView *view = nil;
    [self temporarilySwizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForApplication)
              duringBlockExecution:^{
                  
                  view = [self viewFromNib];
                  [view.accessRightsHelper configureForMode:PNAccessRightsHelperApplicationMode
                                    forAccessRightsAudition:NO orAccessRightsRevoke:YES];
                  [view updateLayout];
              }];
    
    
    return view;
}

+ (instancetype)viewFromNibForChannelAudit {
    
    __block PNAccessRightsView *view = nil;
    [self temporarilySwizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForChannel)
              duringBlockExecution:^{
                  
                  view = [self viewFromNib];
                  [view.accessRightsHelper configureForMode:PNAccessRightsHelperChannelMode
                                    forAccessRightsAudition:YES orAccessRightsRevoke:NO];
                  [view updateLayout];
              }];
    
    
    return view;
}

+ (instancetype)viewFromNibForChannelGrant {
    
    __block PNAccessRightsView *view = nil;
    [self temporarilySwizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForChannel)
              duringBlockExecution:^{
                  
                  view = [self viewFromNib];
                  [view.accessRightsHelper configureForMode:PNAccessRightsHelperChannelMode
                                    forAccessRightsAudition:NO orAccessRightsRevoke:NO];
                  [view updateLayout];
              }];
    
    
    return view;
}

+ (instancetype)viewFromNibForChannelRevoke {
    
    __block PNAccessRightsView *view = nil;
    [self temporarilySwizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForChannel)
              duringBlockExecution:^{
                  
                  view = [self viewFromNib];
                  [view.accessRightsHelper configureForMode:PNAccessRightsHelperChannelMode
                                    forAccessRightsAudition:NO orAccessRightsRevoke:YES];
                  [view updateLayout];
              }];
    
    
    return view;
}

+ (instancetype)viewFromNibForUserAudit {
    
    __block PNAccessRightsView *view = nil;
    [self temporarilySwizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForUser)
              duringBlockExecution:^{
                  
                  view = [self viewFromNib];
                  [view.accessRightsHelper configureForMode:PNAccessRightsHelperUserMode
                                    forAccessRightsAudition:YES orAccessRightsRevoke:NO];
                  [view updateLayout];
              }];
    
    
    return view;
}

+ (instancetype)viewFromNibForUserGrant {
    
    __block PNAccessRightsView *view = nil;
    [self temporarilySwizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForUser)
              duringBlockExecution:^{
                  
                  view = [self viewFromNib];
                  [view.accessRightsHelper configureForMode:PNAccessRightsHelperUserMode
                                    forAccessRightsAudition:NO orAccessRightsRevoke:NO];
                  [view updateLayout];
              }];
    
    
    return view;
}

+ (instancetype)viewFromNibForUserRevoke {
    
    __block PNAccessRightsView *view = nil;
    [self temporarilySwizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForUser)
              duringBlockExecution:^{
                  
                  view = [self viewFromNib];
                  [view.accessRightsHelper configureForMode:PNAccessRightsHelperUserMode
                                    forAccessRightsAudition:NO orAccessRightsRevoke:YES];
                  [view updateLayout];
              }];
    
    
    return view;
}

+ (NSString *)viewNibNameForApplication {
    
    return @"PNApplicationAccessRightsView";
}

+ (NSString *)viewNibNameForChannel {
    
    return @"PNChannelAccessRightsView";
}

+ (NSString *)viewNibNameForUser {
    
    return @"PNUserAccessRightsView";
}


#pragma mark - Instance methods

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNViewAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNViewDisappearAnimationDuration;
}

- (void)prepareLayout {
    
    NSString *action = ([self.accessRightsHelper isAuditingAccessRights] ? @"Audit" : @"Grant");
    if ([self.accessRightsHelper isRevokingAccessRights]) {
        
        action = @"Revoke";
    }
    
    self.headerLabel.text = [NSString stringWithFormat:self.headerLabel.text, action];
    [self.actionButton setTitle:action forState:UIControlStateNormal];
    
    NSString *processDescription = nil;
    switch (self.accessRightsHelper.operationMode) {
        case PNAccessRightsHelperApplicationMode:
            
            processDescription = @"applicationAccessRightsAudit";
            if (![self.accessRightsHelper isAuditingAccessRights]) {
                
                processDescription = @"applicationAccessRightsGrant";
                if ([self.accessRightsHelper isRevokingAccessRights]) {
                    
                    processDescription = @"applicationAccessRightsRevoke";
                }
            }
            break;
        case PNAccessRightsHelperChannelMode:
            
            processDescription = @"channelAccessRightsAudit";
            if (![self.accessRightsHelper isAuditingAccessRights]) {
                
                processDescription = @"channelAccessRightsGrant";
                if ([self.accessRightsHelper isRevokingAccessRights]) {
                    
                    processDescription = @"channelAccessRightsRevoke";
                }
            }
            break;
        case PNAccessRightsHelperUserMode:
            
            processDescription = @"userAccessRightsAudit";
            if (![self.accessRightsHelper isAuditingAccessRights]) {
                
                processDescription = @"userAccessRightsGrant";
                if ([self.accessRightsHelper isRevokingAccessRights]) {
                    
                    processDescription = @"userAccessRightsRevoke";
                }
            }
            break;
        default:
            break;
    }
    CGRect accessRightsManipulationViewFrame = self.accessRightsManipulationView.frame;
    CGRect accessRightsProcessDescriptionLabelFrame = self.accessRightsProcessDescriptionLabel.frame;
    CGFloat userProvidedDataVerticalOffset = 0.0f;
    CGFloat blocksVerticalOffset = (accessRightsManipulationViewFrame.origin.y -
                                    (accessRightsProcessDescriptionLabelFrame.origin.y +accessRightsProcessDescriptionLabelFrame.size.height));
    if (self.userProvidedDataView) {
        
        CGRect userProvidedDataViewFrame = self.userProvidedDataView.frame;
        blocksVerticalOffset = (accessRightsManipulationViewFrame.origin.y -
                                (userProvidedDataViewFrame.origin.y +userProvidedDataViewFrame.size.height));
        userProvidedDataVerticalOffset = (userProvidedDataViewFrame.origin.y -
                                          (accessRightsProcessDescriptionLabelFrame.origin.y +accessRightsProcessDescriptionLabelFrame.size.height));
    }
    self.accessRightsProcessDescriptionLabel.text = [processDescription localized];
    CGSize updatedLabelSize = [self.accessRightsProcessDescriptionLabel.text sizeWithFont:self.accessRightsProcessDescriptionLabel.font
                                                                        constrainedToSize:accessRightsProcessDescriptionLabelFrame.size
                                                                            lineBreakMode:self.accessRightsProcessDescriptionLabel.lineBreakMode];
    accessRightsProcessDescriptionLabelFrame.size = (CGSize){.width = accessRightsProcessDescriptionLabelFrame.size.width,
                                                             .height = ceilf(updatedLabelSize.height)};
    self.accessRightsProcessDescriptionLabel.frame = accessRightsProcessDescriptionLabelFrame;
    if (!self.userProvidedDataView) {
        
        accessRightsManipulationViewFrame.origin.y = ((accessRightsProcessDescriptionLabelFrame.origin.y +accessRightsProcessDescriptionLabelFrame.size.height) +
                                                      blocksVerticalOffset);
    }
    else {
        
        CGRect userProvidedDataViewFrame = self.userProvidedDataView.frame;
        userProvidedDataViewFrame.origin.y = ((accessRightsProcessDescriptionLabelFrame.origin.y +accessRightsProcessDescriptionLabelFrame.size.height) +
                                               userProvidedDataVerticalOffset);
        self.userProvidedDataView.frame = userProvidedDataViewFrame;
        accessRightsManipulationViewFrame.origin.y = ((userProvidedDataViewFrame.origin.y +userProvidedDataViewFrame.size.height) +
                                                      blocksVerticalOffset);
        
        CGRect additionalUserProvidedDataViewFrame = self.additionalUserProvidedDataView.frame;
        additionalUserProvidedDataViewFrame.size = userProvidedDataViewFrame.size;
        additionalUserProvidedDataViewFrame.origin.y = userProvidedDataViewFrame.origin.y;
        self.additionalUserProvidedDataView.frame = additionalUserProvidedDataViewFrame;
    }
    self.accessRightsManipulationView.frame = accessRightsManipulationViewFrame;
    
    
    if ([self.accessRightsHelper isAuditingAccessRights] || [self.accessRightsHelper isRevokingAccessRights]) {
        
        CGRect accessRightsManipulationViewFrame = self.accessRightsManipulationView.frame;
        self.accessRightsManipulationView.hidden = YES;
        
        CGRect accessRightsInformationViewFrame = self.accessRightsInformationView.frame;
        CGFloat additionalHeight = (accessRightsInformationViewFrame.origin.y - accessRightsManipulationViewFrame.origin.y);
        accessRightsInformationViewFrame.size.height = accessRightsInformationViewFrame.size.height + additionalHeight;
        accessRightsInformationViewFrame.origin.y = accessRightsManipulationViewFrame.origin.y;
        self.accessRightsInformationView.frame = accessRightsInformationViewFrame;
    }
    
    self.layoutPrepared = YES;
}

- (void)updateLayout {
    
    if (!self.isLayoutPrepared) {
        
        [self prepareLayout];
    }
    self.actionButton.enabled = [self.accessRightsHelper isAbleToChangeAccessRights];
    if (self.accessRightsHelper.accessRightsApplicationDuration > 0) {
        
        self.accessRightsApplicationDuration.text = [NSString stringWithFormat:@"%d", (unsigned int)self.accessRightsHelper.accessRightsApplicationDuration];
    }
    else {
        
        self.accessRightsApplicationDuration.text = nil;
    }
    
    [self.readRightsSwitch setOn:self.accessRightsHelper.shouldAllowRead animated:YES];
    [self.writeRightsSwitch setOn:self.accessRightsHelper.shouldAllowWrite animated:YES];
}

- (void)updateLayoutForAccessRightsInformation:(PNAccessRightsInformation *)information {
    
    // TODO: Update helper state
    self.accessRightsHelper.accessRightsApplicationDuration = information.accessPeriodDuration;
    self.accessRightsHelper.allowRead = [information hasReadRight];
    self.accessRightsHelper.allowWrite = [information hasWriteRight];
    if (information.level == PNUserAccessRightsLevel) {
        
        [self.accessRightsHelper addObject:information.authorizationKey];
        self.accessRightsHelper.channelName = information.channel.name;
        self.channelNameInputTextField.text = information.channel.name;
    }
    else if (information.level == PNChannelAccessRightsLevel) {
        
        [self.accessRightsHelper addObject:information.channel];
        [self.userProvidedDataList reloadData];
    }
    
    [self updateLayout];
}

- (void)showPopover {
    
    UIPickerView *picker = [UIPickerView new];
    picker.delegate = self;
    picker.dataSource = self;
    CGSize pickerSize = picker.bounds.size;
    
    
    UIViewController *pickerViewController = [UIViewController new];
    [pickerViewController.view addSubview:picker];
    pickerViewController.contentSizeForViewInPopover = pickerSize;
    
    CGRect targetFrame = self.accessRightsApplicationDuration.frame;
    targetFrame = CGRectOffset(targetFrame, self.accessRightsManipulationView.frame.origin.x,
                               self.accessRightsManipulationView.frame.origin.y);
    
    self.pickerPopoverController = [[UIPopoverController alloc] initWithContentViewController:pickerViewController];
    self.pickerPopoverController.delegate = self;
    [self.pickerPopoverController presentPopoverFromRect:targetFrame inView:self permittedArrowDirections:UIPopoverArrowDirectionUp
                                                animated:YES];
}


#pragma mark - Handler methods

- (IBAction)handleDataAdditionButtonTap:(id)sender {
    
    if (self.accessRightsHelper.operationMode == PNAccessRightsHelperChannelMode) {
        
        PNChannelInformationView *information = [PNChannelInformationView viewFromNib];
        information.delegate = self;
        information.allowEditing = YES;
        [information showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
    }
    else {
        
        [self completeUserInput];
        PNClientIdentifierAddView *identifierInput = [PNClientIdentifierAddView viewFromNib];
        identifierInput.delegate = self;
        [identifierInput showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
    }
}

- (IBAction)handleActionButtonTap:(id)sender {
    
    [self completeUserInput];
    
    if ([self.accessRightsApplicationDuration.text integerValue] > 0) {
        
        self.accessRightsHelper.accessRightsApplicationDuration = [self.accessRightsApplicationDuration.text integerValue];
    }
    else if (self.accessRightsHelper.accessRightsApplicationDuration == 0) {
        
        self.accessRightsHelper.accessRightsApplicationDuration = [self.accessRightsApplicationDuration.placeholder integerValue];
    }
    if (![self.accessRightsHelper isAuditingAccessRights] && ![self.accessRightsHelper isRevokingAccessRights]) {
        
        self.accessRightsHelper.allowRead = self.readRightsSwitch.isOn;
        self.accessRightsHelper.allowWrite = self.writeRightsSwitch.isOn;
    }
    
    
    PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
    [progressAlertView show];
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [self.accessRightsHelper performRequestWithBlock:^(NSError *requestError) {
        
        [progressAlertView dismissWithAnimation:YES];
        
        PNAlertType type = (requestError ? PNAlertWarning : PNAlertSuccess);
        NSString *shortDescription = (requestError ? @"accessRightsChangeFailureAlertViewShortDescription" :
                                                     @"accessRightsChangeSuccessAlertViewShortDescription");
        if ([self.accessRightsHelper isAuditingAccessRights]) {
            
            shortDescription = (requestError ? @"accessRightsAuditFailureAlertViewShortDescription" :
                                               @"accessRightsAuditSuccessAlertViewShortDescription");
        }
        NSString *detailedDescription = nil;
        
        if (self.accessRightsHelper.operationMode == PNAccessRightsHelperApplicationMode) {
            
            if ([self.accessRightsHelper isAuditingAccessRights]) {
                
                detailedDescription = (requestError ? @"accessRightsAuditApplicationFailureAlertViewShortDescription" :
                                                      @"accessRightsAuditApplicationSuccessAlertViewShortDescription");
                if (requestError) {

                    detailedDescription = [NSString stringWithFormat:[detailedDescription localized],
                                           requestError.localizedFailureReason];
                }
            }
            else {
                
                detailedDescription = (requestError ? @"accessRightsChangeApplicationFailureAlertViewShortDescription" :
                                                      @"accessRightsChangeApplicationSuccessAlertViewShortDescription");
                if (requestError) {

                    detailedDescription = [NSString stringWithFormat:[detailedDescription localized],
                                           requestError.localizedFailureReason];
                }
            }
        }
        else if (self.accessRightsHelper.operationMode == PNAccessRightsHelperChannelMode) {
            
            NSString *channelsList = [[[self.accessRightsHelper userData] valueForKey:@"name"] componentsJoinedByString:@", "];
            NSString *localizationKey = @"accessRightsChangeChannelSuccessAlertViewShortDescription";
            
            if (!requestError) {
                
                if ([self.accessRightsHelper isAuditingAccessRights]) {
                    
                    localizationKey = @"accessRightsAuditChannelSuccessAlertViewShortDescription";
                }
                detailedDescription = [NSString stringWithFormat:[localizationKey localized], channelsList];
            }
            else {
                
                localizationKey = @"accessRightsChangeChannelFailureAlertViewShortDescription";
                if ([self.accessRightsHelper isAuditingAccessRights]) {
                    
                    localizationKey = @"accessRightsAuditChannelFailureAlertViewShortDescription";
                }
                detailedDescription = [NSString stringWithFormat:[localizationKey localized], channelsList,
                                       requestError.localizedFailureReason];
            }
        }
        else {
            
            NSString *identifiersList = [[self.accessRightsHelper userData] componentsJoinedByString:@", "];
            NSString *localizationKey = @"accessRightsChangeUserSuccessAlertViewShortDescription";
            
            
            if ([self.accessRightsHelper isAuditingAccessRights]) {
            detailedDescription = [NSString stringWithFormat:[@"accessRightsChangeUserSuccessAlertViewShortDescription" localized],
                                   identifiersList];
            }
            if (!requestError) {
                
                localizationKey = @"accessRightsChangeUserSuccessAlertViewShortDescription";
                if ([self.accessRightsHelper isAuditingAccessRights]) {
                    
                    localizationKey = @"accessRightsAuditUserSuccessAlertViewShortDescription";
                }
                detailedDescription = [NSString stringWithFormat:[localizationKey localized], identifiersList];
            }
            else {
                
                localizationKey = @"accessRightsChangeUserFailureAlertViewShortDescription";
                if ([self.accessRightsHelper isAuditingAccessRights]) {
                    
                    localizationKey = @"accessRightsAuditUserFailureAlertViewShortDescription";
                }
                detailedDescription = [NSString stringWithFormat:[localizationKey localized], identifiersList,
                                       requestError.localizedFailureReason];
            }
        }
        
        PNAlertView *alert = [PNAlertView viewWithTitle:@"accessRightsAlertViewTitle" type:type
                                           shortMessage:shortDescription detailedMessage:detailedDescription cancelButtonTitle:nil
                                      otherButtonTitles:nil andEventHandlingBlock:NULL];
        [alert show];
        [weakSelf.accessRightsList reloadData];
    }];
}

- (IBAction)handleCloseButtonTap:(id)sender {
    
    [self dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
}


#pragma mark - Client identifier delegate methods

- (void)identifierView:(PNClientIdentifierAddView *)view didEndClientIdentifierInput:(NSString *)clientIdentifier {
    
    [view dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
    
    [self.accessRightsHelper addObject:clientIdentifier];
    [self.userProvidedDataList reloadData];
    [self updateLayout];
}


#pragma mark - Channel information delegate methods

- (void)channelInformation:(PNChannelInformationView *)informationView didEndEditingChanne:(PNChannel *)channel
                 withState:(NSDictionary *)channelState andPresenceObservation:(BOOL)shouldObserverPresence {
    
    [informationView dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
    
    [self.accessRightsHelper addObject:channel];
    [self.userProvidedDataList reloadData];
    [self updateLayout];
}


#pragma mark - UITextField delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (![textField isEqual:self.accessRightsApplicationDuration]) {
        
        NSString *targetName = [textField.text stringByReplacingCharactersInRange:range withString:string];
        self.accessRightsHelper.channelName = targetName;
        
        [self updateLayout];
    }
    
    
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    BOOL textFieldShouldBeginEditing = ![textField isEqual:self.accessRightsApplicationDuration];
    
    if (!textFieldShouldBeginEditing) {
        
        [self showPopover];
    }
    
    
    return textFieldShouldBeginEditing;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self completeUserInput];
    
    
    return YES;
}


#pragma mark - UIPickerView delegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return 525600;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [NSString stringWithFormat:@"%d", (int)(row + 1)];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.accessRightsHelper.accessRightsApplicationDuration = (row + 1);
    
    [self updateLayout];
}


#pragma mark - UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger numberOfSectionsInTable = 1;
    if ([tableView isEqual:self.accessRightsList]) {
        
        numberOfSectionsInTable = [[self.accessRightsHelper accessRights] count];
    }
    
    
    return numberOfSectionsInTable;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRowsInSection = [[self.accessRightsHelper userData] count];
    if ([tableView isEqual:self.accessRightsList]) {
        
        numberOfRowsInSection = [[[[self.accessRightsHelper accessRights] objectAtIndex:section] valueForKey:PNAccessRightsDataKeys.sectionData] count];
    }
    else if ([tableView isEqual:self.channelsList]) {
        
        numberOfRowsInSection = [[self.accessRightsHelper channels] count];
    }
    
    
    return numberOfRowsInSection;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger indentationLevel = 0;
    if ([tableView isEqual:self.accessRightsList]) {
        
        NSDictionary *sectionData = [[[[self.accessRightsHelper accessRights] objectAtIndex:indexPath.section]
                                      valueForKey:PNAccessRightsDataKeys.sectionData] objectAtIndex:indexPath.row];
        indentationLevel = [[sectionData valueForKey:PNAccessRightsDataKeys.entrieShouldIndent] boolValue] ? 3 : 0;
    }
    
    
    return indentationLevel;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return ([tableView isEqual:self.accessRightsList] ? [[[self.accessRightsHelper accessRights] objectAtIndex:section] valueForKey:PNAccessRightsDataKeys.sectionName] : nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *accessRightsInformationCellIdentifier = @"accessRightsInformationCellIdentifier";
    static NSString *userInputedDataCellIdentifier = @"userInputedDataCellIdentifier";
    static NSString *channelCellIdentifier = @"channelCellIdentifier";
    NSString *targetCellIdentifier = ([tableView isEqual:self.accessRightsList] ? accessRightsInformationCellIdentifier :
                                      userInputedDataCellIdentifier);
    if ([tableView isEqual:self.channelsList]) {
        
        targetCellIdentifier = channelCellIdentifier;
    }
    
    id cell = [tableView dequeueReusableCellWithIdentifier:targetCellIdentifier];
    if (!cell) {
        
        if ([targetCellIdentifier isEqualToString:accessRightsInformationCellIdentifier]) {
            
            cell = [[PNAccessRightsInformationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:targetCellIdentifier];
            if (![self.accessRightsHelper isAuditingAccessRights]) {
                
                ((PNAccessRightsInformationCell *)cell).selectedBackgroundView = nil;
                ((PNAccessRightsInformationCell *)cell).selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        else  {
            
            if (self.accessRightsHelper.operationMode == PNAccessRightsHelperChannelMode || [tableView isEqual:self.channelsList]) {
                
                cell = [[PNChannelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:targetCellIdentifier];
                ((PNChannelCell *)cell).showBadge = NO;
            }
            else {
                    
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:targetCellIdentifier];
                ((UITableViewCell *)cell).textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
                
                ((PNAccessRightsInformationCell *)cell).selectedBackgroundView = nil;
                ((PNAccessRightsInformationCell *)cell).selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
    }
    if ([targetCellIdentifier isEqualToString:accessRightsInformationCellIdentifier]) {
        
        NSDictionary *data = [[[[self.accessRightsHelper accessRights] objectAtIndex:indexPath.section] valueForKey:PNAccessRightsDataKeys.sectionData]
                              objectAtIndex:indexPath.row];
        [(PNAccessRightsInformationCell *)cell updateWithAccessRightsInformation:data];
    }
    else {
        
        if (self.accessRightsHelper.operationMode == PNAccessRightsHelperChannelMode) {
            
            PNChannel *channel = [[self.accessRightsHelper userData] objectAtIndex:indexPath.row];
            [(PNChannelCell *)cell updateForChannel:channel];
            
            if ([self.accessRightsHelper willManipulateWith:channel]) {
                
                ((PNChannelCell *)cell).accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                
                ((PNChannelCell *)cell).accessoryType = UITableViewCellAccessoryNone;
            }
        }
        else if (self.accessRightsHelper.operationMode == PNAccessRightsHelperUserMode) {
            
            NSString *identifier = [[self.accessRightsHelper userData] objectAtIndex:indexPath.row];
            ((UITableViewCell *)cell).textLabel.text = identifier;
        }
        else if ([targetCellIdentifier isEqualToString:channelCellIdentifier]) {
            
            PNChannel *channel = [[self.accessRightsHelper channels] objectAtIndex:indexPath.row];
            [(PNChannelCell *)cell updateForChannel:channel];
        }
    }
    
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    if ([tableView isEqual:self.userProvidedDataList] && self.accessRightsHelper.operationMode == PNAccessRightsHelperUserMode) {
        
        style = UITableViewCellEditingStyleDelete;
    }
    
    return style;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([tableView isEqual:self.accessRightsList]) {
        
        if ([self.accessRightsHelper isAuditingAccessRights]) {
            
            NSDictionary *data = [[[[self.accessRightsHelper accessRights] objectAtIndex:indexPath.section] valueForKey:PNAccessRightsDataKeys.sectionData]
                                  objectAtIndex:indexPath.row];
            PNAccessRightsInformation *information = [data valueForKey:PNAccessRightsDataKeys.entrieData];
            PNAccessRightsView *view = [[self class] viewFrromNibForAccessRightsInformation:information];
            [view showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
        }
    }
    else {
        
        if ([tableView isEqual:self.userProvidedDataList]) {
            
            id targetObject = [[self.accessRightsHelper userData] objectAtIndex:indexPath.row];
            
            if (![self.accessRightsHelper willManipulateWith:targetObject]) {
                
                [self.accessRightsHelper addObject:targetObject];
            }
            else {
                
                [self.accessRightsHelper removeObject:targetObject];
            }
            [self.userProvidedDataList reloadData];
        }
        else if (self.accessRightsHelper.operationMode == PNAccessRightsHelperUserMode) {
            
            PNChannel *channel = [[self.accessRightsHelper channels] objectAtIndex:indexPath.row];
            self.accessRightsHelper.channelName = channel.name;
            self.channelNameInputTextField.text = channel.name;
        }
    }
    [self updateLayout];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSString *identifier = [[self.accessRightsHelper userData] objectAtIndex:indexPath.row];
        [self.accessRightsHelper removeObject:identifier];
        [self.userProvidedDataList reloadData];
        [self updateLayout];
    }
}

#pragma mark -


@end
