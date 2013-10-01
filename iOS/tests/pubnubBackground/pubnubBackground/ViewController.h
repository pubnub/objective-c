//
//  ViewController.h
//  pubnubBackground
//
//  Created by rajat  on 23/09/13.
//  Copyright (c) 2013 pubnub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textViewLogs;

@property (weak, nonatomic) IBOutlet UITextField *textStatus;

- (IBAction)btnStart:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *textIdleTime;

- (IBAction)switchShowAllChanged:(id)sender;

- (IBAction)btnStop:(id)sender;

- (void)DisplayInLog: (NSString *)message;

- (void)ShowChannelInLabel: (NSString *)message bRemove:(bool)bRemove;

@property (weak, nonatomic) IBOutlet UIButton *btnStartTest;

@property (weak, nonatomic) IBOutlet UIButton *btnStopTest;

@property (weak, nonatomic) IBOutlet UITextField *textChannels;

- (IBAction)switchAutoNamesValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UISwitch *switchAutoNames;

@end
