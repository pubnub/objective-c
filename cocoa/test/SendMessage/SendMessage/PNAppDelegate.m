//
//  PNAppDelegate.m
//  SendMessage
//
//  Created by Valentin Tuller on 4/4/14.
//  Copyright (c) 2014 Valentin Tuller. All rights reserved.
//

#import "PNAppDelegate.h"

@interface PNAppDelegate ()
{
	BOOL isClientDidReceivePresenceEventNotification;
	BOOL isClientDidReceivePresenceEventLeaveNotification;
    
	NSUInteger countClientDidReceiveMessageNotification;
	NSUInteger countClientDidReceiveMessageDelegate;
	NSUInteger countExpectMessage;
    
	NSMutableArray *expectedMessageObjectsNotification;
	NSMutableArray *expectedMessageObjectsDelegate;
}

@end

@implementation PNAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(kPNClientDidReceivePresenceEventNotification:)
							   name:kPNClientDidReceivePresenceEventNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(kPNClientDidReceiveMessageNotification:)
										 name:kPNClientDidReceiveMessageNotification object:nil];

	NSLog(@"applicationDidFinishLaunching %@", aNotification);
	expectedMessageObjectsNotification = [NSMutableArray array];
	expectedMessageObjectsDelegate = [NSMutableArray array];
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
	[self startSendCommand];
}

#pragma mark - Apple Event Manager
- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSString* url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSLog(@"handleURLEvent %@", url);
}

#pragma mark - PubNub functions

- (void)connect
{
	PNConfiguration *configuration = [PNConfiguration defaultConfiguration];
    
//	configuration = [PNConfiguration configurationForOrigin: @"37.58.79.177" publishKey: @"demo-36" subscribeKey: @"demo-36" secretKey: @"demo-36" authorizationKey: nil];
    
	[PubNub setConfiguration:configuration];
	[PubNub setDelegate:self];
	[PubNub connectWithSuccessBlock:^(NSString *origin){}
                         errorBlock:^(PNError *connectionError){}];
}

- (void)connectAfter:(int)after
            toOrigin:(NSString*)origin
          publishKey:(NSString*)publishKey
        subscribeKey:(NSString*)subscribeKey
           secretKey: (NSString*)secretKey
    authorizationKey:(NSString*)authorizationKey {
    
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [PubNub resetClient];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                    [PubNub setDelegate: self];
                    PNConfiguration *configuration = [PNConfiguration configurationForOrigin: origin publishKey: publishKey subscribeKey: subscribeKey secretKey: secretKey authorizationKey: authorizationKey];
                    [PubNub setConfiguration: configuration];
                
                    [PubNub connectWithSuccessBlock:^(NSString *origin) {
                        [self sendCommand: [NSString stringWithFormat: @"connect %@ %@ %@ %@ %@", origin, publishKey, subscribeKey, secretKey, authorizationKey]];
                        
                } errorBlock:^(PNError *connectionError) {}];
		});
	});
}

-(void)sendCommand:(NSString*)command
{
	[self addMessageToLog: [NSString stringWithFormat: @"send command: %@", command]];
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: [NSString stringWithFormat: @"mediator:///%@", [command stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]]];
}

#pragma mark - Logging

-(void)addMessageToLog:(NSString*)message {
	NSAttributedString *string = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"%@%@ %@", @"\n", [NSDate date], message]];
	[self addAttributedStringToLog: string];
	NSLog(@"log %@", message);
}

-(void)addErrorToLog:(NSString*)message {
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"%@%@ %@", @"\n", [NSDate date], message]];
	NSRange boldedRange = NSMakeRange(0, string.length);
	[string addAttribute: NSFontAttributeName value:[NSFont boldSystemFontOfSize: 15] range:boldedRange];

	[self addAttributedStringToLog: string];
	NSLog(@"log %@", message);
}

-(void)addAttributedStringToLog:(NSAttributedString*)message {

	NSTextStorage *storage = [self.logTextView textStorage];
	[storage beginEditing];

	[storage appendAttributedString: message];
	[storage endEditing];

	if( self.autoscrollButton.state == NSOnState )
		[self.logTextView moveToEndOfDocument: nil];
}

#pragma mark - Test Methods

-(void)startSendCommand
{
	[self.reloadButton setEnabled: NO];
	int delay = 0;
    
	[self sendCommand: @"start"];
	delay += 3;

	[self connectAfter:delay
              toOrigin:@"37.58.79.177"
            publishKey:@"demo-36"
          subscribeKey:@"demo-36"
             secretKey:@"demo-36"
      authorizationKey:@""];
	delay += 5;

	[self subscribeToChannelsWithNames:@[@"ch1", @"ch2", @"ch3"]
                                 after:delay];
	delay += 5;

	[self subscribeToChannelWithName:@"chWithMessageMac"
                               after:delay];
	delay += 5;

	[self checkPresenceAfter:delay];
	delay += 1;

	[self subscribeToChannelWithName:@"myTestChannel010"
                               after:delay];
	delay += 5;

	[self checkPresenceAfter:delay];
	delay += 1;

	[self sendMessage:@[@"test1", @"test1"]
                after:delay
    toChannelWithName:@"chWithMessageMac"
        andCheckAfter:5];
	delay += 6;

	[self sendMessage:@{@"key": @"value"}
                after:delay
    toChannelWithName:@"chWithMessageMac"
        andCheckAfter:5];
	delay += 6;

	[self sendMessages:10
                 after:delay
     toChannelWithName:@"chWithMessageMac"
         andCheckAfter:10];
	delay += 11;

	[self sendMessages:10
                 after:delay
     toChannelWithName:@"chWithMessageMac"
         andCheckAfter:10];
	delay += 11;

	[self sendMessages:10
                 after:delay
     toChannelWithName:@"chWithMessageMac"
         andCheckAfter:10];
	delay += 11;

	[self sendMessages:10
                 after:delay
     toChannelWithName: @"chWithMessageMac"
         andCheckAfter: 10];
	delay += 11;

	[self sendMessages:10
                 after:delay
     toChannelWithName:@"chWithMessageMac"
         andCheckAfter:10];
	delay += 11;

	[self subscribeToChannelWithName: @"ch1" after: delay];
	delay += 5;
	[self checkPresenceAfter: delay];
	delay += 1;

	[self sendMessages:100
                 after:delay
     toChannelWithName:@"myTestChannel010"
         andCheckAfter:30];
	delay += 31;

	[self sendMessages:100
                 after:delay
     toChannelWithName:@"chWithMessageMac"
         andCheckAfter:30];
	delay += 31;

	[self sendMessages:100 after: delay toChannelWithName: @"chWithMessageMac" andCheckAfter: 30];
	delay += 21;

	[self unsubscribeFromAllChannelsAfter: delay];
	delay += 5;

	[self logFinishAfter: delay];
}

-(void)logFinishAfter:(int)after {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
		[self addMessageToLog:@"finish"];
		[self.reloadButton setEnabled: YES];
        
	});
}

-(void)connectAfter:(int)delay {
    
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[self sendCommand:@"connect"];
	});
}

-(void)sendMessages:(int)countMessage after:(int)after toChannelWithName:(NSString*)name andCheckAfter:(int)checkAfter {
    
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		countExpectMessage = countMessage;
		countClientDidReceiveMessageNotification = NO;
		countClientDidReceiveMessageDelegate = NO;
	});
    
 	for( int i=0; i<countMessage; i++ )	{
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC + 1000 + i * 1000), dispatch_get_main_queue(), ^{
            
			NSString *message = [NSString stringWithFormat: @"message_%d", i + 1];
			[self sendCommand: [NSString stringWithFormat: @"sendMessage %@ %@", name, message]];
            
			[expectedMessageObjectsNotification addObject:message];
			[expectedMessageObjectsDelegate addObject:message];
            
		});
	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (after+checkAfter) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if( countClientDidReceiveMessageNotification != countExpectMessage ) {
			[self addErrorToLog: [NSString stringWithFormat: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! invalid message count %lu/%lu", countClientDidReceiveMessageNotification, countExpectMessage]];
        } else {
			[self addMessageToLog: [NSString stringWithFormat: @"received all (%lu) message (notification)", countExpectMessage]];
        }
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (after+checkAfter) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if( countClientDidReceiveMessageDelegate != countExpectMessage ) {
			[self addErrorToLog:[NSString stringWithFormat: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! invalid message count %lu/%lu", countClientDidReceiveMessageDelegate, countExpectMessage]];
        } else {
			[self addMessageToLog:[NSString stringWithFormat: @"received all (%lu) message (delegate)", countExpectMessage]];
        }
	});
}

-(void)sendMessage:(id)message after:(int)after toChannelWithName:(NSString*)name andCheckAfter:(int)checkAfter {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		countExpectMessage = 1;
		countClientDidReceiveMessageNotification = 0;
		countClientDidReceiveMessageDelegate = 0;
	});
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC + 1000), dispatch_get_main_queue(), ^{
		id object = @"ERROR message";
		if( [message isKindOfClass: [NSString class]] == YES )
			object = [message stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
		if( [message isKindOfClass: [NSDictionary class]] == YES || [message isKindOfClass: [NSArray class]] == YES ) {
			NSError *error;
			NSData *jsonData = [NSJSONSerialization dataWithJSONObject: message options: 0 error: &error];
			if( jsonData != nil) {
				object = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
				object = [object stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
			}
		}
		[self sendCommand: [NSString stringWithFormat: @"sendMessage %@ %@", name, object]];
		[expectedMessageObjectsNotification addObject: message];
		[expectedMessageObjectsDelegate addObject: message];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (after+checkAfter) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if( countClientDidReceiveMessageNotification != countExpectMessage )
			[self addErrorToLog: [NSString stringWithFormat: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! invalid message count %d/%d", countClientDidReceiveMessageNotification, countExpectMessage]];
		else
			[self addMessageToLog: [NSString stringWithFormat: @"received all (%d) message (notification)", countExpectMessage]];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (after+checkAfter) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if( countClientDidReceiveMessageDelegate != countExpectMessage )
			[self addErrorToLog: [NSString stringWithFormat: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! invalid message count %d/%d", countClientDidReceiveMessageDelegate, countExpectMessage]];
		else
			[self addMessageToLog: [NSString stringWithFormat: @"received all (%d) message (delegate)", countExpectMessage]];
	});
}
////////////////////////////////////////////////////////////////////////////////////////
-(void)subscribeToChannelWithName:(NSString*)name after:(int)after
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
		isClientDidReceivePresenceEventNotification = NO;
        
		PNChannel *pnChannel = [PNChannel channelWithName: name shouldObservePresence: YES];
		[PubNub subscribeOnChannel: pnChannel withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
			[self addMessageToLog: [NSString stringWithFormat: @"subscribeOnChannel %@ %lu", name, state]];
			[self sendCommand: [NSString stringWithFormat: @"subscribe %@", name]];
		 }];

	});
}

-(void)subscribeToChannelsWithNames:(NSArray*)names after:(int)after
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
		isClientDidReceivePresenceEventNotification = 0;
        
		NSMutableArray *channels = [NSMutableArray array];
		for( int i=0; i< names.count; i++ )
			[channels addObject: [PNChannel channelWithName: names[i] shouldObservePresence: YES]];
            [PubNub subscribeOnChannels: channels withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
                [self addMessageToLog: [NSString stringWithFormat: @"subscribeOnChannels %@ %lu", names, state]];

			NSMutableString *command = [@"subscribeToChannels " mutableCopy];
			for( int i=0; i<names.count; i++ )
				[command appendFormat: @"%@%@", names[i], (i<names.count-1) ? @" " : @""];
			[self sendCommand: command];
		}];
	});
}

-(void)checkPresenceAfter:(int)after
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if( isClientDidReceivePresenceEventNotification == NO )
			[self addErrorToLog: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! kPNClientDidReceivePresenceEventNotification not called"];
		else
			[self addMessageToLog: @"kPNClientDidReceivePresenceEventNotification called"];
	});
}

- (void)kPNClientDidReceivePresenceEventNotification:(NSNotification *)notification {
	PNPresenceEvent *event = (PNPresenceEvent*)notification.userInfo;
    PNLog(PNLogGeneralLevel, self, @"NSNotification kPNClientDidReceivePresenceEventNotification: %@", event);
    
    // unknown type of presence event
	NSString *type = @"???";
	type = (event.type == PNPresenceEventChanged) ? @"changed" : type;
	type = (event.type == PNPresenceEventJoin) ? @"join" : type;
	type = (event.type == PNPresenceEventLeave) ? @"leave" : type;
	type = (event.type == PNPresenceEventTimeout) ? @"timeout" : type;
    
	[self addMessageToLog: [NSString stringWithFormat: @"kPNClientDidReceivePresenceEventNotification, %@, %@", type ,event.client.channel.name]];
    
	if( event.type == PNPresenceEventJoin ) {
		isClientDidReceivePresenceEventNotification = YES;
    }
    
	if( event.type == PNPresenceEventLeave ) {
		isClientDidReceivePresenceEventLeaveNotification = YES;
    }
}

-(void)unsubscribeFromChannelWithName:(NSString*)name
                                after:(int)after
                   andCheckLeaveAfter:(int)checkAfter {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		isClientDidReceivePresenceEventLeaveNotification = NO;
		[self sendCommand: [NSString stringWithFormat: @"unsubscribe %@", name]];
	});
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (after+checkAfter) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
		if( isClientDidReceivePresenceEventLeaveNotification == NO ) {
			[self addErrorToLog: @"ERROR clientDidReceivePresenceEventNotification leave is not called"];
        } else {
			[self addMessageToLog: @"clientDidReceivePresenceEventNotification leave called"];
        }

		PNChannel *pnChannel = [PNChannel channelWithName: name];
		[PubNub unsubscribeFromChannel: pnChannel withCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError)
		 {
			 [self addMessageToLog: [NSString stringWithFormat: @"unsubscribeFromChannel %@", (unsubscribeError!=nil) ? unsubscribeError:@""]];
		 }];
	});
}

-(void)unsubscribeFromAllChannelsAfter:(int)after {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[self sendCommand: [NSString stringWithFormat: @"unsubscribeAll"]];
	});
}

#pragma mark - PubNub client delegate

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
	countClientDidReceiveMessageDelegate++;
    
	[self addMessageToLog: [NSString stringWithFormat: @"didReceiveMessage %@", message.message]];
    
	if( expectedMessageObjectsDelegate.count == 0 ) {
		[self addErrorToLog: [NSString stringWithFormat: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! unexpected message %@", message.message]];
		return;
	}
    
	if( [expectedMessageObjectsDelegate[0] isEqualTo:message.message] == NO ) {
		[self addErrorToLog: [NSString stringWithFormat: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! invalid message \"%@\" != \"%@\"", expectedMessageObjectsDelegate[0], message.message]];
	}
    
	[expectedMessageObjectsDelegate removeObjectAtIndex: 0];
}


- (void)kPNClientDidReceiveMessageNotification:(NSNotification *)notification {
    
	countClientDidReceiveMessageNotification++;

	PNMessage *message = (PNMessage*)(notification.userInfo);
	[self addMessageToLog: [NSString stringWithFormat: @"kPNClientDidReceiveMessageNotification %@", message.message]];
    
	if( expectedMessageObjectsNotification.count == 0 ) {
		[self addErrorToLog: [NSString stringWithFormat: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! unexpected message %@", message.message]];
		return;
	}

	if( [expectedMessageObjectsNotification[0] isEqualTo:message.message] == NO ) {
		[self addErrorToLog: [NSString stringWithFormat: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! invalid message \"%@\" != \"%@\"", expectedMessageObjectsNotification[0], message.message]];
	}
    
	[expectedMessageObjectsNotification removeObjectAtIndex: 0];
}

#pragma mark - Callbacks

- (IBAction)reloadClick:(id)sender {
    
	[self.logTextView setString:[NSString string]];
	[self startSendCommand];
    
}

@end
