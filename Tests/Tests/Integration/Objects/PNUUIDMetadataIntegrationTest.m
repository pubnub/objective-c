/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import <PubNub/NSDateFormatter+PNCacheable.h>
#import <PubNub/PNHelpers.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNUUIDMetadataIntegrationTest : PNRecordableTestCase


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNUUIDMetadataIntegrationTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    [self completePubNubConfiguration:self.client];
    [self removeAllObjects];
}


#pragma mark - Tests :: Builder pattern-based set uuid metadata

- (void)testItShouldSetUUIDMetadataAndReceiveStatusWithExpectedOperationAndCategoryWhenOnlyUUIDIsSet {
    NSString *identifier = [self randomizedValuesWithValues:@[@"test-uuid"]].firstObject;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().setUUIDMetadata()
            .uuid(identifier)
            .includeFields(PNUUIDCustomField)
            .performWithCompletion(^(PNSetUUIDMetadataStatus *status) {
                PNUUIDMetadata *metadata = status.data.metadata;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(metadata);
                XCTAssertEqualObjects(metadata.externalId, [NSNull null]);
                XCTAssertEqualObjects(metadata.profileUrl, [NSNull null]);
                XCTAssertEqualObjects(metadata.custom, [NSNull null]);
                XCTAssertEqualObjects(metadata.email, [NSNull null]);
                XCTAssertEqualObjects(metadata.uuid, identifier);
                XCTAssertNotNil(metadata.updated);
                XCTAssertNotNil(metadata.eTag);
                XCTAssertNotEqual([metadata.debugDescription rangeOfString:@"uuid-metadata"].location, NSNotFound);
                XCTAssertEqual(status.operation, PNSetUUIDMetadataOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];

    [self removeUUIDsMetadata:@[identifier] usingClient:nil];
}

/**
 * @brief To test 'retry' functionality
 *  'ItShouldSetUUIDMetadataWhenAdditionalInformationIsSet.json' should
 *  be modified after cassette recording. Find first mention of UUID metadata set and copy paste 4 entries
 *  which belong to it. For new entries change 'id' field to be different from source. For original
 *  response entry change status code to 404.
 */
- (void)testItShouldSetUUIDMetadataWhenAdditionalInformationIsSet {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }

    NSString *externalId = [self randomizedValuesWithValues:@[@"test-external-identifier"]].firstObject;
    NSString *email = [self randomizedValuesWithValues:@[@"test-uuid-email"]].firstObject;
    NSString *identifier = [self randomizedValuesWithValues:@[@"test-uuid"]].firstObject;
    NSString *name = [self randomizedValuesWithValues:@[@"test-uuid-name"]].firstObject;
    NSString *profileUrl = @"https://pubnub.com";
    NSDictionary *custom = @{
        @"uuid-custom1": [@[name, @"custom", @"data", @"1"] componentsJoinedByString:@"-"],
        @"uuid-custom2": [@[name, @"custom", @"data", @"2"] componentsJoinedByString:@"-"]
    };
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().setUUIDMetadata()
            .uuid(identifier)
            .name(name)
            .externalId(externalId)
            .profileUrl(profileUrl)
            .email(email)
            .custom(custom)
            .includeFields(PNUUIDCustomField)
            .performWithCompletion(^(PNSetUUIDMetadataStatus *status) {
                if (!retried && !YHVVCR.cassette.isNewCassette) {
                    XCTAssertTrue(status.error);
                    XCTAssertEqual(status.operation, PNSetUUIDMetadataOperation);
                    XCTAssertEqual(status.category, PNMalformedResponseCategory);

                    retried = YES;
                    [status retry];
                } else {
                    PNUUIDMetadata *metadata = status.data.metadata;
                    XCTAssertFalse(status.isError);
                    XCTAssertNotNil(metadata);
                    XCTAssertEqualObjects(metadata.externalId, externalId);
                    XCTAssertEqualObjects(metadata.profileUrl, profileUrl);
                    XCTAssertEqualObjects(metadata.uuid, identifier);
                    XCTAssertEqualObjects(metadata.custom, custom);
                    XCTAssertEqualObjects(metadata.email, email);
                    XCTAssertEqualObjects(metadata.name, name);
                    XCTAssertNotNil(metadata.updated);
                    XCTAssertNotNil(metadata.eTag);
                    
                    handler();
                    }
            });
    }];

    [self removeUUIDsMetadata:@[identifier] usingClient:nil];
}


#pragma mark - Tests :: Builder pattern-based remove uuid metadata

/**
 * @brief To test 'retry' functionality
 *  'ItShouldRemoveUUIDMetadataAndReceiveStatusWithExpectedOperationAndCategory.json' should
 *  be modified after cassette recording. Find first mention of UUID metadata remove and copy paste 4 entries
 *  which belong to it. For new entries change 'id' field to be different from source. For original
 *  response entry change status code to 404.
 */
- (void)testItShouldRemoveUUIDMetadataAndReceiveStatusWithExpectedOperationAndCategory {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }

    NSArray<PNUUIDMetadata *> *uuids = [self setUUIDMetadata:2 usingClient:nil];
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().removeUUIDMetadata()
            .uuid(uuids.firstObject.uuid)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                if (!retried && !YHVVCR.cassette.isNewCassette) {
                    XCTAssertTrue(status.error);
                    XCTAssertEqual(status.operation, PNRemoveUUIDMetadataOperation);
                    XCTAssertEqual(status.category, PNMalformedResponseCategory);

                    retried = YES;
                    [status retry];
                } else {
                    XCTAssertFalse(status.error);
                    XCTAssertEqual(status.operation, PNRemoveUUIDMetadataOperation);
                    XCTAssertEqual(status.category, PNAcknowledgmentCategory);

                    [self removeCachedUUIDMetadata:uuids.firstObject.uuid];
                    
                    handler();
                }
            });
    }];


    [self verifyUUIDMetadataCountShouldEqualTo:(uuids.count - 1) usingClient:nil];

    [self removeAllUUIDMetadataUsingClient:nil];
}

- (void)testItShouldRemoveUUIDMetadataAndTriggerDeleteEventToUUIDChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNUUIDMetadata *> *uuids = [self setUUIDMetadata:2 usingClient:client1];
    NSString *channel = uuids.firstObject.uuid;
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {
                                  
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.type, @"uuid");
            XCTAssertEqualObjects(event.data.uuidMetadata.uuid, uuids.firstObject.uuid);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;

            handler();
        }];
        
        client1.objects().removeUUIDMetadata().uuid(uuids.firstObject.uuid)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertFalse(status.isError);

                [self removeCachedUUIDMetadata:uuids.firstObject.uuid];
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];


    [self verifyUUIDMetadataCountShouldEqualTo:(uuids.count - 1) usingClient:client1];

    [self removeAllUUIDMetadataUsingClient:client1];
}

/**
 * @brief To test event skip for older Objects version
 *  'ItShouldNotTriggerDeleteEventToUUIDChannelWhenSentFromPreviousObjectsVersion.json' should
 *  be modified after cassette recording. Find GET request for subscribe with longest Base64
 *  encoded body. Decode body, change objects version to "1.0" and encode string back to use as
 *  replacement for original.
 */
- (void)testItShouldNotTriggerDeleteEventToUUIDChannelWhenSentFromPreviousObjectsVersion {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNUUIDMetadata *> *uuids = [self setUUIDMetadata:2 usingClient:client1];
    NSString *channel = uuids.firstObject.uuid;
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {
                                  
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.type, @"uuid");
            XCTAssertEqualObjects(event.data.uuidMetadata.uuid, uuids.firstObject.uuid);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;

            handler();
        }];
        
        client1.objects().removeUUIDMetadata().uuid(uuids.firstObject.uuid)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertFalse(status.isError);

                [self removeCachedUUIDMetadata:uuids.firstObject.uuid];
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];


    [self verifyUUIDMetadataCountShouldEqualTo:(uuids.count - 1) usingClient:client1];

    [self removeAllUUIDMetadataUsingClient:client1];
}


#pragma mark - Tests :: Builder pattern-based fetch uuid metadata

- (void)testItShouldFetchUUIDMetadataAndReceiveResultWithExpectedOperation {
    NSArray<PNUUIDMetadata *> *uuids = [self setUUIDMetadata:1 usingClient:nil];
    NSDate *updateDate = uuids.firstObject.updated;
    NSString *eTag = uuids.firstObject.eTag;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().uuidMetadata()
            .uuid(uuids.firstObject.uuid)
            .includeFields(PNUUIDCustomField)
            .performWithCompletion(^(PNFetchUUIDMetadataResult *result, PNErrorStatus *status) {
                PNUUIDMetadata *metadata = result.data.metadata;
                XCTAssertNil(status);
                XCTAssertNotNil(metadata);
                XCTAssertEqualObjects(metadata.updated, updateDate);
                XCTAssertEqualObjects(metadata.eTag, eTag);
                XCTAssertEqual(result.operation, PNFetchUUIDMetadataOperation);
                
                handler();
            });
    }];

    [self removeAllUUIDMetadataUsingClient:nil];
}

- (void)testItShouldNotFetchUUIDMetadataWhenTargetUUIDDoesNotHaveMetadata {
    NSString *identifier = [self randomizedValuesWithValues:@[@"test-uuid"]].firstObject;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().uuidMetadata()
            .uuid(identifier)
            .includeFields(PNUUIDCustomField)
            .performWithCompletion(^(PNFetchUUIDMetadataResult *result, PNErrorStatus *status) {
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


#pragma mark - Tests :: Builder pattern-based fetch all uuids metadata

/**
 * @brief To test 'retry' functionality
 *  'ItShouldFetchAllUUIDMetadataAndReceiveResultWithExpectedOperation.json' should
 *  be modified after cassette recording. Find first mention of UUID metadata fetch and copy paste 4 entries
 *  which belong to it. For new entries change 'id' field to be different from source. For original
 *  response entry change status code to 404.
 */
- (void)testItShouldFetchAllUUIDMetadataAndReceiveResultWithExpectedOperation {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    NSArray<PNUUIDMetadata *> *uuids = [self setUUIDMetadata:6 usingClient:nil];
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().allUUIDMetadata()
            .includeCount(NO)
            .performWithCompletion(^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {
                if (!retried && !YHVVCR.cassette.isNewCassette) {
                    XCTAssertTrue(status.error);
                    XCTAssertEqual(status.operation, PNFetchAllUUIDMetadataOperation);
                    XCTAssertEqual(status.category, PNMalformedResponseCategory);
                    
                    retried = YES;
                    [status retry];
                } else {
                    XCTAssertNil(status);
                    XCTAssertEqual(result.data.metadata.count, uuids.count);
                    XCTAssertEqual(result.data.totalCount, 0);
                    XCTAssertEqual(result.operation, PNFetchAllUUIDMetadataOperation);
                    
                    handler();
                }
            });
    }];

    [self removeAllUUIDMetadataUsingClient:nil];
}

- (void)testItShouldFetchFilteredUUIDsMetadataWhenFilterIsSet {
    NSDateFormatter *formatter = [NSDateFormatter pn_formatterWithString:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSArray<PNUUIDMetadata *> *uuids = [self setUUIDMetadata:6 usingClient:nil];
    NSUInteger targetUUIDOffset = 3;
    NSDate *targetUUIDUpdateDate = uuids[targetUUIDOffset].updated;
    NSString *filterExpression = [NSString stringWithFormat:@"updated >= '%@'",
                                  [formatter stringFromDate:targetUUIDUpdateDate]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().allUUIDMetadata()
            .includeCount(YES)
            .filter(filterExpression)
            .performWithCompletion(^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {
                NSURLRequest *request = [result valueForKey:@"clientRequest"];
                XCTAssertNil(status);
                XCTAssertEqual(result.data.totalCount, uuids.count - targetUUIDOffset);
                XCTAssertEqual(result.data.metadata.count, result.data.totalCount);
                XCTAssertNil(result.data.prev);
                XCTAssertNotNil(result.data.next);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                  NSNotFound);
                
                handler();
            });
    }];

    [self removeAllUUIDMetadataUsingClient:nil];
}

- (void)testItShouldFetchSortedUUIDMetadataWhenSortIsSet {
    NSArray<PNUUIDMetadata *> *uuids = [self setUUIDMetadata:6 usingClient:nil];
    NSString *expectedSort = @"name%3Adesc,updated";
    NSArray<PNUUIDMetadata *> *expectedUUIDsOrder = [uuids sortedArrayUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:YES]
    ]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().allUUIDMetadata()
            .includeCount(YES)
            .sort(@[@"name:desc", @"updated"])
            .performWithCompletion(^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {
                NSArray<PNUUIDMetadata *> *fetchedUUIDs = result.data.metadata;
                NSURLRequest *request = [result valueForKey:@"clientRequest"];
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedUUIDs);
                XCTAssertNil(result.data.prev);
                XCTAssertNotNil(result.data.next);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);
                
                for (NSUInteger idx = 0; idx < fetchedUUIDs.count; idx++) {
                    XCTAssertEqualObjects(fetchedUUIDs[idx].uuid, expectedUUIDsOrder[idx].uuid);
                }
                
                handler();
            });
    }];

    [self removeAllUUIDMetadataUsingClient:nil];
}

- (void)testItShouldFetchAllUUIDMetadataWhenLimitItSet {
    NSArray<PNUUIDMetadata *> *uuids = [self setUUIDMetadata:6 usingClient:nil];
    NSUInteger expectedCount = 2;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().allUUIDMetadata()
            .limit(expectedCount)
            .includeFields(PNUUIDCustomField)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {
                NSArray<PNUUIDMetadata *> *fetchedUUIDs = result.data.metadata;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedUUIDs);
                XCTAssertEqual(fetchedUUIDs.count, expectedCount);
                XCTAssertEqual(result.data.totalCount, uuids.count);
                XCTAssertNotNil(fetchedUUIDs.firstObject.custom);
                
                handler();
            });
    }];

    [self removeAllUUIDMetadataUsingClient:nil];
}

- (void)testItShouldFetchNextUUIDMetadataPageWhenStartAndLimitIsSet {
    NSArray<PNUUIDMetadata *> *uuids = [self setUUIDMetadata:6 usingClient:nil];
    __block NSString *next = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().allUUIDMetadata()
            .limit(uuids.count - 2)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {
                NSArray<PNUUIDMetadata *> *fetchedUUIDs = result.data.metadata;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedUUIDs);
                XCTAssertEqual(fetchedUUIDs.count, uuids.count - 2);
                next = result.data.next;
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().allUUIDMetadata()
            .start(next)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {
                NSArray<PNUUIDMetadata *> *fetchedUUIDs = result.data.metadata;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedUUIDs);
                XCTAssertEqual(fetchedUUIDs.count, 2);
                
                handler();
            });
    }];

    [self removeAllUUIDMetadataUsingClient:nil];
}

#pragma mark -

#pragma clang diagnostic pop

@end
