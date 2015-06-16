//
//  PNPublishTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/15/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>
#import <JSZVCR/JSZVCR.h>

@interface PNPublishTests : JSZVCRTestCase
@property (nonatomic) PubNub *client;
@property (nonatomic) XCTestExpectation *networkExpectation;
@end

@implementation PNPublishTests

- (BOOL)recording {
    return NO;
}

- (void)setUp {
    [super setUp];
    PNConfiguration *config = [PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
    config.uuid = @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C";
    self.client = [PubNub clientWithConfiguration:config];
}

- (void)tearDown {
    self.networkExpectation = nil;
    self.client = nil;
    [super tearDown];
}

- (void)testSimplePublish {
    [self performVerifiedPublish:@"test"];
}

- (void)performVerifiedPublish:(id)message {
    XCTestExpectation *networkExpectation = [self expectationWithDescription:@"network"];
    NSString *uniqueChannel = [NSUUID UUID].UUIDString;
    [self.client publish:@"test" toChannel:uniqueChannel withCompletion:^(PNStatus<PNPublishStatus> *status) {
        XCTAssertNotNil(status);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.operation, PNPublishOperation);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertFalse(status.isError);
        XCTAssertEqualObjects(status.data.information, @"Sent");
        NSLog(@"timeToken: %@", status.data.timetoken);
//        XCTAssertEqualObjects(status.data.timetoken, @14344367967452689);
        [networkExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

@end
