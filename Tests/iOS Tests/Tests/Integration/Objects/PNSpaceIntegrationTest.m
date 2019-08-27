/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNObjectsTestCase.h"
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Test interface declaration

@interface PNSpaceIntegrationTest : PNObjectsTestCase


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNSpaceIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    if ([self.name rangeOfString:@"testFetchAll"].location != NSNotFound) {
        self.testSpacesCount = 6;
        [self cleanUpSpaceObjects];
    }
}


#pragma mark - Tests :: Create

- (void)testCreate_ShouldCreateNewSpace_WhenCalledWithNameIdentifierOnly {
    NSString *spaceId = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createSpace().spaceId(spaceId).name(name).includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNCreateSpaceStatus *status) {
                PNSpace *space = status.data.space;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(space);
                XCTAssertEqualObjects(space.custom, [NSNull null]);
                XCTAssertEqualObjects(space.identifier, spaceId);
                XCTAssertEqualObjects(space.name, name);
                XCTAssertNotNil(space.created);
                XCTAssertNotNil(space.updated);
                XCTAssertNotNil(space.eTag);
                
                handler();
            });
    }];
}

- (void)testCreate_ShouldCreateNewSpace_WhenCalledWithAdditionalFields {
    NSString *information = [NSUUID UUID].UUIDString;
    NSString *spaceId = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    NSDictionary *custom = @{
        @"space-custom1": [NSUUID UUID].UUIDString,
        @"space-custom2": [NSUUID UUID].UUIDString
    };
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createSpace().spaceId(spaceId).name(name).information(information).custom(custom)
            .includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNCreateSpaceStatus *status) {
                PNSpace *space = status.data.space;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(space);
                XCTAssertEqualObjects(space.information, information);
                XCTAssertEqualObjects(space.identifier, spaceId);
                XCTAssertEqualObjects(space.custom, custom);
                XCTAssertEqualObjects(space.name, name);
                XCTAssertNotNil(space.created);
                XCTAssertNotNil(space.updated);
                XCTAssertNotNil(space.eTag);
                
                handler();
            });
    }];
}

- (void)testCreate_ShouldFail_WhenCreatingSecondSpaceWithSameIdentifier {
    NSString *spaceId = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createSpace().spaceId(spaceId).name(name)
            .performWithCompletion(^(PNCreateSpaceStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(status.data.space);
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createSpace().spaceId(spaceId).name(name)
            .performWithCompletion(^(PNCreateSpaceStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 409);
                XCTAssertNil(status.data.space);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Update

- (void)testUpdate_ShouldUpdate_WhenSpaceExists {
    NSString *spaceId = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    NSString *expectedName = [NSUUID UUID].UUIDString;
    __block NSDate *createDate = nil;
    __block NSDate *updateDate = nil;
    __block NSString *eTag = nil;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createSpace().spaceId(spaceId).name(name).includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNCreateSpaceStatus *status) {
                PNSpace *space = status.data.space;
                createDate = space.created;
                updateDate = space.updated;
                eTag = space.eTag;
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.updateSpace().spaceId(spaceId).name(expectedName).includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNUpdateSpaceStatus *status) {
                PNSpace *space = status.data.space;
                XCTAssertNotEqualObjects(space.updated, updateDate);
                XCTAssertEqualObjects(space.created, createDate);
                XCTAssertEqualObjects(space.name, expectedName);
                XCTAssertNotEqualObjects(space.eTag, eTag);
                
                handler();
            });
    }];
}

- (void)testUpdate_ShouldTriggerUpdateEvent_WhenUpdatingExistingSpace {
    NSString *spaceId = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    NSString *channel = spaceId;
    NSDictionary *expectedCustom = @{ @"space-custom": [NSUUID UUID].UUIDString };
    NSString *expectedName = [NSUUID UUID].UUIDString;
    [self.client2 addListener:self];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createSpace().spaceId(spaceId).name(name).includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNCreateSpaceStatus *status) {
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client2
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {

            if (status.category == PNConnectedCategory) {
                *remove = YES;
                
                handler();
            }
        }];
        
        self.client2.subscribe().channels(@[channel]).perform();
    }];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addSpaceHandlerForClient:self.client2
                             withBlock:^(PubNub *client, PNSpaceEventResult *event, BOOL *remove) {
            *remove = YES;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            XCTAssertEqualObjects(event.data.event, @"update");
            XCTAssertEqualObjects(event.data.name, expectedName);
            XCTAssertEqualObjects(event.data.custom, expectedCustom);
            XCTAssertNotNil(event.data.updated);
            XCTAssertNotNil(event.data.timestamp);
#pragma GCC diagnostic pop

            handler();
        }];
        
        self.client1.updateSpace().spaceId(spaceId).name(expectedName).custom(expectedCustom)
            .performWithCompletion(^(PNUpdateSpaceStatus *status) { });
    }];
    
}

- (void)testUpdate_ShouldFail_WhenSpaceNotExist {
    NSString *spaceId = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.updateSpace().spaceId(spaceId).name(name)
            .performWithCompletion(^(PNUpdateSpaceStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 404);
                XCTAssertNil(status.data.space);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Delete

- (void)testDelete_ShouldDelete_WhenSpaceExists {
    NSString *spaceId = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createSpace().spaceId(spaceId).name(name)
            .performWithCompletion(^(PNCreateSpaceStatus *status) {
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.deleteSpace().spaceId(spaceId)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                handler();
            });
    }];
}

- (void)testDelete_ShouldTriggerDeleteEvent_WhenDeletingExistingSpace {
    NSString *spaceId = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    NSString *channel = spaceId;
    [self.client2 addListener:self];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createSpace().spaceId(spaceId).name(name)
            .performWithCompletion(^(PNCreateSpaceStatus *status) {
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client2
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
                                  
            if (status.category == PNConnectedCategory) {
                *remove = YES;

                handler();
            }
        }];
        
        self.client2.subscribe().channels(@[channel]).perform();
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addSpaceHandlerForClient:self.client2
                             withBlock:^(PubNub *client, PNSpaceEventResult *event, BOOL *remove) {
            *remove = YES;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.identifier, spaceId);
            XCTAssertNotNil(event.data.timestamp);
#pragma GCC diagnostic pop

            handler();
        }];
        
        self.client1.deleteSpace().spaceId(spaceId).performWithCompletion(^(PNAcknowledgmentStatus *status) { });
    }];
}


#pragma mark - Tests :: Fetch

- (void)testFetch_ShouldFetch_WhenSpaceExists {
    NSString *spaceId = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    NSDictionary *custom = @{
        @"space-custom1": [NSUUID UUID].UUIDString,
        @"space-custom2": [NSUUID UUID].UUIDString
    };
    __block NSDate *createDate = nil;
    __block NSDate *updateDate = nil;
    __block NSString *eTag = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createSpace().spaceId(spaceId).name(name).custom(custom)
            .performWithCompletion(^(PNCreateSpaceStatus *status) {
                PNSpace *space = status.data.space;
                createDate = space.created;
                updateDate = space.updated;
                eTag = space.eTag;
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchSpace().spaceId(spaceId).includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNFetchSpaceResult *result, PNErrorStatus *status) {
                PNSpace *space = result.data.space;
                XCTAssertNotNil(space);
                XCTAssertEqualObjects(space.created, createDate);
                XCTAssertEqualObjects(space.updated, updateDate);
                XCTAssertEqualObjects(space.eTag, eTag);
                
                handler();
            });
    }];
}

- (void)testFetch_ShouldFail_WhenSpaceNotExist {
    NSString *spaceId = [NSUUID UUID].UUIDString;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchSpace().spaceId(spaceId)
            .performWithCompletion(^(PNFetchSpaceResult *result, PNErrorStatus *status) {
                XCTAssertNil(result);
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 404);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Fetch all

- (void)testFetchAll_ShouldFetch_WhenCalledWithDefauls {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchSpaces()
            .performWithCompletion(^(PNFetchSpacesResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.spaces.count, spaces.count);
                XCTAssertEqual(result.data.totalCount, 0);
                
                handler();
            });
    }];
}

- (void)testFetchAll_ShouldFetchLimited_WhenCalledWithLimit {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSUInteger expectedCount = 2;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchSpaces().limit(expectedCount).includeFields(PNSpaceCustomField)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchSpacesResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.spaces.count, expectedCount);
                XCTAssertEqual(result.data.totalCount, spaces.count);
                XCTAssertNotNil(result.data.spaces[0].custom);
                
                handler();
            });
    }];
}

- (void)testFetchAll_ShouldFetchNextPage_WhenCalledWithStart {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    __block NSString *next = nil;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchSpaces().limit(spaces.count - 2)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchSpacesResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.spaces.count, spaces.count - 2);
                next = result.data.next;
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchSpaces().start(next).includeCount(YES)
            .performWithCompletion(^(PNFetchSpacesResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.spaces.count, 2);
                
                handler();
            });
    }];
}

#pragma mark -


@end
