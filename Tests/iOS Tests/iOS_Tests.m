//
//  iOS_Tests.m
//  iOS Tests
//
//  Created by Jordan Zucker on 6/4/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <JSZVCR/JSZVCR.h>

@interface iOS_Tests : XCTestCase <PNObjectEventListener>
@property (nonatomic) PubNub *client;
@property (nonatomic) XCTestExpectation *networkExpectation;
@end

@implementation iOS_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [JSZVCR swizzleNSURLSessionClasses];
    self.client = [PubNub clientWithConfiguration:[PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"]];
    [self.client addListeners:@[self]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.client removeListeners:@[self]];
    self.client = nil;
    [super tearDown];
}

//+ (void)tearDown {
//    [[JSZVCR sharedInstance] dumpRecordingsToFile:@"testfile"];
//}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

//- (void)testSimpleSubscribe {
//    self.networkExpectation = [self expectationWithDescription:@"network call"];
//    [self.client subscribeToChannels:@[@"a"] withPresence:NO];
//    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
//        if (error) {
//            NSLog(@"error: %@", error);
//        }
//    }];
//    
//}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveMessage:(PNResult<PNMessageResult> *)message withStatus:(PNStatus<PNStatus> *)status {
    NSLog(@"message: %@", message);
    NSLog(@"status: %@", status);
    [self.networkExpectation fulfill];
}

@end
