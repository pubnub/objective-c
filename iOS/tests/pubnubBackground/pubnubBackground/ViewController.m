//
//  ViewController.m
//  pubnubBackground
//
//  Created by rajat  on 23/09/13.
//  Copyright (c) 2013 pubnub. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

AppDelegate *appDelegate;

- (void)DisplayInLog: (NSString *)message{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:zone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    PNLog(PNLogGeneralLevel, self, message);
    [self.textViewLogs setText:[NSString stringWithFormat:@"%@\n%@:%@", self.textViewLogs.text,[formatter stringFromDate:date], message]];
    [self.textViewLogs scrollRangeToVisible:NSMakeRange([self.textViewLogs.text length], 0)];
}

- (void)ShowChannelInLabel: (NSString *)message bRemove:(bool)bRemove{
    NSLog(@"TextStatus: %@,%@", self.textStatus.text, message);
    if(bRemove){
        NSString *newString = [self.textStatus.text stringByReplacingOccurrencesOfString:message withString:@""];
        NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
        if ([[newString stringByTrimmingCharactersInSet: set] length] == 0){
            [self.btnStopTest setTitle:@"Stopped" forState:UIControlStateDisabled];
            [self.btnStartTest setEnabled:YES];
            [self.textStatus setText: @""];
        } else {
            [self.textStatus setText: newString];
        }
    } else {
        [self.textStatus setText:[NSString stringWithFormat:@"%@ %@", self.textStatus.text, message]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate InitializePubNubClient];
    
    [appDelegate ConnectPubnubClient];
    [appDelegate shouldDisplayAllLogs:NO];

    [self.btnStartTest setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.btnStopTest setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

    [self.btnStopTest setEnabled:NO];
    [self.btnStopTest setTitle:@"Stopped" forState:UIControlStateDisabled];
    
    [self.textStatus setEnabled:NO];
    
    /*[[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                        withCallbackBlock:^(NSString *origin,
                                                                            BOOL connected,
                                                                            PNError *connectionError) {
                                                            [self DisplayInLog: [NSString stringWithFormat: @"{BLOCK} client identifier %@", [PubNub clientIdentifier]]];
                                                        }];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)btnStart:(id)sender {
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if ([[self.textIdleTime.text stringByTrimmingCharactersInSet: set] length] == 0){
        self.textIdleTime.text = @"10";
    }
   
    [appDelegate SetIdleTime: self.textIdleTime.text];
    [appDelegate isLoopingOn:true];
    [self StartSendLoop];
    [self.btnStartTest setEnabled:NO];
    [self.btnStartTest setTitle:@"Running" forState:UIControlStateDisabled];    
    [self.btnStopTest setEnabled:YES];
}

- (IBAction)switchShowAllChanged:(id)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn]) {
        [appDelegate shouldDisplayAllLogs:YES];
    } else {
        [appDelegate shouldDisplayAllLogs:NO];
    }
}

- (IBAction)btnStop:(id)sender {
    [appDelegate EndSendLoop];
    //[appDelegate Disconnect];
    [self.btnStopTest setEnabled:NO];
    [self.btnStopTest setTitle:@"Unsubscribing" forState:UIControlStateDisabled];
}

- (void)StartSendLoop{
    [appDelegate performSelectorInBackground:@selector(SendLoop) withObject:nil];
}

@end
