//
//  MainViewController.m
//  pubnubDemoExample
//
//  Created by rajat  on 18/09/13.
//  Copyright (c) 2013 pubnub. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)DisplayInLog: (NSString *)message{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:zone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [self.textViewLogs setText:[NSString stringWithFormat:@"%@\n%@:%@", self.textViewLogs.text,[formatter stringFromDate:date], message]];
    [self.textViewLogs scrollRangeToVisible:NSMakeRange([self.textViewLogs.text length], 0)];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self DisplayInLog: [NSString stringWithFormat:@"Cipher: %@", ([self.sCipher length] == 0)?@"--nil--":self.sCipher]];
    [self DisplayInLog: [NSString stringWithFormat:@"Uuid: %@", [PubNub clientIdentifier]]];
    [self DisplayInLog: [NSString stringWithFormat:@"Secret: %@", ([self.sSecret length] == 0)?@"--nil--":self.sSecret]];
    [self DisplayInLog: [NSString stringWithFormat:@"SSL: %@", self.bSsl?@"On":@"Off"]];
    
    MainViewController *weakSelf = self;
    
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                        withCallbackBlock:^(NSString *origin,
                                                                            BOOL connected,
                                                                            PNError *connectionError) {
                                                            NSLog(@"{BLOCK} client identifier %@", [PubNub clientIdentifier]);
                                                            weakSelf.sCustomUuid = [PubNub clientIdentifier];
                                                        }];
    
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                         withBlock:^(PNMessage *message) {
                                                             [self DisplayInLog: [NSString stringWithFormat:@"[%@]: %@",message.channel.name, message.message]];
                                                         }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSendTouchUpInside:(id)sender {
    NSString *channel = [self.txtChannel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
    if([channel length]>0){
        PNChannel *ch = [PNChannel channelWithName:self.txtChannel.text
                                   shouldObservePresence:NO];
        [PubNub sendMessage:[NSString stringWithFormat:@"\"%@\"", self.txtMessage.text]
                  toChannel:ch];
        [self.txtMessage setText:@""];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Publish"
                                                            message:@"Please enter a valid channel name"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }

    [self.view endEditing:YES];
}

- (IBAction)btnSubscribeTouchUpInside:(id)sender {
    NSString *channel = [self.txtChannel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
    if([channel length]>0){
        self.currentChannel = [PNChannel channelWithName:self.txtChannel.text
                                   shouldObservePresence:NO];
        NSLog(@"currentChannel:%p", self.currentChannel);
        
        [PubNub subscribeOn:@[self.currentChannel]
withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
            
            NSString *alertMessage = [NSString stringWithFormat:@"Subscribed on channel: %@",
                                      self.currentChannel.name];
            if (state == PNSubscriptionProcessNotSubscribedState) {
                
                alertMessage = [NSString stringWithFormat:@"Failed to subscribe on: %@", self.currentChannel.name];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Subscribe"
                                                                    message:alertMessage
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            } else if (state == PNSubscriptionProcessSubscribedState) {
                [self DisplayInLog: alertMessage];
                [self ShowChannelInLabel: self.currentChannel.name bRemove:FALSE];
            }
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Subscribe"
                                                            message:@"Please enter a valid channel name"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    self.txtChannel.text =@"";
    
    [self.view endEditing:YES];
}

- (void)ShowChannelInLabel: (NSString *)message bRemove:(bool)bRemove{
    NSUInteger loc= [self.lblStatus.text rangeOfString:[NSString stringWithFormat:@"%@,",message]].location;
    if((loc == NSNotFound) && (!bRemove)){
        if([self.lblStatus.text length] !=0) {
            self.lblStatus.text = [NSString stringWithFormat:@"%@%@,", self.lblStatus.text, message];
        }
        else {
            self.lblStatus.text = [NSString stringWithFormat:@"%@,", message];
        }
    } else if ((loc != NSNotFound) && (bRemove)){
        if([self.lblStatus.text length] !=0) {
            self.lblStatus.text =[self.lblStatus.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,",message] withString:@""];
        }
    } 
}

- (IBAction)btnUnsubscribeTouchUpInside:(id)sender {
    NSString *channel = [self.txtChannel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
    if([channel length]>0){
    
        PNChannel *channel = [PNChannel channelWithName:self.txtChannel.text];
        [PubNub unsubscribeFrom:@[channel] withCompletionHandlingBlock:^(NSArray *channels, PNError *subscriptionError){
            NSString *alertMessage = [NSString stringWithFormat:@"Unsubscribed channel: %@",
                                      channel.name];
            if(subscriptionError != nil){
                 alertMessage = [NSString stringWithFormat:@"Unsubscribe error : %@, %@",
                                          channel.name, subscriptionError.description];
            }
            [self DisplayInLog: alertMessage];
            [self ShowChannelInLabel: channel.name bRemove:TRUE];
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unsubscribe"
                                                            message:@"Please enter a valid channel name"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    self.txtChannel.text =@"";
    [self.view endEditing:YES];
}
@end
