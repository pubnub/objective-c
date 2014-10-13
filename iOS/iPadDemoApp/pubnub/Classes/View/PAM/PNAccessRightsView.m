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
#import "PNObjectInformationDelegate.h"
#import "PNClientIdentifierAddView.h"
#import "PNObjectInformationView.h"
#import "NSString+PNLocalization.h"
#import "PNNamespaceAddDelegate.h"
#import "PNAccessRightsHelper.h"
#import "NSObject+PNAddition.h"
#import "PNNamespaceAddView.h"
#import "UIView+PNAddition.h"
#import "PNObjectCell.h"
#import "PNTableView.h"
#import "PNAlertView.h"
#import "PNButton.h"


#pragma mark Static

static NSTimeInterval const kPNViewAppearAnimationDuration = 0.4f;
static NSTimeInterval const kPNViewDisappearAnimationDuration = 0.2f;


#pragma mark - Private interface declaration

@interface PNAccessRightsView () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource,
                                  UIPickerViewDelegate, UIPopoverControllerDelegate, UITextFieldDelegate,
                                  PNObjectInformationDelegate, PNClientIdentifierAddDelegate, PNNamespaceAddDelegate>


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
 Stores reference on namespace addition button for channel group access rights representation.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *addNamespaceButton;

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
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *manageGroupSwitch;

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


#pragma mark - Class methods

/**
 @brief Retrieve reference on access rights representation view basing on parameters.
 
 @discussion Depending on parameters view can be used to represent application/channe/group or user access rights for
 audition/change or revoke.
 
 @param nibNameSelector        Selector which should be used inside of nib name method swizzling
 @param mode                   One of \b PNAccessRightsHelperMode fields which specify whos access rights it should
                               represent.
 @param willAuditAccessRights  Whether view presented for access rights audition operation or not
 @param willRevokeAccessRights Whether view presented for access rights revoke operation or not
 
 @return Constructed and ready to use instance.
 
 @since 3.6.8
 */
+ (instancetype)accessRightsViewWithNameFrom:(SEL)nibNameSelector forMode:(PNAccessRightsHelperMode)mode
                                       audit:(BOOL)willAuditAccessRights revoke:(BOOL)willRevokeAccessRights;


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

+ (instancetype)viewFromNibForAccessRightsInformation:(PNAccessRightsInformation *)information {
    
    PNAccessRightsView *view = nil;
    switch (information.level) {
        case PNApplicationAccessRightsLevel:
            
            view = [self viewFromNibForApplicationGrant];
            break;
        case PNChannelGroupAccessRightsLevel:
            
            view = [self viewFromNibForChannelGroupGrant];
            break;
        case PNChannelAccessRightsLevel:
            
            view = [self viewFromNibForChannelGrant];
            break;
        case PNUserAccessRightsLevel:
            
            if ([information.object isKindOfClass:[PNChannelGroup class]]) {
                
                view = [self viewFromNibForUserGrantOnChannelGroup];
            }
            else {
                
                view = [self viewFromNibForUserGrantOnChannel];
            }
            break;
    }
    [view updateLayoutForAccessRightsInformation:information];
    
    
    return view;
}

+ (instancetype)viewFromNibForApplicationAudit {
    
    return [self accessRightsViewWithNameFrom:@selector(viewNibNameForApplication)
                                      forMode:PNAccessRightsHelperApplicationMode audit:YES revoke:NO];
}

+ (instancetype)viewFromNibForApplicationGrant {

    return [self accessRightsViewWithNameFrom:@selector(viewNibNameForApplication)
                                      forMode:PNAccessRightsHelperApplicationMode audit:NO revoke:NO];
}

+ (instancetype)viewFromNibForApplicationRevoke {

    return [self accessRightsViewWithNameFrom:@selector(viewNibNameForApplication)
                                      forMode:PNAccessRightsHelperApplicationMode audit:NO revoke:YES];
}

+ (instancetype)viewFromNibForChannelAudit {
    
    return [self accessRightsViewWithNameFrom:@selector(viewNibNameForChannel) forMode:PNAccessRightsHelperChannelMode
                                        audit:YES revoke:NO];
}

+ (instancetype)viewFromNibForChannelGrant {

    return [self accessRightsViewWithNameFrom:@selector(viewNibNameForChannel) forMode:PNAccessRightsHelperChannelMode
                                        audit:NO revoke:NO];
}

+ (instancetype)viewFromNibForChannelRevoke {
    
    return [self accessRightsViewWithNameFrom:@selector(viewNibNameForChannel) forMode:PNAccessRightsHelperChannelMode
                                        audit:NO revoke:YES];
}

+ (instancetype)viewFromNibForChannelGroupAudit {
    
    return [self accessRightsViewWithNameFrom:@selector(viewNibNameForChannelGroup)
                                      forMode:PNAccessRightsHelperChannelGroupMode audit:YES revoke:NO];
}

+ (instancetype)viewFromNibForChannelGroupGrant {
    
    return [self accessRightsViewWithNameFrom:@selector(viewNibNameForChannelGroup)
                                      forMode:PNAccessRightsHelperChannelGroupMode audit:NO revoke:NO];
}

+ (instancetype)viewFromNibForChannelGroupRevoke {
    
    return [self accessRightsViewWithNameFrom:@selector(viewNibNameForChannelGroup)
                                      forMode:PNAccessRightsHelperChannelGroupMode audit:NO revoke:YES];
}

+ (instancetype)viewFromNibForUserAuditOnChannel {
    
    return [self accessRightsViewWithNameFrom:@selector(viewNibNameForUserOnChannel)
                                      forMode:PNAccessRightsHelperUserOnChannelMode audit:YES revoke:NO];
}

+ (instancetype)viewFromNibForUserGrantOnChannel {
    
    return [self accessRightsViewWithNameFrom:@selector(viewNibNameForUserOnChannel)
                                      forMode:PNAccessRightsHelperUserOnChannelMode audit:NO revoke:NO];
}

+ (instancetype)viewFromNibForUserRevokeOnChannel {
    
    return [self accessRightsViewWithNameFrom:@selector(viewNibNameForUserOnChannel)
                                      forMode:PNAccessRightsHelperUserOnChannelMode audit:NO revoke:YES];
}

+ (instancetype)viewFromNibForUserAuditOnChannelGroup {
    
    return [self accessRightsViewWithNameFrom:@selector(viewNibNameForUserOnChannelGroup)
                                      forMode:PNAccessRightsHelperUserOnChannelGroupMode audit:YES revoke:NO];
}

+ (instancetype)viewFromNibForUserGrantOnChannelGroup {
    
    return [self accessRightsViewWithNameFrom:@selector(viewNibNameForUserOnChannelGroup)
                                      forMode:PNAccessRightsHelperUserOnChannelGroupMode audit:NO revoke:NO];
}

+ (instancetype)viewFromNibForUserRevokeOnChannelGroup {
    
    return [self accessRightsViewWithNameFrom:@selector(viewNibNameForUserOnChannelGroup)
                                      forMode:PNAccessRightsHelperUserOnChannelGroupMode audit:NO revoke:YES];
}

+ (instancetype)accessRightsViewWithNameFrom:(SEL)nibNameSelector forMode:(PNAccessRightsHelperMode)mode
                                       audit:(BOOL)willAuditAccessRights revoke:(BOOL)willRevokeAccessRights {
    
    __block PNAccessRightsView *view = nil;
    [self temporarilySwizzleMethod:@selector(viewNibName) with:nibNameSelector duringBlockExecution:^{
        
        view = [self viewFromNib];
        [view.accessRightsHelper configureForMode:mode forAccessRightsAudition:willAuditAccessRights
                             orAccessRightsRevoke:willRevokeAccessRights];
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

+ (NSString *)viewNibNameForChannelGroup {
    
    return @"PNChannelGroupAccessRightsView";
}

+ (NSString *)viewNibNameForUserOnChannel {
    
    return @"PNUserAccessRightsOnChannelView";
}

+ (NSString *)viewNibNameForUserOnChannelGroup {
    
    return @"PNUserAccessRightsOnChannelGroupView";
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
        case PNAccessRightsHelperChannelGroupMode:
            
            processDescription = @"channelGroupAccessRightsAudit";
            if (![self.accessRightsHelper isAuditingAccessRights]) {
                
                processDescription = @"channelGroupAccessRightsGrant";
                if ([self.accessRightsHelper isRevokingAccessRights]) {
                    
                    processDescription = @"channelGroupAccessRightsRevoke";
                }
            }
            break;
        case PNAccessRightsHelperUserOnChannelMode:
            
            processDescription = @"userAccessRightsAuditOnChannel";
            if (![self.accessRightsHelper isAuditingAccessRights]) {
                
                processDescription = @"userAccessRightsGrantOnChannel";
                if ([self.accessRightsHelper isRevokingAccessRights]) {
                    
                    processDescription = @"userAccessRightsRevokeOnChannel";
                }
            }
            break;
        case PNAccessRightsHelperUserOnChannelGroupMode:
            
            processDescription = @"userAccessRightsAuditOnChannelGroup";
            if (![self.accessRightsHelper isAuditingAccessRights]) {
                
                processDescription = @"userAccessRightsGrantOnChannelGroup";
                if ([self.accessRightsHelper isRevokingAccessRights]) {
                    
                    processDescription = @"userAccessRightsRevokeOnChannelGroup";
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
    NSString *duration = nil;
    if (self.accessRightsHelper.accessRightsApplicationDuration > 0) {
        
        duration = [NSString stringWithFormat:@"%d", (unsigned int)self.accessRightsHelper.accessRightsApplicationDuration];
    }
    self.accessRightsApplicationDuration.text = duration;
    
    [self.readRightsSwitch setOn:self.accessRightsHelper.shouldAllowRead animated:YES];
    [self.writeRightsSwitch setOn:self.accessRightsHelper.shouldAllowWrite animated:YES];
    [self.manageGroupSwitch setOn:self.accessRightsHelper.shouldAllowManagement animated:YES];
    [self.userProvidedDataList reloadData];
}

- (void)updateLayoutForAccessRightsInformation:(PNAccessRightsInformation *)information {
    
    self.accessRightsHelper.accessRightsApplicationDuration = information.accessPeriodDuration;
    self.accessRightsHelper.allowRead = [information hasReadRight];
    self.accessRightsHelper.allowWrite = [information hasWriteRight];
    self.accessRightsHelper.allowManagement = [information hasManagementRight];
    if (information.level == PNUserAccessRightsLevel) {
        
        [self.accessRightsHelper addObject:information.authorizationKey];
        self.accessRightsHelper.channelName = information.object.name;
        self.channelNameInputTextField.text = information.object.name;
    }
    else if (information.level == PNChannelAccessRightsLevel) {
        
        [self.accessRightsHelper addObject:information.object];
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
        
        PNObjectInformationView *information = [PNObjectInformationView viewFromNib];
        information.delegate = self;
        information.allowEditing = YES;
        [information showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
    }
    else if (self.accessRightsHelper.operationMode == PNAccessRightsHelperChannelGroupMode) {
        
        if (![sender isEqual:self.addNamespaceButton]) {
            
            PNObjectInformationView *information = [PNObjectInformationView viewFromNibForChannelGroup];
            information.delegate = self;
            information.allowEditing = YES;
            [information showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
        }
        else {
            
            PNNamespaceAddView *namespaceNameInput = [PNNamespaceAddView viewFromNib];
            namespaceNameInput.delegate = self;
            [namespaceNameInput showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
        }
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
        self.accessRightsHelper.allowManagement = self.manageGroupSwitch.isOn;
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
        else if (self.accessRightsHelper.operationMode == PNAccessRightsHelperChannelMode ||
                 self.accessRightsHelper.operationMode == PNAccessRightsHelperChannelGroupMode) {
            
            NSString *channelsList = [[[self.accessRightsHelper userData] valueForKey:@"name"] componentsJoinedByString:@", "];
            NSString *localizationKey = @"accessRightsChangeChannelSuccessAlertViewShortDescription";
            if (self.accessRightsHelper.operationMode == PNAccessRightsHelperChannelGroupMode) {
                
                localizationKey = @"accessRightsChangeChannelGroupSuccessAlertViewShortDescription";
            }
            
            if (!requestError) {
                
                if ([self.accessRightsHelper isAuditingAccessRights]) {
                    
                    localizationKey = @"accessRightsAuditChannelSuccessAlertViewShortDescription";
                    if (self.accessRightsHelper.operationMode == PNAccessRightsHelperChannelGroupMode) {
                        
                        localizationKey = @"accessRightsAuditChannelGroupSuccessAlertViewShortDescription";
                    }
                }
                detailedDescription = [NSString stringWithFormat:[localizationKey localized], channelsList];
            }
            else {
                
                localizationKey = @"accessRightsChangeChannelFailureAlertViewShortDescription";
                if (self.accessRightsHelper.operationMode == PNAccessRightsHelperChannelGroupMode) {
                    
                    localizationKey = @"accessRightsChangeChannelGroupFailureAlertViewShortDescription";
                }
                if ([self.accessRightsHelper isAuditingAccessRights]) {
                    
                    localizationKey = @"accessRightsAuditChannelFailureAlertViewShortDescription";
                    if (self.accessRightsHelper.operationMode == PNAccessRightsHelperChannelGroupMode) {
                        
                        localizationKey = @"accessRightsAuditChannelGroupFailureAlertViewShortDescription";
                    }
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
    [self updateLayout];
}


#pragma mark - Namespace addition delegate methods

- (void)namespaceView:(PNNamespaceAddView *)view didEndNamespaceInput:(PNChannelGroupNamespace *)nspace {
    
    [view dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
    
    [self.accessRightsHelper addObject:nspace];
    [self updateLayout];
}


#pragma mark - Channel information delegate methods

- (void)objectInformation:(PNObjectInformationView *)informationView didEndEditing:(id <PNChannelProtocol>)object
                withState:(NSDictionary *)channelState andPresenceObservation:(BOOL)shouldObserverPresence {
    
    [informationView dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
    
    [self.accessRightsHelper addObject:object];
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
            
            if (self.accessRightsHelper.operationMode == PNAccessRightsHelperChannelMode ||
                self.accessRightsHelper.operationMode == PNAccessRightsHelperChannelGroupMode ||
                [tableView isEqual:self.channelsList]) {
                
                cell = [[PNObjectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:targetCellIdentifier];
                ((PNObjectCell *)cell).showBadge = NO;
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
        
        if ([targetCellIdentifier isEqualToString:channelCellIdentifier]) {
            
            PNChannel *channel = [[self.accessRightsHelper channels] objectAtIndex:indexPath.row];
            [(PNObjectCell *)cell updateForObject:channel];
        }
        else if (self.accessRightsHelper.operationMode == PNAccessRightsHelperChannelMode ||
                 self.accessRightsHelper.operationMode == PNAccessRightsHelperChannelGroupMode) {
            
            PNChannel *channel = [[self.accessRightsHelper userData] objectAtIndex:indexPath.row];
            [(PNObjectCell *)cell updateForObject:channel];
            
            if ([self.accessRightsHelper willManipulateWith:channel]) {
                
                ((PNObjectCell *)cell).accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                
                ((PNObjectCell *)cell).accessoryType = UITableViewCellAccessoryNone;
            }
        }
        else if (self.accessRightsHelper.operationMode == PNAccessRightsHelperUserOnChannelMode ||
                 self.accessRightsHelper.operationMode == PNAccessRightsHelperUserOnChannelGroupMode) {
            
            if (indexPath.row < [[self.accessRightsHelper userData] count]) {
                
                NSString *identifier = [[self.accessRightsHelper userData] objectAtIndex:indexPath.row];
                ((UITableViewCell *)cell).textLabel.text = identifier;
            }
        }
    }
    
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    if ([tableView isEqual:self.userProvidedDataList] &&
        (self.accessRightsHelper.operationMode == PNAccessRightsHelperUserOnChannelMode ||
         self.accessRightsHelper.operationMode == PNAccessRightsHelperUserOnChannelGroupMode)) {
        
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
            PNAccessRightsView *view = [[self class] viewFromNibForAccessRightsInformation:information];
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
        else if (self.accessRightsHelper.operationMode == PNAccessRightsHelperUserOnChannelMode ||
                 self.accessRightsHelper.operationMode == PNAccessRightsHelperUserOnChannelGroupMode) {
            
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
        [self updateLayout];
    }
}

#pragma mark -


@end
