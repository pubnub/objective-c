//
//  PNClientConfigurationTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/29/15.
//
//

#import <UIKit/UIKit.h>
#import <PubNub/PubNub.h>
#import <JSZVCR/JSZVCRTestCase.h>

@interface PNClientConfigurationTests : JSZVCRTestCase
@end

@implementation PNClientConfigurationTests

- (BOOL)isRecording {
    return NO;
}

- (void)testCreateClientWithBasicConfiguration {
    PNConfiguration *config = [PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
    XCTAssertNotNil(config);
    PubNub *client = [PubNub clientWithConfiguration:config];
    XCTAssertNotNil(client);
}

- (void)testCreateClientWithCallbackQueue {
    PNConfiguration *config = [PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
    XCTAssertNotNil(config);
    dispatch_queue_t callbackQueue = dispatch_queue_create("com.testCreateClientWithCallbackQueue", DISPATCH_QUEUE_SERIAL);
    PubNub *client = [PubNub clientWithConfiguration:config callbackQueue:callbackQueue];
    XCTAssertNotNil(client);
}

@end
