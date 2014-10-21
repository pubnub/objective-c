//
//  PNChannelRegistryView.m
//  pubnub
//
//  Created by Sergey Mamontov on 10/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelRegistryView.h"
#import "PNObjectInformationDelegate.h"
#import "PNObjectInformationView.h"
#import "NSString+PNLocalization.h"
#import "PNChannelRegistryHelper.h"
#import "NSObject+PNAddition.h"
#import "UIView+PNAddition.h"
#import "PNObjectCell.h"
#import "PNTableView.h"
#import "PNAlertView.h"
#import "PNButton.h"


#pragma mark Static

static NSTimeInterval const kPNViewAppearAnimationDuration = 0.4f;
static NSTimeInterval const kPNViewDisappearAnimationDuration = 0.2f;


#pragma mark - Private interface declaration

@interface PNChannelRegistryView () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,
                                     PNObjectInformationDelegate>


#pragma mark - Properties

@property (nonatomic, pn_desired_weak) IBOutlet PNButton *dataAdditionButton;
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *dataFetchButton;
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *actionButton;

/**
 @brief Reference on label which represent current window label and store format for it's composition.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *headerTitleLabel;

/**
 @brief Reference on label which stores operation description message for user.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *operationDescription;

/**
 @brief Reference on holder which allow user to specify target object (channel group / namespace) for which operation
 should be performed.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UIView *objectIdentificationHolder;

/**
 @brief Reference on view which holds required elements to specify channel group.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UIView *channelGroupNameHolder;

/**
 @brief Reference on text field input which allow user to specify target channel group name (or in case if view has been
 opened from one of audition views).
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *channelGroupNameTextField;

/**
 @brief Reference on view which holds required elements to specify namespace.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UIView *namespaceHolder;

/**
 @brief Reference on text field input which allow user to specify target namespace name (or in case if view has been
 opened from one of audition view).
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *namespaceNameTextField;

/**
 @brief Reference on view which holds elements for fetched / user-provided data representation.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UIView *dataRepresentationHolder;

/**
 @brief Reference on table which is used to represent fetched and user-provided data.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNTableView *dataRepresentationList;

/**
 @brief Reference on label which stores description about action which is allowed to the user.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *actionTitle;

/**
 @brief Reference on helper model which will handle and route all channel registry manipulation requests.
 */
@property (nonatomic, strong) IBOutlet PNChannelRegistryHelper *registryHelper;

/**
 Stores whether initial interface layout has been performed or not.
 */
@property (nonatomic, assign, getter = isLayoutPrepared) BOOL layoutPrepared;



#pragma mark - Class methods

/**
 @brief Construct and initialise channel registry manipulation view (for namespace and channel groups) with predefined
 parameters.
 
 @param mode            Mode for which helper and view should be configured.
 
 @return Contructed and ready to use \b PNChannelRegistryView instance.
 */
+ (instancetype)channelRegistryViewWithMode:(PNChannelRegistryHelperMode)mode;


#pragma mark - Instance methods

/**
 @brief Prepare user interface with initial state and parameters
 */
- (void)prepareLayout;

/**
 @brief Update layout basing on existing data and it's representation parameters.
 */
- (void)updateLayout;

- (void)updateWithChannelGroupName:(NSString *)channelGroupName andNamespace:(NSString *)namespaceName;


#pragma mark - Handler methods

- (IBAction)handleDataAdditionButtonTap:(id)sender;
- (IBAction)handleDataFetchButtonTap:(id)sender;
- (IBAction)handleActionButtonTap:(id)sender;
- (IBAction)handleCloseButtonTap:(id)sender;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNChannelRegistryView


#pragma mark - Class methods

+ (instancetype)viewFromNibForNamespaceAudit {
    
    return [self channelRegistryViewWithMode:PNChannelRegistryHelperNamespaceAuditMode];
}

+ (instancetype)viewFromNibForNamespaceRemove {
    
    return [self channelRegistryViewWithMode:PNChannelRegistryHelperNamespaceRemoveMode];
}

+ (instancetype)viewFromNibForChannelGroupAudit {
    
    return [self channelRegistryViewWithMode:PNChannelRegistryHelperGroupAuditMode];
}

+ (instancetype)viewFromNibForChannelGroupRemove {
    
    return [self channelRegistryViewWithMode:PNChannelRegistryHelperGroupRemoveMode];
}

+ (instancetype)viewFromNibForChannelGroupChannelsAdd {
    
    return [self channelRegistryViewWithMode:PNChannelRegistryHelperGroupChannelsAddMode];
}

+ (instancetype)viewFromNibForChannelGroupChannelsRemove {
    
    return [self channelRegistryViewWithMode:PNChannelRegistryHelperGroupChannelsRemoveMode];
}

+ (instancetype)viewFromNibForChannelGroupChannelsAudit {
    
    return [self channelRegistryViewWithMode:PNChannelRegistryHelperGroupChannelsAuditMode];
}

+ (instancetype)channelRegistryViewWithMode:(PNChannelRegistryHelperMode)mode; {
    
    PNChannelRegistryView *view = [self viewFromNib];
    view.registryHelper.operationMode = mode;
    [view updateLayout];
    
    
    return view;
}


#pragma mark - Instance methods

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNViewAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNViewDisappearAnimationDuration;
}

- (void)prepareLayout {
    
    self.dataAdditionButton.hidden = YES;
    self.actionButton.hidden = YES;
    NSString *action = ([self.registryHelper isObjectAudition] ? @"Audit" : @"Remove");
    NSString *actionButtonTitle = ([self.registryHelper isObjectAudition] ? action : nil);
    NSString *target = @"Namespace";
    if ([self.registryHelper workingWithChannelGroup]) {
        
        target = @"Channel Group";
    }
    else if ([self.registryHelper workingWithChannelGroupChannels]) {
        
        if (![self.registryHelper isObjectRemove] && ![self.registryHelper isObjectAudition]) {
            
            action = @"Add";
            actionButtonTitle = action;
        }
        target = @"Channels";
    }
    if (actionButtonTitle) {
        
        [self.actionButton setTitle:actionButtonTitle forState:UIControlStateNormal];
    }
    self.headerTitleLabel.text = [NSString stringWithFormat:self.headerTitleLabel.text, target, action];
    
    BOOL objectIdentificationHolderVisible = YES;
    BOOL channelGroupDataHolderVisible = YES;
    NSString *processDescription = nil;
    NSString *actionDescription = nil;
    void(^changeButtonOrder)(CGFloat, PNButton *, NSArray *) = ^(CGFloat buttonHorizontalStep, PNButton *rightButton,
                                                                 NSArray *orderedButtons) {
        
        CGRect rightMarkerButtonFrame = rightButton.frame;
        __block CGRect lastButtonFrame = CGRectZero;
        [orderedButtons enumerateObjectsWithOptions:NSEnumerationReverse
                                         usingBlock:^(PNButton *button, NSUInteger buttonIdx,
                                                      BOOL *buttonEnumeratorStop) {
                                             
             if (CGRectIsEmpty(lastButtonFrame)) {
                 
                 lastButtonFrame = button.frame;
                 lastButtonFrame.origin.x = (CGRectGetMaxX(rightMarkerButtonFrame) - lastButtonFrame.size.width);
                 button.frame = lastButtonFrame;
             }
             else {
                 
                 lastButtonFrame.origin.x = (CGRectGetMinX(lastButtonFrame) - buttonHorizontalStep - button.frame.size.width);
                 lastButtonFrame.size.width = button.frame.size.width;
                 button.frame = lastButtonFrame;
             }
         }];
    };
    switch (self.registryHelper.operationMode) {
        case PNChannelRegistryHelperNamespaceRemoveMode:
        case PNChannelRegistryHelperNamespaceAuditMode:

            processDescription = @"channelRegistryNamespacesAuditDescription";
            actionDescription = @"channelRegistryNamespacesAuditActionDescription";
            objectIdentificationHolderVisible = NO;
            if (![self.registryHelper isObjectAudition]) {
                
                processDescription = @"channelRegistryNamespaceRemoveDescription";
                actionDescription = @"channelRegistryNamespaceRemoveActionDescription";
            }
            break;
        case PNChannelRegistryHelperGroupAuditMode:
        case PNChannelRegistryHelperGroupRemoveMode:
            
            processDescription = @"channelRegistryGroupsAuditDescription";
            actionDescription = @"channelRegistryGroupsAuditActionDescription";
            channelGroupDataHolderVisible = NO;
            if (![self.registryHelper isObjectAudition]) {
                
                processDescription = @"channelRegistryGroupRemoveDescription";
                actionDescription = @"channelRegistryGroupRemoveActionDescription";
            }
            break;
        case PNChannelRegistryHelperGroupChannelsAddMode:
        case PNChannelRegistryHelperGroupChannelsRemoveMode:
        case PNChannelRegistryHelperGroupChannelsAuditMode:
            
            self.dataAdditionButton.hidden = !(![self.registryHelper isObjectAudition] && ![self.registryHelper isObjectRemove]);
            self.dataFetchButton.hidden = !self.dataAdditionButton.isHidden;
            self.actionButton.hidden = [self.registryHelper isObjectAudition];
            
            if ([self.registryHelper isObjectRemove] || !self.dataAdditionButton.isHidden) {
                
                CGFloat horizontalStep = (CGRectGetMinX(self.dataAdditionButton.frame) - CGRectGetMaxX(self.actionButton.frame));
                if ([self.registryHelper isObjectRemove]) {
                    
                    changeButtonOrder(horizontalStep, self.dataFetchButton, @[self.dataAdditionButton,
                                                                              self.dataFetchButton, self.actionButton]);
                }
                else {
                    
                    changeButtonOrder(horizontalStep, self.dataFetchButton, @[self.dataFetchButton,
                                                                              self.dataAdditionButton, self.actionButton]);
                }
                
                self.dataFetchButton.mainBackgroundColor = self.dataAdditionButton.mainBackgroundColor;
                self.dataFetchButton.highlightedBackgroundColor = self.dataAdditionButton.highlightedBackgroundColor;
                [self.dataFetchButton update];
            }

            processDescription = @"channelRegistryGroupChannelsAddDescription";
            actionDescription = @"channelRegistryGroupChannelsAddActionDescription";
            if ([self.registryHelper isObjectRemove]) {
                
                processDescription = @"channelRegistryGroupChannelsRemoveDescription";
                actionDescription = @"channelRegistryGroupChannelsRemoveActionDescription";
            }
            else if ([self.registryHelper isObjectAudition]) {
                
                processDescription = @"channelRegistryGroupChannelsAuditDescription";
                actionDescription = nil;
            }
            break;
        default:
            break;
    }
    
    self.actionTitle.text = [actionDescription localized];
    
    // Update operation description label size and position
    CGRect operationDescriptionFrame = self.operationDescription.frame;
    CGFloat verticalOffsetToIdentificationHolder = (CGRectGetMinY(self.objectIdentificationHolder.frame) -
                                                    CGRectGetMaxY(operationDescriptionFrame));
    self.operationDescription.text = [processDescription localized];
    CGSize updatedLabelSize = [self.operationDescription.text sizeWithFont:self.operationDescription.font
                                                         constrainedToSize:operationDescriptionFrame.size
                                                             lineBreakMode:self.operationDescription.lineBreakMode];
    operationDescriptionFrame.size = (CGSize){.width = operationDescriptionFrame.size.width,
                                              .height = ceilf(updatedLabelSize.height)};
    self.operationDescription.frame = operationDescriptionFrame;
    
    // Update object identification holder size and position
    CGRect objectIdentificationHolderFrame = self.objectIdentificationHolder.frame;
    CGFloat verticalOffsetToRepresentationHolder = (CGRectGetMinY(self.dataRepresentationHolder.frame) -
                                                    CGRectGetMaxY(objectIdentificationHolderFrame));
    objectIdentificationHolderFrame.origin.y = (CGRectGetMaxY(operationDescriptionFrame) +
                                                verticalOffsetToIdentificationHolder);
    self.objectIdentificationHolder.hidden = !objectIdentificationHolderVisible;
    self.channelGroupNameHolder.hidden = !channelGroupDataHolderVisible;
    if (!channelGroupDataHolderVisible) {
        
        self.namespaceHolder.frame = self.channelGroupNameHolder.frame;
    }
    
    // Update data representation holder size and position
    CGRect dataRepresentationHolderFrame = self.dataRepresentationHolder.frame;
    CGFloat targetVerticalPosition = (CGRectGetMaxY(objectIdentificationHolderFrame) +
                                      verticalOffsetToRepresentationHolder);
    if (!objectIdentificationHolderVisible) {
        
        targetVerticalPosition = CGRectGetMinY(objectIdentificationHolderFrame);
    }
    CGFloat targetHeight = (CGRectGetMaxY(dataRepresentationHolderFrame) - targetVerticalPosition);
    dataRepresentationHolderFrame.origin.y = targetVerticalPosition;
    dataRepresentationHolderFrame.size.height = targetHeight;
    self.dataRepresentationHolder.frame = dataRepresentationHolderFrame;
    
    self.layoutPrepared = YES;
    [self updateLayout];
}

- (void)updateLayout {
    
    if (!self.isLayoutPrepared) {
        
        [self prepareLayout];
    }
    self.dataFetchButton.enabled = [self.registryHelper isAblePerformAuditRequest];
    self.actionButton.enabled = [self.registryHelper isAblePerformModifyRequest];
    self.channelGroupNameTextField.text = self.registryHelper.channelGroupName;
    self.namespaceNameTextField.text = self.registryHelper.namespaceName;
    [self.dataRepresentationList reloadData];
}

- (void)updateWithChannelGroupName:(NSString *)channelGroupName andNamespace:(NSString *)namespaceName {
    
    self.registryHelper.channelGroupName = channelGroupName;
    self.registryHelper.namespaceName = namespaceName;
    [self updateLayout];
}


#pragma mark - Handler methods

- (IBAction)handleDataAdditionButtonTap:(id)sender {
    
    PNObjectInformationView *information = [PNObjectInformationView viewFromNib];
    information.delegate = self;
    information.allowEditing = YES;
    [information showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
}

- (IBAction)handleDataFetchButtonTap:(id)sender {
    
    [self completeUserInput];
    
    PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
    [progressAlertView show];
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [self.registryHelper performDataFetchRequestWithBlock:^(NSError *requestError) {
        
        [progressAlertView dismissWithAnimation:YES];
        PNAlertType type = (requestError ? PNAlertWarning : PNAlertSuccess);
        
        NSString *shortDescription = (requestError ? @"channelRegistryAuditFailureAlertViewShortDescription" :
                                      @"channelRegistryAuditSuccessAlertViewShortDescription");
        NSString *detailedDescription = nil;
        
        if ([weakSelf.registryHelper workingWithNamespace]) {
            
            detailedDescription = (requestError ? @"channelRegistryNamespaceAuditFailureAlertViewDescription" :
                                   @"channelRegistryNamespaceAuditSuccessAlertViewDescription");
            
            if (requestError) {
                
                detailedDescription = [NSString stringWithFormat:[detailedDescription localized], requestError];
            }
        }
        else if ([weakSelf.registryHelper workingWithChannelGroup]) {
            
            detailedDescription = (requestError ? @"channelRegistryGroupAuditFailureAlertViewDescription" :
                                   @"channelRegistryGroupAuditSuccessAlertViewDescription");
            
            if (!requestError) {
                
                detailedDescription = [NSString stringWithFormat:[detailedDescription localized],
                                       weakSelf.registryHelper.namespaceName];
            }
            else {
                
                detailedDescription = [NSString stringWithFormat:[detailedDescription localized],
                                       weakSelf.registryHelper.namespaceName, requestError];
            }
        }
        else {
            
            detailedDescription = (requestError ? @"channelRegistryGroupChannelsAuditFailureAlertViewDescription" :
                                   @"channelRegistryGroupChannelsAuditSuccessAlertViewDescription");
            
            PNChannelGroup *group = [PNChannelGroup channelGroupWithName:weakSelf.registryHelper.channelGroupName
                                                             inNamespace:weakSelf.registryHelper.namespaceName];
            if (!requestError) {
                
                detailedDescription = [NSString stringWithFormat:[detailedDescription localized], group.name];
            }
            else {
                
                detailedDescription = [NSString stringWithFormat:[detailedDescription localized], group.name,
                                       requestError];
            }
        }
        
        PNAlertView *alert = [PNAlertView viewWithTitle:@"channelRegistryAlertViewTitle" type:type
                                           shortMessage:shortDescription detailedMessage:[detailedDescription localized]
                                      cancelButtonTitle:nil otherButtonTitles:nil andEventHandlingBlock:NULL];
        [alert show];
        [weakSelf updateLayout];
    }];
}

- (IBAction)handleActionButtonTap:(id)sender {
    
    [self completeUserInput];
    
    PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
    [progressAlertView show];
    
    NSArray *objectForManipulation = [[self.registryHelper representationData] copy];
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    
    [self.registryHelper performDataModifyRequestWithBlock:^(NSError *requestError) {
        
        [progressAlertView dismissWithAnimation:YES];
        PNAlertType type = (requestError ? PNAlertWarning : PNAlertSuccess);
        
        NSString *shortDescription = nil;
        NSString *detailedDescription = nil;
        
        if ([weakSelf.registryHelper workingWithNamespace]) {
                
            shortDescription = (requestError ? @"channelRegistryNamespaceRemoveFailureAlertViewShortDescription" :
                                @"channelRegistryNamespaceRemoveSuccessAlertViewShortDescription");
            
            detailedDescription = (requestError ? @"channelRegistryNamespaceRemoveFailureAlertViewDescription" :
                                   @"channelRegistryNamespaceRemoveSuccessAlertViewDescription");
            
            if (!requestError) {
                
                detailedDescription = [NSString stringWithFormat:[detailedDescription localized],
                                       weakSelf.registryHelper.namespaceName];
            }
            else {
                
                detailedDescription = [NSString stringWithFormat:[detailedDescription localized],
                                       weakSelf.registryHelper.namespaceName, requestError];
            }
        }
        else if ([weakSelf.registryHelper workingWithChannelGroup]) {
            
            shortDescription = (requestError ? @"channelRegistryGroupRemoveFailureAlertViewShortDescription" :
                                @"channelRegistryGroupRemoveSuccessAlertViewShortDescription");
            
            detailedDescription = (requestError ? @"channelRegistryGroupRemoveFailureAlertViewDescription" :
                                   @"channelRegistryGroupRemoveSuccessAlertViewDescription");
            
            if (!requestError) {
                
                detailedDescription = [NSString stringWithFormat:[detailedDescription localized],
                                       weakSelf.registryHelper.channelGroupName];
            }
            else {
                
                detailedDescription = [NSString stringWithFormat:[detailedDescription localized],
                                       weakSelf.registryHelper.channelGroupName, requestError];
            }
        }
        else {
                
            shortDescription = (requestError ? @"channelRegistryGroupChannelListModificationFailureAlertViewShortDescription" :
                                @"channelRegistryGroupChannelListModificationSuccessAlertViewShortDescription");
            
            detailedDescription = (requestError ? @"channelRegistryGroupChannelsAddFailureAlertViewShortDescription" :
                                   @"channelRegistryGroupChannelsAddSuccessAlertViewShortDescription");
            if ([weakSelf.registryHelper isObjectRemove]) {
                
                detailedDescription = (requestError ? @"channelRegistryGroupChannelsRemoveFailureAlertViewShortDescription" :
                                       @"channelRegistryGroupChannelsRemoveSuccessAlertViewShortDescription");
            }
            
            PNChannelGroup *group = [PNChannelGroup channelGroupWithName:weakSelf.registryHelper.channelGroupName
                                                             inNamespace:weakSelf.registryHelper.namespaceName];
            NSString *objects = [[objectForManipulation valueForKey:@"name"] componentsJoinedByString:@","];
            if (!requestError) {
                
                detailedDescription = [NSString stringWithFormat:[detailedDescription localized], objects, group];
            }
            else {
                
                detailedDescription = [NSString stringWithFormat:[detailedDescription localized], objects, group,
                                       requestError];
            }
        }
        
        PNAlertView *alert = [PNAlertView viewWithTitle:@"channelRegistryAlertViewTitle" type:type
                                           shortMessage:shortDescription detailedMessage:[detailedDescription localized]
                                      cancelButtonTitle:nil otherButtonTitles:nil andEventHandlingBlock:NULL];
        [alert show];
        [weakSelf updateLayout];
    }];
}

- (IBAction)handleCloseButtonTap:(id)sender {
    
    [self dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
}


#pragma mark - Channel information delegate methods

- (void)objectInformation:(PNObjectInformationView *)informationView didEndEditing:(id <PNChannelProtocol>)object
                withState:(NSDictionary *)channelState andPresenceObservation:(BOOL)shouldObserverPresence {
    
    [informationView dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
    [self.registryHelper addObject:object];
    [self updateLayout];
}


#pragma mark - UItextField delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:self.channelGroupNameTextField]) {
        
        self.registryHelper.channelGroupName = finalString;
    }
    else {
        
        self.registryHelper.namespaceName = finalString;
    }
    
    [self updateLayout];
    
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self completeUserInput];
    
    
    return YES;
}


#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [[self.registryHelper representationData] count];;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *objectCellIdentifier = @"objectCellIdentifier";
    
    id cell = [tableView dequeueReusableCellWithIdentifier:objectCellIdentifier];
    if (!cell) {
                
        cell = [[PNObjectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:objectCellIdentifier];
        ((PNObjectCell *)cell).showBadge = NO;
    }
    
    id <PNChannelProtocol> object = [[self.registryHelper representationData] objectAtIndex:indexPath.row];
    [(PNObjectCell *)cell updateForObject:object];
    
    if ([self.registryHelper workingWithChannelGroupChannels]) {
        
        ((PNObjectCell *)cell).selectedBackgroundView = nil;
        ((PNObjectCell *)cell).selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([self.registryHelper isObjectRemove]) {
        
        if ([self.registryHelper willManipulateWith:object]) {
            
            ((PNObjectCell *)cell).accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            
            ((PNObjectCell *)cell).accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    if (self.registryHelper.operationMode == PNChannelRegistryHelperNamespaceRemoveMode ||
        self.registryHelper.operationMode == PNChannelRegistryHelperGroupRemoveMode ||
        self.registryHelper.operationMode == PNChannelRegistryHelperGroupChannelsAddMode) {
        
        style = UITableViewCellEditingStyleDelete;
    }
    
    
    return style;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id targetObject = [[self.registryHelper representationData] objectAtIndex:indexPath.row];
    if (self.registryHelper.operationMode == PNChannelRegistryHelperGroupChannelsRemoveMode) {
        
        if (![self.registryHelper willManipulateWith:targetObject]) {
            
            [self.registryHelper addObject:targetObject];
        }
        else {
            
            [self.registryHelper removeObject:targetObject];
        }
        [self.dataRepresentationList reloadData];
    }
    else {
        
        id <PNChannelProtocol> object = [[self.registryHelper representationData] objectAtIndex:indexPath.row];
        if (self.registryHelper.operationMode == PNChannelRegistryHelperNamespaceAuditMode) {

            PNChannelRegistryView *registryView = [PNChannelRegistryView viewFromNibForChannelGroupAudit];
            [registryView updateWithChannelGroupName:nil andNamespace:((PNChannelGroupNamespace *)object).nspace];
            [registryView showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
        }
        else if (self.registryHelper.operationMode == PNChannelRegistryHelperGroupAuditMode) {
            
            PNChannelRegistryView *registryView = [PNChannelRegistryView viewFromNibForChannelGroupChannelsAudit];
            [registryView updateWithChannelGroupName:((PNChannelGroup *)object).groupName
                                        andNamespace:((PNChannelGroup *)object).nspace];
            [registryView showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
        }
    }
    
    [self updateLayout];
}

- (void)  tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
  forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        id <PNChannelProtocol> object = [[self.registryHelper representationData] objectAtIndex:indexPath.row];
        
        if ([self.registryHelper workingWithChannelGroup]) {
            
            self.registryHelper.channelGroupName = ((PNChannelGroup *)object).groupName;
        }
        
        if ([self.registryHelper workingWithNamespace] || [self.registryHelper workingWithChannelGroup]) {
            
            self.registryHelper.namespaceName = ((PNChannelGroupNamespace *)object).nspace;
            
            [self handleActionButtonTap:nil];
        }
        
        if ([self.registryHelper workingWithChannelGroupChannels]){
            
            [self.registryHelper removeObject:object];
            [self updateLayout];
        }
    }
}

#pragma mark -


@end
