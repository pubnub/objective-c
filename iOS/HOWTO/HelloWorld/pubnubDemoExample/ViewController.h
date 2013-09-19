//
//  ViewController.h
//  pubnubDemoExample
//
//  Created by rajat  on 18/09/13.
//  Copyright (c) 2013 pubnub. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface ViewController : UIViewController

@property (strong, nonatomic) MainViewController *viewController;

@property (weak, nonatomic) IBOutlet UISwitch *switchSsl;

@property (weak, nonatomic) IBOutlet UITextField *txtSecretKey;

@property (weak, nonatomic) IBOutlet UITextField *txtCipherKey;

@property (weak, nonatomic) IBOutlet UITextField *txtCustomUuid;

- (IBAction)launchTouchUpInside:(id)sender;

@end
