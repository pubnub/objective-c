/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNObjectsTestCase.h"
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Test interface declaration

@interface PNMembershipIntegrationTest : PNObjectsTestCase


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNMembershipIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    if ([self.name rangeOfString:@"testFetch"].location != NSNotFound) {
        self.testSpacesCount = 6;
    } else {
        self.testSpacesCount = 2;
    }
    
    self.testUsersCount = 1;
    
    if ([self.name rangeOfString:@"testFetch"].location != NSNotFound ||
        ([self.name rangeOfString:@"testDelete"].location != NSNotFound &&
         [self.name rangeOfString:@"Fail"].location == NSNotFound) ) {
            
        [self cleanUpUserObjects];
        [self cleanUpSpaceObjects];
    }
}


#pragma mark - Tests :: Create

- (void)testCreate_ShouldCreateNewMembership_WhenCalled {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    NSArray<NSDictionary *> *customs = @[
        @{ @"user-membership-custom": [NSUUID UUID].UUIDString },
        @{ @"user-membership-custom": [NSUUID UUID].UUIDString }
    ];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMemberships().userId(users[0][@"id"])
            .includeFields(PNMembershipCustomField)
            .add(@[
                @{ @"spaceId": spaces[0][@"id"], @"custom": customs[0] },
                @{ @"spaceId": spaces[1][@"id"], @"custom": customs[1] }
            ])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSArray<PNMembership *> *memberships = status.data.memberships;
                
                for (PNMembership *membership in memberships) {
                    for (NSUInteger spaceIdx = 0; spaceIdx < spaces.count; spaceIdx++) {
                        NSDictionary *space = spaces[spaceIdx];
                        
                        if ([membership.spaceId isEqualToString:space[@"id"]]) {
                            XCTAssertEqualObjects(membership.custom, customs[spaceIdx]);
                            break;
                        }
                    }
                }
                
                handler();
            });
    }];
}

- (void)testCreate_ShouldCreateAndReturnSpaceInformation_WhenSpaceAndSpaceCustomFlagsSet {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMemberships().userId(users[0][@"id"])
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .add(@[@{ @"spaceId": spaces[0][@"id"] }, @{ @"spaceId": spaces[1][@"id"] }])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSArray<PNMembership *> *memberships = status.data.memberships;
                
                for (PNMembership *membership in memberships) {
                    XCTAssertNotNil(membership.space);
                    
                    for (NSDictionary *space in spaces) {
                        if ([membership.space.identifier isEqualToString:space[@"id"]]) {
                            XCTAssertEqualObjects(membership.space.custom, space[@"custom"]);
                            break;
                        }
                    }
                }
                
                handler();
            });
    }];
}

- (void)testCreate_ShouldTriggerCreateEventOnUserChannel_WhenNewMembershipCreated {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    NSMutableArray *createdMemberships = [NSMutableArray new];
    NSString *channel = users[0][@"id"];
    [self.client2 addListener:self];
    
    
    [self subscribeOnObjectChannels:@[channel]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:self.client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            if ([createdMemberships indexOfObject:event.data.spaceId] == NSNotFound) {
                [createdMemberships addObject:event.data.spaceId];
            }
                                      
            *remove = createdMemberships.count == spaces.count;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            XCTAssertEqualObjects(event.data.event, @"create");
            XCTAssertNotNil(event.data.created);
            XCTAssertNotNil(event.data.timestamp);
                                      
            if (createdMemberships.count == spaces.count) {
                XCTAssertNotEqual([createdMemberships indexOfObject:spaces[0][@"id"]], NSNotFound);
                XCTAssertNotEqual([createdMemberships indexOfObject:spaces[1][@"id"]], NSNotFound);
                handler();
            }
#pragma GCC diagnostic pop
        }];
        
        self.client1.manageMemberships().userId(users[0][@"id"])
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .add(@[@{ @"spaceId": spaces[0][@"id"] }, @{ @"spaceId": spaces[1][@"id"] }])
            .performWithCompletion(^(PNManageMembershipsStatus *status) { });
    }];
}

- (void)testCreate_ShouldTriggerCreateEventOnSpaceChannel_WhenNewMembershipCreated {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    NSString *channel = spaces[0][@"id"];
    [self.client2 addListener:self];
    
    
    [self subscribeOnObjectChannels:@[channel]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:self.client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
                                      
            *remove = YES;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            XCTAssertEqualObjects(event.data.event, @"create");
            XCTAssertNotNil(event.data.created);
            XCTAssertNotNil(event.data.timestamp);

            handler();
#pragma GCC diagnostic pop
        }];
        
        self.client1.manageMemberships().userId(users[0][@"id"])
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .add(@[@{ @"spaceId": spaces[0][@"id"] }, @{ @"spaceId": spaces[1][@"id"] }])
            .performWithCompletion(^(PNManageMembershipsStatus *status) { });
    }];
}

 - (void)testCreate_ShouldFail_WhenCreatingUserHasMembershipWithTargetSpaces {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMemberships().userId(users[0][@"id"])
            .add(@[ @{ @"spaceId": spaces[0][@"id"] }, @{ @"spaceId": spaces[1][@"id"] }])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertFalse(status.isError);
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMemberships().userId(users[0][@"id"])
            .includeFields(PNMembershipCustomField)
            .add(@[ @{ @"spaceId": spaces[0][@"id"] }, @{ @"spaceId": spaces[1][@"id"] }])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 400);
                handler();
            });
    }];
}


#pragma mark - Tests :: Update

- (void)testUpdate_ShouldUpdate_WhenMembershipExists {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    NSArray<NSDictionary *> *customs = @[
        @{ @"user-membership-custom": [NSUUID UUID].UUIDString },
        @{ @"user-membership-custom": [NSUUID UUID].UUIDString }
    ];
    NSArray<NSDictionary *> *expectedCustoms = @[
        @{ @"user-membership-custom": [NSUUID UUID].UUIDString },
        @{ @"user-membership-custom": [NSUUID UUID].UUIDString }
    ];
    
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:customs];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMemberships().userId(users[0][@"id"])
            .includeFields(PNMembershipCustomField)
            .update(@[
                @{ @"spaceId": spaces[0][@"id"], @"custom": expectedCustoms[0] },
                @{ @"spaceId": spaces[1][@"id"], @"custom": expectedCustoms[1] }
            ])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSArray<PNMembership *> *memberships = status.data.memberships;
                
                for (PNMembership *membership in memberships) {
                    for (NSUInteger spaceIdx = 0; spaceIdx < spaces.count; spaceIdx++) {
                        NSDictionary *space = spaces[spaceIdx];
                        
                        if ([membership.spaceId isEqualToString:space[@"id"]]) {
                            XCTAssertEqualObjects(membership.custom, expectedCustoms[spaceIdx]);
                            break;
                        }
                    }
                }
                
                handler();
            });
    }];
}

- (void)testUpdate_ShouldUpdateAndReturnSpaceInformation_WhenSpaceAndSpaceCustomFlagsSet {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    NSArray<NSDictionary *> *customs = @[
        @{ @"user-membership-custom": [NSUUID UUID].UUIDString },
        @{ @"user-membership-custom": [NSUUID UUID].UUIDString }
    ];
    
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMemberships().userId(users[0][@"id"])
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .update(@[
                @{ @"spaceId": spaces[0][@"id"], @"custom": customs[0] },
                @{ @"spaceId": spaces[1][@"id"], @"custom": customs[1] }
            ])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSArray<PNMembership *> *memberships = status.data.memberships;
                
                for (PNMembership *membership in memberships) {
                    XCTAssertNotNil(membership.space);
                    
                    for (NSDictionary *space in spaces) {
                        if ([membership.space.identifier isEqualToString:space[@"id"]]) {
                            XCTAssertEqualObjects(membership.space.custom, space[@"custom"]);
                            break;
                        }
                    }
                }
                
                handler();
            });
    }];
}

- (void)testUpdate_ShouldTriggerUpdateEventOnUserChannel_WhenMembershipUpdated {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    NSMutableArray *updatedMemberships = [NSMutableArray new];
    NSArray<NSDictionary *> *customs = @[
        @{ @"user-membership-custom": [NSUUID UUID].UUIDString },
        @{ @"user-membership-custom": [NSUUID UUID].UUIDString }
    ];
    NSString *channel = users[0][@"id"];
    [self.client2 addListener:self];
    
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil];
    [self subscribeOnObjectChannels:@[channel]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:self.client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            if ([updatedMemberships indexOfObject:event.data.spaceId] == NSNotFound) {
                [updatedMemberships addObject:event.data.spaceId];
            }
                                      
            *remove = updatedMemberships.count == spaces.count;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            XCTAssertEqualObjects(event.data.event, @"update");
            XCTAssertNotNil(event.data.updated);
            XCTAssertNotNil(event.data.timestamp);
                                      
            if (updatedMemberships.count == spaces.count) {
                XCTAssertNotEqual([updatedMemberships indexOfObject:spaces[0][@"id"]], NSNotFound);
                XCTAssertNotEqual([updatedMemberships indexOfObject:spaces[1][@"id"]], NSNotFound);
                handler();
            }
#pragma GCC diagnostic pop
        }];
        
        self.client1.manageMemberships().userId(users[0][@"id"])
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .update(@[
                @{ @"spaceId": spaces[0][@"id"], @"custom": customs[0] },
                @{ @"spaceId": spaces[1][@"id"], @"custom": customs[1] }
            ])
            .performWithCompletion(^(PNManageMembershipsStatus *status) { });
    }];
}

- (void)testUpdate_ShouldTriggerUpdateEventOnSpaceChannel_WhenMembershipUpdated {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    NSString *channel = spaces[0][@"id"];
    NSArray<NSDictionary *> *customs = @[
        @{ @"user-membership-custom": [NSUUID UUID].UUIDString },
        @{ @"user-membership-custom": [NSUUID UUID].UUIDString }
    ];
    [self.client2 addListener:self];
    
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil];
    [self subscribeOnObjectChannels:@[channel]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:self.client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            *remove = YES;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            XCTAssertEqualObjects(event.data.event, @"update");
            XCTAssertEqualObjects(event.data.spaceId, spaces[0][@"id"]);
            XCTAssertNotNil(event.data.updated);
            XCTAssertNotNil(event.data.timestamp);
                                      
            handler();
#pragma GCC diagnostic pop
        }];
        
        self.client1.manageMemberships().userId(users[0][@"id"]).update(@[
                @{ @"spaceId": spaces[0][@"id"], @"custom": customs[0] },
                @{ @"spaceId": spaces[1][@"id"], @"custom": customs[1] }
            ])
            .performWithCompletion(^(PNManageMembershipsStatus *status) { });
    }];
}

 - (void)testUpdate_ShouldFail_WhenUserDoesntHaveMembershipWithTargetSpaces {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    NSArray<NSDictionary *> *customs = @[
        @{ @"user-membership-custom": [NSUUID UUID].UUIDString },
        @{ @"user-membership-custom": [NSUUID UUID].UUIDString }
    ];
    
   
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMemberships().userId(users[0][@"id"])
            .includeFields(PNMembershipCustomField)
            .update(@[
                @{ @"spaceId": spaces[0][@"id"], @"custom": customs[0] },
                @{ @"spaceId": spaces[1][@"id"], @"custom": customs[1] }
            ])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 400);
                handler();
            });
    }];
}


#pragma mark - Tests :: Delete

- (void)testDelete_ShouldDelete_WhenMembershipExists {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMemberships().userId(users[0][@"id"])
            .includeFields(PNMembershipCustomField)
            .remove(@[ spaces[0][@"id"] ])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertEqual(status.data.memberships.count, 1);
                XCTAssertEqualObjects(status.data.memberships[0].spaceId, spaces[1][@"id"]);
                XCTAssertNil(status.data.memberships[0].space);
                
                handler();
            });
    }];
}

- (void)testDelete_ShouldUpdateAndReturnSpaceInformation_WhenSpaceAndSpaceCustomFlagsSet {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMemberships().userId(users[0][@"id"])
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .remove(@[ spaces[0][@"id"] ])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertEqual(status.data.memberships.count, 1);
                XCTAssertNotNil(status.data.memberships[0].space);
                XCTAssertEqualObjects(status.data.memberships[0].space.identifier, spaces[1][@"id"]);
                XCTAssertEqualObjects(status.data.memberships[0].space.custom, spaces[1][@"custom"]);
                
                handler();
            });
    }];
}

- (void)testDelete_ShouldTriggerDeleteEventOnUserChannel_WhenMembershipRemoved {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    NSMutableArray *deletedMemberships = [NSMutableArray new];
    NSString *channel = users[0][@"id"];
    [self.client2 addListener:self];
    
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil];
    [self subscribeOnObjectChannels:@[channel]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:self.client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            if ([deletedMemberships indexOfObject:event.data.spaceId] == NSNotFound) {
                [deletedMemberships addObject:event.data.spaceId];
            }
                                      
            *remove = deletedMemberships.count == spaces.count;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertNotNil(event.data.timestamp);
                                      
            if (deletedMemberships.count == spaces.count) {
                XCTAssertNotEqual([deletedMemberships indexOfObject:spaces[0][@"id"]], NSNotFound);
                XCTAssertNotEqual([deletedMemberships indexOfObject:spaces[1][@"id"]], NSNotFound);
                handler();
            }
#pragma GCC diagnostic pop
        }];
        
        self.client1.manageMemberships().userId(users[0][@"id"])
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .remove(@[ spaces[0][@"id"], spaces[1][@"id"] ])
            .performWithCompletion(^(PNManageMembershipsStatus *status) { });
    }];
}

- (void)testDelete_ShouldTriggerDeleteEventOnSpaceChannel_WhenMembershipRemoved {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    NSString *channel = spaces[0][@"id"];
    [self.client2 addListener:self];
    
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil];
    [self subscribeOnObjectChannels:@[channel]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:self.client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            *remove = YES;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.spaceId, spaces[0][@"id"]);
            XCTAssertNotNil(event.data.timestamp);
                                      
            handler();
#pragma GCC diagnostic pop
        }];
        
        self.client1.manageMemberships().userId(users[0][@"id"])
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .remove(@[ spaces[0][@"id"], spaces[1][@"id"] ])
            .performWithCompletion(^(PNManageMembershipsStatus *status) { });
    }];
}


#pragma mark - Tests :: Fetch

- (void)testFetch_ShouldFetch_WhenCalledWithDefauls {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    NSMutableArray *customs = [NSMutableArray new];
    
    for (NSUInteger spaceIdx = 0; spaceIdx < spaces.count; spaceIdx++) {
        [customs addObject:@{ @"user-membership-custom": [NSUUID UUID].UUIDString }];
    }
    
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:customs];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchMemberships().userId(users[0][@"id"])
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.memberships.count, spaces.count);
                XCTAssertEqual(result.data.totalCount, 0);
                
                handler();
            });
    }];
}

- (void)testFetch_ShouldFetchLimited_WhenCalledWithLimit {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    NSMutableArray *customs = [NSMutableArray new];
    NSUInteger expectedCount = 2;
    
    for (NSUInteger spaceIdx = 0; spaceIdx < spaces.count; spaceIdx++) {
        [customs addObject:@{ @"user-membership-custom": [NSUUID UUID].UUIDString }];
    }
    
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:customs];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchMemberships().userId(users[0][@"id"]).limit(expectedCount)
            .includeFields(PNMembershipCustomField).includeCount(YES)
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.memberships.count, expectedCount);
                XCTAssertEqual(result.data.totalCount, spaces.count);
                XCTAssertNotNil(result.data.memberships[0].custom);
                
                handler();
            });
    }];
}

- (void)testFetch_ShouldFetchNextPage_WhenCalledWithStart {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    __block NSString *next = nil;
    
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchMemberships().userId(users[0][@"id"]).limit(spaces.count - 2)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertEqual(result.data.memberships.count, spaces.count - 2);
                next = result.data.next;
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchMemberships().userId(users[0][@"id"]).start(next).includeCount(YES)
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.memberships.count, 2);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Member events

- (void)testUser_ShouldTriggerDeleteEventOnSpaceChannel_WhenUserFromMembershipsDeleted {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    NSString *channel = spaces[0][@"id"];
    [self.client2 addListener:self];
    
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil];
    [self subscribeOnObjectChannels:@[channel]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addUserHandlerForClient:self.client2
                            withBlock:^(PubNub *client, PNUserEventResult *event, BOOL *remove) {
            *remove = YES;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.identifier, users[0][@"id"]);
            XCTAssertNotNil(event.data.timestamp);
                                
            handler();
#pragma GCC diagnostic pop
        }];
        
        self.client1.deleteUser().userId(users[0][@"id"])
            .performWithCompletion(^(PNAcknowledgmentStatus *status) { });
    }];
}

#pragma mark -


@end
