//
//  PNJSONSerializationTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/5/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNJSONSerialization.h"

@interface PNJSONSerialization (test)
+ (void)getCallbackMethodName:(NSString **)callbackMethodName fromJSONString:(NSString *)jsonString;
+ (NSString *)JSONStringFromJSONPString:(NSString *)jsonpString callbackMethodName:(NSString *)callbackMethodName;
+ (BOOL)isJSONStringObject:(id)object;
+ (BOOL)isNSJSONAvailable;
+ (BOOL)isJSONKitAvailable;
@end


@interface PNJSONSerializationTest : SenTestCase

@end

@implementation PNJSONSerializationTest

-(void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testJSONObjectWithString {
	NSArray *arr = @[ @[@"t_9c086([13916003554183288])", @[@(13916003554183288)], @(YES), @"t_9c086", [NSNull null]],
						@[@"t_1c4ee([13916004043951171])", @[@(13916004043951171)], @(YES), @"t_1c4ee", [NSNull null]],
					  @[@"cpe_34fa4({\"error\": \"Expected 32byte hex device token\"})", @{@"error":@"Expected 32byte hex device token"}, @(YES), @"cpe_34fa4", [NSNull null]],
					  @[@"cpe_4acaf({\"status\":403,\"service\":\"Access Manager\",\"error\":true,\"message\":\"Forbidden\",\"payload\":{\"channels\":[\"andoirddev\"]}})", @{@"error":@(YES), @"message":@"Forbidden", @"payload":@{@"channels":@[@"andoirddev"]}, @"service":@"Access Manager", @"status":@(403)}, @(YES), @"cpe_4acaf", [NSNull null]],
					  @[@"pec_6ab27([])", @[], @(YES), @"pec_6ab27", [NSNull null]],
					  @[@"cpd_2a962([1, \"Modified Channels\"])", @[@(1), @"Modified Channels"], @(YES), @"cpd_2a962", [NSNull null]],
					  @[@"arc_f9bbd({\"status\":200,\"message\":\"Success\",\"payload\":{\"subscribe_key\":\"sub-c-6b43405c-3694-11e3-a5ee-02ee2ddab7fe\",\"r\":1,\"ttl\":10,\"w\":1,\"level\":\"subkey\"},\"service\":\"Access Manager\"})", @{@"message":@"Success", @"payload":@{@"level":@"subkey", @"r":@(1), @"subscribe_key":@"sub-c-6b43405c-3694-11e3-a5ee-02ee2ddab7fe", @"ttl":@(10), @"w":@(1)}, @"service":@"Access Manager", @"status":@(200)}, @(YES), @"arc_f9bbd", [NSNull null]],
					  @[@"s_fe4b7([[],\"13916004435944770\",\"\"])", @[@[], @"13916004435944770", @""], @(YES), @"s_fe4b7", [NSNull null]],
					  @[@"lv_9200a({\"action\": \"leave\"})", @{@"action":@"leave"}, @(YES), @"lv_9200a", [NSNull null]],
					 ];

	for( int i=0; i<arr.count; i++ ) {
		NSArray *arrTest = arr[i];
		NSString *json = arrTest[0];

		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
		[PNJSONSerialization JSONObjectWithString: json
								  completionBlock:^(id result, BOOL isJSONP, NSString *callbackMethodName){
									  dispatch_semaphore_signal(semaphore);
									  STAssertTrue( [result isEqual: arrTest[1]], @"");
									  STAssertTrue( isJSONP == [arrTest[2] boolValue], @"");
									  STAssertTrue( [callbackMethodName isEqualToString: arrTest[3]], @"");
								  }
									   errorBlock:^(NSError *error) {
										   dispatch_semaphore_signal(semaphore);
										   STAssertTrue( [arrTest[4] isEqual: [NSNull null]], @"");
									   }];
		while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

		semaphore = dispatch_semaphore_create(0);
		[PNJSONSerialization JSONObjectWithData: [json dataUsingEncoding:NSUTF8StringEncoding]
								  completionBlock:^(id result, BOOL isJSONP, NSString *callbackMethodName){
									  dispatch_semaphore_signal(semaphore);
									  //									  NSLog(@"result %@", result);
									  STAssertTrue( [result isEqual: arrTest[1]], @"");
									  STAssertTrue( isJSONP == [arrTest[2] boolValue], @"");
									  STAssertTrue( [callbackMethodName isEqualToString: arrTest[3]], @"");
								  }
									   errorBlock:^(NSError *error) {
										   dispatch_semaphore_signal(semaphore);
										   STAssertTrue( [arrTest[4] isEqual: [NSNull null]], @"");
									   }];
		while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	}
}

-(void)testStringFromJSONObject {
	STAssertTrue( [[PNJSONSerialization stringFromJSONObject: @"message"] isEqualToString: @"\"message\""], @"");
	STAssertTrue( [[PNJSONSerialization stringFromJSONObject: @(123)] isEqualToString: @"123"], @"");
	STAssertTrue( [[PNJSONSerialization stringFromJSONObject: @(123)] isEqual: @(123)], @"");
	STAssertTrue( [[PNJSONSerialization stringFromJSONObject: @[@"message"]] isEqualToString: @"[\"message\"]"], @"");
	STAssertTrue( [[PNJSONSerialization stringFromJSONObject: @{@"key":@"object"}] isEqualToString: @"{\"key\":\"object\"}"], @"");
}

-(void)testGetCallbackMethodName {
	NSString *callbackMethodName = nil;
	[PNJSONSerialization getCallbackMethodName: &callbackMethodName fromJSONString: @"t_7e40c([13916077996244541])"];
	STAssertTrue( [callbackMethodName isEqualToString: @"t_7e40c"] == YES, @"");

	callbackMethodName = nil;
	[PNJSONSerialization getCallbackMethodName: &callbackMethodName fromJSONString: @"s_afa30([[],\"13916077995773328\"])"];
	STAssertTrue( [callbackMethodName isEqualToString: @"s_afa30"] == YES, @"");

	callbackMethodName = nil;
	[PNJSONSerialization getCallbackMethodName: &callbackMethodName fromJSONString: @"(s_afa30[[],\"13916077995773328\"]))"];
	STAssertTrue( callbackMethodName == nil, @"");
}

-(void)testJSONStringFromJSONPString {
	STAssertTrue( [[PNJSONSerialization JSONStringFromJSONPString: @"t_80d4f([13916089297925772])" callbackMethodName: @"t_80d4f"] isEqualToString: @"[13916089297925772]"] == YES, @"");
	STAssertTrue( [[PNJSONSerialization JSONStringFromJSONPString: @"s_3c1cb([[],\"13916089301310032\"])" callbackMethodName: @"s_3c1cb"] isEqualToString: @"[[],\"13916089301310032\"]"] == YES, @"");
	STAssertTrue( [[PNJSONSerialization JSONStringFromJSONPString: @"s_3c1cbErr([[],\"13916089301310032\"])" callbackMethodName: @"s_3c1cb"] isEqualToString: @"[[],\"13916089301310032\"]"] == YES, @"");
	STAssertTrue( [[PNJSONSerialization JSONStringFromJSONPString: @"s_3c1c_Err([[],\"13916089301310032\"])" callbackMethodName: @"s_3c1cb"] isEqualToString: @"[[],\"13916089301310032\"]"] == NO, @"");
	STAssertTrue( [[PNJSONSerialization JSONStringFromJSONPString: @"66([[],\"13916089301310032\"])" callbackMethodName: @"s_3c1cb"] isEqualToString: @"[[],\"13916089301310032\"]"] == NO, @"");
}

-(void)testIsJSONString {
	STAssertTrue( [PNJSONSerialization isJSONString: @"Hello PubNub"] == NO, @"");
	STAssertTrue( [PNJSONSerialization isJSONString: @"\"Hello PubNub\""] == YES, @"");
	STAssertTrue( [PNJSONSerialization isJSONString: @"\"[Hello PubNub]\""] == YES, @"");
	STAssertTrue( [PNJSONSerialization isJSONString: @"\"(Hello PubNub)\""] == YES, @"");
	STAssertTrue( [PNJSONSerialization isJSONString: @"[\"Hello PubNub\"]"] == YES, @"");
	STAssertTrue( [PNJSONSerialization isJSONString: @"[\"Hello PubNub\""] == NO, @"");
}

-(void)testIsJSONStringObject {
	STAssertTrue( [PNJSONSerialization isJSONStringObject: @"Hello PubNub"] == NO, @"");
	STAssertTrue( [PNJSONSerialization isJSONStringObject: @"\"Hello PubNub\""] == YES, @"");
	STAssertTrue( [PNJSONSerialization isJSONStringObject: @"\"Hello PubNub"] == NO, @"");
}

-(void)testIsNSJSONAvailable {
	STAssertTrue( [PNJSONSerialization isNSJSONAvailable] == (NSClassFromString(@"NSJSONSerialization")!=nil), @"" );
}

-(void)testIsJSONKitAvailable {
	STAssertTrue( [PNJSONSerialization isJSONKitAvailable] == [@"" respondsToSelector:NSSelectorFromString(@"JSONString")], @"" );
}

@end


