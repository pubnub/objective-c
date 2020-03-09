/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import <PubNub/NSDateFormatter+PNCacheable.h>
#import <PubNub/PNHelpers.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNUserIntegrationTest : PNRecordableTestCase


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNUserIntegrationTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    [self completePubNubConfiguration:self.client];
    [self removeAllObjects];
}


#pragma mark - Tests :: Builder pattern-based create user

- (void)testItShouldCreateUserAndReceiveStatusWithExpectedOperationAndCategoryWhenOnlySpaceAndIdentifierIsSet {
    NSString *identifier = [self randomizedValuesWithValues:@[@"test-user"]].firstObject;
    NSString *name = [self randomizedValuesWithValues:@[@"test-user-name"]].firstObject;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.createUser()
            .userId(identifier)
            .name(name)
            .includeFields(PNUserCustomField)
            .performWithCompletion(^(PNCreateUserStatus *status) {
                PNUser *user = status.data.user;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(user);
                XCTAssertEqualObjects(user.externalId, [NSNull null]);
                XCTAssertEqualObjects(user.profileUrl, [NSNull null]);
                XCTAssertEqualObjects(user.custom, [NSNull null]);
                XCTAssertEqualObjects(user.email, [NSNull null]);
                XCTAssertEqualObjects(user.identifier, identifier);
                XCTAssertEqualObjects(user.name, name);
                XCTAssertNotNil(user.created);
                XCTAssertNotNil(user.updated);
                XCTAssertNotNil(user.eTag);
                XCTAssertEqual(status.operation, PNCreateUserOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];
    
    [self deleteUsers:@[identifier] usingClient:nil];
}

- (void)testItShouldCreateUserWhenAdditionalInformationIsSet {
    NSString *externalId = [self randomizedValuesWithValues:@[@"test-external-identifier"]].firstObject;
    NSString *email = [self randomizedValuesWithValues:@[@"test-user-email"]].firstObject;
    NSString *identifier = [self randomizedValuesWithValues:@[@"test-user"]].firstObject;
    NSString *name = [self randomizedValuesWithValues:@[@"test-user-name"]].firstObject;
    NSString *profileUrl = @"https://pubnub.com";
    NSDictionary *custom = @{
        @"user-custom1": [@[name, @"custom", @"data", @"1"] componentsJoinedByString:@"-"],
        @"user-custom2": [@[name, @"custom", @"data", @"2"] componentsJoinedByString:@"-"]
    };
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.createUser()
            .userId(identifier)
            .name(name)
            .externalId(externalId)
            .profileUrl(profileUrl)
            .email(email).custom(custom)
            .includeFields(PNUserCustomField)
            .performWithCompletion(^(PNCreateUserStatus *status) {
                PNUser *user = status.data.user;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(user);
                XCTAssertEqualObjects(user.externalId, externalId);
                XCTAssertEqualObjects(user.profileUrl, profileUrl);
                XCTAssertEqualObjects(user.identifier, identifier);
                XCTAssertEqualObjects(user.custom, custom);
                XCTAssertEqualObjects(user.email, email);
                XCTAssertEqualObjects(user.name, name);
                XCTAssertNotNil(user.created);
                XCTAssertNotNil(user.updated);
                XCTAssertNotNil(user.eTag);
                
                handler();
            });
    }];
    
    [self deleteUsers:@[identifier] usingClient:nil];
}

- (void)testItShouldNotCreateUserWhenSameUserAlreadyExists {
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.createUser()
            .userId(users.firstObject.identifier)
            .name(users.firstObject.name)
            .performWithCompletion(^(PNCreateUserStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 409);
                XCTAssertNil(status.data.user);
                
                if (!retried) {
                    retried = YES;
                    [status retry];
                } else {
                    handler();
                }
            });
    }];
    
    [self deleteUserObjectsUsingClient:nil];
}


#pragma mark - Tests :: Builder pattern-based update space

- (void)testItShouldUpdateUserAndReceiveStatusWithExpectedOperationAndCategory {
    NSString *name = [self randomizedValuesWithValues:@[@"test-space-name"]].firstObject;
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    NSDate *createDate = users.firstObject.created;
    NSDate *updateDate = users.firstObject.updated;
    NSString *eTag = users.firstObject.eTag;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.updateUser()
            .userId(users.firstObject.identifier)
            .name(name)
            .includeFields(PNUserCustomField)
            .performWithCompletion(^(PNUpdateUserStatus *status) {
                PNUser *user = status.data.user;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(user);
                XCTAssertNotEqualObjects(user.updated, updateDate);
                XCTAssertEqualObjects(user.created, createDate);
                XCTAssertEqualObjects(user.name, name);
                XCTAssertNotEqualObjects(user.eTag, eTag);
                XCTAssertEqual(status.operation, PNUpdateUserOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];
    
    [self deleteUserObjectsUsingClient:nil];
}

- (void)testItShouldUpdateUserAndTriggerUpdateEventToUserChannel {
    NSString *name = [self randomizedValuesWithValues:@[@"test-space-name"]].firstObject;
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:client1];
    NSString *channel = users.firstObject.identifier;
    NSDictionary *custom = @{
        @"user-custom1": [@[name, @"custom", @"data", @"1"] componentsJoinedByString:@"-"],
        @"user-custom2": [@[name, @"custom", @"data", @"2"] componentsJoinedByString:@"-"]
    };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addUserHandlerForClient:client2
                            withBlock:^(PubNub *client, PNUserEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"update");
            XCTAssertEqualObjects(event.data.name, name);
            XCTAssertEqualObjects(event.data.custom, custom);
            XCTAssertNotNil(event.data.updated);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;

            handler();
        }];
        
        client1.updateUser()
            .userId(users.firstObject.identifier)
            .name(name)
            .custom(custom)
            .performWithCompletion(^(PNUpdateUserStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
    
    [self deleteUserObjectsUsingClient:client1];
}

- (void)testItShouldNotUpdateUserWhenTargetUserNotExists {
    NSString *identifier = [self randomizedValuesWithValues:@[@"test-user"]].firstObject;
    NSString *name = [self randomizedValuesWithValues:@[@"test-user-name"]].firstObject;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.updateUser()
            .userId(identifier)
            .name(name)
            .performWithCompletion(^(PNUpdateUserStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 404);
                XCTAssertNil(status.data.user);
                
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
 *  'ItShouldDeleteUserAndReceiveStatusWithExpectedOperationAndCategory.json' should
 *  be modified after cassette recording. Find first mention of user remove and copy paste 4 entries
 *  which belong to it. For new entries change 'id' field to be different from source. For original
 *  response entry change status code to 404.
 */
- (void)testItShouldDeleteUserAndReceiveStatusWithExpectedOperationAndCategory {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:nil];
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.deleteUser()
            .userId(users.firstObject.identifier)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                if (!retried && !YHVVCR.cassette.isNewCassette) {
                    XCTAssertTrue(status.error);
                    XCTAssertEqual(status.operation, PNDeleteUserOperation);
                    XCTAssertEqual(status.category, PNMalformedResponseCategory);
                    
                    retried = YES;
                    [status retry];
                } else {
                    XCTAssertFalse(status.error);
                    XCTAssertEqual(status.operation, PNDeleteUserOperation);
                    XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                    
                    [self deleteCachedUser:users.firstObject.identifier];
                    
                    handler();
                }
            });
    }];
    
    
    [self verifyUsersCountShouldEqualTo:(users.count - 1) usingClient:nil];
    
    [self deleteUserObjectsUsingClient:nil];
}

- (void)testItShouldDeleteUserAndTriggerDeleteEventToSUserChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:client1];
    NSString *channel = users.firstObject.identifier;
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addUserHandlerForClient:client2
                            withBlock:^(PubNub *client, PNUserEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.identifier, users.firstObject.identifier);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;

            handler();
        }];
        
        client1.deleteUser()
            .userId(users.firstObject.identifier)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertFalse(status.isError);
                
                [self deleteCachedUser:users.firstObject.identifier];
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
    
    
    [self verifyUsersCountShouldEqualTo:(users.count - 1) usingClient:client1];
    
    [self deleteUserObjectsUsingClient:client1];
}


#pragma mark - Tests :: Builder pattern-based fetch users

- (void)testItShouldFetchUserAndReceiveResultWithExpectedOperation {
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    NSDate *createDate = users.firstObject.created;
    NSDate *updateDate = users.firstObject.updated;
    NSString *eTag = users.firstObject.eTag;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchUser()
            .userId(users.firstObject.identifier)
            .includeFields(PNUserCustomField)
            .performWithCompletion(^(PNFetchUserResult *result, PNErrorStatus *status) {
                PNUser *user = result.data.user;
                XCTAssertNil(status);
                XCTAssertNotNil(user);
                XCTAssertEqualObjects(user.created, createDate);
                XCTAssertEqualObjects(user.updated, updateDate);
                XCTAssertEqualObjects(user.eTag, eTag);
                XCTAssertEqual(result.operation, PNFetchUserOperation);
                
                handler();
            });
    }];
    
    [self deleteUserObjectsUsingClient:nil];
}

- (void)testItShouldNotFetchUserWhenTargetUserNotExists {
    NSString *identifier = [self randomizedValuesWithValues:@[@"test-user"]].firstObject;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchUser()
            .userId(identifier)
            .includeFields(PNUserCustomField)
            .performWithCompletion(^(PNFetchUserResult *result, PNErrorStatus *status) {
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


#pragma mark - Tests :: Builder pattern-based fetch all users

/**
 * @brief To test 'retry' functionality
 *  'ItShouldFetchAllUsersAndReceiveResultWithExpectedOperation.json' should
 *  be modified after cassette recording. Find first mention of users fetch and copy paste 4 entries
 *  which belong to it. For new entries change 'id' field to be different from source. For original
 *  response entry change status code to 404.
 */
- (void)testItShouldFetchAllUsersAndReceiveResultWithExpectedOperation {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    NSArray<PNUser *> *users = [self createObjectForUsers:6 usingClient:nil];
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchUsers().performWithCompletion(^(PNFetchUsersResult *result, PNErrorStatus *status) {
            if (!retried && !YHVVCR.cassette.isNewCassette) {
                XCTAssertTrue(status.error);
                XCTAssertEqual(status.operation, PNFetchUsersOperation);
                XCTAssertEqual(status.category, PNMalformedResponseCategory);
                
                retried = YES;
                [status retry];
            } else {
                XCTAssertNil(status);
                XCTAssertEqual(result.data.users.count, users.count);
                XCTAssertEqual(result.data.totalCount, 0);
                XCTAssertEqual(result.operation, PNFetchUsersOperation);
                
                handler();
            }
        });
    }];
    
    [self deleteUserObjectsUsingClient:nil];
}

- (void)testItShouldFetchFilteredUsersWhenFilterIsSet {
    NSDateFormatter *formatter = [NSDateFormatter pn_formatterWithString:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSArray<PNUser *> *users = [self createObjectForUsers:6 usingClient:nil];
    NSUInteger targetUserOffset = 3;
    NSDate *targetUserUpdateDate = users[targetUserOffset].updated;
    NSString *filterExpression = [NSString stringWithFormat:@"updated >= '%@'",
                                  [formatter stringFromDate:targetUserUpdateDate]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchUsers()
            .includeCount(YES)
            .filter(filterExpression)
            .performWithCompletion(^(PNFetchUsersResult *result, PNErrorStatus *status) {
                NSURLRequest *request = [result valueForKey:@"clientRequest"];
                XCTAssertNil(status);
                XCTAssertEqual(result.data.totalCount, users.count - targetUserOffset);
                XCTAssertEqual(result.data.users.count, result.data.totalCount);
                XCTAssertNil(result.data.prev);
                XCTAssertNotNil(result.data.next);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                  NSNotFound);
                
                handler();
            });
    }];
    
    [self deleteUserObjectsUsingClient:nil];
}

- (void)testItShouldFetchSortedUsersWhenSortIsSet {
    NSArray<PNUser *> *users = [self createObjectForUsers:6 usingClient:nil];
    NSString *expectedSort = @"name%3Adesc,created";
    NSArray<PNUser *> *expectedUsersOrder = [users sortedArrayUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]
    ]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchUsers()
            .includeCount(YES)
            .sort(@[@"name:desc", @"created"])
            .performWithCompletion(^(PNFetchUsersResult *result, PNErrorStatus *status) {
                NSArray<PNUser *> *fetchedUsers = result.data.users;
                NSURLRequest *request = [result valueForKey:@"clientRequest"];
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedUsers);
                XCTAssertNil(result.data.prev);
                XCTAssertNotNil(result.data.next);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);
                
                for (NSUInteger fetchedUserIdx = 0; fetchedUserIdx < fetchedUsers.count; fetchedUserIdx++) {
                    XCTAssertEqualObjects(fetchedUsers[fetchedUserIdx].identifier,
                                          expectedUsersOrder[fetchedUserIdx].identifier);
                }
                
                handler();
            });
    }];
    
    [self deleteUserObjectsUsingClient:nil];
}

- (void)testItShouldFetchAllUsersWhenLimitItSet {
    NSArray<PNUser *> *users = [self createObjectForUsers:6 usingClient:nil];
    NSUInteger expectedCount = 2;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchUsers()
            .limit(expectedCount)
            .includeFields(PNUserCustomField)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchUsersResult *result, PNErrorStatus *status) {
                NSArray<PNUser *> *fetchedUsers = result.data.users;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedUsers);
                XCTAssertEqual(fetchedUsers.count, expectedCount);
                XCTAssertEqual(result.data.totalCount, users.count);
                XCTAssertNotNil(fetchedUsers.firstObject.custom);
                
                handler();
            });
    }];
    
    [self deleteUserObjectsUsingClient:nil];
}

- (void)testItShouldFetchNextUsersPageWhenStartAndLimitIsSet {
    NSArray<PNUser *> *users = [self createObjectForUsers:6 usingClient:nil];
    __block NSString *next = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchUsers()
            .limit(users.count - 2)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchUsersResult *result, PNErrorStatus *status) {
                NSArray<PNUser *> *fetchedUsers = result.data.users;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedUsers);
                XCTAssertEqual(fetchedUsers.count, users.count - 2);
                next = result.data.next;
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchUsers()
            .start(next)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchUsersResult *result, PNErrorStatus *status) {
                NSArray<PNUser *> *fetchedUsers = result.data.users;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedUsers);
                XCTAssertEqual(fetchedUsers.count, 2);
                
                handler();
            });
    }];
    
    [self deleteUserObjectsUsingClient:nil];
}

#pragma mark -

#pragma clang diagnostic pop

@end
