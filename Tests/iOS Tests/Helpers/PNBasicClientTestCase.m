//
//  PNBasicClientTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//
#import <BeKindRewind/BKRTestCaseFilePathHelper.h>
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PubNub.h>

#import "PNDeviceIndependentMatcher.h"
#import "PNBasicClientTestCase.h"

@implementation PNBasicClientTestCase

- (void)setUp {
    [super setUp];
    
    self.configuration = [PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
    self.configuration.uuid = @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C";
    self.configuration.origin = @"ps.pndsn.com";
    self.configuration = [self overrideClientConfiguration:self.configuration];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.configuration.stripMobilePayload = NO;
#pragma clang diagnostic pop
    self.client = [PubNub clientWithConfiguration:self.configuration];
    self.client.logger.enabled = NO;
    [self.client.logger setLogLevel:PNVerboseLogLevel];
}

- (void)tearDown {
    
    [self.client.sequenceManager reset];
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
    return defaultConfiguration;
}

//- (NSString *)baseFixturesDirectoryFilePath {
////    return [super baseFixturesDirectoryFilePath];
//    return [BKRTestCaseFilePathHelper fixtureWriteDirectoryInProject];
//}


#pragma mark - Configuration override

- (PNConfiguration *)overrideClientConfiguration:(PNConfiguration *)configuration {
    
    return configuration;
}

#pragma mark - Publish Helpers

- (void)PNTest_publish:(id)message toChannel:(NSString *)channel withMetadata:(NSDictionary *)metadata withCompletion:(PNPublishCompletionBlock)block {
    self.publishExpectation = [self expectationWithDescription:@"publish"];
    [self.client publish:message toChannel:channel withMetadata:metadata completion:^(PNPublishStatus *status) {
        if (block) {
            block(status);
        }
        [self.publishExpectation fulfill];
    }];
}

#pragma mark - Channel Group Helpers

- (void)performVerifiedAddChannels:(NSArray *)channels toGroup:(NSString *)channelGroup withAssertions:(PNChannelGroupAssertions)assertions {
    XCTestExpectation *addChannelsToGroupExpectation = [self expectationWithDescription:@"addChannels"];
    [self.client addChannels:channels toGroup:channelGroup
              withCompletion:^(PNAcknowledgmentStatus *status) {
                  if (assertions) {
                      assertions(status);
                  }
                  [addChannelsToGroupExpectation fulfill];
              }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)performVerifiedRemoveAllChannelsFromGroup:(NSString *)channelGroup withAssertions:(PNChannelGroupAssertions)assertions {
    XCTestExpectation *removeChannels = [self expectationWithDescription:@"removeChannels"];
    [self.client removeChannelsFromGroup:channelGroup withCompletion:^(PNAcknowledgmentStatus *status) {
        if (assertions) {
            assertions(status);
        }
        [removeChannels fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)performVerifiedRemoveChannels:(NSArray *)channels fromGroup:(NSString *)channelGroup withAssertions:(PNChannelGroupAssertions)assertions {
    XCTestExpectation *removeSpecificChannels = [self expectationWithDescription:@"removeSpecificChannels"];
    [self.client removeChannels:channels fromGroup:channelGroup withCompletion:^(PNAcknowledgmentStatus *status) {
        if (assertions) {
            assertions(status);
        }
        [removeSpecificChannels fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end
