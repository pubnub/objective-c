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
{
	BOOL isRun;
}


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
                NSString *newString = self.textStatus.text;
                NSRange rOriginal = [self.textStatus.text rangeOfString: message];
                if (NSNotFound != rOriginal.location) {
                        newString = [newString
                                                stringByReplacingCharactersInRange: rOriginal
                                                withString:@""];
                }
                NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
                if ([[newString stringByTrimmingCharactersInSet: set] length] == 0){
                        [self.btnStopTest setTitle:@"Stopped" forState:UIControlStateDisabled];
                        [self.btnStartTest setEnabled:YES];
                        [self.textStatus setText: @""];
                        if([self.switchAutoNames isOn]){
                                [self.textChannels setEnabled:NO];
                                [self.textChannels setPlaceholder:@"Disable Auto Names to enter"];
                        } else {
                                [self.textChannels setEnabled:YES];
                                [self.textChannels setPlaceholder:@"Channels (comma sep)"];
                        }
                        [self.switchAutoNames setEnabled:YES];
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
        [self.textChannels setEnabled:NO];
        [self.textChannels setPlaceholder:@"Disable Auto Names to enter"];
        
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
        
        if ([[self.textChannels.text stringByTrimmingCharactersInSet: set] length] == 0){
                [self.switchAutoNames setOn:YES];
                [self.textChannels setPlaceholder:@"Disable Auto Names to enter"];
        }
//
//        [appDelegate SetChannels: self.textChannels.text];
//        [appDelegate shouldUseAutoNames: [self.switchAutoNames isOn]];
//        [appDelegate isLoopingOn:true];
//        [self StartSendLoop];
	[self.btnStartTest setEnabled:NO];
	[self.btnStartTest setTitle:@"Running" forState:UIControlStateDisabled];        
	[self.btnStopTest setEnabled:YES];
	[self.textChannels setEnabled:NO];
	[self.switchAutoNames setEnabled:NO];
	isRun = YES;

	for( int i=0; i<100 && isRun == YES; i++ ) {
		int64_t delayInSeconds = 10.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (i+1)*delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

				[self checkChannelWithName: [NSString stringWithFormat: @"%@", [NSDate date]]];
		});
	}
}


-(void)checkChannelWithName:(NSString*)name {
	if( isRun == NO )
		return;
	
	PNChannel *pnChannel = [PNChannel channelWithName: name];
	__block BOOL isCompletionBlockCalled = NO;
	NSLog(@"start subscribeOnChannels");

	[self.textViewLogs setText:[NSString stringWithFormat:@"%@\n%@:%@", self.textViewLogs.text,[NSDate date], @"start subscribe"]];
	[self.textViewLogs scrollRangeToVisible:NSMakeRange([self.textViewLogs.text length], 0)];

	[PubNub subscribeOnChannels: @[pnChannel]
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
		 isCompletionBlockCalled = YES;

		if( subscriptionError == nil ) {
			BOOL isSubscribed = NO;
			for( int j=0; j<channels.count; j++ ) {
				if( [[channels[j] name] isEqualToString: name] == YES ) {
					isSubscribed = YES;
					break;
				}
			}
			if( isSubscribed == NO ) {
				NSString *eventString = [NSString stringWithFormat:@"      not subscribed %@", name];
				[self.textViewLogs setText:[NSString stringWithFormat:@"%@\n%@:%@", self.textViewLogs.text,[NSDate date], eventString]];
				[self.textViewLogs scrollRangeToVisible:NSMakeRange([self.textViewLogs.text length], 0)];
			}
		}

		NSString *eventString = [NSString stringWithFormat:@"subscribed %@ %@", (subscriptionError!=nil) ? @"ERROR" : @"",
								  (subscriptionError!=nil) ? subscriptionError : @""];
		[self.textViewLogs setText:[NSString stringWithFormat:@"%@\n%@:%@", self.textViewLogs.text,[NSDate date], eventString]];
		[self.textViewLogs scrollRangeToVisible:NSMakeRange([self.textViewLogs.text length], 0)];

//		if( subscriptionError == nil ) {
//		[self performSelector: @selector(checkChannelWithName:) withObject: @"asads" afterDelay: 2.0];
//		[self checkChannelWithName: @"asdfadsfad"];
		[self unsubscribeFromChannels: pnChannel];
	 }];
    // Run loop
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, ([PNConfiguration defaultConfiguration].subscriptionRequestTimeout + 1)* NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		if( isCompletionBlockCalled == NO ) {
			[self.textViewLogs setText:[NSString stringWithFormat:@"%@\n%@:%@", self.textViewLogs.text,[NSDate date], @"subscr. block not called"]];
			[self performSelector: @selector(errorSelectorSubscrBlockNotCalled)];
		}
		else
			[self.textViewLogs setText:[NSString stringWithFormat:@"%@\n%@:%@", self.textViewLogs.text,[NSDate date], @"subscr block"]];
		[self.textViewLogs scrollRangeToVisible:NSMakeRange([self.textViewLogs.text length], 0)];
	});

//	for( int j=0; j<[PNConfiguration defaultConfiguration].subscriptionRequestTimeout+20 && isCompletionBlockCalled == NO; j++ )
//	{
//		NSLog(@"run loop (subscr)");
//		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow:1]];
//	}
//	NSLog(@"end subscribeOnChannels %d", isCompletionBlockCalled);
}

-(void)unsubscribeFromChannels:(PNChannel*)pnChannel {
	__block BOOL isUnCompletionBlockCalled = NO;
	NSLog(@"start unsubscribeFromChannels");

	[self.textViewLogs setText:[NSString stringWithFormat:@"%@\n%@:%@", self.textViewLogs.text,[NSDate date], @"start unsub"]];
	[self.textViewLogs scrollRangeToVisible:NSMakeRange([self.textViewLogs.text length], 0)];
	[PubNub unsubscribeFromChannels: @[pnChannel] withPresenceEvent: YES
		 andCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError)
	 {
		 isUnCompletionBlockCalled = YES;
		 NSString *eventString = [NSString stringWithFormat:@"unsub %@ %@", (unsubscribeError!=nil) ? @"ERROR" : @"",
								  (unsubscribeError!=nil) ? unsubscribeError : @""];
		 [self.textViewLogs setText:[NSString stringWithFormat:@"%@\n%@:%@", self.textViewLogs.text,[NSDate date], eventString]];
		 [self.textViewLogs scrollRangeToVisible:NSMakeRange([self.textViewLogs.text length], 0)];
	 }];
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, ([PNConfiguration defaultConfiguration].subscriptionRequestTimeout + 1) * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		if( isUnCompletionBlockCalled == NO ) {
			[self.textViewLogs setText:[NSString stringWithFormat:@"%@\n%@:%@", self.textViewLogs.text,[NSDate date], @"unsub block not called"]];
			[self performSelector: @selector(errorSelectorUnsubBlockNotCalled)];
		}
		else
			[self.textViewLogs setText:[NSString stringWithFormat:@"%@\n%@:%@", self.textViewLogs.text,[NSDate date], @"unsub block"]];
		[self.textViewLogs scrollRangeToVisible:NSMakeRange([self.textViewLogs.text length], 0)];
	});

	// Run loop
//	for( int j=0; j<[PNConfiguration defaultConfiguration].subscriptionRequestTimeout+20 && isUnCompletionBlockCalled == NO; j++ )
//	{
//		NSLog(@"run loop (ubsubscr)");
//		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow:1]];
//	}
//	NSLog(@"end unsubscribeFromChannels %d", isUnCompletionBlockCalled);
//	if( isUnCompletionBlockCalled == NO )
//		[self.textViewLogs setText:[NSString stringWithFormat:@"%@\n%@:%@", self.textViewLogs.text,[NSDate date], @"unsub block not called"]];
//	[self.textViewLogs scrollRangeToVisible:NSMakeRange([self.textViewLogs.text length], 0)];
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

	[self.btnStartTest setEnabled: YES];
        [self.btnStopTest setEnabled:NO];
        [self.btnStopTest setTitle:@"Unsubscribing" forState:UIControlStateDisabled];
	isRun = NO;
}

- (void)StartSendLoop{
        [appDelegate performSelectorInBackground:@selector(SendLoop) withObject:nil];
}

- (IBAction)switchAutoNamesValueChanged:(id)sender {
        UISwitch *mySwitch = (UISwitch *)sender;
        if ([mySwitch isOn]) {
                [self.textChannels setEnabled:NO];
                [self.textChannels setText:@""];
                [self.textChannels setPlaceholder:@"Disable Auto Names to enter"];
        } else {
                [self.textChannels setEnabled:YES];
                [self.textChannels setPlaceholder:@"Channels (comma sep)"];
        }
}
@end
