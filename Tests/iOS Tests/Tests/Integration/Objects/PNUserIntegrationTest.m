/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNObjectsTestCase.h"
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Test interface declaration

@interface PNUserIntegrationTest : PNObjectsTestCase


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNUserIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    if ([self.name rangeOfString:@"testFetchAll"].location != NSNotFound) {
        self.testUsersCount = 6;
        [self cleanUpUserObjects];
    }
}


#pragma mark - Tests :: Create

- (void)testCreate_ShouldCreateNewUser_WhenCalledWithNameIdentifierOnly {
    NSString *userId = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createUser().userId(userId).name(name).includeFields(PNUserCustomField)
            .performWithCompletion(^(PNCreateUserStatus *status) {
                PNUser *user = status.data.user;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(user);
                XCTAssertEqualObjects(user.externalId, [NSNull null]);
                XCTAssertEqualObjects(user.profileUrl, [NSNull null]);
                XCTAssertEqualObjects(user.custom, [NSNull null]);
                XCTAssertEqualObjects(user.email, [NSNull null]);
                XCTAssertEqualObjects(user.identifier, userId);
                XCTAssertEqualObjects(user.name, name);
                XCTAssertNotNil(user.created);
                XCTAssertNotNil(user.updated);
                XCTAssertNotNil(user.eTag);
                
                handler();
            });
    }];
}

- (void)testCreate_ShouldCreateNewUser_WhenCalledWithAdditionalFields {
    NSString *externalId = [NSUUID UUID].UUIDString;
    NSString *profileUrl = @"https://pubnub.com";
    NSString *userId = [NSUUID UUID].UUIDString;
    NSString *email = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    NSDictionary *custom = @{
        @"user-custom1": [NSUUID UUID].UUIDString,
        @"user-custom2": [NSUUID UUID].UUIDString
    };
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createUser().userId(userId).name(name).externalId(externalId)
            .profileUrl(profileUrl).email(email).custom(custom)
            .includeFields(PNUserCustomField)
            .performWithCompletion(^(PNCreateUserStatus *status) {
                PNUser *user = status.data.user;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(user);
                XCTAssertEqualObjects(user.externalId, externalId);
                XCTAssertEqualObjects(user.profileUrl, profileUrl);
                XCTAssertEqualObjects(user.identifier, userId);
                XCTAssertEqualObjects(user.custom, custom);
                XCTAssertEqualObjects(user.email, email);
                XCTAssertEqualObjects(user.name, name);
                XCTAssertNotNil(user.created);
                XCTAssertNotNil(user.updated);
                XCTAssertNotNil(user.eTag);
                
                handler();
            });
    }];
}

- (void)testCreate_ShouldFail_WhenCreatingSecondUserWithSameIdentifier {
    NSString *userId = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createUser().userId(userId).name(name)
            .performWithCompletion(^(PNCreateUserStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(status.data.user);
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createUser().userId(userId).name(name)
            .performWithCompletion(^(PNCreateUserStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 409);
                XCTAssertNil(status.data.user);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Update

- (void)testUpdate_ShouldUpdate_WhenUserExists {
    NSString *userId = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    NSString *expectedName = [NSUUID UUID].UUIDString;
    __block NSDate *createDate = nil;
    __block NSDate *updateDate = nil;
    __block NSString *eTag = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createUser().userId(userId).name(name).includeFields(PNUserCustomField)
            .performWithCompletion(^(PNCreateUserStatus *status) {
                createDate = status.data.user.created;
                updateDate = status.data.user.updated;
                eTag = status.data.user.eTag;
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.updateUser().userId(userId).name(expectedName).includeFields(PNUserCustomField)
            .performWithCompletion(^(PNUpdateUserStatus *status) {
                XCTAssertEqualObjects(status.data.user.name, expectedName);
                XCTAssertEqualObjects(status.data.user.created, createDate);
                XCTAssertNotEqualObjects(status.data.user.updated, updateDate);
                XCTAssertNotEqualObjects(status.data.user.name, eTag);
                
                handler();
            });
    }];
}

- (void)testUpdate_ShouldTriggerUpdateEvent_WhenUpdatingExistingUser {
    NSString *userId = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    NSDictionary *custom = @{ @"user-custom": [NSUUID UUID].UUIDString };
    NSDictionary *expectedCustom = @{ @"user-custom": [NSUUID UUID].UUIDString };
    NSString *expectedName = [NSUUID UUID].UUIDString;
    [self.client2 addListener:self];
    NSString *channel = userId;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createUser().userId(userId).name(name).custom(custom)
            .performWithCompletion(^(PNCreateUserStatus *status) {
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
        [self addUserHandlerForClient:self.client2
                            withBlock:^(PubNub *client, PNUserEventResult *event, BOOL *remove) {
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
        
        self.client1.updateUser().userId(userId).name(expectedName).custom(expectedCustom)
            .performWithCompletion(^(PNUpdateUserStatus *status) { });
    }];
}

- (void)testUpdate_ShouldFail_WhenUserNotExist {
    NSString *userId = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.updateUser().userId(userId).name(name)
            .performWithCompletion(^(PNUpdateUserStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 404);
                XCTAssertNil(status.data.user);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Delete

- (void)testDelete_ShouldDelete_WhenUserExists {
    NSString *userId = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createUser().userId(userId).name(name)
            .performWithCompletion(^(PNCreateUserStatus *status) {
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.deleteUser().userId(userId)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                handler();
            });
    }];
}

- (void)testDelete_ShouldTriggerDeleteEvent_WhenDeletingExistingUser {
    NSString *userId = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    [self.client2 addListener:self];
    NSString *channel = userId;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createUser().userId(userId).name(name)
            .performWithCompletion(^(PNCreateUserStatus *status) {
                
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
        [self addUserHandlerForClient:self.client2
                            withBlock:^(PubNub *client, PNUserEventResult *event, BOOL *remove) {
            *remove = YES;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.identifier, userId);
            XCTAssertNotNil(event.data.timestamp);
#pragma GCC diagnostic pop

            handler();
        }];
        
        self.client1.deleteUser().userId(userId).performWithCompletion(^(PNAcknowledgmentStatus *status) { });
    }];
}


#pragma mark - Tests :: Fetch

- (void)testFetch_ShouldFetch_WhenUserExists {
    NSString *userId = [NSUUID UUID].UUIDString;
    NSString *name = [NSUUID UUID].UUIDString;
    NSDictionary *custom = @{
        @"user-custom1": [NSUUID UUID].UUIDString,
        @"user-custom2": [NSUUID UUID].UUIDString
    };
    __block NSDate *createDate = nil;
    __block NSDate *updateDate = nil;
    __block NSString *eTag = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.createUser().userId(userId).name(name).custom(custom)
            .performWithCompletion(^(PNCreateUserStatus *status) {
                PNUser *user = status.data.user;
                createDate = user.created;
                updateDate = user.updated;
                eTag = user.eTag;
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchUser().userId(userId).includeFields(PNUserCustomField)
            .performWithCompletion(^(PNFetchUserResult *result, PNErrorStatus *status) {
                PNUser *user = result.data.user;
                XCTAssertNotNil(user);
                XCTAssertEqualObjects(user.created, createDate);
                XCTAssertEqualObjects(user.updated, updateDate);
                XCTAssertEqualObjects(user.eTag, eTag);
                
                handler();
            });
    }];
}

- (void)testFetch_ShouldFail_WhenUserNotExist {
    NSString *userId = [NSUUID UUID].UUIDString;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchUser().userId(userId)
            .performWithCompletion(^(PNFetchUserResult *result, PNErrorStatus *status) {
                XCTAssertNil(result);
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 404);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Fetch all

- (void)testFetchAll_ShouldFetch_WhenCalledWithDefauls {
    NSArray<NSDictionary *> *users = [self createTestUsers];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchUsers()
            .performWithCompletion(^(PNFetchUsersResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.users.count, users.count);
                XCTAssertEqual(result.data.totalCount, 0);
                
                handler();
            });
    }];
}

- (void)testFetchAll_ShouldFetchLimited_WhenCalledWithLimit {
    NSArray<NSDictionary *> *users = [self createTestUsers];
    NSUInteger expectedCount = 2;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchUsers().limit(expectedCount).includeFields(PNUserCustomField)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchUsersResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.users.count, expectedCount);
                XCTAssertEqual(result.data.totalCount, users.count);
                XCTAssertNotNil(result.data.users[0].custom);
                
                handler();
            });
    }];
}

- (void)testFetchAll_ShouldFetchNextPage_WhenCalledWithStart {
    NSArray<NSDictionary *> *users = [self createTestUsers];
    __block NSString *next = nil;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchUsers().limit(users.count - 2)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchUsersResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.users.count, users.count - 2);
                next = result.data.next;
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchUsers().start(next).includeCount(YES)
            .performWithCompletion(^(PNFetchUsersResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.users.count, 2);
                
                handler();
            });
    }];
}

#pragma mark -


@end
