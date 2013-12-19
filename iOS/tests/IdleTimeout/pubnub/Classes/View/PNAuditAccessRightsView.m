//
//  PNAuditAccessRightsView.m
//  pubnub
//
//  Created by Sergey Mamontov on 11/27/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//


#import "PNAuditAccessRightsView.h"
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

struct PNAuditInterfaceElementsVisibilityStruct {
    
    BOOL targetChannelLabel;
    BOOL targetChannelTextField;
    BOOL targetObjectLabel;
    BOOL targetObjectTextField;
    BOOL targetObjectAdditionButton;
    BOOL targetObjectsTableView;
    BOOL accessRightsLabel;
    BOOL accessRightsTableView;
};

struct PNAuditInterfaceElementsPositionStruct {
    
    CGSize viewSize;
    CGPoint targetObjectLabelPosition;
    CGPoint targetObjectTextFieldPosition;
    CGPoint targetObjectAdditionButtonPosition;
    CGPoint targetObjectsTableViewPosition;
    CGPoint accessRightsLabelPosition;
    CGPoint accessRightsTableViewPosition;
};

struct PNAuditInterfaceLayoutStruct {
    
    struct PNAuditInterfaceElementsPositionStruct application;
    struct PNAuditInterfaceElementsPositionStruct channel;
    struct PNAuditInterfaceElementsPositionStruct user;
};

struct PNAuditInterfaceVisibilityStruct {
    
    struct PNAuditInterfaceElementsVisibilityStruct application;
    struct PNAuditInterfaceElementsVisibilityStruct channel;
    struct PNAuditInterfaceElementsVisibilityStruct user;
};

static struct PNAuditInterfaceLayoutStruct PNAuditInterfaceLayout = {
    
    .application = {
        
        .viewSize = {.width = 600.0f, 389.0f},
        .targetObjectLabelPosition = {.x = 10.0f, .y = 127.0f},
        .targetObjectTextFieldPosition = {.x = 162.0f, .y = 127.0f},
        .targetObjectAdditionButtonPosition = {.x = 530.0f, .y = 119.0f},
        .targetObjectsTableViewPosition = {.x = 10.0f, .y = 167.0f},
        .accessRightsLabelPosition = {.x = 10.0f, .y = 90.0f},
        .accessRightsTableViewPosition = {.x = 10.0f, .y = 119.0f}
    },
    .channel = {
        
        .viewSize = {.width = 600.0f, 593.0f},
        .targetObjectLabelPosition = {.x = 10.0f, .y = 90.0f},
        .targetObjectTextFieldPosition = {.x = 162.0f, .y = 90.0f},
        .targetObjectAdditionButtonPosition = {.x = 530.0f, .y = 82.0f},
        .targetObjectsTableViewPosition = {.x = 10.0f, .y = 130.0f},
        .accessRightsLabelPosition = {.x = 10.0f, .y = 294.0f},
        .accessRightsTableViewPosition = {.x = 10.0f, .y = 323.0f}
    },
    .user = {
        
        .viewSize = {.width = 600.0f, 637.0f},
        .targetObjectLabelPosition = {.x = 10.0f, .y = 133.0f},
        .targetObjectTextFieldPosition = {.x = 162.0f, .y = 133.0f},
        .targetObjectAdditionButtonPosition = {.x = 530.0f, .y = 128.0f},
        .targetObjectsTableViewPosition = {.x = 10.0f, .y = 173.0f},
        .accessRightsLabelPosition = {.x = 10.0f, .y = 337.0f},
        .accessRightsTableViewPosition = {.x = 10.0f, .y = 366.0f}
    }
};

static struct PNAuditInterfaceVisibilityStruct PNAuditInterfaceVisibility = {
    
    .application = {
        
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
        
        .targetChannelLabel = YES,
        .targetChannelTextField = YES,
        .targetObjectLabel = YES,
        .targetObjectTextField = YES,
        .targetObjectAdditionButton = YES,
        .targetObjectsTableView = YES,
        .accessRightsLabel = YES,
        .accessRightsTableView = YES
    }
};

#pragma mark - Private interface methods

@interface PNAuditAccessRightsView () <UITextFieldDelegate, UITableViewDataSource>


#pragma mark - Properties

@property (nonatomic, assign) PNAccessRightsLevel currentAccessRightsLevel;
@property (nonatomic, assign) CGRect realFrame;

// Stores reference on data manipulation helper
@property (nonatomic, strong) IBOutlet PNAccessRightsHelper *helper;

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
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *auditButton;

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
- (IBAction)auditButtonTapped:(id)sender;
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

@implementation PNAuditAccessRightsView


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
    
    self.auditButton.enabled = [self.helper canSendRequest];
    
    [self updateElementsVisibility];
    [self updateElementsPositionAndSize];
    [self updateShadow];
}

- (void)updateElementsVisibility {
    
    struct PNAuditInterfaceElementsVisibilityStruct targetVisibilityStruct = PNAuditInterfaceVisibility.application;
    if (self.currentAccessRightsLevel == PNChannelAccessRightsLevel) {
        
        targetVisibilityStruct = PNAuditInterfaceVisibility.channel;
    }
    else if (self.currentAccessRightsLevel == PNUserAccessRightsLevel) {
        
        targetVisibilityStruct = PNAuditInterfaceVisibility.user;
    }
    
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
    
    struct PNAuditInterfaceElementsPositionStruct targetPositionStruct = PNAuditInterfaceLayout.application;
    if (self.currentAccessRightsLevel == PNChannelAccessRightsLevel) {
        
        targetPositionStruct = PNAuditInterfaceLayout.channel;
    }
    else if (self.currentAccessRightsLevel == PNUserAccessRightsLevel) {
        
        targetPositionStruct = PNAuditInterfaceLayout.user;
    }
    
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
    CGRect targetAuditButtonFrame = self.auditButton.frame;
    CGFloat buttonsBottomOffset = self.frame.size.height - (targetCloseButtonFrame.origin.y + targetCloseButtonFrame.size.height);
    targetCloseButtonFrame.origin.y = targetViewFrame.size.height - targetCloseButtonFrame.size.height - buttonsBottomOffset;
    targetAuditButtonFrame.origin.y = targetCloseButtonFrame.origin.y;
    self.closeButton.frame = targetCloseButtonFrame;
    self.auditButton.frame = targetAuditButtonFrame;
    
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

- (IBAction)auditButtonTapped:(id)sender {
    
    self.userInteractionEnabled = NO;
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    
    switch (self.currentAccessRightsLevel) {
        case PNApplicationAccessRightsLevel:
            {
                [self.delegate auditAccessRightsForApplication:self withHandlerBlock:^(PNAccessRightsCollection *collection, PNError *auditionError) {
                    
                    weakSelf.userInteractionEnabled = YES;
                    [weakSelf.helper updateWithAccessRightsCollectionInformation:collection];
                }];
            }
            break;
        case PNChannelAccessRightsLevel:
            {
                [self.delegate auditAccessRightsForChannels:[PNChannel channelsWithNames:self.helper.targetObjects]
                                       fromAccessRightsView:self withHandlerBlock:^(PNAccessRightsCollection *collection, PNError *auditionError) {
                    
                    weakSelf.userInteractionEnabled = YES;
                    [weakSelf.helper updateWithAccessRightsCollectionInformation:collection];
                }];
            }
            break;
        case PNUserAccessRightsLevel:
            {
                [self.delegate auditAccessRightsForChannel:[PNChannel channelWithName:self.helper.targetChannel]
                                                   clients:self.helper.targetObjects
                                      fromAccessRightsView:self withHandlerBlock:^(PNAccessRightsCollection *collection, PNError *auditionError) {
                    
                    weakSelf.userInteractionEnabled = YES;
                    [weakSelf.helper updateWithAccessRightsCollectionInformation:collection];
                }];
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
    
    NSString *targetChannel = nil;
    if ([textField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0) {
        
        targetChannel = textField.text;
    }
    
    self.helper.targetChannel = targetChannel;
    [self updateInterface];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self endEditing:YES];
    
    
    return YES;
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
