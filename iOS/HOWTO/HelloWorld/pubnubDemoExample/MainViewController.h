//
//  MainViewController.h
//  pubnubDemoExample
//
//  Created by rajat  on 18/09/13.
//  Copyright (c) 2013 pubnub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblStatus;

@property (weak, nonatomic) IBOutlet UITextField *txtChannel;

- (IBAction)btnSubscribeTouchUpInside:(id)sender;

- (IBAction)btnUnsubscribeTouchUpInside:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *txtMessage;

- (IBAction)btnSendTouchUpInside:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *textViewLogs;

// Stores reference on current channel
@property (nonatomic, strong) PNChannel *currentChannel;

// Stores reference on current channel
@property (nonatomic, strong) NSString *connectedChannels;

@property (assign, nonatomic) NSString *sCipher;
@property (assign, nonatomic, setter=setSsl:) BOOL bSsl;
@property (assign, nonatomic) NSString *sSecret;
@property (assign, nonatomic) NSString *sCustomUuid;

- (void)DisplayInLog: (NSString *)message;
- (void)ShowChannelInLabel: (NSString *)message :(bool *)bRemove;

@end
