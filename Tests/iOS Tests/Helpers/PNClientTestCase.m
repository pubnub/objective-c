//
//  PNClientTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/20/16.
//
//

#import "PNClientTestCase.h"
#import "PNDeviceIndependentMatcher.h"

@interface PNClientTestCase ()
@property (nonatomic, strong, readwrite) PNConfiguration *configuration;
@property (nonatomic, strong, readwrite) PubNub *client;

@end

@implementation PNClientTestCase

- (void)setUp {
    [super setUp];
    [PNLog enabled:NO];
    self.configuration = [self clientConfiguration];
    self.client = [PubNub clientWithConfiguration:self.configuration];
}

- (void)tearDown {
    self.client = nil;
    [super tearDown];
}

- (BKRTestConfiguration *)testConfiguration {
    BKRTestConfiguration *defaultConfiguration = [super testConfiguration];
    defaultConfiguration.matcherClass = [PNDeviceIndependentMatcher class];
    defaultConfiguration.beginRecordingBlock = nil;
    defaultConfiguration.endRecordingBlock = nil;
    defaultConfiguration.shouldSaveEmptyCassette = YES;
    defaultConfiguration.tearDownExpectationTimeout = 60.0;
    defaultConfiguration.requestMatchingFailedBlock = ^void (NSURLRequest *request) {
        NSLog(@"Failed to match request: %@", request);
        XCTFail(@"Failed to match request: %@", request);
    };
    return defaultConfiguration;
}

- (PNConfiguration *)clientConfiguration {
    
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
    configuration.uuid = @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C";
    configuration.origin = @"pubsub.pubnub.com";
    return configuration;
}

- (void)waitFor:(NSTimeInterval)timeout {
    [self waitFor:timeout withHandler:nil];
}

- (void)waitFor:(NSTimeInterval)timeout withHandler:(XCWaitCompletionHandler)handler {
    NSParameterAssert(timeout);
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        if (handler) {
            handler(error);
        }
    }];
}

@end
