/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import <PubNub/NSDateFormatter+PNCacheable.h>
#import <PubNub/PNHelpers.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNChannelMetadataIntegrationTest : PNRecordableTestCase


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNChannelMetadataIntegrationTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    [self completePubNubConfiguration:self.client];
    [self removeAllObjects];
}


#pragma mark - Tests :: Builder pattern-based set channel metadata

- (void)testItShouldSetChannelMetadataAndReceiveStatusWithExpectedOperationAndCategoryWhenOnlyChannelIsSet {
    NSString *identifier = [self randomizedValuesWithValues:@[@"test-channel"]].firstObject;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().setChannelMetadata(identifier)
            .performWithCompletion(^(PNSetChannelMetadataStatus *status) {
                PNChannelMetadata *metadata = status.data.metadata;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(metadata);
                XCTAssertNil(metadata.custom);
                XCTAssertEqualObjects(metadata.channel, identifier);
                XCTAssertNotNil(metadata.updated);
                XCTAssertNotNil(metadata.eTag);
                XCTAssertEqual(status.operation, PNSetChannelMetadataOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];

    [self removeChannelsMetadata:@[identifier] usingClient:nil];
}

- (void)testItShouldSetChannelMetadataAndNotCrashWhenCompletionBlockIsNil {
    NSString *identifier = [self randomizedValuesWithValues:@[@"test-channel"]].firstObject;
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
            self.client.objects().setChannelMetadata(identifier)
                .performWithCompletion(nil);
#pragma clang diagnostic pop
        } @catch (NSException *exception) {
            handler();
        }
    }];
    
    [self removeChannelsMetadata:@[identifier] usingClient:nil];
}

/**
 * @brief To test 'retry' functionality
 *  'ItShouldSetChannelMetadataWhenAdditionalInformationIsSet.json' should
 *  be modified after cassette recording. Find first mention of channel metadata set and copy paste 4 entries
 *  which belong to it. For new entries change 'id' field to be different from source. For original
 *  response entry change `Content-Type` to `text/html`.
 */
- (void)testItShouldSetChannelMetadataWhenAdditionalInformationIsSet {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    NSString *information = [self randomizedValuesWithValues:@[@"test-channel-information"]].firstObject;
    NSString *identifier = [self randomizedValuesWithValues:@[@"test-channel"]].firstObject;
    NSString *name = [self randomizedValuesWithValues:@[@"test-channel-name"]].firstObject;
    NSDictionary *custom = @{
        @"channel-custom1": [@[name, @"custom", @"data", @"1"] componentsJoinedByString:@"-"],
        @"channel-custom2": [@[name, @"custom", @"data", @"2"] componentsJoinedByString:@"-"]
    };
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().setChannelMetadata(identifier)
            .name(name)
            .information(information)
            .custom(custom)
            .performWithCompletion(^(PNSetChannelMetadataStatus *status) {
                if (!retried && !YHVVCR.cassette.isNewCassette) {
                    XCTAssertTrue(status.error);
                    XCTAssertEqual(status.operation, PNSetChannelMetadataOperation);
                    XCTAssertEqual(status.category, PNMalformedResponseCategory);

                    retried = YES;
                    [status retry];
                } else {
                    PNChannelMetadata *metadata = status.data.metadata;
                    XCTAssertFalse(status.isError);
                    XCTAssertNotNil(metadata);
                    XCTAssertEqualObjects(metadata.custom, custom);
                    XCTAssertEqualObjects(metadata.information, information);
                    
                    handler();
                }
            });
    }];

    [self removeChannelsMetadata:@[identifier] usingClient:nil];
}


#pragma mark - Tests :: Builder pattern-based remove channel metadata

/**
 * @brief To test 'retry' functionality
 *  'ItShouldRemoveChannelMetadataAndReceiveStatusWithExpectedOperationAndCategory.json' should
 *  be modified after cassette recording. Find first mention of channel metadata remove and copy paste 4 entries
 *  which belong to it. For new entries change 'id' field to be different from source. For original
 *  response entry change `Content-Type` to `text/html`.
 */
- (void)testItShouldRemoveChannelMetadataAndReceiveStatusWithExpectedOperationAndCategory {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    NSArray<PNChannelMetadata *> *channels = [self setChannelsMetadata:2 usingClient:nil];
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().removeChannelMetadata(channels.firstObject.channel)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                if (!retried && !YHVVCR.cassette.isNewCassette) {
                    XCTAssertTrue(status.error);
                    XCTAssertEqual(status.operation, PNRemoveChannelMetadataOperation);
                    XCTAssertEqual(status.category, PNMalformedResponseCategory);

                    retried = YES;
                    [status retry];
                } else {
                    XCTAssertFalse(status.error);
                    XCTAssertEqual(status.operation, PNRemoveChannelMetadataOperation);
                    XCTAssertEqual(status.category, PNAcknowledgmentCategory);

                    [self removeCachedChannelsMetadata:channels.firstObject.channel];
                    
                    handler();
                }
            });
    }];


    [self verifyChannelsMetadataCountShouldEqualTo:(channels.count - 1) usingClient:nil];

    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveChannelMetadataAndNotCrashWhenCompletionBlockIsNil {
    NSArray<PNChannelMetadata *> *channels = [self setChannelsMetadata:2 usingClient:nil];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
            self.client.objects().removeChannelMetadata(channels.firstObject.channel)
                .performWithCompletion(nil);
#pragma clang diagnostic pop
        } @catch (NSException *exception) {
            handler();
        }
    }];
    
    
    [self verifyChannelsMetadataCountShouldEqualTo:(channels.count - 1) usingClient:nil];

    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveChannelsMetadataAndTriggerDeleteEventToChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channels = [self setChannelsMetadata:2 usingClient:client1];
    NSString *channel = channels.firstObject.channel;
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {
                                  
            XCTAssertEqualObjects(event.data.type, @"channel");
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.channelMetadata.channel, channels.firstObject.channel);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;

            handler();
        }];
        
        client1.objects().removeChannelMetadata(channels.firstObject.channel)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertFalse(status.isError);

                [self removeCachedChannelsMetadata:channels.firstObject.channel];
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];


    [self verifyChannelsMetadataCountShouldEqualTo:(channels.count - 1) usingClient:client1];

    [self removeChannelsMetadataUsingClient:client1];
}


#pragma mark - Tests :: Builder pattern-based fetch channel metadata

- (void)testItShouldFetchChannelMetadataAndReceiveResultWithExpectedOperation {
    NSArray<PNChannelMetadata *> *channels = [self setChannelsMetadata:1 usingClient:nil];
    NSDate *updateDate = channels.firstObject.updated;
    NSString *eTag = channels.firstObject.eTag;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().channelMetadata(channels.firstObject.channel)
            .includeFields(PNChannelCustomField)
            .performWithCompletion(^(PNFetchChannelMetadataResult *result, PNErrorStatus *status) {
                PNChannelMetadata *channel = result.data.metadata;
                XCTAssertNil(status);
                XCTAssertNotNil(channel);
                XCTAssertEqualObjects(channel.updated, updateDate);
                XCTAssertEqualObjects(channel.eTag, eTag);
                XCTAssertEqual(result.operation, PNFetchChannelMetadataOperation);
                
                handler();
            });
    }];

    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldNotFetchChannelMetadataWhenTargetChannelDoesNotHaveMetadata {
    NSString *identifier = [self randomizedValuesWithValues:@[@"test-channel"]].firstObject;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().channelMetadata(identifier)
            .includeFields(PNChannelCustomField)
            .performWithCompletion(^(PNFetchChannelMetadataResult *result, PNErrorStatus *status) {
                XCTAssertNil(result);
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 404);
                
                if (!retried) {
                    retried = YES;
                    [status retry];
                } else {
                    handler();
                }
            });
    }];
}


#pragma mark - Tests :: Builder pattern-based fetch all channels metadata

/**
 * @brief To test 'retry' functionality
 *  'ItShouldFetchAllChannelsMetadataAndReceiveResultWithExpectedOperation.json' should
 *  be modified after cassette recording. Find first mention of channels metadata fetch and copy paste 4 entries
 *  which belong to it. For new entries change 'id' field to be different from source. For original
 *  response entry change `Content-Type` to `text/html`.
 */
- (void)testItShouldFetchAllChannelsMetadataAndReceiveResultWithExpectedOperation {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    NSArray<PNChannelMetadata *> *channels = [self setChannelsMetadata:6 usingClient:nil];
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().allChannelsMetadata()
            .includeCount(NO)
            .performWithCompletion(^(PNFetchAllChannelsMetadataResult *result, PNErrorStatus *status) {
            if (!retried && !YHVVCR.cassette.isNewCassette) {
                XCTAssertTrue(status.error);
                XCTAssertEqual(status.operation, PNFetchAllChannelsMetadataOperation);
                XCTAssertEqual(status.category, PNMalformedResponseCategory);

                retried = YES;
                [status retry];
            } else {
                XCTAssertNil(status);
                XCTAssertEqual(result.data.metadata.count, channels.count);
                XCTAssertEqual(result.data.totalCount, 0);
                XCTAssertEqual(result.operation, PNFetchAllChannelsMetadataOperation);
                
                handler();
            }
        });
    }];

    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldFetchFilteredChannelsMetadataWhenFilterIsSet {
    NSDateFormatter *formatter = [NSDateFormatter pn_formatterWithString:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSArray<PNChannelMetadata *> *channels = [self setChannelsMetadata:6 usingClient:nil];
    NSUInteger targetChannelOffset = 3;
    NSDate *targetChannelMetadataUpdateDate = channels[targetChannelOffset].updated;
    NSString *filterExpression = [NSString stringWithFormat:@"updated >= '%@'",
                                  [formatter stringFromDate:targetChannelMetadataUpdateDate]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().allChannelsMetadata()
            .includeCount(YES)
            .filter(filterExpression)
            .performWithCompletion(^(PNFetchAllChannelsMetadataResult *result, PNErrorStatus *status) {
                NSURLRequest *request = [result valueForKey:@"clientRequest"];
                XCTAssertNil(status);
                XCTAssertEqual(result.data.totalCount, channels.count - targetChannelOffset);
                XCTAssertEqual(result.data.metadata.count, result.data.totalCount);
                XCTAssertNil(result.data.prev);
                XCTAssertNotNil(result.data.next);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                  NSNotFound);
                
                handler();
        });
    }];

    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldFetchSortedChannelsMetadataWhenSortIsSet {
    NSArray<PNChannelMetadata *> *channels = [self setChannelsMetadata:6 usingClient:nil];
    NSString *expectedSort = @"name%3Adesc%2Cupdated";
    NSArray<PNChannelMetadata *> *expectedChannelsOrder = [channels sortedArrayUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:YES]
    ]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().allChannelsMetadata()
            .includeCount(YES)
            .sort(@[@"name:desc", @"updated"])
            .performWithCompletion(^(PNFetchAllChannelsMetadataResult *result, PNErrorStatus *status) {
                NSURLRequest *request = [result valueForKey:@"clientRequest"];
                XCTAssertNil(status);
                XCTAssertNil(result.data.prev);
                XCTAssertNotNil(result.data.next);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);
                
                for (NSUInteger idx = 0; idx < result.data.metadata.count; idx++) {
                    XCTAssertEqualObjects(result.data.metadata[idx].channel,
                                          expectedChannelsOrder[idx].channel);
                }
                
                handler();
        });
    }];

    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldFetchAllChannelsMetadataWhenLimitItSet {
    NSArray<PNChannelMetadata *> *channels = [self setChannelsMetadata:6 usingClient:nil];
    NSUInteger expectedCount = 2;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().allChannelsMetadata()
            .limit(expectedCount)
            .includeFields(PNChannelCustomField)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchAllChannelsMetadataResult *result, PNErrorStatus *status) {
                NSArray<PNChannelMetadata *> *fetchedChannels = result.data.metadata;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedChannels);
                XCTAssertEqual(fetchedChannels.count, expectedCount);
                XCTAssertEqual(result.data.totalCount, channels.count);
                XCTAssertNotNil(fetchedChannels.firstObject.custom);
                
                handler();
            });
    }];

    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldFetchNextChannelsMetadataPageWhenStartAndLimitIsSet {
    NSArray<PNChannelMetadata *> *channels = [self setChannelsMetadata:6 usingClient:nil];
    __block NSString *next = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().allChannelsMetadata()
            .limit(channels.count - 2)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchAllChannelsMetadataResult *result, PNErrorStatus *status) {
                NSArray<PNChannelMetadata *> *fetchedChannels = result.data.metadata;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedChannels);
                XCTAssertEqual(fetchedChannels.count, channels.count - 2);
                next = result.data.next;
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().allChannelsMetadata()
            .start(next)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchAllChannelsMetadataResult *result, PNErrorStatus *status) {
                NSArray<PNChannelMetadata *> *fetchedChannels = result.data.metadata;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedChannels);
                XCTAssertEqual(fetchedChannels.count, 2);
                
                handler();
            });
    }];

    [self removeChannelsMetadataUsingClient:nil];
}

#pragma mark -

#pragma clang diagnostic pop

@end
