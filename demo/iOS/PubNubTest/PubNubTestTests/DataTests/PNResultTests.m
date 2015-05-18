//
//  PNResultTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/13/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import "PNResult+Private.h"
#import "PNRequest+Private.h"
#import "PNPrivateStructures.h"

#import "PubNub.h"

#import "GCDGroup.h"
#import "GCDWrapper.h"

static NSString const *deviceid = @"F9D977FE-34AB-440D-B1D3-531F0780FD51";

@interface PNResultTests : XCTestCase

@end

@implementation PNResultTests {
    
    PubNub *_pubNub;
}

- (void)setUp {
    
    [super setUp];
    _pubNub = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
    _pubNub.uuid = @"testUUID";
    _pubNub.callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
}

- (void)tearDown {
    
    _pubNub = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void)testInitializationFabricMethod {
    
    GCDGroup *group = [GCDGroup group];
    [group enter];
    
    [_pubNub timeWithCompletion:^(PNResult *result, PNStatus *status) {
        
        NSLog(@"!!! %@ (status: %@)", [result clientRequest], [status debugDescription]);
        [group leave];
    }];
    
    
    if ([GCDWrapper isGCDGroup:group timeoutFiredValue:10]) {
        NSLog(@"Timeout fired");
    }
    
    
    /*
     // Init with nil-parametrs
    PNResult *testResult = [PNResult resultForRequest:nil withResponse:nil andData:nil];
    
    assertThat(testResult, notNilValue());
    
    assertThat([testResult request], equalTo nil);
    assertThat([testResult response], equalTo(@"(null)\n\t\(null)"));
    assertThat([testResult origin], equalTo nil);
    assertThat([testResult data], equalTo nil);
    
    assertThatInteger([testResult operation], is(equalToInteger(0)));
    assertThatInteger([testResult statusCode], is(equalToInteger(0)));
    
    
    // Init with correct parametrs
    NSString *requestWithPath = @"test/path";
    NSDictionary *parameters = @{@"test": @43};
    PNOperationType operationType = PNTimeOperation;
    void(^completionBlock)(PNResult *result, PNStatus *status) = ^void(PNResult *result, PNStatus *status){};
    
    PNRequest *testRequest = [PNRequest requestWithPath:requestWithPath parameters:parameters forOperation:operationType withCompletion:completionBlock];
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://pubsub.pubnub.com/time/0?"] statusCode:1 HTTPVersion:@"2" headerFields:nil];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://pubsub.pubnub.com/time/0?"]];
    
    testResult = [PNResult resultForRequest:testRequest withResponse:response andData:data];
    
    assertThat(testResult, notNilValue());
    
    assertThat(testResult, hasProperty(@"request", notNilValue()));
    assertThat(testResult, hasProperty(@"response", notNilValue()));
    assertThat(testResult, hasProperty(@"origin", notNilValue()));
    assertThat(testResult, hasProperty(@"data", notNilValue()));
    
    assertThatInteger([testResult operation], is(equalToInteger(operationType)));
    assertThatInteger([testResult statusCode], is(equalToInteger(response.statusCode)));
    
    
    // Init with uncorrect parametrs (has no control for input parameters !!!)
    requestWithPath = @"test/path";
    parameters = @{@"test": @43};
    operationType = 100;
    
    testRequest = [PNRequest requestWithPath:requestWithPath parameters:parameters forOperation:operationType withCompletion:completionBlock];
    response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"test/path"] statusCode:1 HTTPVersion:@"2" headerFields:nil];
    data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://pubsub.pubnub.com/time/0?"]];
    
    testResult = [PNResult resultForRequest:testRequest withResponse:response andData:data];
    
    assertThat(testResult, notNilValue());
    
    assertThat([testResult request], equalTo nil);
    assertThat(testResult, hasProperty(@"response", notNilValue()));
    assertThat([testResult origin], equalTo nil);
    assertThat([testResult data], equalTo nil);
    
    assertThatInteger([testResult operation], is(equalToInteger(operationType)));
    assertThatInteger([testResult statusCode], is(equalToInteger(response.statusCode)));
     */
}

@end
