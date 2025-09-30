/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import <PubNub/NSDateFormatter+PNCacheable.h>
#import <PubNub/PNBaseRequest+Private.h>
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
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    [self completePubNubConfiguration:self.client];
    [self removeAllObjects];
}


#pragma mark - Tests :: Set uuid metadata

- (void)testItShouldSetUUIDMetadataWithStatuTypeAndReceiveStatusWithExpectedOperationAndCategory {
    NSString *identifier = [self randomizedValuesWithValues:@[@"test-uuid"]].firstObject;


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNSetUUIDMetadataRequest *request = [PNSetUUIDMetadataRequest requestWithUUID:identifier];
        request.includeFields = PNUUIDStatusField | PNUUIDTypeField | PNUUIDCustomField;
        request.custom = @{ @"importand": @"data" };
        request.status = @"offline";
        request.type = @"admin";

        [self.client setUUIDMetadataWithRequest:request completion:^(PNSetUUIDMetadataStatus *status) {
            PNUUIDMetadata *metadata = status.data.metadata;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(metadata);
            XCTAssertNil(metadata.externalId);
            XCTAssertNil(metadata.profileUrl);
            XCTAssertNil(metadata.email);
            XCTAssertEqualObjects(metadata.custom, request.custom);
            XCTAssertEqualObjects(metadata.status, request.status);
            XCTAssertEqualObjects(metadata.type, request.type);
            XCTAssertEqualObjects(metadata.uuid, identifier);
            XCTAssertNotNil(metadata.updated);
            XCTAssertNotNil(metadata.eTag);
            XCTAssertEqual(status.operation, PNSetUUIDMetadataOperation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);

            handler();
        }];
    }];

    [self removeUUIDsMetadata:@[identifier] usingClient:nil];
}

- (void)testItShouldSetUUIDMetadataWithStatuTypeAndTriggerDeleteEventToChannel {
    NSString *uuid = [self randomizedValuesWithValues:@[@"test-uuid"]].firstObject;
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];


    [self subscribeClient:client2 toChannels:@[uuid] withPresence:NO];

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNSetUUIDMetadataRequest *request = [PNSetUUIDMetadataRequest requestWithUUID:uuid];
        request.includeFields = PNUUIDStatusField | PNUUIDTypeField | PNUUIDCustomField;
        request.custom = @{ @"importand": @"data" };
        request.status = @"offline";
        request.type = @"admin";

        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {

            XCTAssertEqualObjects(event.data.type, @"uuid");
            XCTAssertEqualObjects(event.data.event, @"set");
            XCTAssertEqualObjects(event.data.uuidMetadata.uuid, uuid);
            XCTAssertEqualObjects(event.data.uuidMetadata.custom, request.custom);
            XCTAssertEqualObjects(event.data.uuidMetadata.status, request.status);
            XCTAssertEqualObjects(event.data.uuidMetadata.type, request.type);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;

            handler();
        }];

        [client1 setUUIDMetadataWithRequest:request completion:^(PNSetUUIDMetadataStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];

    [self unsubscribeClient:client2 fromChannels:@[uuid] withPresence:NO];

    [self removeChannelsMetadataUsingClient:client1];
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
                XCTAssertNil(metadata.externalId);
                XCTAssertNil(metadata.profileUrl);
                XCTAssertNil(metadata.custom);
                XCTAssertNil(metadata.email);
                XCTAssertEqualObjects(metadata.uuid, identifier);
                XCTAssertNotNil(metadata.updated);
                XCTAssertNotNil(metadata.eTag);
                XCTAssertEqual(status.operation, PNSetUUIDMetadataOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];

    [self removeUUIDsMetadata:@[identifier] usingClient:nil];
}

- (void)testItShouldSetUUIDMetadataAndNotCrashWhenCompletionBlockIsNil {
    NSString *identifier = [self randomizedValuesWithValues:@[@"test-uuid"]].firstObject;
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
            self.client.objects().setUUIDMetadata()
                .uuid(identifier)
                .includeFields(PNUUIDCustomField)
                .performWithCompletion(nil);
#pragma clang diagnostic pop
        } @catch (NSException *exception) {
            handler();
        }
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
        __block __weak PNSetUUIDMetadataCompletionBlock weakBlock;
        __block PNSetUUIDMetadataCompletionBlock block;
        PNSetUUIDMetadataRequest *request = [PNSetUUIDMetadataRequest requestWithUUID:identifier];
        request.name = name;
        request.externalId = externalId;
        request.profileUrl = profileUrl;
        request.email = email;
        request.custom = custom;
        request.includeFields = PNUUIDCustomField;
        
        block = ^(PNSetUUIDMetadataStatus *status) {
            __strong PNSetUUIDMetadataCompletionBlock strongBlock = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            if (!retried && !YHVVCR.cassette.isNewCassette) {
                XCTAssertTrue(status.error);
                XCTAssertEqual(status.operation, PNSetUUIDMetadataOperation);
                XCTAssertEqual(status.category, PNMalformedResponseCategory);
                
                retried = YES;
                [self.client setUUIDMetadataWithRequest:request completion:strongBlock];
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
        };
        weakBlock = block;
        [self.client setUUIDMetadataWithRequest:request completion:block];
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
        PNRemoveUUIDMetadataRequest *request = [PNRemoveUUIDMetadataRequest requestWithUUID:uuids.firstObject.uuid];
        __block __weak PNRemoveUUIDMetadataCompletionBlock weakBlock;
        __block PNRemoveUUIDMetadataCompletionBlock block;
        
        block = ^(PNAcknowledgmentStatus *status) {
            __strong PNRemoveUUIDMetadataCompletionBlock strongBlock = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            if (!retried && !YHVVCR.cassette.isNewCassette) {
                XCTAssertTrue(status.error);
                XCTAssertEqual(status.operation, PNRemoveUUIDMetadataOperation);
                XCTAssertEqual(status.category, PNMalformedResponseCategory);
                
                retried = YES;
                [self.client removeUUIDMetadataWithRequest:request completion:strongBlock];
            } else {
                XCTAssertFalse(status.error);
                XCTAssertEqual(status.operation, PNRemoveUUIDMetadataOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                [self removeCachedUUIDMetadata:uuids.firstObject.uuid];
                
                handler();
            }
        };
        
        weakBlock = block;
        [self.client removeUUIDMetadataWithRequest:request completion:block];
    }];


    [self verifyUUIDMetadataCountShouldEqualTo:(uuids.count - 1) usingClient:nil];

    [self removeAllUUIDMetadataUsingClient:nil];
}

- (void)testItShouldRemoveUUIDMetadataAndNotCrashWhenCompletionBlockIsNil {
    NSArray<PNUUIDMetadata *> *uuids = [self setUUIDMetadata:2 usingClient:nil];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
            self.client.objects().removeUUIDMetadata()
                .uuid(uuids.firstObject.uuid)
                .performWithCompletion(nil);
#pragma clang diagnostic pop
        } @catch (NSException *exception) {
            handler();
        }
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
        PNFetchUUIDMetadataRequest *request = [PNFetchUUIDMetadataRequest requestWithUUID:identifier];
        request.includeFields = PNUUIDCustomField;
        __block __weak PNFetchUUIDMetadataCompletionBlock weakBlock;
        __block PNFetchUUIDMetadataCompletionBlock block;
        
        block = ^(PNFetchUUIDMetadataResult *result, PNErrorStatus *status) {
            __strong PNFetchUUIDMetadataCompletionBlock strongBlock = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            XCTAssertNil(result);
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.category, PNResourceNotFoundCategory);
            
            if (!retried) {
                retried = YES;
                [self.client uuidMetadataWithRequest:request completion:strongBlock];
            } else {
                handler();
            }
        };
        
        weakBlock = block;
        [self.client uuidMetadataWithRequest:request completion:block];
    }];
}


#pragma mark - Tests :: Builder pattern-based fetch all uuids metadata

/**
 * @brief To test 'retry' functionality
 *  'ItShouldFetchAllUUIDMetadataAndReceiveResultWithExpectedOperation.json' should
 *  be modified after cassette recording. Find first mention of UUID metadata fetch and copy paste 4 entries
 *  which belong to it. For new entries change 'id' field to be different from source. For original
 *  response entry change `Content-Type` code to `text/html`.
 */
- (void)testItShouldFetchAllUUIDMetadataAndReceiveResultWithExpectedOperation {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    NSArray<PNUUIDMetadata *> *uuids = [self setUUIDMetadata:6 usingClient:nil];
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNFetchAllUUIDMetadataRequest *request = [PNFetchAllUUIDMetadataRequest new];
        // Unset included fields.
        request.includeFields = 0;
        __block __weak PNFetchAllUUIDMetadataCompletionBlock weakBlock;
        __block PNFetchAllUUIDMetadataCompletionBlock block;
        
        block = ^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {
            __strong PNFetchAllUUIDMetadataCompletionBlock strongBlock = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            if (!retried && !YHVVCR.cassette.isNewCassette) {
                XCTAssertTrue(status.error);
                XCTAssertEqual(status.operation, PNFetchAllUUIDMetadataOperation);
                XCTAssertEqual(status.category, PNMalformedResponseCategory);
                
                retried = YES;
                [self.client allUUIDMetadataWithRequest:request completion:strongBlock];
            } else {
                XCTAssertNil(status);
                XCTAssertEqual(result.data.metadata.count, uuids.count);
                XCTAssertEqual(result.data.totalCount, 0);
                XCTAssertEqual(result.operation, PNFetchAllUUIDMetadataOperation);
                
                handler();
            }
        };
        
        weakBlock = block;
        [self.client allUUIDMetadataWithRequest:request completion:block];
    }];

    [self removeAllUUIDMetadataUsingClient:nil];
}

- (void)testItShouldFetchFilteredUUIDsMetadataWhenFilterIsSet {
    NSDateFormatter *formatter = [NSDateFormatter pn_formatterWithString:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSArray<PNUUIDMetadata *> *uuids = [self setUUIDMetadata:6 usingClient:nil];
    NSUInteger targetUUIDOffset = 3;
    NSDate *targetUUIDUpdateDate = uuids[targetUUIDOffset].updated;
    NSString *expectedFilterExpression = [NSString stringWithFormat:@"updated >= '%@'",
                                          [formatter stringFromDate:targetUUIDUpdateDate]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNFetchAllUUIDMetadataRequest *request = [PNFetchAllUUIDMetadataRequest new];
        request.includeFields |= PNUUIDTotalCountField;
        request.filter = expectedFilterExpression;
        
        [self.client allUUIDMetadataWithRequest:request completion:^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {
            XCTAssertNil(status);
            XCTAssertEqual(result.data.totalCount, uuids.count - targetUUIDOffset);
            XCTAssertEqual(result.data.metadata.count, result.data.totalCount);
            XCTAssertNil(result.data.prev);
            XCTAssertNotNil(result.data.next);
            XCTAssertEqualObjects(request.request.query[@"filter"], expectedFilterExpression);
            
            handler();
        }];
    }];

    [self removeAllUUIDMetadataUsingClient:nil];
}

- (void)testItShouldFetchSortedUUIDMetadataWhenSortIsSet {
    NSArray<PNUUIDMetadata *> *uuids = [self setUUIDMetadata:6 usingClient:nil];
    NSString *expectedSort = @"name:desc,updated";
    NSArray<PNUUIDMetadata *> *expectedUUIDsOrder = [uuids sortedArrayUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:YES]
    ]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNFetchAllUUIDMetadataRequest *request = [PNFetchAllUUIDMetadataRequest new];
        request.includeFields |= PNUUIDTotalCountField;
        request.sort = @[@"name:desc", @"updated"];
        
        [self.client allUUIDMetadataWithRequest:request completion:^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {
            NSArray<PNUUIDMetadata *> *fetchedUUIDs = result.data.metadata;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedUUIDs);
            XCTAssertNil(result.data.prev);
            XCTAssertNotNil(result.data.next);
            XCTAssertEqualObjects(request.request.query[@"sort"], expectedSort);
            
            for (NSUInteger idx = 0; idx < fetchedUUIDs.count; idx++) {
                XCTAssertEqualObjects(fetchedUUIDs[idx].uuid, expectedUUIDsOrder[idx].uuid);
            }
            
            handler();
        }];
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
