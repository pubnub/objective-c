//
//  MyPNConnection.m
//  pubnub
//
//  Created by Valentin Tuller on 2/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "MyPNConnection.h"
#import "PNResponseDeserialize.h"

@interface PNConnection (Test)

@property NSMutableData *retrievedData;
@property (nonatomic, strong) PNResponseDeserialize *deserializer;

@end

@implementation MyPNConnection

- (NSMutableData *)retrievedData {
	NSMutableData *data = [super retrievedData];
	NSString *str = [NSString stringWithUTF8String:[data bytes]];
	NSLog(@"MyPNConnection retrievedData\n|%@|", str);
	if( str != nil && [str rangeOfString: @"\"status\": 200"].location != NSNotFound &&
	   [str rangeOfString: @"\"message\": \"OK\""].location != NSNotFound &&
	   [str rangeOfString: @"\"service\": \"Presence\""].location != NSNotFound ) {
		[[NSNotificationCenter defaultCenter] postNotificationName: @"presenceEvent" object: str];
	}
    return data;
}

@end
