//
//  PNConsoleView.h
//  pubnub
//
//  Created by Sergey Mamontov on 4/3/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark Public interface declaration

@interface PNConsoleView : UITextView


#pragma mark - Instance methods

/**
 Completely replae console output with passed value.
 
 @param consoleOutput
 \b NSString instance which should be used to replace current console output.
 */
- (void)setOutputTo:(NSString *)consoleOutput;

/**
 Append to current console output provided information.
 
 @param consoleOutput
 \b NSString instance which should be appended at the end of console output.
 */
- (void)addOutput:(NSString *)consoleOutput;

#pragma mark -


@end
