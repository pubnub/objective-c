/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import <PubNub/NSDateFormatter+PNCacheable.h>
#import <PubNub/PNHelpers.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNSpaceIntegrationTest : PNRecordableTestCase


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNSpaceIntegrationTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    [self completePubNubConfiguration:self.client];
    [self removeAllObjects];
}


#pragma mark - Tests :: Builder pattern-based create space

- (void)testItShouldCreateSpaceAndReceiveStatusWithExpectedOperationAndCategoryWhenOnlySpaceAndIdentifierIsSet {
    NSString *identifier = [self randomizedValuesWithValues:@[@"test-space"]].firstObject;
    NSString *name = [self randomizedValuesWithValues:@[@"test-space-name"]].firstObject;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.createSpace()
            .spaceId(identifier)
            .name(name)
            .includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNCreateSpaceStatus *status) {
                PNSpace *space = status.data.space;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(space);
                XCTAssertEqualObjects(space.custom, [NSNull null]);
                XCTAssertEqualObjects(space.identifier, identifier);
                XCTAssertEqualObjects(space.name, name);
                XCTAssertNotNil(space.created);
                XCTAssertNotNil(space.updated);
                XCTAssertNotNil(space.eTag);
                XCTAssertEqual(status.operation, PNCreateSpaceOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];
    
    [self deleteSpaces:@[identifier] usingClient:nil];
}

- (void)testItShouldCreateSpaceWhenAdditionalInformationIsSet {
    NSString *information = [self randomizedValuesWithValues:@[@"test-space-information"]].firstObject;
    NSString *identifier = [self randomizedValuesWithValues:@[@"test-space"]].firstObject;
    NSString *name = [self randomizedValuesWithValues:@[@"test-space-name"]].firstObject;
    NSDictionary *custom = @{
        @"space-custom1": [@[name, @"custom", @"data", @"1"] componentsJoinedByString:@"-"],
        @"space-custom2": [@[name, @"custom", @"data", @"2"] componentsJoinedByString:@"-"]
    };
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.createSpace()
            .spaceId(identifier)
            .name(name)
            .information(information)
            .custom(custom)
            .includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNCreateSpaceStatus *status) {
                PNSpace *space = status.data.space;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(space);
                XCTAssertEqualObjects(space.custom, custom);
                XCTAssertEqualObjects(space.information, information);
                
                handler();
            });
    }];
    
    [self deleteSpaces:@[identifier] usingClient:nil];
}

- (void)testItShouldNotCreateSpaceWhenSameSpaceAlreadyExists {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.createSpace()
            .spaceId(spaces.firstObject.identifier)
            .name(spaces.firstObject.name)
            .performWithCompletion(^(PNCreateSpaceStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 409);
                XCTAssertNil(status.data.space);
                
                if (!retried) {
                    retried = YES;
                    [status retry];
                } else {
                    handler();
                }
            });
    }];
    
    [self deleteSpaceObjectsUsingClient:nil];
}


#pragma mark - Tests :: Builder pattern-based update space

- (void)testItShouldUpdateSpaceAndReceiveStatusWithExpectedOperationAndCategory {
    NSString *name = [self randomizedValuesWithValues:@[@"test-space-name"]].firstObject;
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSDate *createDate = spaces.firstObject.created;
    NSDate *updateDate = spaces.firstObject.updated;
    NSString *eTag = spaces.firstObject.eTag;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.updateSpace()
            .spaceId(spaces.firstObject.identifier)
            .name(name)
            .includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNUpdateSpaceStatus *status) {
                PNSpace *space = status.data.space;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(space);
                XCTAssertNotEqualObjects(space.updated, updateDate);
                XCTAssertEqualObjects(space.created, createDate);
                XCTAssertEqualObjects(space.name, name);
                XCTAssertNotEqualObjects(space.eTag, eTag);
                XCTAssertEqual(status.operation, PNUpdateSpaceOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];
    
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldUpdateSpaceAndTriggerUpdateEventToSpaceChannel {
    NSString *name = [self randomizedValuesWithValues:@[@"test-space-name"]].firstObject;
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:client1];
    NSString *channel = spaces.firstObject.identifier;
    NSDictionary *custom = @{
        @"space-custom1": [@[name, @"custom", @"data", @"1"] componentsJoinedByString:@"-"],
        @"space-custom2": [@[name, @"custom", @"data", @"2"] componentsJoinedByString:@"-"]
    };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addSpaceHandlerForClient:client2
                             withBlock:^(PubNub *client, PNSpaceEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"update");
            XCTAssertEqualObjects(event.data.name, name);
            XCTAssertEqualObjects(event.data.custom, custom);
            XCTAssertNotNil(event.data.updated);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;

            handler();
        }];
        
        client1.updateSpace()
            .spaceId(spaces.firstObject.identifier)
            .name(name)
            .custom(custom)
            .includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNUpdateSpaceStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
    
    [self deleteSpaceObjectsUsingClient:client1];
}

- (void)testItShouldNotUpdateSpaceWhenTargetSpaceNotExists {
    NSString *identifier = [self randomizedValuesWithValues:@[@"test-space"]].firstObject;
    NSString *name = [self randomizedValuesWithValues:@[@"test-space-name"]].firstObject;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.updateSpace()
            .spaceId(identifier)
            .name(name)
            .performWithCompletion(^(PNUpdateSpaceStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 404);
                XCTAssertNil(status.data.space);
                
                if (!retried) {
                    retried = YES;
                    [status retry];
                } else {
                    handler();
                }
            });
    }];
}


#pragma mark - Tests :: Builder pattern-based delete space

/**
 * @brief To test 'retry' functionality
 *  'ItShouldDeleteSpaceAndReceiveStatusWithExpectedOperationAndCategory.json' should
 *  be modified after cassette recording. Find first mention of space remove and copy paste 4 entries
 *  which belong to it. For new entries change 'id' field to be different from source. For original
 *  response entry change status code to 404.
 */
- (void)testItShouldDeleteSpaceAndReceiveStatusWithExpectedOperationAndCategory {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:nil];
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client
            .deleteSpace()
            .spaceId(spaces.firstObject.identifier)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                if (!retried && !YHVVCR.cassette.isNewCassette) {
                    XCTAssertTrue(status.error);
                    XCTAssertEqual(status.operation, PNDeleteSpaceOperation);
                    XCTAssertEqual(status.category, PNMalformedResponseCategory);

                    retried = YES;
                    [status retry];
                } else {
                    XCTAssertFalse(status.error);
                    XCTAssertEqual(status.operation, PNDeleteSpaceOperation);
                    XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                    
                    [self deleteCachedSpace:spaces.firstObject.identifier];
                    
                    handler();
                }
            });
    }];
    
    
    [self verifySpacesCountShouldEqualTo:(spaces.count - 1) usingClient:nil];
    
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldDeleteSpaceAndTriggerDeleteEventToSpaceChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:client1];
    NSString *channel = spaces.firstObject.identifier;
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addSpaceHandlerForClient:client2
                             withBlock:^(PubNub *client, PNSpaceEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.identifier, spaces.firstObject.identifier);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;

            handler();
        }];
        
        client1.deleteSpace()
            .spaceId(spaces.firstObject.identifier)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertFalse(status.isError);
                
                [self deleteCachedSpace:spaces.firstObject.identifier];
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
    
    
    [self verifySpacesCountShouldEqualTo:(spaces.count - 1) usingClient:client1];
    
    [self deleteSpaceObjectsUsingClient:client1];
}


#pragma mark - Tests :: Builder pattern-based fetch space

- (void)testItShouldFetchSpaceAndReceiveResultWithExpectedOperation {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSDate *createDate = spaces.firstObject.created;
    NSDate *updateDate = spaces.firstObject.updated;
    NSString *eTag = spaces.firstObject.eTag;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchSpace()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNFetchSpaceResult *result, PNErrorStatus *status) {
                PNSpace *space = result.data.space;
                XCTAssertNil(status);
                XCTAssertNotNil(space);
                XCTAssertEqualObjects(space.created, createDate);
                XCTAssertEqualObjects(space.updated, updateDate);
                XCTAssertEqualObjects(space.eTag, eTag);
                XCTAssertEqual(result.operation, PNFetchSpaceOperation);
                
                handler();
            });
    }];
    
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldNotFetchSpaceWhenTargetSpaceNotExists {
    NSString *identifier = [self randomizedValuesWithValues:@[@"test-space"]].firstObject;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchSpace()
            .spaceId(identifier)
            .includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNFetchSpaceResult *result, PNErrorStatus *status) {
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


#pragma mark - Tests :: Builder pattern-based fetch all spaces

/**
 * @brief To test 'retry' functionality
 *  'ItShouldFetchAllSpacesAndReceiveResultWithExpectedOperation.json' should
 *  be modified after cassette recording. Find first mention of spaces fetch and copy paste 4 entries
 *  which belong to it. For new entries change 'id' field to be different from source. For original
 *  response entry change status code to 404.
 */
- (void)testItShouldFetchAllSpacesAndReceiveResultWithExpectedOperation {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:6 usingClient:nil];
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchSpaces().performWithCompletion(^(PNFetchSpacesResult *result, PNErrorStatus *status) {
            if (!retried && !YHVVCR.cassette.isNewCassette) {
                XCTAssertTrue(status.error);
                XCTAssertEqual(status.operation, PNFetchSpacesOperation);
                XCTAssertEqual(status.category, PNMalformedResponseCategory);

                retried = YES;
                [status retry];
            } else {
                XCTAssertNil(status);
                XCTAssertEqual(result.data.spaces.count, spaces.count);
                XCTAssertEqual(result.data.totalCount, 0);
                XCTAssertEqual(result.operation, PNFetchSpacesOperation);
                
                handler();
            }
        });
    }];
    
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldFetchFilteredSpacesWhenFilterIsSet {
    NSDateFormatter *formatter = [NSDateFormatter pn_formatterWithString:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:6 usingClient:nil];
    NSUInteger targetSpaceOffset = 3;
    NSDate *targetSpaceUpdateDate = spaces[targetSpaceOffset].updated;
    NSString *filterExpression = [NSString stringWithFormat:@"updated >= '%@'",
                                  [formatter stringFromDate:targetSpaceUpdateDate]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchSpaces()
            .includeCount(YES)
            .filter(filterExpression)
            .performWithCompletion(^(PNFetchSpacesResult *result, PNErrorStatus *status) {
                NSURLRequest *request = [result valueForKey:@"clientRequest"];
                XCTAssertNil(status);
                XCTAssertEqual(result.data.totalCount, spaces.count - targetSpaceOffset);
                XCTAssertEqual(result.data.spaces.count, result.data.totalCount);
                XCTAssertNil(result.data.prev);
                XCTAssertNotNil(result.data.next);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                  NSNotFound);
                
                handler();
        });
    }];
    
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldFetchSortedSpacesWhenSortIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:6 usingClient:nil];
    NSString *expectedSort = @"name%3Adesc,created";
    NSArray<PNSpace *> *expectedSpacesOrder = [spaces sortedArrayUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]
    ]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchSpaces()
            .includeCount(YES)
            .sort(@[@"name:desc", @"created"])
            .performWithCompletion(^(PNFetchSpacesResult *result, PNErrorStatus *status) {
                NSURLRequest *request = [result valueForKey:@"clientRequest"];
                XCTAssertNil(status);
                XCTAssertNil(result.data.prev);
                XCTAssertNotNil(result.data.next);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);
                
                for (NSUInteger fetchedSpaceIdx = 0; fetchedSpaceIdx < result.data.spaces.count; fetchedSpaceIdx++) {
                    XCTAssertEqualObjects(result.data.spaces[fetchedSpaceIdx].identifier,
                                          expectedSpacesOrder[fetchedSpaceIdx].identifier);
                }
                
                handler();
        });
    }];
    
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldFetchAllSpacesWhenLimitItSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:6 usingClient:nil];
    NSUInteger expectedCount = 2;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchSpaces()
            .limit(expectedCount)
            .includeFields(PNSpaceCustomField)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchSpacesResult *result, PNErrorStatus *status) {
                NSArray<PNSpace *> *fetchedSpaces = result.data.spaces;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedSpaces);
                XCTAssertEqual(fetchedSpaces.count, expectedCount);
                XCTAssertEqual(result.data.totalCount, spaces.count);
                XCTAssertNotNil(fetchedSpaces.firstObject.custom);
                
                handler();
            });
    }];
    
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldFetchNextSpacesPageWhenStartAndLimitIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:6 usingClient:nil];
    __block NSString *next = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchSpaces()
            .limit(spaces.count - 2)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchSpacesResult *result, PNErrorStatus *status) {
                NSArray<PNSpace *> *fetchedSpaces = result.data.spaces;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedSpaces);
                XCTAssertEqual(fetchedSpaces.count, spaces.count - 2);
                next = result.data.next;
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchSpaces()
            .start(next)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchSpacesResult *result, PNErrorStatus *status) {
                NSArray<PNSpace *> *fetchedSpaces = result.data.spaces;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedSpaces);
                XCTAssertEqual(fetchedSpaces.count, 2);
                
                handler();
            });
    }];
    
    [self deleteSpaceObjectsUsingClient:nil];
}

#pragma mark -

#pragma clang diagnostic pop

@end
