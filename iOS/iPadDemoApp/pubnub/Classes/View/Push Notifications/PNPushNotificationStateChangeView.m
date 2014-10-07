//
//  PNPushNotificationStateChangeView.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/5/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNPushNotificationStateChangeView.h"
#import "PNObjectInformationDelegate.h"
#import "PNObjectInformationView.h"
#import "PNPushNotificationHelper.h"
#import "NSString+PNLocalization.h"
#import "NSObject+PNAddition.h"
#import "UIView+PNAddition.h"
#import "PNChannelCell.h"
#import "PNAlertView.h"
#import "PNTableView.h"
#import "PNButton.h"


#pragma mark Static

static NSTimeInterval const kPNViewAppearAnimationDuration = 0.4f;
static NSTimeInterval const kPNViewDisappearAnimationDuration = 0.2f;


#pragma mark - Private interface declaration

@interface PNPushNotificationStateChangeView () <UITableViewDelegate, UITableViewDataSource, PNObjectInformationDelegate>


#pragma mark - Properties

/**
 Stores reference on action button which can be used by user for push notification enabling / disabling on target set of
 channels.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *actionButton;

/**
 Stores reference on list of channels on which push notification enabling / disabling will be performed.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNTableView *channelsList;

/**
 Stores reference on helper which will handle and process push notifications for channels.
 */
@property (nonatomic, strong) IBOutlet PNPushNotificationHelper *notificationHelper;

/**
 Stores whether view created for push notification enabling or not.
 */
@property (nonatomic, assign, getter = isEnablingPushNotifications) BOOL enablingPushNotifications;


#pragma mark - Instance methods

- (void)prepareLayout;
- (void)updateLayout;


#pragma mark - Handler methods

- (IBAction)handleAddChannelButtonTap:(id)sender;
- (IBAction)handleActionButtonTap:(id)sender;
- (IBAction)handleCloseButtonTap:(id)sender;

#pragma mark -


@end


#pragma mark Public interface implementation

@implementation PNPushNotificationStateChangeView


#pragma mark - Class methods

+ (instancetype)viewFromNibForEnabling {
    
    // Swap method which should provide name for NIB file.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForEnabling)];
    
    PNPushNotificationStateChangeView *view = [self viewFromNib];
    view.enablingPushNotifications = YES;
    
    // Swap method implementation back to restore original.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForEnabling)];
    
    
    return view;
}

+ (instancetype)viewFromNibForDisabling {
    
    // Swap method which should provide name for NIB file.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForDisabling)];
    
    PNPushNotificationStateChangeView *view = [self viewFromNib];
    view.enablingPushNotifications = NO;
    
    // Swap method implementation back to restore original.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForDisabling)];
    
    
    return view;
}

+ (NSString *)viewNibNameForEnabling {
    
    return @"PNPushNotificationEnableView";
}

+ (NSString *)viewNibNameForDisabling {
    
    return @"PNPushNotificationDisableView";
}


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];
    
    [self prepareLayout];
    [self updateLayout];
}

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNViewAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNViewDisappearAnimationDuration;
}

- (void)setEnablingPushNotifications:(BOOL)enablingPushNotifications {
    
    BOOL isStateChanged = _enablingPushNotifications != enablingPushNotifications;
    _enablingPushNotifications = enablingPushNotifications;
    self.notificationHelper.enablingPushNotifications = enablingPushNotifications;
    
    
    if (isStateChanged) {
        
        [self updateLayout];
    }
}

- (void)prepareLayout {
    
    PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
    [progressAlertView show];
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [self.notificationHelper requestPushNotificationEnabledChannelsWithBlock:^{
        
        [progressAlertView dismissWithAnimation:YES];
        [weakSelf.channelsList reloadData];
        [weakSelf updateLayout];
    }];
}

- (void)updateLayout {
    
    self.actionButton.enabled = [self.notificationHelper isAbleToChangePushNotificationState];
}


#pragma mark - Handler methods

- (IBAction)handleAddChannelButtonTap:(id)sender {
    
    PNObjectInformationView *information = [PNObjectInformationView viewFromNib];
    information.delegate = self;
    information.allowEditing = YES;
    [information showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
}

- (IBAction)handleActionButtonTap:(id)sender {
    
    [self completeUserInput];
    
    PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
    [progressAlertView show];
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [self.notificationHelper performRequestWithBlock:^(NSArray *channels, PNError *requestError) {
        
        [progressAlertView dismissWithAnimation:YES];
        
        PNAlertType type = (requestError ? PNAlertWarning : PNAlertSuccess);
        NSString *title = (self.isEnablingPushNotifications ? @"pushNotificationEnableAlertViewTitle" : @"pushNotificationDisableAlertViewTitle");
        NSString *shortDescription = nil;
        NSString *detailedDescription = nil;
        
        if (!requestError) {
            
            [weakSelf.channelsList reloadData];
            [weakSelf updateLayout];
            if (self.isEnablingPushNotifications) {
                
                shortDescription = @"pushNotificationEnableSuccessAlertViewShortDescription";
                detailedDescription = [NSString stringWithFormat:[@"pushNotificationEnableSuccessAlertViewDetailedDescription" localized],
                                       [[channels valueForKey:@"name"] componentsJoinedByString:@", "]];
            }
            else {
                
                shortDescription = @"pushNotificationDisableSuccessAlertViewShortDescription";
                detailedDescription = [NSString stringWithFormat:[@"pushNotificationDisableSuccessAlertViewDetailedDescription" localized],
                                       [[channels valueForKey:@"name"] componentsJoinedByString:@", "]];
            }
        }
        else {
            
            if (self.isEnablingPushNotifications) {
                
                shortDescription = @"pushNotificationEnableFailureAlertViewShortDescription";
                detailedDescription = [NSString stringWithFormat:[@"pushNotificationEnableFailureAlertViewDetailedDescription" localized],
                                       [[channels valueForKey:@"name"] componentsJoinedByString:@", "], requestError.localizedFailureReason];
            }
            else {
                
                shortDescription = @"pushNotificationDisableFailureAlertViewShortDescription";
                detailedDescription = [NSString stringWithFormat:[@"pushNotificationDisableFailureAlertViewDetailedDescription" localized],
                                       [[channels valueForKey:@"name"] componentsJoinedByString:@", "], requestError.localizedFailureReason];
            }
        }
            
        PNAlertView *alert = [PNAlertView viewWithTitle:title type:type shortMessage:shortDescription
                                        detailedMessage:detailedDescription cancelButtonTitle:@"confirmButtonTitle"
                                      otherButtonTitles:nil andEventHandlingBlock:NULL];
        [alert show];
    }];
}

- (IBAction)handleCloseButtonTap:(id)sender {
    
    [self dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
}


#pragma mark - PNChannel information delegate methods

- (void)objectInformation:(PNObjectInformationView *)informationView didEndEditing:(id <PNChannelProtocol>)object
                withState:(NSDictionary *)channelState andPresenceObservation:(BOOL)shouldObserverPresence {
    
    [informationView dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
    [self.notificationHelper addChannel:object];
    
    if ([self.notificationHelper willChangePushNotificationStateForChanne:object]) {
        
        [self updateLayout];
        [self.channelsList reloadData];
    }
    else if (self.isEnablingPushNotifications) {
        
        NSString *detailedDescription = [NSString stringWithFormat:[@"pushNotificationEnableSuccessAlertViewDetailedDescription" localized],
                                         object.name];
        
        PNAlertView *alert = [PNAlertView viewWithTitle:@"pushNotificationEnableAlertViewTitle" type:PNAlertSuccess
                                           shortMessage:@"pushNotificationEnableSuccessAlertViewShortDescription"
                                        detailedMessage:detailedDescription cancelButtonTitle:nil otherButtonTitles:nil
                                  andEventHandlingBlock:NULL];
        [alert show];
    }
}


#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.notificationHelper channels] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *channelCellIdentifier = @"channelCellIdentifier";
    PNChannelCell *cell = (PNChannelCell *)[tableView dequeueReusableCellWithIdentifier:channelCellIdentifier];
    if (!cell) {
        
        cell = [[PNChannelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:channelCellIdentifier];
        cell.showBadge = NO;
    }
    PNChannel *channel = [[self.notificationHelper channels] objectAtIndex:indexPath.row];
    [cell updateForChannel:channel];
    if ([self.notificationHelper willChangePushNotificationStateForChanne:channel]) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PNChannel *channel = [[self.notificationHelper channels] objectAtIndex:indexPath.row];
    if (![self.notificationHelper willChangePushNotificationStateForChanne:channel]) {
        
        [self.notificationHelper addChannel:channel];
    }
    else {
        
        [self.notificationHelper removeChannel:channel];
    }
    [self.channelsList reloadData];
    [self updateLayout];
}

#pragma mark -


@end
