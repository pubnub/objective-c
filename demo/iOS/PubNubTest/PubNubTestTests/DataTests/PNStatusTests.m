//
//  PNStatusTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/14/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import "PNStatus+Private.h"
#import "PNRequest+Private.h"
#import "PNResult+Private.h"

#import "PubNub.h"

#import "GCDGroup.h"
#import "GCDWrapper.h"

@interface PNStatusTests : XCTestCase

@end

@implementation PNStatusTests {
    
    GCDGroup *_resGroup;
    PubNub *_pubNub;
    NSString *_testFileName;
}

- (void)setUp {
    
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
    _pubNub.uuid = @"testUUID";
    _pubNub.callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    NSString *_testFileName = @"Temp_PNResult";
}

- (void)tearDown {
    
    _pubNub = nil;
    [super tearDown];
}

- (void)testInitializationFabricMethod {
    
    // Save correctly PNResult for testing to file
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    __block PNResult *_result;
    _pubNub.callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    [_pubNub timeWithCompletion:^(PNResult *result, PNStatus *status) {
        
        NSLog(@"!!! %@ (status: %@)", [result clientRequest], [status debugDescription]);
        _result = result;
        [_resGroup leave];
    }];
    
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        NSLog(@"Timeout fired");
    }
    
    [self saveObject:_result inFileWithName:_testFileName];

    /*
    // Init with nil-parametrs
    PNStatus *testStatus = [PNStatus statusForRequest:nil withResponse:nil error:nil andData:nil];

    assertThat(testStatus, notNilValue());
    
    assertThat(testStatus, hasProperty(@"isSSLEnabled", @0));
    assertThat([testStatus channels], equalTo nil);
    assertThat([testStatus groups], equalTo nil);
    assertThat([testStatus uuid], equalTo nil);
    assertThat([testStatus authorizationKey], equalTo nil);
    assertThat([testStatus state], equalTo nil);
    assertThat(testStatus, hasProperty(@"isError", @1));
    assertThat([testStatus currentTimetoken], equalTo nil);
    assertThat([testStatus previousTimetoken], equalTo nil);
    

    // Init with correct parametrs
    NSString *requestWithPath = @"test/path";
    NSDictionary *parameters = @{@"test": @43};
    PNOperationType operationType = PNTimeOperation;
    void(^completionBlock)(PNResult *result, PNStatus *status) = ^void(PNResult *result, PNStatus *status){};
    
    PNRequest *testRequest = [PNRequest requestWithPath:requestWithPath parameters:parameters forOperation:operationType withCompletion:completionBlock];
    
    NSHTTPURLResponse *testResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"http://loveza.ru/masha/205.jpg"] statusCode:1 HTTPVersion:@"2" headerFields:nil];
    
    testStatus = [PNStatus statusForRequest:testRequest withResponse:testResponse error:nil andData:nil];

    // Init with uncorrect parametrs
    
    */
}


#pragma mark - private methods

- (void)saveObject:(id)classObject inFileWithName:(NSString *)filename {
    
    filename = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
    
    NSData *dataOnObject = [NSKeyedArchiver archivedDataWithRootObject:classObject];
    [dataOnObject writeToFile:filename atomically:YES];
}

@end
