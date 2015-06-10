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

@interface PNIntegrationTests : XCTestCase <PNObjectEventListener>
@property (nonatomic) PubNub *client;
@property (nonatomic) XCTestExpectation *networkExpectation;
@property (nonatomic) NSArray *networkResponses;
@end

@implementation PNIntegrationTests

+ (void)setUp {
    [super setUp];
//    [JSZVCR swizzleNSURLSessionClasses];
}

- (void)setUp {
    [super setUp];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"AC941D0E-EB09-4E8D-8489-84534DD51756" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    self.networkResponses = [NSArray arrayWithArray:[dict objectForKey:@"Root"]];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString isEqualToString:@"https://pubsub.pubnub.com/time/0?pnsdk=PubNub-ObjC-iOS%2F4.0&deviceid=7BD5E671-EAE9-47EE-B238-B664101D4994&uuid=322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithHTTPMessageData:nil];
    }];
    self.client = [PubNub clientWithConfiguration:[PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"]];
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
    [[JSZVCR sharedInstance] dumpRecordingsToFile:@"testfile"];
    [super tearDown];
}

- (void)testSimpleSubscribe {
    self.networkExpectation = [self expectationWithDescription:@"network"];
    [self.client subscribeToChannels:@[@"a"] withPresence:NO];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    XCTAssert(YES, @"Pass");
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveMessage:(PNResult<PNMessageResult> *)message withStatus:(PNStatus<PNStatus> *)status {
    [self.networkExpectation fulfill];
    XCTAssertNil(status);
    XCTAssertEqualObjects(self.client, client);
//    XCTAssertEqualObjects(message.uuid, @"08434225-3C89-4B58-ACB9-E727C4167887");
    NSLog(@"message.uuid:");
    NSLog(@"%@", message.uuid);
    XCTAssertNotNil(message.uuid);
//    XCTAssertNil(message.authKey);
    XCTAssertEqual(message.statusCode, 200);
    XCTAssertTrue(message.TLSEnabled);
    XCTAssertEqual(message.operation, PNSubscribeOperation);
    NSLog(@"message:");
    NSLog(@"%@", message.data.message);
    XCTAssertEqualObjects(message.data.message, @"*.............. 3306 - 2015-06-09 16:09:40");
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult<PNPresenceEventResult> *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus<PNSubscriberStatus> *)status {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
