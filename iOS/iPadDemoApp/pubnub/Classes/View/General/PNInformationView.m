//
//  PNInformationView.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/8/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNInformationView.h"
#import "UIView+PNAddition.h"
#import "PNButton.h"


#pragma mark Static

static NSTimeInterval const kPNViewAppearAnimationDuration = 0.4f;
static NSTimeInterval const kPNViewDisappearAnimationDuration = 0.2f;


#pragma mark - Private interface declaration

@interface PNInformationView () <UITextFieldDelegate>


#pragma mark - Properties

/**
 Storss reference on label which is used for client's UUID output.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *clientUUIDLabel;

/**
 Stores reference on label which will be used to show user which current IP address is used by device.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *clientConnectionIPAddressLabel;

/**
 Stores reference on text field which is used for client's UUID modification.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *clientUUIDImnputTextField;

/**
 Button which allow user to change client's UUID.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *changeUUIDButton;

@property (nonatomic, strong) NSString *clientsUUID;


#pragma mark - Instance methods

- (void)prepareLayout;
- (void)updateLayout;

#pragma mark - Handler methods

- (IBAction)handleCloseButtonTap:(id)sender;
- (IBAction)handleChangeUUIDButtonTap:(id)sender;


#pragma mark - Misc methods

- (void)enableDataObservation;
- (void)disableDataObservation;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNInformationView


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];
    
    [self enableDataObservation];
    [self prepareLayout];
}

- (void)prepareLayout {
    
    self.clientsUUID = [PubNub clientIdentifier];
    self.clientUUIDImnputTextField.text = self.clientsUUID;
    [self updateLayout];
}

- (void)updateLayout {
    
    self.changeUUIDButton.enabled = [[PubNub sharedInstance] isConnected];
    if (self.changeUUIDButton.isEnabled && !self.clientUUIDImnputTextField.isHidden) {
        
        self.changeUUIDButton.enabled = ![self.clientsUUID isEmpty];
    }
    
    NSString *identifier = self.clientsUUID;
    NSString *address = [PNNetworkHelper networkAddress];
    if (![[PubNub sharedInstance] isConnected]) {
        
        identifier = @"---";
        address = @"-.-.-.-";
    }
    self.clientUUIDLabel.text = identifier;
    self.clientConnectionIPAddressLabel.text = address;
}

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNViewAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNViewDisappearAnimationDuration;
}

#pragma mark - Handler methods

- (IBAction)handleChangeUUIDButtonTap:(id)sender {
    
    [self completeUserInput];
    
    if (self.clientUUIDImnputTextField.isHidden) {
        
        [self.changeUUIDButton setTitle:@"Save" forState:UIControlStateNormal];
        self.clientUUIDImnputTextField.hidden = NO;
        self.clientUUIDLabel.hidden = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self handleCloseButtonTap:nil];
        });
    }
    else {
        
        [self.changeUUIDButton setTitle:@"Change" forState:UIControlStateNormal];
        self.clientUUIDImnputTextField.hidden = YES;
        self.clientUUIDLabel.hidden = NO;
        self.clientUUIDLabel.text = self.clientsUUID;
        [PubNub setClientIdentifier:self.clientsUUID];
    }
}

- (IBAction)handleCloseButtonTap:(id)sender {
    
    [self dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
}


#pragma mark - Misc methods

- (void)enableDataObservation {
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                        withCallbackBlock:^(NSString *origin, BOOL connected, PNError *error) {
                                                            
                                                            [weakSelf updateLayout];
                                                        }];
    
    [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:weakSelf
                                                                 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels,
                                                                                     PNError *subscriptionError) {
                                                                     
                                                                     switch (state) {
                                                                             
                                                                         case PNSubscriptionProcessNotSubscribedState:
                                                                             
                                                                             if (subscriptionError.code == kPNAPIAccessForbiddenError) {
                                                                                 
                                                                                 [weakSelf updateLayout];
                                                                             }
                                                                             break;
                                                                         default:
                                                                             break;
                                                                     }
                                                                 }];
}

- (void)disableDataObservation {
    
    [[PNObservationCenter defaultCenter] removeClientConnectionStateObserver:self];
    [[PNObservationCenter defaultCenter] removeClientChannelSubscriptionStateObserver:self];
}

- (void)dealloc {
    
    [self disableDataObservation];
}


#pragma mark - UITextField delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    self.clientsUUID = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self updateLayout];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self completeUserInput];
    
    
    return YES;
}

#pragma mark -


@end
