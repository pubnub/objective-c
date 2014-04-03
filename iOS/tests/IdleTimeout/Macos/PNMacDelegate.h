//
//  PNAppDelegate.h
//  Macos
//
//  Created by Valentin Tuller on 4/3/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PNMacDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (retain) NSDate *lastReconnect;

-(void)didConnectionReconnect;

@end
