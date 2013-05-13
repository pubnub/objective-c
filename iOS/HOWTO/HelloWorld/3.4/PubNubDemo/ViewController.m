//
//  ViewController.m
//  PubNubDemo
//
//  Created by Jiang ZC on 2/21/13.
//  Copyright (c) 2013 JiangZC. All rights reserved.
//

#import "ViewController.h"
#import "PNMessage+Protected.h"
#import "PNChannel+Protected.h"

@interface ViewController ()


#pragma mark - Properties

//@property (nonatomic, strong) PNConfiguration *configuration;
//
//// Stores reference on dictionary which stores messages for each of channels
//@property (nonatomic, strong) NSMutableDictionary *messages;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.currentChannel = nil;
    self.messages = [NSMutableDictionary dictionary];
    self.configuration = [PNConfiguration defaultConfiguration];

    self.sendMessageButton.enabled = NO;
    self.subscribeButton.enabled = NO;


    ViewController *weakSelf = self;

    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                        withCallbackBlock:^(NSString *origin,
                                                                BOOL connected,
                                                                PNError *connectionError) {
                                                            PNLog(PNLogGeneralLevel, self, @"{BLOCK} client identifier %@", [PubNub clientIdentifier]);
                                                            weakSelf.clientIdentifier.text = [PubNub clientIdentifier];


                                                        }];
    //
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                         withBlock:^(PNMessage *message) {

                                                             NSDateFormatter *dateFormatter = [NSDateFormatter new];
                                                             dateFormatter.dateFormat = @"HH:mm:ss MM/dd/yy";

                                                             PNChannel *channel = message.channel;
                                                             NSString *messages = [weakSelf.messages valueForKey:channel.name];
                                                             if (messages == nil) {

                                                                 messages = @"";
                                                             }
                                                             messages = [messages stringByAppendingFormat:@"<%@> %@\n",
                                                                                                          [dateFormatter stringFromDate:message.receiveDate],
                                                                                                          message.message];
                                                             [weakSelf.messages setValue:messages forKey:channel.name];

                                                             [self.messageTextView setText:messages];

                                                             //weakSelf.currentChannelChat = [weakSelf.messages valueForKey:weakSelf.currentChannel.name];
                                                         }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectButtonTapped:(id)sender {
    // Update PubNub client configuration
    [PubNub setConfiguration:self.configuration];

    [PubNub connectWithSuccessBlock:^(NSString *origin) {

        PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client connected to: %@", origin);
        self.subscribeButton.enabled = YES;
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
}

- (IBAction)disconnectButtonTapped:(id)sender {
    [PubNub disconnect];

    self.subscribeButton.enabled = NO;
    self.sendMessageButton.enabled = NO;
}

- (IBAction)addChannelButtonTapped:(id)sender {
    self.currentChannel = [PNChannel channelWithName:self.channelName.text
                               shouldObservePresence:NO];
    NSLog(@"%p", self.currentChannel);

    [PubNub subscribeOnChannel:self.currentChannel withCompletionHandlingBlock:^(PNSubscriptionProcessState state,
            NSArray *channels,
            PNError *subscriptionError) {

        NSString *alertMessage = [NSString stringWithFormat:@"Subscribed on channel: %@\nTo be able to send messages, select channel from righthand list",
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
            self.sendMessageButton.enabled = YES;
        }

    }];

    [self.view endEditing:YES];
}

- (IBAction)sendMessageButtonTapped:(id)sender {
    if (self.currentChannel != nil) {
        [PubNub sendMessage:[NSString stringWithFormat:@"\"%@\"", self.messageTextField.text]
                  toChannel:self.currentChannel];
    }

    [self.messageTextField setText:@""];
    [self.view endEditing:YES];
}

#pragma mark - UITextField delegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField {

    NSString *clientIdentifier = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];

    if ([clientIdentifier length] == 0) {

        clientIdentifier = nil;
    }

    [PubNub setClientIdentifier:clientIdentifier];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [self.view endEditing:YES];
    return YES;
}


@end
