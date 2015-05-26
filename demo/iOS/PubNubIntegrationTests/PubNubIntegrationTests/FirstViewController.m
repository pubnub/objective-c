//
//  FirstViewController.m
//  PubNubIntegrationTests
//
//  Created by Jordan Zucker on 5/26/15.
//  Copyright (c) 2015 pubnub. All rights reserved.
//
#import <PubNub/PubNub.h>

#import "FirstViewController.h"

@interface FirstViewController () <
                                    PNObjectEventListener,
                                    UITextFieldDelegate
                                    >
@property (nonatomic) PubNub *client;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UILabel *channelLabel;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;
@property (nonatomic, weak) IBOutlet UIButton *generateRandomStringButton;
@property (nonatomic, weak) IBOutlet UITextField *textField;
//@property (nonatomic, copy) NSString *uniqueMessageString;
@property (nonatomic, copy) NSString *uniqueChannelName;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.client = [PubNub clientWithPublishKey:@"demo-36" andSubscribeKey:@"demo-36"];
    [self.client addListeners:@[self]];
    self.uniqueChannelName = [[NSUUID UUID] UUIDString];
    [self.client subscribeToChannels:@[self.uniqueChannelName] withPresence:NO andCompletion:nil];
//    self.uniqueMessageString = [[NSUUID UUID] UUIDString];
    [self.sendButton addTarget:self action:@selector(startButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.isAccessibilityElement = YES;
    self.sendButton.accessibilityIdentifier = @"sendButton";
    self.textField.delegate = self;
    self.textField.isAccessibilityElement = YES;
    self.textField.accessibilityIdentifier = @"textField";
    [self.generateRandomStringButton addTarget:self action:@selector(generateRandomStringButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.generateRandomStringButton.isAccessibilityElement = YES;
    self.generateRandomStringButton.accessibilityIdentifier = @"generateRandomStringButton";
    self.messageLabel.accessibilityIdentifier = @"messageLabel";
    self.channelLabel.accessibilityIdentifier = @"channelLabel";
    [self setUIEnabled:YES];
//    [self.client publish:self.uniqueMessageString toChannel:uniqueChannelName withCompletion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.client removeListeners:@[self]];
}

#pragma mark - UI

- (void)setUIEnabled:(BOOL)enabled {
    self.textField.enabled = enabled;
    self.sendButton.enabled = enabled;
    self.generateRandomStringButton.enabled = enabled;
}

- (void)generateRandomStringButtonTapped:(UIButton *)sender {
    if (self.textField.isEnabled) {
        self.textField.text = [[NSUUID UUID] UUIDString];
    }
}

- (void)startButtonTapped:(UIButton *)sender {
    __weak typeof(self) wself = self;
    if (!self.textField.text.length) {
        return;
    }
    [self setUIEnabled:NO];
    [self.client publish:self.textField.text toChannel:self.uniqueChannelName withCompletion:^(PNStatus *status) {
        __strong typeof(wself) sself = wself;
        if (sself) {
            [sself setUIEnabled:YES];
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
//    textField.accessibilityValue = textField.text;
    return YES;
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveMessage:(PNResult *)message withStatus:(PNStatus *)status {
    [self setUIEnabled:YES];
    NSLog(@"message: %@", message.data);
    self.messageLabel.text = message.data[@"message"];
    
//    self.messageLabel.accessibilityValue = self.messageLabel.text;
    self.channelLabel.text = message.data[@"channel"];
//    self.channelLabel.accessibilityValue = self.channelLabel.text;
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult *)event {
    [self setUIEnabled:YES];
}

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    [self setUIEnabled:YES];
}

@end
