//
//  PNPresenceObservationView.m
//  pubnub
//
//  Created by Sergey Mamontov on 3/31/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNPresenceObservationView.h"
#import "PNObjectInformationDelegate.h"
#import "PNPresenceObservationHelper.h"
#import "PNObjectInformationView.h"
#import "NSString+PNLocalization.h"
#import "NSObject+PNAddition.h"
#import "UIView+PNAddition.h"
#import "PNChannelCell.h"
#import "PNAlertView.h"
#import "PNButton.h"


#pragma mark Static

static NSTimeInterval const kPNViewAppearAnimationDuration = 0.4f;
static NSTimeInterval const kPNViewDisappearAnimationDuration = 0.2f;


#pragma mark - Private interface declaration

@interface PNPresenceObservationView () <PNObjectInformationDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>


#pragma mark - Properties

/**
 Stores reference on table which display all channels on which client subscribed at this moment and can be used for
 presence manipulation.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *channelsList;

/**
 Stores reference on action button which allow to enable or disable presence observation on provided channel.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *actionButton;

@property (nonatomic, strong) IBOutlet PNPresenceObservationHelper *presenceStateHelper;

/**
 Stores whether view configured to disaply interface for presence enabling or not.
 */
@property (nonatomic, assign, getter = isPresenceEnablingState) BOOL presenceEnablingState;


#pragma mark - Instance methods

- (void)updateLayout;


#pragma mark - Handler methods

- (IBAction)handleChannelAddButtonTap:(id)sender;
- (IBAction)handleActionButtonTap:(id)sender;
- (IBAction)handleCloseButtonTap:(id)sender;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNPresenceObservationView


#pragma mark - Instance methods

+ (instancetype)viewFromNibForEnabling {
    
    // Swap method which should provide name for NIB file.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForEnabling)];
    
    PNPresenceObservationView *view = [self viewFromNib];
    view.presenceEnablingState = YES;
    
    // Swap method implementation back to restore original.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForEnabling)];
    
    
    return view;
}

+ (instancetype)viewFromNibForDisabling {
    
    // Swap method which should provide name for NIB file.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForDisabling)];
    
    PNPresenceObservationView *view = [self viewFromNib];
    
    // Swap method implementation back to restore original.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForDisabling)];
    
    
    return view;
}

+ (NSString *)viewNibNameForEnabling {
    
    return @"PNPresenceObservationEnableView";
}

+ (NSString *)viewNibNameForDisabling {
    
    return @"PNPresenceObservationDisableView";
}

- (void)awakeFromNib {
    
    // Forward method call to the super class
    [super awakeFromNib];

    [self updateLayout];
}

- (void)setPresenceEnablingState:(BOOL)presenceEnablingState {
    
    BOOL isStateChanged = presenceEnablingState != _presenceEnablingState;
    _presenceEnablingState = presenceEnablingState;
    self.presenceStateHelper.enablingPresenceObservation = presenceEnablingState;
    
    if (isStateChanged) {
        
        [self updateLayout];
    }
}

- (void)updateLayout {
    
    self.actionButton.enabled = [self.presenceStateHelper isAbleToChangePresenceState];
}

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNViewAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNViewDisappearAnimationDuration;
}


#pragma mark - Handler methods

- (IBAction)handleChannelAddButtonTap:(id)sender {
    
    PNObjectInformationView *information = [PNObjectInformationView viewFromNib];
    information.delegate = self;
    [information showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
}

- (IBAction)handleActionButtonTap:(id)sender {
    
    PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
    [progressAlertView show];
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [self.presenceStateHelper performRequestWithBlock:^(NSArray *channels, PNError *presenceManipulationError) {
        
        [progressAlertView dismissWithAnimation:YES];
        
        PNAlertType type = (presenceManipulationError ? PNAlertWarning : PNAlertSuccess);
        NSString *shortDescription = nil;
        NSString *detailedDescription = nil;
        
        if (!presenceManipulationError) {
            
            [weakSelf.channelsList reloadData];
            [weakSelf updateLayout];
            
            shortDescription = @"presenceObservationSuccessAlertViewShortDescription";
            NSString *localizedKey = @"presenceObservationEnableSuccessAlertViewDetailedDescription";
            if (!self.isPresenceEnablingState) {
                
                localizedKey = @"presenceObservationDisableSuccessAlertViewDetailedDescription";
            }
            
            detailedDescription = [NSString stringWithFormat:[localizedKey localized],
                                   [[channels valueForKey:@"name"] componentsJoinedByString:@", "]];
        }
        else {
            
            shortDescription = @"presenceObservationFailureAlertViewShortDescription";
            NSString *localizedKey = @"presenceObservationEnableFailureAlertViewDetailedDescription";
            if (!self.isPresenceEnablingState) {
                
                localizedKey = @"presenceObservationDisableFailureAlertViewDetailedDescription";
            }
            
            detailedDescription = [NSString stringWithFormat:[localizedKey localized],
                                   [[channels valueForKey:@"name"] componentsJoinedByString:@", "], presenceManipulationError.localizedFailureReason];
        }
        
        if (detailedDescription) {
            
            PNAlertView *alert = [PNAlertView viewWithTitle:@"presenceObservationAlertViewTitle" type:type
                                               shortMessage:shortDescription detailedMessage:detailedDescription
                                          cancelButtonTitle:@"confirmButtonTitle" otherButtonTitles:nil andEventHandlingBlock:NULL];
            [alert show];
        }
    }];
}

- (IBAction)handleCloseButtonTap:(id)sender {
    
    [self dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
}


#pragma mark - Channel information delegate methods

- (void)objectInformation:(PNObjectInformationView *)informationView didEndEditing:(id <PNChannelProtocol>)object
                 withState:(NSDictionary *)channelState andPresenceObservation:(BOOL)shouldObserverPresence {
    
    [informationView dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
    
    if (![self.presenceStateHelper willChangePresenceStateForChanne:object]) {
        
        [self.presenceStateHelper addChannel:object];
        
        [self.channelsList reloadData];
        [self updateLayout];
    }
}


#pragma mark - UITableVide delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.presenceStateHelper channels] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *channelCellIdentifier = @"channelCellIdentifier";
    PNChannelCell *cell = (PNChannelCell *)[tableView dequeueReusableCellWithIdentifier:channelCellIdentifier];
    if (!cell) {
        
        cell = [[PNChannelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:channelCellIdentifier];
        cell.showBadge = NO;
    }
    PNChannel *channel = [[self.presenceStateHelper channels] objectAtIndex:indexPath.row];
    [cell updateForChannel:channel];
    if ([self.presenceStateHelper willChangePresenceStateForChanne:channel]) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PNChannelCell *cell = (PNChannelCell *)[tableView cellForRowAtIndexPath:indexPath];
    PNChannel *channel = [[self.presenceStateHelper channels] objectAtIndex:indexPath.row];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        
        [self.presenceStateHelper addChannel:channel];
    }
    else {
        
        [self.presenceStateHelper removeChannel:channel];
    }
    [self.channelsList reloadData];
    [self updateLayout];
}

#pragma mark -


@end
