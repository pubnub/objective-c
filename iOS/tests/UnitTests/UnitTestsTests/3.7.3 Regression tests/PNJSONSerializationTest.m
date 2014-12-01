//
//  PNJSONSerializationTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/5/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNJSONSerialization.h"

@interface PNJSONSerialization (test)

+ (void)getCallbackMethodName:(NSString **)callbackMethodName
               fromJSONString:(NSString *)jsonString;
+ (NSString *)JSONStringFromJSONPString:(NSString *)jsonpString
                     callbackMethodName:(NSString *)callbackMethodName;
+ (BOOL)isJSONStringObject:(id)object;
+ (BOOL)isNSJSONAvailable;
+ (BOOL)isJSONKitAvailable;

@end


@interface PNJSONSerializationTest : XCTestCase {
    NSDictionary *_dictionary;
    NSDictionary *_deserializedDictionaryNS;
    NSDictionary *_deserializedDictionaryPN;
    
    NSString *_jsonString;
    NSString *_jsonStringNS;
    NSString *_jsonStringPN;
}

@end

@implementation PNJSONSerializationTest

-(void)tearDown {
    [super tearDown];
}

- (void)setUp {
    [super setUp];
}

#pragma mark - Tests



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
									  XCTAssertTrue( [result isEqual: arrTest[1]], @"");
									  XCTAssertTrue( isJSONP == [arrTest[2] boolValue], @"");
									  XCTAssertTrue( [callbackMethodName isEqualToString: arrTest[3]], @"");
								  }
									   errorBlock:^(NSError *error) {
										   dispatch_semaphore_signal(semaphore);
										   XCTAssertTrue( [arrTest[4] isEqual: [NSNull null]], @"");
									   }];
		while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        

		semaphore = dispatch_semaphore_create(0);
		[PNJSONSerialization JSONObjectWithData: [json dataUsingEncoding:NSUTF8StringEncoding]
								  completionBlock:^(id result, BOOL isJSONP, NSString *callbackMethodName){
									  dispatch_semaphore_signal(semaphore);
									  NSLog(@"result %@", result);
									  XCTAssertTrue( [result isEqual: arrTest[1]], @"");
									  XCTAssertTrue( isJSONP == [arrTest[2] boolValue], @"");
									  XCTAssertTrue( [callbackMethodName isEqualToString: arrTest[3]], @"");
								  }
									   errorBlock:^(NSError *error) {
										   dispatch_semaphore_signal(semaphore);
										   XCTAssertTrue( [arrTest[4] isEqual: [NSNull null]], @"");
									   }];
		while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        	}
}


// SERGEY
// Comparison PNJSONSerialization with NSJSONSerialization
-(void)testComparisonJSONSerialization {
    
    // Initial dictionary for JSONSerialization
    _dictionary =
  @{
    @"First Name": @"Anthony",
    @"Last Name": @"Robbins",
    @"Age": @51,
    @"children": @[
            @"Anthony's Son 1",
            @"Anthony's Daughter 1",
            @"Anthony's Son 2",
            @"Anthony's Son 3",
            @"Anthony's Daughter 2"
            ],
    };

    // Serialize the dictionary in a JSON object with NSJSONSerialization and PNJSONSerialization, then сomparison of the results
    
    // Serialize the dictionary in a JSON object (NS)
    NSError *error = nil;
        NSData *jsonDataNS = [NSJSONSerialization dataWithJSONObject:_dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];

    if ([jsonDataNS length] > 0 && error == nil){
        _jsonStringNS = [[NSString alloc] initWithData: jsonDataNS
                                                     encoding: NSUTF8StringEncoding];
        NSLog(@"Successfully serialized the dictionary into Json data (NS) = %@", _jsonStringNS);
    }
    else if ([jsonDataNS length] == 0 && error == nil){
        NSLog(@"No data was returned after serialization the dictionary into Json data  (NS)");
    }
    else if (error!= nil){
        NSLog(@"An error happened while serialization into Json data (NS) %@", error);
    }
    
    // Serialize the dictionary in a JSON object (PN)   !!! Thera no method [PNJSONSerialization dataWithJSONObject] ???
    _jsonStringPN = [PNJSONSerialization stringFromJSONObject:_dictionary];
    NSLog(@"Successfully serialized the dictionary into data (PN) = %@", _jsonStringPN);
    
    NSData *jsonDataPN = [_jsonStringPN dataUsingEncoding:NSUTF8StringEncoding];

    
    // Test equal result jsonDataNS and jsonDataPN
    NSLog(@"Serialized the dictionary in a JSON object (NS) = %@", jsonDataNS);
    NSLog(@"Serialized the dictionary in a JSON object (PN) = %@", jsonDataPN);
//    XCTAssertTrue([_jsonStringNS isEqualToString: _jsonStringPN], @"Equaling jsonStrings after serialized - error");
//    XCTAssertEqualObjects(jsonDataNS, jsonDataPN, @"Equaling jsonDatas after serialized - error");   !!! Work differently (/n), afterwards it works correctly ???
    

    
    // Deserialize the JSON object in a dictionary with NSJSONSerialization and PNJSONSerialization, then сomparison of the results
    
    // Deserialize the JSON object in a dictionary (NS)
    error = nil;
    id jsonObjectNS = [NSJSONSerialization JSONObjectWithData:jsonDataNS
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    if (jsonObjectNS!= nil && error == nil){
        
        if ([jsonObjectNS isKindOfClass: [NSDictionary class]]){
            _deserializedDictionaryNS = (NSDictionary *)jsonObjectNS;
            NSLog(@"Successfully deserialized the JSON data (NS) = %@", _deserializedDictionaryNS);
        }
        else {
            NSLog(@"Error deserialized the JSON data (NS)");
        }
 
    }
    else if (error!= nil){
        NSLog(@"An error happened while deserializing the JSON data (NS)");
    }
    
    // Deserialize the JSON object in a dictionary (PN)
    error = nil;
    [PNJSONSerialization JSONObjectWithData:jsonDataPN
                            completionBlock:^(id jsonObjectPN, BOOL isJSONP, NSString *callbackMethodName) {
                                
                                if (jsonObjectPN!= nil && [jsonObjectPN isKindOfClass: [NSDictionary class]]){
                                    _deserializedDictionaryPN = (NSDictionary *)jsonObjectPN;
                                    NSLog(@"Successfully deserialized the JSON data (PN) = %@", _deserializedDictionaryPN);
                                }
                                else {
                                    NSLog(@"Error deserialized the JSON data (PN)");
                                }
                                
                            } errorBlock:^(NSError *error) {
                                NSLog(@"An error happened while deserializing the JSON data (PN) %@", error);
                            }];
   
    // Test equal result deserializedDictionaryNS and deserializedDictionaryPN
    _jsonStringNS = [_deserializedDictionaryNS description];
    _jsonStringPN = [_deserializedDictionaryPN description];
    XCTAssertTrue([_jsonStringNS isEqualToString: _jsonStringPN], @"Equaling strings after deserialized - error");
    XCTAssertEqualObjects(_deserializedDictionaryNS, _deserializedDictionaryPN, @"Equaling dictionaries after deserialized - error");
    

    // Test equal result dictionary (PN) and initial dictionary
    _jsonString = [_dictionary description];
    XCTAssertTrue([_jsonString isEqualToString: _jsonStringPN], @"Serialize error");
    XCTAssertEqualObjects(_dictionary, _deserializedDictionaryPN, @"Serialize error");
    
}


-(void)testStringFromJSONObject {
	XCTAssertTrue( [[PNJSONSerialization stringFromJSONObject: @"message"] isEqualToString: @"\"message\""], @"");
	XCTAssertTrue( [[PNJSONSerialization stringFromJSONObject: @[@"message"]] isEqualToString: @"[\"message\"]"], @"");
	XCTAssertTrue( [[PNJSONSerialization stringFromJSONObject: @{@"key":@"object"}] isEqualToString: @"{\"key\":\"object\"}"], @"");
}

-(void)testGetCallbackMethodName {
	NSString *callbackMethodName = nil;
	[PNJSONSerialization getCallbackMethodName: &callbackMethodName fromJSONString: @"t_7e40c([13916077996244541])"];
	XCTAssertTrue( [callbackMethodName isEqualToString: @"t_7e40c"] == YES, @"");

	callbackMethodName = nil;
	[PNJSONSerialization getCallbackMethodName: &callbackMethodName fromJSONString: @"s_afa30([[],\"13916077995773328\"])"];
	XCTAssertTrue( [callbackMethodName isEqualToString: @"s_afa30"] == YES, @"");

	callbackMethodName = nil;
	[PNJSONSerialization getCallbackMethodName: &callbackMethodName fromJSONString: @"(s_afa30[[],\"13916077995773328\"]))"];
	XCTAssertTrue( callbackMethodName == nil, @"");
}

-(void)testJSONStringFromJSONPString {
	XCTAssertTrue( [[PNJSONSerialization JSONStringFromJSONPString: @"t_80d4f([13916089297925772])" callbackMethodName: @"t_80d4f"] isEqualToString: @"[13916089297925772]"] == YES, @"");
	XCTAssertTrue( [[PNJSONSerialization JSONStringFromJSONPString: @"s_3c1cb([[],\"13916089301310032\"])" callbackMethodName: @"s_3c1cb"] isEqualToString: @"[[],\"13916089301310032\"]"] == YES, @"");
	XCTAssertTrue( [[PNJSONSerialization JSONStringFromJSONPString: @"s_3c1cbErr([[],\"13916089301310032\"])" callbackMethodName: @"s_3c1cb"] isEqualToString: @"[[],\"13916089301310032\"]"] == YES, @"");
	XCTAssertTrue( [[PNJSONSerialization JSONStringFromJSONPString: @"s_3c1c_Err([[],\"13916089301310032\"])" callbackMethodName: @"s_3c1cb"] isEqualToString: @"[[],\"13916089301310032\"]"] == YES, @"");
	XCTAssertTrue( [[PNJSONSerialization JSONStringFromJSONPString: @"66([[],\"13916089301310032\"])" callbackMethodName: @"s_3c1cb"] isEqualToString: @"[[],\"13916089301310032\"]"] == YES, @"");
}

-(void)testIsJSONString {
	XCTAssertTrue( [PNJSONSerialization isJSONString: @"Hello PubNub"] == NO, @"");
	XCTAssertTrue( [PNJSONSerialization isJSONString: @"\"Hello PubNub\""] == YES, @"");
	XCTAssertTrue( [PNJSONSerialization isJSONString: @"\"[Hello PubNub]\""] == YES, @"");
	XCTAssertTrue( [PNJSONSerialization isJSONString: @"\"(Hello PubNub)\""] == YES, @"");
	XCTAssertTrue( [PNJSONSerialization isJSONString: @"[\"Hello PubNub\"]"] == YES, @"");
	XCTAssertTrue( [PNJSONSerialization isJSONString: @"[\"Hello PubNub\""] == NO, @"");
}

-(void)testIsJSONStringObject {
	XCTAssertTrue( [PNJSONSerialization isJSONStringObject: @"Hello PubNub"] == NO, @"");
	XCTAssertTrue( [PNJSONSerialization isJSONStringObject: @"\"Hello PubNub\""] == YES, @"");
    XCTAssertTrue( [PNJSONSerialization isJSONStringObject: @"\"[Hello PubNub]\""] == YES, @"");
	XCTAssertTrue( [PNJSONSerialization isJSONStringObject: @"\"Hello PubNub"] == NO, @"");
}

-(void)testIsNSJSONAvailable {
	XCTAssertTrue( [PNJSONSerialization isNSJSONAvailable] == (NSClassFromString(@"NSJSONSerialization")!=nil), @"" );
}

-(void)testIsJSONKitAvailable {
   	XCTAssertTrue( [PNJSONSerialization isJSONKitAvailable] == [@"" respondsToSelector:NSSelectorFromString(@"JSONString")], @"" );
}

@end


