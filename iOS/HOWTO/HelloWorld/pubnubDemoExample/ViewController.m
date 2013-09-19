//
//  ViewController.m
//  pubnubDemoExample
//
//  Created by rajat  on 18/09/13.
//  Copyright (c) 2013 pubnub. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "MainViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)launchTouchUpInside:(id)sender {
    NSLog(@"test %@", self.txtCustomUuid.text);
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Update PubNub client configuration
    bool bSecretKeyEmpty = YES;
    NSString *secretKey = @"";
    if([self.txtSecretKey.text length] != 0){
        secretKey = self.txtSecretKey.text;
        bSecretKeyEmpty = NO;
    }
    bool bCipherKeyEmpty = YES;
    NSString *cipherKey = @"";
    if([self.txtCipherKey.text length] != 0){
        cipherKey = self.txtCipherKey.text;
        bCipherKeyEmpty = NO;
    }
    
    if(bSecretKeyEmpty && bCipherKeyEmpty) {
        appDelegate.pubnubConfig = [PNConfiguration defaultConfiguration];
    } else if (bCipherKeyEmpty) {
        appDelegate.pubnubConfig = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey:secretKey];
    } else if(bSecretKeyEmpty){
        appDelegate.pubnubConfig = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey:nil cipherKey:cipherKey];
    } else {
        appDelegate.pubnubConfig = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey:secretKey cipherKey:cipherKey];
    }

    NSLog(@"%@", appDelegate.pubnubConfig);
    [PubNub setConfiguration:appDelegate.pubnubConfig];
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        
        PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client connected to: %@", origin);
    }
     // In case of error you always can pull out error code and
     // identify what is happened and what you can do
     // (additional information is stored inside error's
     // localizedDescription, localizedFailureReason and
     // localizedRecoverySuggestion)
                         errorBlock:^(PNError *connectionError) {
                             BOOL isControlsEnabled = connectionError.code != kPNClientConnectionFailedOnInternetFailureError;
                             
                             // Enable controls so user will be able to try again
                             ((UIButton *) sender).enabled = isControlsEnabled;
                             
                             if (connectionError.code == kPNClientConnectionFailedOnInternetFailureError) {
                                 PNLog(PNLogGeneralLevel, self, @"Connection will be established as soon as internet connection will be restored");
                             }
                             
                             UIAlertView *connectionErrorAlert = [UIAlertView new];
                             connectionErrorAlert.title = [NSString stringWithFormat:@"%@(%@)",
                                                           [connectionError localizedDescription],
                                                           NSStringFromClass([self class])];
                             connectionErrorAlert.message = [NSString stringWithFormat:@"Reason:\n%@\n\nSuggestion:\n%@",
                                                             [connectionError localizedFailureReason],
                                                             [connectionError localizedRecoverySuggestion]];
                             [connectionErrorAlert addButtonWithTitle:@"OK"];
                             
                             [connectionErrorAlert show];
                             
                             
                         }];
    
    appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPad" bundle:nil];
    }
    self.viewController.bSsl = self.switchSsl.isOn;
    self.viewController.sCipher = self.txtCipherKey.text;
    self.viewController.sCustomUuid = self.txtCustomUuid.text;
    self.viewController.sSecret = self.txtSecretKey.text;
    
    appDelegate.window.rootViewController = self.viewController;
    [appDelegate.window makeKeyAndVisible];
}
@end
