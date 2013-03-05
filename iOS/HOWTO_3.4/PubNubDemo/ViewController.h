//
//  ViewController.h
//  PubNubDemo
//
//  Created by Jiang ZC on 2/21/13.
//  Copyright (c) 2013 JiangZC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>



// Stores reference on text field where user can
// input his identifier
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *clientIdentifier;

// Stores reference on channel name input text field
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *channelName;

// Stores reference on message input text field
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *messageTextField;

// Stores reference on message input text field
@property (nonatomic, pn_desired_weak) IBOutlet UITextView *messageTextView;


// Stores reference on PubNub client configuration
@property (nonatomic, strong) PNConfiguration *configuration;

// Stores reference on current channel
@property (nonatomic, strong) PNChannel *currentChannel;

// Stores reference on dictionary which stores messages for each of channels
@property (nonatomic, strong) NSMutableDictionary *messages;


- (IBAction)connectButtonTapped:(id)sender;
- (IBAction)addChannelButtonTapped:(id)sender;
- (IBAction)sendMessageButtonTapped:(id)sender;
- (IBAction)disconnectButtonTapped:(id)sender;

@end
