//
//  PNIntegrationTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/9/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>
#import <JSZVCR/JSZVCR.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <JSZVCR/JSZVCRResourceLoader.h>

@interface PNIntegrationTests : XCTestCase <PNObjectEventListener>
@property (nonatomic) PubNub *client;
@property (nonatomic) XCTestExpectation *networkExpectation;
@end

@implementation PNIntegrationTests

+ (void)setUp {
    [super setUp];
//    [JSZVCR swizzleNSURLSessionClasses];
    [[JSZVCRResourceLoader sharedInstance] setResourceBundle:@"NetworkResponses" containingClass:self.class];
}

- (void)setUp {
    [super setUp];
    [[JSZVCRResourceLoader sharedInstance] setTest:self];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [[JSZVCRResourceLoader sharedInstance] hasResponseForRequest:request];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our "wsresponse.json" stub file (which is in same bundle as self)
        NSDictionary *responseDict = [[JSZVCRResourceLoader sharedInstance] responseForRequest:request];
        return [OHHTTPStubsResponse responseWithData:responseDict[@"data"]
                                          statusCode:[responseDict[@"statusCode"] intValue]
                                             headers:responseDict[@"httpHeaders"]];
    }];
    PNConfiguration *config = [PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
    config.uuid = @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C";
    self.client = [PubNub clientWithConfiguration:config];
    [self.client addListeners:@[self]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.networkExpectation = nil;
    [self.client removeListeners:@[self]];
    self.client = nil;
    [OHHTTPStubs removeAllStubs];
    [super tearDown];
}

+ (void)tearDown {
//    [[JSZVCR sharedInstance] dumpRecordingsToFile:@"testfile"];
    [super tearDown];
}

- (void)testSimpleSubscribe {
    self.networkExpectation = [self expectationWithDescription:@"network"];
    [self.client subscribeToChannels:@[@"a"] withPresence:NO];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveMessage:(PNResult<PNMessageResult> *)message withStatus:(PNStatus<PNStatus> *)status {
    [self.networkExpectation fulfill];
    XCTAssertNil(status);
    XCTAssertEqualObjects(self.client, client);
//    XCTAssertEqualObjects(message.uuid, @"08434225-3C89-4B58-ACB9-E727C4167887");
    NSLog(@"message.uuid:");
    NSLog(@"%@", message.uuid);
    XCTAssertNotNil(message.uuid);
    XCTAssertNil(message.authKey);
    XCTAssertEqual(message.statusCode, 200);
    XCTAssertTrue(message.TLSEnabled);
    XCTAssertEqual(message.operation, PNSubscribeOperation);
    NSLog(@"message:");
    NSLog(@"%@", message.data.message);
    XCTAssertEqualObjects(message.data.message, @"******......... 3440 - 2015-06-10 14:33:55");
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult<PNPresenceEventResult> *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus<PNSubscriberStatus> *)status {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
