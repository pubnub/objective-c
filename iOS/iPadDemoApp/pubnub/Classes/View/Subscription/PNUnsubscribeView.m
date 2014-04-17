//
//  PNUnsubscribeView.m
//  pubnub
//
//  Created by Sergey Mamontov on 3/27/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNUnsubscribeView.h"
#import "NSString+PNLocalization.h"
#import "PNUnsubscribeHelper.h"
#import "UIView+PNAddition.h"
#import "PNChannelCell.h"
#import "PNAlertView.h"
#import "PNButton.h"


#pragma mark Static

static NSTimeInterval const kPNViewAppearAnimationDuration = 0.4f;
static NSTimeInterval const kPNViewDisappearAnimationDuration = 0.2f;


#pragma mark - Private interface declaration

@interface PNUnsubscribeView () <UITableViewDelegate, UITableViewDataSource>


#pragma mark - Properties

/**
 Stores reference on table which is used for channels layout.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *channelsList;

/**
 Stores reference on button which
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *unsubscribeButton;

/**
 Stores reference on helper which will process all unsubscription requests.
 */
@property (nonatomic, strong) IBOutlet PNUnsubscribeHelper *unsubscribeHelper;


#pragma mark - Instance methods

- (void)updateLayout;


#pragma mark - Handler methods

- (IBAction)handleUnsubscribeButtonTap:(id)sender;
- (IBAction)handleCloseButtonTap:(id)sender;

#pragma mark -


@end



#pragma mark - Public interface implementation

@implementation PNUnsubscribeView


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class
    [super awakeFromNib];

    [self updateLayout];
}

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNViewAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNViewDisappearAnimationDuration;
}

- (void)updateLayout {
    
    self.unsubscribeButton.enabled = [self.unsubscribeHelper canUnsubscribe];
}


#pragma mark - Handler methods

- (IBAction)handleUnsubscribeButtonTap:(id)sender {
    
    PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
    [progressAlertView show];
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [self.unsubscribeHelper unsubscribeWithBlock:^(NSArray *channels, PNError *unsubscribeError) {
        
        [progressAlertView dismissWithAnimation:YES];
        [weakSelf.channelsList reloadData];
        
        [progressAlertView dismissWithAnimation:YES];
        
        PNAlertType type = (unsubscribeError ? PNAlertWarning : PNAlertSuccess);
        NSString *title = @"unsubscribeAlertViewTitle";
        NSString *shortDescription = (unsubscribeError ? @"unsubscribeFailureAlertViewShortDescription" : @"unsubscribeSuccessAlertViewShortDescription");
        NSString *detailedDescription = [NSString stringWithFormat:[@"unsubscribeSuccessAlertViewDetailedDescription" localized],
                                         [[channels valueForKey:@"name"] componentsJoinedByString:@", "]];
        if (unsubscribeError) {
            
            detailedDescription = [NSString stringWithFormat:[@"unsubscribeFailureAlertViewDetailedDescription" localized],
                                   [[channels valueForKey:@"name"] componentsJoinedByString:@", "],
                                   unsubscribeError.localizedFailureReason];
        }
        
        PNAlertView *alertView = [PNAlertView viewWithTitle:title type:type shortMessage:shortDescription
                                            detailedMessage:detailedDescription cancelButtonTitle:nil
                                          otherButtonTitles:nil andEventHandlingBlock:^(PNAlertView *view, NSUInteger buttonIndex) {
                                              
                                              if (!unsubscribeError && [[weakSelf.unsubscribeHelper channelsForUnsubscription] count] == 0) {
                                                  
                                                  [self dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
                                              }
                                          }];
        [alertView show];
    }];
}

- (IBAction)handleCloseButtonTap:(id)sender {
    
    [self dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
}

#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.unsubscribeHelper channelsForUnsubscription] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *unsubscriptionCellIdentifier = @"unsubscribeCellIdentifier";
    PNChannelCell *cell = [tableView dequeueReusableCellWithIdentifier:unsubscriptionCellIdentifier];
    if (!cell) {
        
        cell = [[PNChannelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:unsubscriptionCellIdentifier];
        cell.showBadge = NO;
    }
    PNChannel *channel = [[self.unsubscribeHelper channelsForUnsubscription] objectAtIndex:indexPath.row];
    [cell updateForChannel:channel];
    if ([self.unsubscribeHelper willUnsubscribeFromChannel:channel]) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView beginUpdates];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PNChannel *channel = [[self.unsubscribeHelper channelsForUnsubscription] objectAtIndex:indexPath.row];
    
    if ([self.unsubscribeHelper willUnsubscribeFromChannel:channel]) {
        
        [self.unsubscribeHelper removeChannel:channel];
    }
    else {
        
        [self.unsubscribeHelper addChannelForUnsubscription:channel];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
    
    [self updateLayout];
}

#pragma mark -


@end
