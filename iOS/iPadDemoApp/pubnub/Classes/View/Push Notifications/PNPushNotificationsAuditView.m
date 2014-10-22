//
//  PNPushNotificationsAuditView.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/5/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNPushNotificationsAuditView.h"
#import "PNPushNotificationsAuditionHelper.h"
#import "NSString+PNLocalization.h"
#import "UIView+PNAddition.h"
#import "PNObjectCell.h"
#import "PNTableView.h"
#import "PNAlertView.h"
#import "PNButton.h"


#pragma mark Static

static NSTimeInterval const kPNViewAppearAnimationDuration = 0.4f;
static NSTimeInterval const kPNViewDisappearAnimationDuration = 0.2f;


#pragma mark - Private interface declaration

@interface PNPushNotificationsAuditView () <UITableViewDelegate, UITableViewDataSource>


#pragma mark - Properties

/**
 Stores reference on table which will show list of channels for which push notifications has been enabled.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNTableView *channelsList;

/**
 Stores reference on helper which handle and process request.
 */
@property (nonatomic, strong) IBOutlet PNPushNotificationsAuditionHelper *notificationHelper;


#pragma mark - Instance methods

#pragma mark - Handler methods

- (IBAction)handleAuditButtonTap:(id)sender;
- (IBAction)handleCloseButtonTap:(id)sender;

#pragma mark -


@end


#pragma mark - Public interface declaration

@implementation PNPushNotificationsAuditView


#pragma mark - Instance methods

#pragma mark - Handler methods

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNViewAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNViewDisappearAnimationDuration;
}

- (IBAction)handleAuditButtonTap:(id)sender {
    
    PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
    [progressAlertView show];
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [self.notificationHelper performRequestWithBlock:^(NSArray *channels, PNError *requestError) {
        
        [progressAlertView dismissWithAnimation:YES];
        
        [weakSelf.channelsList reloadData];
        
        PNAlertType type = (requestError ? PNAlertWarning : PNAlertSuccess);
        NSString *shortDescription = @"pushNotificationAuditSuccessAlertViewShortDescription";
        NSString *detailedDescription = @"pushNotificationAuditSuccessAlertViewDetailedDescription";
        
        if (requestError) {
            
            shortDescription = @"pushNotificationAuditFailureAlertViewShortDescription";
            detailedDescription = [NSString stringWithFormat:[@"pushNotificationAuditFailureAlertViewDetailedDescription" localized],
                                   requestError.localizedFailureReason];
        }
        
        PNAlertView *alert = [PNAlertView viewWithTitle:@"pushNotificationAuditAlertViewTitle" type:type
                                           shortMessage:shortDescription detailedMessage:detailedDescription
                                      cancelButtonTitle:nil otherButtonTitles:nil andEventHandlingBlock:NULL];
        [alert show];
    }];
}

- (IBAction)handleCloseButtonTap:(id)sender {
    
    [self dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
}


#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.notificationHelper channels] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *channelCellIdentifier = @"channelCellIdentifier";
    PNObjectCell *cell = [tableView dequeueReusableCellWithIdentifier:channelCellIdentifier];
    if (!cell) {
        
        cell = [[PNObjectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:channelCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.showBadge = NO;
    }
    PNChannel *channel = [[self.notificationHelper channels] objectAtIndex:indexPath.row];
    [cell updateForObject:channel];
    
    
    return cell;
}

#pragma mark -

@end
