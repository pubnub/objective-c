//
//  PNChangeAccessRightsView.m
//  pubnub
//
//  Created by Sergey Mamontov on 11/27/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//


#import "PNChangeAccessRightsView.h"
#import "PNAccessRightsHelper.h"
#import "PNAccessRightsInformationCell.h"


#pragma mark Structures

/**
 Represent possible access levels.
 */
typedef enum _PNAccessLevels {
    PNApplicationAccessLevel,
    PNChannelAccessLevel,
    PNUserAccessLevel
} PNAccessLevels;

struct PNChangeInterfaceElementsVisibilityStruct {
    
    BOOL accesRightsSwitchHolderView;
    BOOL accessDurationLabel;
    BOOL accessDurationTextField;
    BOOL accessDurationMaximumValueLabel;
    BOOL targetChannelLabel;
    BOOL targetChannelTextField;
    BOOL targetObjectLabel;
    BOOL targetObjectTextField;
    BOOL targetObjectAdditionButton;
    BOOL targetObjectsTableView;
    BOOL accessRightsLabel;
    BOOL accessRightsTableView;
};

struct PNChangeInterfaceElementsPositionStruct {
    
    CGSize viewSize;
    CGPoint targetChannelLabelPosition;
    CGPoint targetChannelTextFieldPosition;
    CGPoint targetObjectLabelPosition;
    CGPoint targetObjectTextFieldPosition;
    CGPoint targetObjectAdditionButtonPosition;
    CGPoint targetObjectsTableViewPosition;
    CGPoint accessRightsLabelPosition;
    CGPoint accessRightsTableViewPosition;
};

struct PNChangeInterfaceLayoutStruct {
    
    struct PNChangeInterfaceElementsPositionStruct application;
    struct PNChangeInterfaceElementsPositionStruct channel;
    struct PNChangeInterfaceElementsPositionStruct user;
};

struct PNChangeInterfaceLayoutByModeStruct {
    
    struct PNChangeInterfaceLayoutStruct grant;
    struct PNChangeInterfaceLayoutStruct revoke;
};

struct PNChangeInterfaceVisibilityStruct {
    
    struct PNChangeInterfaceElementsVisibilityStruct application;
    struct PNChangeInterfaceElementsVisibilityStruct channel;
    struct PNChangeInterfaceElementsVisibilityStruct user;
};

struct PNChangeInterfaceVisibilityByModeStruct {
    
    struct PNChangeInterfaceVisibilityStruct grant;
    struct PNChangeInterfaceVisibilityStruct revoke;
};

static struct PNChangeInterfaceLayoutByModeStruct PNChangeInterfaceLayout = {
    
    .grant = {
        
        .application = {
            
            .viewSize = {.width = 600.0f, 485.0f},
            .targetChannelLabelPosition = {.x = 10.0f, .y = 190.0f},
            .targetChannelTextFieldPosition = {.x = 162.0f, .y = 187.0f},
            .targetObjectLabelPosition = {.x = 10.0f, .y = 170.0f},
            .targetObjectTextFieldPosition = {.x = 162.0f, .y = 167.0f},
            .targetObjectAdditionButtonPosition = {.x = 530.0f, .y = 159.0f},
            .targetObjectsTableViewPosition = {.x = 10.0f, .y = 207.0f},
            .accessRightsLabelPosition = {.x = 10.0f, .y = 186.0f},
            .accessRightsTableViewPosition = {.x = 10.0f, .y = 215.0f}
        },
        .channel = {
            
            .viewSize = {.width = 600.0f, 695.0f},
            .targetChannelLabelPosition = {.x = 10.0f, .y = 190.0f},
            .targetChannelTextFieldPosition = {.x = 162.0f, .y = 187.0f},
            .targetObjectLabelPosition = {.x = 10.0f, .y = 190.0f},
            .targetObjectTextFieldPosition = {.x = 162.0f, .y = 187.0f},
            .targetObjectAdditionButtonPosition = {.x = 530.0f, .y = 181.0f},
            .targetObjectsTableViewPosition = {.x = 10.0f, .y = 227.0f},
            .accessRightsLabelPosition = {.x = 10.0f, .y = 395.0f},
            .accessRightsTableViewPosition = {.x = 10.0f, .y = 424.0f}
        },
        .user = {
            
            .viewSize = {.width = 600.0f, 740.0f},
            .targetChannelLabelPosition = {.x = 10.0f, .y = 190.0f},
            .targetChannelTextFieldPosition = {.x = 162.0f, .y = 187.0f},
            .targetObjectLabelPosition = {.x = 10.0f, .y = 223.0f},
            .targetObjectTextFieldPosition = {.x = 162.0f, .y = 226.0f},
            .targetObjectAdditionButtonPosition = {.x = 530.0f, .y = 221.0f},
            .targetObjectsTableViewPosition = {.x = 10.0f, .y = 270.0f},
            .accessRightsLabelPosition = {.x = 10.0f, .y = 438.0f},
            .accessRightsTableViewPosition = {.x = 10.0f, .y = 467.0f}
        }
    },
    .revoke = {
        .application = {
            
            .viewSize = {.width = 600.0f, 389.0f},
            .targetChannelLabelPosition = {.x = 10.0f, .y = 147.0f},
            .targetChannelTextFieldPosition = {.x = 162.0f, .y = 144.0f},
            .targetObjectLabelPosition = {.x = 10.0f, .y = 127.0f},
            .targetObjectTextFieldPosition = {.x = 162.0f, .y = 127.0f},
            .targetObjectAdditionButtonPosition = {.x = 530.0f, .y = 119.0f},
            .targetObjectsTableViewPosition = {.x = 10.0f, .y = 167.0f},
            .accessRightsLabelPosition = {.x = 10.0f, .y = 90.0f},
            .accessRightsTableViewPosition = {.x = 10.0f, .y = 119.0f}
        },
        .channel = {
            
            .viewSize = {.width = 600.0f, 593.0f},
            .targetChannelLabelPosition = {.x = 10.0f, .y = 147.0f},
            .targetChannelTextFieldPosition = {.x = 162.0f, .y = 144.0f},
            .targetObjectLabelPosition = {.x = 10.0f, .y = 90.0f},
            .targetObjectTextFieldPosition = {.x = 162.0f, .y = 90.0f},
            .targetObjectAdditionButtonPosition = {.x = 530.0f, .y = 85.0f},
            .targetObjectsTableViewPosition = {.x = 10.0f, .y = 130.0f},
            .accessRightsLabelPosition = {.x = 10.0f, .y = 294.0f},
            .accessRightsTableViewPosition = {.x = 10.0f, .y = 323.0f}
        },
        .user = {
            
            .viewSize = {.width = 600.0f, 637.0f},
            .targetChannelLabelPosition = {.x = 10.0f, .y = 93.0f},
            .targetChannelTextFieldPosition = {.x = 162.0f, .y = 90.0f},
            .targetObjectLabelPosition = {.x = 10.0f, .y = 133.0f},
            .targetObjectTextFieldPosition = {.x = 162.0f, .y = 133.0f},
            .targetObjectAdditionButtonPosition = {.x = 530.0f, .y = 128.0f},
            .targetObjectsTableViewPosition = {.x = 10.0f, .y = 173.0f},
            .accessRightsLabelPosition = {.x = 10.0f, .y = 337.0f},
            .accessRightsTableViewPosition = {.x = 10.0f, .y = 366.0f}
        }
    }
};

static struct PNChangeInterfaceVisibilityByModeStruct PNChangeInterfaceVisibility = {
    
    .grant = {
        .application = {
            
            .accesRightsSwitchHolderView = YES,
            .accessDurationLabel = YES,
            .accessDurationTextField = YES,
            .accessDurationMaximumValueLabel = YES,
            .targetChannelLabel = NO,
            .targetChannelTextField = NO,
            .targetObjectLabel = NO,
            .targetObjectTextField = NO,
            .targetObjectAdditionButton = NO,
            .targetObjectsTableView = NO,
            .accessRightsLabel = YES,
            .accessRightsTableView = YES
        },
        .channel = {
            
            .accesRightsSwitchHolderView = YES,
            .accessDurationLabel = YES,
            .accessDurationTextField = YES,
            .accessDurationMaximumValueLabel = YES,
            .targetChannelLabel = NO,
            .targetChannelTextField = NO,
            .targetObjectLabel = YES,
            .targetObjectTextField = YES,
            .targetObjectAdditionButton = YES,
            .targetObjectsTableView = YES,
            .accessRightsLabel = YES,
            .accessRightsTableView = YES
        },
        .user = {
            
            .accesRightsSwitchHolderView = YES,
            .accessDurationLabel = YES,
            .accessDurationTextField = YES,
            .accessDurationMaximumValueLabel = YES,
            .targetChannelLabel = YES,
            .targetChannelTextField = YES,
            .targetObjectLabel = YES,
            .targetObjectTextField = YES,
            .targetObjectAdditionButton = YES,
            .targetObjectsTableView = YES,
            .accessRightsLabel = YES,
            .accessRightsTableView = YES
        }
    },
    .revoke = {
        
        .application = {
            
            .accesRightsSwitchHolderView = NO,
            .accessDurationLabel = NO,
            .accessDurationTextField = NO,
            .accessDurationMaximumValueLabel = NO,
            .targetChannelLabel = NO,
            .targetChannelTextField = NO,
            .targetObjectLabel = NO,
            .targetObjectTextField = NO,
            .targetObjectAdditionButton = NO,
            .targetObjectsTableView = NO,
            .accessRightsLabel = YES,
            .accessRightsTableView = YES
        },
        .channel = {
            
            .accesRightsSwitchHolderView = NO,
            .accessDurationLabel = NO,
            .accessDurationTextField = NO,
            .accessDurationMaximumValueLabel = NO,
            .targetChannelLabel = NO,
            .targetChannelTextField = NO,
            .targetObjectLabel = YES,
            .targetObjectTextField = YES,
            .targetObjectAdditionButton = YES,
            .targetObjectsTableView = YES,
            .accessRightsLabel = YES,
            .accessRightsTableView = YES
        },
        .user = {
            
            .accesRightsSwitchHolderView = NO,
            .accessDurationLabel = NO,
            .accessDurationTextField = NO,
            .accessDurationMaximumValueLabel = NO,
            .targetChannelLabel = YES,
            .targetChannelTextField = YES,
            .targetObjectLabel = YES,
            .targetObjectTextField = YES,
            .targetObjectAdditionButton = YES,
            .targetObjectsTableView = YES,
            .accessRightsLabel = YES,
            .accessRightsTableView = YES
        }
    }
};

#pragma mark - Private interface methods

@interface PNChangeAccessRightsView () <UITextFieldDelegate, UITableViewDataSource>


#pragma mark - Properties

@property (nonatomic, assign) PNAccessRightsLevel currentAccessRightsLevel;
@property (nonatomic, assign) PNAccessRightsChangeMode currentAccessRightsChangeMode;
@property (nonatomic, assign) CGRect realFrame;

// Stores reference on data manipulation helper
@property (nonatomic, strong) IBOutlet PNAccessRightsHelper *helper;

@property (nonatomic, pn_desired_weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, pn_desired_weak) IBOutlet UIView *accessRightsSwitchHolderView;
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *readAccessRightSwitch;
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *writeAccessRightSwitch;
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *accessDurationLabel;
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *accessDurationTextField;
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *accessDurationMaximumValueLabel;

@property (nonatomic, pn_desired_weak) IBOutlet UIButton *applicationAccessLevelButton;
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *channelAccessLevelButton;
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *userAccessLevelButton;

@property (nonatomic, pn_desired_weak) IBOutlet UILabel *accessRightsLabel;
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *accessRightsTableView;

@property (nonatomic, pn_desired_weak) IBOutlet UILabel *targetChannelNameLabel;
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *targetChannelNameTextField;

@property (nonatomic, pn_desired_weak) IBOutlet UILabel *targetObjectAdditionLabel;
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *targetObjectAdditionLabelTextField;
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *addButton;
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *targetObjectsTableView;

@property (nonatomic, pn_desired_weak) IBOutlet UIButton *closeButton;
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *actionButton;

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *redButtons;


#pragma mark - Instance methods

#pragma mark - Interface customization

- (void)prepareInterface;
- (void)updateInterface;
- (void)updateElementsVisibility;
- (void)updateElementsPositionAndSize;

/**
 Iterate over list of access level types button and select specified. All other buttons will be deselected.
 
 @param button
 \b UIButton instance which should be selected among other buttons of same type/group.
 */
- (void)selectAccessLevelButton:(UIButton *)buttonForSelection;


#pragma mark - Handler methods

- (IBAction)addButtonTapped:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)actionButtonTapped:(id)sender;
- (IBAction)applicationAccessLevelButtonTapped:(id)sender;
- (IBAction)channelAccessLevelButtonTapped:(id)sender;
- (IBAction)userAccessLevelButtonTapped:(id)sender;

#pragma mark - Misc methods

/**
 List of buttons which allow to change target access level.
 
 @return \b NSArray instance with list of access level change buttons.
 */
- (NSArray *)accessLevelSelectorButtons;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNChangeAccessRightsView


#pragma mark - Class methods

+ (id)viewFromNib {
    
    NSArray *nibElements = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    __block UIView *view = nil;
    [nibElements enumerateObjectsUsingBlock:^(id element, NSUInteger elementIds, BOOL *elementEnumeratorStop) {
        
        if (![element isKindOfClass:[PNAccessRightsHelper class]]) {
            
            view = element;
            *elementEnumeratorStop = YES;

        }
    }];
    
    
    return view;
}


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward to the super class to complete intialization
    [super awakeFromNib];
    
    self.currentAccessRightsLevel = PNApplicationAccessRightsLevel;
}

- (void)didMoveToSuperview {
    
    self.realFrame = self.frame;
    [self.helper updateAccessRightsLevel:self.currentAccessRightsLevel];
    [self prepareInterface];
    [self updateInterface];
}

- (void)setAccessRightsChangeMode:(PNAccessRightsChangeMode)mode {
    
    self.currentAccessRightsChangeMode = mode;
}


#pragma mark - Interface customization

- (void)prepareInterface {
    
    NSArray *buttons = [[self accessLevelSelectorButtons] arrayByAddingObjectsFromArray:self.redButtons];
    [buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger buttonIdx, BOOL *buttonEnumeratorStop) {
        
        UIImage *buttonBackground = [button backgroundImageForState:UIControlStateNormal];
        UIImage *selectedButtonBackground = [button backgroundImageForState:UIControlStateSelected];
        UIImage *stretchableButtonBackground = [buttonBackground stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f];
        UIImage *stretchableSelectedButtonBackground = [selectedButtonBackground stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f];
        
        [button setBackgroundImage:stretchableButtonBackground forState:UIControlStateNormal];
        [button setBackgroundImage:stretchableSelectedButtonBackground forState:UIControlStateSelected];
    }];
    
    self.applicationAccessLevelButton.selected = YES;
}

- (void)updateInterface {
    
    [self selectAccessLevelButton:[[self accessLevelSelectorButtons] objectAtIndex:self.currentAccessRightsLevel]];
    
    NSString *targetObjectLabelText = (self.currentAccessRightsLevel == PNUserAccessRightsLevel ? @"Authorization key" : @"Channel");
    self.targetObjectAdditionLabel.text = [NSString stringWithFormat:@"%@:", targetObjectLabelText];
    self.targetObjectAdditionLabelTextField.text = @"";
    
    NSString *targetAccessRightsChangeAction = (self.currentAccessRightsChangeMode == PNAccessRightsGrantMode ? @"Grant" : @"Revoke");
    self.titleLabel.text = [NSString stringWithFormat:@"%@ access rights", targetAccessRightsChangeAction];
    
    [self.actionButton setTitle:targetAccessRightsChangeAction forState:UIControlStateNormal];
    self.actionButton.enabled = [self.helper canSendRequest];
    
    [self updateElementsVisibility];
    [self updateElementsPositionAndSize];
    [self updateShadow];
}

- (void)updateElementsVisibility {
    
    struct PNChangeInterfaceVisibilityStruct targetModeStruct = PNChangeInterfaceVisibility.grant;
    if (self.currentAccessRightsChangeMode == PNAccessRightsRevokeMode) {
        
        targetModeStruct = PNChangeInterfaceVisibility.revoke;
    }
    struct PNChangeInterfaceElementsVisibilityStruct targetVisibilityStruct = targetModeStruct.application;
    if (self.currentAccessRightsLevel == PNChannelAccessRightsLevel) {
        
        targetVisibilityStruct = targetModeStruct.channel;
    }
    else if (self.currentAccessRightsLevel == PNUserAccessRightsLevel) {
        
        targetVisibilityStruct = targetModeStruct.user;
    }
    
    self.accessRightsSwitchHolderView.hidden = !targetVisibilityStruct.accesRightsSwitchHolderView;
    self.accessDurationLabel.hidden = !targetVisibilityStruct.accessDurationLabel;
    self.accessDurationTextField.hidden = !targetVisibilityStruct.accessDurationTextField;
    self.accessDurationMaximumValueLabel.hidden = !targetVisibilityStruct.accessDurationMaximumValueLabel;
    self.targetChannelNameLabel.hidden = !targetVisibilityStruct.targetChannelLabel;
    self.targetChannelNameTextField.hidden = !targetVisibilityStruct.targetChannelTextField;
    self.targetObjectAdditionLabel.hidden = !targetVisibilityStruct.targetObjectLabel;
    self.targetObjectAdditionLabelTextField.hidden = !targetVisibilityStruct.targetObjectTextField;
    self.targetObjectsTableView.hidden = !targetVisibilityStruct.targetObjectsTableView;
    self.addButton.hidden = !targetVisibilityStruct.targetObjectAdditionButton;
    self.accessRightsLabel.hidden = !targetVisibilityStruct.accessRightsLabel;
    self.accessRightsTableView.hidden = !targetVisibilityStruct.accessRightsTableView;
}

- (void)updateElementsPositionAndSize {
    
    struct PNChangeInterfaceLayoutStruct targetModeStruct = PNChangeInterfaceLayout.grant;
    if (self.currentAccessRightsChangeMode == PNAccessRightsRevokeMode) {
        
        targetModeStruct = PNChangeInterfaceLayout.revoke;
    }
    struct PNChangeInterfaceElementsPositionStruct targetPositionStruct = targetModeStruct.application;
    if (self.currentAccessRightsLevel == PNChannelAccessRightsLevel) {
        
        targetPositionStruct = targetModeStruct.channel;
    }
    else if (self.currentAccessRightsLevel == PNUserAccessRightsLevel) {
        
        targetPositionStruct = targetModeStruct.user;
    }
    
    
    self.targetChannelNameLabel.frame = (CGRect){.origin = targetPositionStruct.targetChannelLabelPosition,
                                                 .size = self.targetChannelNameLabel.frame.size};
    self.targetChannelNameTextField.frame = (CGRect){.origin = targetPositionStruct.targetChannelTextFieldPosition,
                                                     .size = self.targetChannelNameTextField.frame.size};
    self.targetObjectAdditionLabel.frame = (CGRect){.origin = targetPositionStruct.targetObjectLabelPosition,
                                                    .size = self.targetObjectAdditionLabel.frame.size};
    self.targetObjectAdditionLabelTextField.frame = (CGRect){.origin = targetPositionStruct.targetObjectTextFieldPosition,
                                                    .size = self.targetObjectAdditionLabelTextField.frame.size};
    self.addButton.frame = (CGRect){.origin = targetPositionStruct.targetObjectAdditionButtonPosition, .size = self.addButton.frame.size};
    self.targetObjectsTableView.frame = (CGRect){.origin = targetPositionStruct.targetObjectsTableViewPosition,
                                                    .size = self.targetObjectsTableView.frame.size};
    self.accessRightsLabel.frame = (CGRect){.origin = targetPositionStruct.accessRightsLabelPosition, .size = self.accessRightsLabel.frame.size};
    self.accessRightsTableView.frame = (CGRect){.origin = targetPositionStruct.accessRightsTableViewPosition,
                                                .size = self.accessRightsTableView.frame.size};
    
    
    CGSize targetViewSize = targetPositionStruct.viewSize;
    CGRect targetViewFrame = self.frame;
    targetViewFrame.size = targetViewSize;
    targetViewFrame.origin.y = self.realFrame.origin.y + (self.realFrame.size.height - targetViewFrame.size.height) * 0.5f;
    
    
    CGRect targetCloseButtonFrame = self.closeButton.frame;
    CGRect targetAuditButtonFrame = self.actionButton.frame;
    CGFloat buttonsBottomOffset = self.frame.size.height - (targetCloseButtonFrame.origin.y + targetCloseButtonFrame.size.height);
    targetCloseButtonFrame.origin.y = targetViewFrame.size.height - targetCloseButtonFrame.size.height - buttonsBottomOffset;
    targetAuditButtonFrame.origin.y = targetCloseButtonFrame.origin.y;
    self.closeButton.frame = targetCloseButtonFrame;
    self.actionButton.frame = targetAuditButtonFrame;
    
    self.frame = targetViewFrame;
}

- (void)selectAccessLevelButton:(UIButton *)buttonForSelection {
    
    [self endEditing:YES];
    [[self accessLevelSelectorButtons] enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger buttonIdx, BOOL *buttonEnumeratorStop) {
        
        button.selected = [buttonForSelection isEqual:button];
    }];
}


#pragma mark - Handler methods

- (IBAction)addButtonTapped:(id)sender {
    
    if ([[self.targetObjectAdditionLabelTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] length]) {
        
        [self.helper addTargetObject:self.targetObjectAdditionLabelTextField.text];
    }
    
    [self endEditing:YES];
    [self updateInterface];
}

- (IBAction)closeButtonTapped:(id)sender {
    
    [self removeFromSuperview];
}

- (IBAction)actionButtonTapped:(id)sender {
    
    self.userInteractionEnabled = NO;
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    BOOL isReadRightsOn = self.readAccessRightSwitch.isOn;
    BOOL isWriteRightsOn = self.writeAccessRightSwitch.isOn;
    NSInteger period = self.accessDurationTextField.text.length > 0 ? [self.accessDurationTextField.text integerValue] : [self.accessDurationTextField.placeholder integerValue];
    
    PNClientChannelAccessRightsChangeBlock handlerBlock = ^(PNAccessRightsCollection *collection, PNError *revokeError) {
        
        weakSelf.userInteractionEnabled = YES;
        [weakSelf.helper updateWithAccessRightsCollectionInformation:collection];
    };
    switch (self.currentAccessRightsLevel) {
        case PNApplicationAccessRightsLevel:
            {
                if (self.currentAccessRightsChangeMode == PNAccessRightsGrantMode && (isReadRightsOn || isWriteRightsOn)) {
                    
                    if (isReadRightsOn && isWriteRightsOn) {
                        
                        [self.delegate grantApplicationAllRights:self forPeriod:period withHandlerBlock:handlerBlock];
                    }
                    else if (isReadRightsOn) {
                        
                        [self.delegate grantApplicationReadRight:self forPeriod:period withHandlerBlock:handlerBlock];
                    }
                    else {
                        
                        [self.delegate grantApplicationWriteRight:self forPeriod:period withHandlerBlock:handlerBlock];
                    }
                }
                else {
                    
                    [self.delegate revokeApplicationAccessRights:self withHandlerBlock:handlerBlock];
                }
            }
            break;
        case PNChannelAccessRightsLevel:
            {
                NSArray *channels = [PNChannel channelsWithNames:self.helper.targetObjects];
                if (self.currentAccessRightsChangeMode == PNAccessRightsGrantMode && (isReadRightsOn || isWriteRightsOn)) {
                    
                    if (isReadRightsOn && isWriteRightsOn) {
                        
                        [self.delegate grantAllRightsToChannels:channels forPeriod:period fromView:self withHandlerBlock:handlerBlock];
                    }
                    else if (isReadRightsOn) {
                        
                        [self.delegate grantReadRightToChannels:channels forPeriod:period fromView:self withHandlerBlock:handlerBlock];
                    }
                    else {
                        
                        [self.delegate grantWriteRightToChannels:channels forPeriod:period fromView:self withHandlerBlock:handlerBlock];
                    }
                }
                else {
                    
                    [self.delegate revokeAccessRightsFromChannels:channels fromView:self withHandlerBlock:handlerBlock];
                }
            }
            break;
        case PNUserAccessRightsLevel:
            {
                if (self.currentAccessRightsChangeMode == PNAccessRightsGrantMode && (isReadRightsOn || isWriteRightsOn)) {
                    
                    if (isReadRightsOn && isWriteRightsOn) {
                        
                        [self.delegate grantAllRightsToChannel:[PNChannel channelWithName:self.helper.targetChannel]
                                                       clients:self.helper.targetObjects forPeriod:period fromView:self withHandlerBlock:handlerBlock];
                    }
                    else if (isReadRightsOn) {
                        
                        [self.delegate grantReadRightToChannel:[PNChannel channelWithName:self.helper.targetChannel]
                                                       clients:self.helper.targetObjects forPeriod:period fromView:self withHandlerBlock:handlerBlock];
                    }
                    else {
                        
                        [self.delegate grantWriteRightToChannel:[PNChannel channelWithName:self.helper.targetChannel]
                                                        clients:self.helper.targetObjects forPeriod:period fromView:self withHandlerBlock:handlerBlock];
                    }
                }
                else {
                    
                    [self.delegate revokeAccessRightsFromChannel:[PNChannel channelWithName:self.helper.targetChannel]
                                                      forClients:self.helper.targetObjects fromView:self withHandlerBlock:handlerBlock];
                }
            }
            break;
    }
}

- (IBAction)applicationAccessLevelButtonTapped:(id)sender {
    
    self.currentAccessRightsLevel = PNApplicationAccessLevel;
    [self.helper updateAccessRightsLevel:self.currentAccessRightsLevel];
    [self updateInterface];
}

- (IBAction)channelAccessLevelButtonTapped:(id)sender {
    
    self.currentAccessRightsLevel = PNChannelAccessLevel;
    [self.helper updateAccessRightsLevel:self.currentAccessRightsLevel];
    [self updateInterface];
}

- (IBAction)userAccessLevelButtonTapped:(id)sender {
    
    self.currentAccessRightsLevel = PNUserAccessLevel;
    [self.helper updateAccessRightsLevel:self.currentAccessRightsLevel];
    [self updateInterface];
}


#pragma mark - Misc methods

- (NSArray *)accessLevelSelectorButtons {
    
    return @[self.applicationAccessLevelButton, self.channelAccessLevelButton, self.userAccessLevelButton];
}


#pragma mark - UITextField delegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if ([textField isEqual:self.targetChannelNameTextField]) {
        
        NSString *targetChannel = nil;
        if ([textField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0) {
            
            targetChannel = textField.text;
        }
        
        self.helper.targetChannel = targetChannel;
        [self updateInterface];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self endEditing:YES];
    
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL shouldChangeCharactersInRange = YES;
    if ([textField isEqual:self.accessDurationTextField]) {
        
        NSString *resultingString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        shouldChangeCharactersInRange = [resultingString rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound;
        if (shouldChangeCharactersInRange && [resultingString length]) {
            
            shouldChangeCharactersInRange = [resultingString integerValue] <= 525600;
        }
    }
    
    return shouldChangeCharactersInRange;
}


#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *auditionCellIdentifier = @"auditCellIdentifier";
    static NSString *objectCellIdentifier = @"objectCellIdentifier";
    
    id cell = [tableView dequeueReusableCellWithIdentifier:auditionCellIdentifier];
        
    if (!cell) {
        
        Class cellClass = [tableView isEqual:self.accessRightsTableView] ? [PNAccessRightsInformationCell class] : [UITableViewCell class];
            
            cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleValue1
                                    reuseIdentifier:([tableView isEqual:self.accessRightsTableView] ? auditionCellIdentifier : objectCellIdentifier)];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self updateInterface];
    }
}


#pragma mark -


@end
