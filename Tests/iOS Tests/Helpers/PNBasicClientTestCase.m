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


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNBasicClientTestCase ()

/**
 * @brief Content of \c 'Resources/keysset.plist' which is used with this test.
 *
 * @return \a NSDictionary with 'pam' and 'regula' set of 'publish'/'subscribe' keys.
 *
 * @since 4.8.8
 */
+ (NSDictionary *)testKeysSet;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


@implementation PNBasicClientTestCase


#pragma mark - Information

+ (NSDictionary *)testKeysSet {
  
  static NSDictionary *_testKeysSet;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    NSBundle *testBundle = [NSBundle bundleForClass:self];
    NSString *keysPath = [testBundle pathForResource:@"keysset" ofType:@"plist"];
    _testKeysSet = [NSDictionary dictionaryWithContentsOfFile:keysPath];
  });
  
  return _testKeysSet;
}

- (NSString *)pamSubscribeKey {
  
  return [[[self class] testKeysSet] valueForKeyPath:@"pam.subscribe"];
}

- (NSString *)pamPublishKey {
  
  return [[[self class] testKeysSet] valueForKeyPath:@"pam.publish"];
}

- (NSString *)subscribeKey {
  
  return [[[self class] testKeysSet] valueForKeyPath:@"regular.subscribe"];
}

- (NSString *)publishKey {
  
  return [[[self class] testKeysSet] valueForKeyPath:@"regular.publish"];
}

- (void)setUp {
    [super setUp];
  
    dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.configuration = [PNConfiguration configurationWithPublishKey:self.publishKey
                                                         subscribeKey:self.subscribeKey];
    self.configuration.uuid = @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C";
    self.configuration.origin = @"ps.pndsn.com";
    self.configuration = [self overrideClientConfiguration:self.configuration];
    self.client = [PubNub clientWithConfiguration:self.configuration callbackQueue:callbackQueue];
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
