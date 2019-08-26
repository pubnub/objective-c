/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNObjectsTestCase.h"
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Test interface declaration

@interface PNMemberIntegrationTest : PNObjectsTestCase


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNMemberIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    if ([self.name rangeOfString:@"testFetch"].location != NSNotFound) {
        self.testUsersCount = 6;
    } else {
        self.testUsersCount = 2;
    }
    
    self.testSpacesCount = 1;
    
    if ([self.name rangeOfString:@"testFetch"].location != NSNotFound ||
        ([self.name rangeOfString:@"testDelete"].location != NSNotFound &&
         [self.name rangeOfString:@"Fail"].location == NSNotFound) ) {
            
        [self cleanUpUserObjects];
        [self cleanUpSpaceObjects];
    }
}


#pragma mark - Tests :: Create

- (void)testCreate_ShouldCreateAddMembers_WhenCalled {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *members = [self createTestUsers];
    NSArray<NSDictionary *> *customs = @[
        @{ @"user-member-custom": [NSUUID UUID].UUIDString },
        @{ @"user-member-custom": [NSUUID UUID].UUIDString }
    ];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMembers().spaceId(spaces[0][@"id"])
            .includeFields(PNMemberCustomField)
            .add(@[
                @{ @"userId": members[0][@"id"], @"custom": customs[0] },
                @{ @"userId": members[1][@"id"], @"custom": customs[1] }
            ])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                NSArray<PNMember *> *addedMembers = status.data.members;
                
                for (PNMember *addedMember in addedMembers) {
                    for (NSUInteger memberIdx = 0; memberIdx < members.count; memberIdx++) {
                        NSDictionary *member = members[memberIdx];
                        
                        if ([addedMember.userId isEqualToString:member[@"id"]]) {
                            XCTAssertEqualObjects(addedMember.custom, customs[memberIdx]);
                            break;
                        }
                    }
                }
                
                handler();
            });
    }];
}

- (void)testCreate_ShouldCreateAndReturnUserInformation_WhenUserAndUserCustomFlagsSet {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *members = [self createTestUsers];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMembers().spaceId(spaces[0][@"id"])
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .add(@[@{ @"userId": members[0][@"id"] }, @{ @"userId": members[1][@"id"] }])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                NSArray<PNMember *> *addedMembers = status.data.members;
                
                for (PNMember *addedMember in addedMembers) {
                    XCTAssertNotNil(addedMember.user);
                    
                    for (NSDictionary *member in members) {
                        if ([addedMember.user.identifier isEqualToString:member[@"id"]]) {
                            XCTAssertEqualObjects(addedMember.user.custom, member[@"custom"]);
                            break;
                        }
                    }
                }
                
                handler();
            });
    }];
}

- (void)testCreate_ShouldTriggerCreateEventOnSpaceChannel_WhenNewMembersAdded {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *members = [self createTestUsers];
    NSMutableArray *createdMemberships = [NSMutableArray new];
    NSString *channel = spaces[0][@"id"];
    [self.client2 addListener:self];
    
    
    [self subscribeOnObjectChannels:@[channel]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:self.client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            if ([createdMemberships indexOfObject:event.data.userId] == NSNotFound) {
                [createdMemberships addObject:event.data.userId];
            }
                                      
            *remove = createdMemberships.count == members.count;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            XCTAssertEqualObjects(event.data.event, @"create");
            XCTAssertNotNil(event.data.created);
            XCTAssertNotNil(event.data.timestamp);
                                      
            if (createdMemberships.count == members.count) {
                XCTAssertNotEqual([createdMemberships indexOfObject:members[0][@"id"]], NSNotFound);
                XCTAssertNotEqual([createdMemberships indexOfObject:members[1][@"id"]], NSNotFound);
                handler();
            }
#pragma GCC diagnostic pop
        }];
        
        self.client1.manageMembers().spaceId(spaces[0][@"id"])
            .add(@[@{ @"userId": members[0][@"id"] }, @{ @"userId": members[1][@"id"] }])
            .performWithCompletion(^(PNManageMembersStatus *status) { });
    }];
}

- (void)testCreate_ShouldTriggerCreateEventOnUserChannel_WhenNewMemberAdded {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *members = [self createTestUsers];
    NSString *channel = members[0][@"id"];
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
        
        self.client1.manageMembers().spaceId(spaces[0][@"id"])
            .add(@[@{ @"userId": members[0][@"id"] }, @{ @"userId": members[1][@"id"] }])
            .performWithCompletion(^(PNManageMembersStatus *status) { });
    }];
}

 - (void)testCreate_ShouldFail_WhenSpacesAlreadyHasTargetMembersInList {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *members = [self createTestUsers];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMembers().spaceId(spaces[0][@"id"])
            .add(@[ @{ @"userId": members[0][@"id"] }, @{ @"userId": members[1][@"id"] }])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                XCTAssertFalse(status.isError);
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMembers().spaceId(spaces[0][@"id"])
            .add(@[ @{ @"userId": members[0][@"id"] }, @{ @"userId": members[1][@"id"] }])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 400);
                handler();
            });
    }];
}


#pragma mark - Tests :: Update

- (void)testUpdate_ShouldUpdate_WhenExistingMembers {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *members = [self createTestUsers];
    NSArray<NSDictionary *> *customs = @[
        @{ @"user-member-custom": [NSUUID UUID].UUIDString },
        @{ @"user-member-custom": [NSUUID UUID].UUIDString }
    ];
    NSArray<NSDictionary *> *expectedCustoms = @[
        @{ @"user-member-custom": [NSUUID UUID].UUIDString },
        @{ @"user-member-custom": [NSUUID UUID].UUIDString }
    ];
    
    
    [self addMembers:members toSpaces:spaces withCustoms:customs];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMembers().spaceId(spaces[0][@"id"])
            .includeFields(PNMemberCustomField)
            .update(@[
                @{ @"userId": members[0][@"id"], @"custom": expectedCustoms[0] },
                @{ @"userId": members[1][@"id"], @"custom": expectedCustoms[1] }
            ])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                NSArray<PNMember *> *updatedMembers = status.data.members;
                
                for (PNMember *updatedMember in updatedMembers) {
                    for (NSUInteger memberIdx = 0; memberIdx < members.count; memberIdx++) {
                        NSDictionary *member = members[memberIdx];
                        
                        if ([updatedMember.userId isEqualToString:member[@"id"]]) {
                            XCTAssertEqualObjects(updatedMember.custom, expectedCustoms[memberIdx]);
                            break;
                        }
                    }
                }
                
                handler();
            });
    }];
}

- (void)testUpdate_ShouldUpdateAndReturnUserInformation_WhenUserAndUserCustomFlagsSet {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *members = [self createTestUsers];
    NSArray<NSDictionary *> *customs = @[
        @{ @"user-member-custom": [NSUUID UUID].UUIDString },
        @{ @"user-member-custom": [NSUUID UUID].UUIDString }
    ];
    
    
    [self addMembers:members toSpaces:spaces withCustoms:nil];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMembers().spaceId(spaces[0][@"id"])
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .update(@[
                @{ @"userId": members[0][@"id"], @"custom": customs[0] },
                @{ @"userId": members[1][@"id"], @"custom": customs[1] }
            ])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                NSArray<PNMember *> *updatedMembers = status.data.members;
                
                for (PNMember *updatedMember in updatedMembers) {
                    XCTAssertNotNil(updatedMember.user);
                    
                    for (NSDictionary *member in members) {
                        if ([updatedMember.user.identifier isEqualToString:member[@"id"]]) {
                            XCTAssertEqualObjects(updatedMember.user.custom, member[@"custom"]);
                            break;
                        }
                    }
                }
                
                handler();
            });
    }];
}

- (void)testUpdate_ShouldTriggerUpdateEventOnSpaceChannel_WhenMembersUpdated {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *members = [self createTestUsers];
    NSMutableArray *updatedMemberships = [NSMutableArray new];
    NSString *channel = spaces[0][@"id"];
    NSArray<NSDictionary *> *customs = @[
        @{ @"user-member-custom": [NSUUID UUID].UUIDString },
        @{ @"user-member-custom": [NSUUID UUID].UUIDString }
    ];
    [self.client2 addListener:self];
    
    
    [self addMembers:members toSpaces:spaces withCustoms:nil];
    [self subscribeOnObjectChannels:@[channel]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:self.client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            if ([updatedMemberships indexOfObject:event.data.userId] == NSNotFound) {
                [updatedMemberships addObject:event.data.userId];
            }
                                   
            *remove = updatedMemberships.count == members.count;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            XCTAssertEqualObjects(event.data.event, @"update");
            XCTAssertNotNil(event.data.updated);
            XCTAssertNotNil(event.data.timestamp);
                                      
            if (updatedMemberships.count == members.count) {
                XCTAssertNotEqual([updatedMemberships indexOfObject:members[0][@"id"]], NSNotFound);
                XCTAssertNotEqual([updatedMemberships indexOfObject:members[1][@"id"]], NSNotFound);
                handler();
            }
#pragma GCC diagnostic pop
        }];
        
        self.client1.manageMembers().spaceId(spaces[0][@"id"]).update(@[
                @{ @"userId": members[0][@"id"], @"custom": customs[0] },
                @{ @"userId": members[1][@"id"], @"custom": customs[1] }
            ])
            .performWithCompletion(^(PNManageMembersStatus *status) { });
    }];
}

- (void)testUpdate_ShouldTriggerUpdateEventOnUserChannel_WhenMembersUpdated {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *members = [self createTestUsers];
    NSArray<NSDictionary *> *customs = @[
        @{ @"user-member-custom": [NSUUID UUID].UUIDString },
        @{ @"user-member-custom": [NSUUID UUID].UUIDString }
    ];
    NSString *channel = members[0][@"id"];
    [self.client2 addListener:self];
    
    
    [self addMembers:members toSpaces:spaces withCustoms:nil];
    [self subscribeOnObjectChannels:@[channel]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:self.client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
                                      
            *remove = YES;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            XCTAssertEqualObjects(event.data.event, @"update");
            XCTAssertEqualObjects(event.data.userId, members[0][@"id"]);
            XCTAssertNotNil(event.data.updated);
            XCTAssertNotNil(event.data.timestamp);
                                      
            handler();
#pragma GCC diagnostic pop
        }];
        
        self.client1.manageMembers().spaceId(spaces[0][@"id"])
            .update(@[
                @{ @"userId": members[0][@"id"], @"custom": customs[0] },
                @{ @"userId": members[1][@"id"], @"custom": customs[1] }
            ])
            .performWithCompletion(^(PNManageMembersStatus *status) { });
    }];
}

 - (void)testUpdate_ShouldFail_WhenTargetUsersNotSpaceMembers {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *members = [self createTestUsers];
    NSArray<NSDictionary *> *customs = @[
        @{ @"user-member-custom": [NSUUID UUID].UUIDString },
        @{ @"user-member-custom": [NSUUID UUID].UUIDString }
    ];
    
   
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMembers().spaceId(spaces[0][@"id"])
            .update(@[
                @{ @"userId": members[0][@"id"], @"custom": customs[0] },
                @{ @"userId": members[1][@"id"], @"custom": customs[1] }
            ])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 400);
                handler();
            });
    }];
}


#pragma mark - Tests :: Delete

- (void)testDelete_ShouldDelete_WhenMemberExists {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *members = [self createTestUsers];
    
    
    [self addMembers:members toSpaces:spaces withCustoms:nil];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMembers().spaceId(spaces[0][@"id"])
            .remove(@[ members[0][@"id"] ])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertEqual(status.data.members.count, 1);
                XCTAssertEqualObjects(status.data.members[0].userId, members[1][@"id"]);
                XCTAssertNil(status.data.members[0].user);
                
                handler();
            });
    }];
}

- (void)testDelete_ShouldDeleteAndReturnRestOfUsersInformation_WhenUserAndUserCustomFlagsSet {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *members = [self createTestUsers];
    
    
    [self addMembers:members toSpaces:spaces withCustoms:nil];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.manageMembers().spaceId(spaces[0][@"id"])
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .remove(@[ members[0][@"id"] ])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertEqual(status.data.members.count, 1);
                XCTAssertNotNil(status.data.members[0].user);
                XCTAssertEqualObjects(status.data.members[0].user.identifier, members[1][@"id"]);
                XCTAssertEqualObjects(status.data.members[0].user.custom, members[1][@"custom"]);
                
                handler();
            });
    }];
}

- (void)testDelete_ShouldTriggerDeleteEventOnSpaceChannel_WhenMemberRemoved {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *members = [self createTestUsers];
    NSMutableArray *deletedMemberships = [NSMutableArray new];
    NSString *channel = spaces[0][@"id"];
    [self.client2 addListener:self];
    
    
    [self addMembers:members toSpaces:spaces withCustoms:nil];
    [self subscribeOnObjectChannels:@[channel]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:self.client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            if ([deletedMemberships indexOfObject:event.data.userId] == NSNotFound) {
                [deletedMemberships addObject:event.data.userId];
            }
                                      
            *remove = deletedMemberships.count == members.count;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertNotNil(event.data.timestamp);
                                      
            if (deletedMemberships.count == members.count) {
                XCTAssertNotEqual([deletedMemberships indexOfObject:members[0][@"id"]], NSNotFound);
                XCTAssertNotEqual([deletedMemberships indexOfObject:members[1][@"id"]], NSNotFound);
                handler();
            }
#pragma GCC diagnostic pop
        }];
        
        self.client1.manageMembers().spaceId(spaces[0][@"id"])
            .remove(@[ members[0][@"id"], members[1][@"id"] ])
            .performWithCompletion(^(PNManageMembersStatus *status) { });
    }];
}

- (void)testDelete_ShouldTriggerDeleteEventOnUserChannel_WhenMemberRemoved {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *members = [self createTestUsers];
    NSString *channel = members[0][@"id"];
    [self.client2 addListener:self];
    
    
    [self addMembers:members toSpaces:spaces withCustoms:nil];
    [self subscribeOnObjectChannels:@[channel]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:self.client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
                            
            *remove = YES;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.userId, members[0][@"id"]);
            XCTAssertNotNil(event.data.timestamp);
                                      
            handler();
#pragma GCC diagnostic pop
        }];
        
        self.client1.manageMembers().spaceId(spaces[0][@"id"])
            .remove(@[ members[0][@"id"], members[1][@"id"] ])
            .performWithCompletion(^(PNManageMembersStatus *status) { });
    }];
}


#pragma mark - Tests :: Fetch

- (void)testFetch_ShouldFetch_WhenCalledWithDefauls {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *members = [self createTestUsers];
    NSMutableArray *customs = [NSMutableArray new];
    
    for (NSUInteger memberIdx = 0; memberIdx < members.count; memberIdx++) {
        [customs addObject:@{ @"user-member-custom": [NSUUID UUID].UUIDString }];
    }
    
    
    [self addMembers:members toSpaces:spaces withCustoms:nil];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchMembers().spaceId(spaces[0][@"id"])
            .performWithCompletion(^(PNFetchMembersResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.members.count, members.count);
                XCTAssertEqual(result.data.totalCount, 0);
                
                handler();
            });
    }];
}

- (void)testFetch_ShouldFetchLimited_WhenCalledWithLimit {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *members = [self createTestUsers];
    NSMutableArray *customs = [NSMutableArray new];
    NSUInteger expectedCount = 2;
    
    for (NSUInteger memberIdx = 0; memberIdx < members.count; memberIdx++) {
        [customs addObject:@{ @"user-member-custom": [NSUUID UUID].UUIDString }];
    }
    
    
    [self addMembers:members toSpaces:spaces withCustoms:nil];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchMembers().spaceId(spaces[0][@"id"]).limit(expectedCount)
            .includeFields(PNMemberCustomField).includeCount(YES)
            .performWithCompletion(^(PNFetchMembersResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.members.count, expectedCount);
                XCTAssertEqual(result.data.totalCount, members.count);
                XCTAssertNotNil(result.data.members[0].custom);
                
                handler();
            });
    }];
}

- (void)testFetch_ShouldFetchNextPage_WhenCalledWithStart {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *members = [self createTestUsers];
    __block NSString *next = nil;
    
    
    [self addMembers:members toSpaces:spaces withCustoms:nil];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchMembers().spaceId(spaces[0][@"id"]).limit(members.count - 2)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchMembersResult *result, PNErrorStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertEqual(result.data.members.count, members.count - 2);
                next = result.data.next;
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchMembers().spaceId(spaces[0][@"id"]).start(next).includeCount(YES)
            .performWithCompletion(^(PNFetchMembersResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.members.count, 2);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Member events

- (void)testUser_ShouldTriggerUpdateEventOnSpaceChannel_WhenUserFromSpaceMembersUpdated {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    NSString *channel = spaces[0][@"id"];
    NSArray<NSDictionary *> *customs = @[
        @{ @"user-membership-custom": [NSUUID UUID].UUIDString },
        @{ @"user-membership-custom": [NSUUID UUID].UUIDString }
    ];
    [self.client2 addListener:self];
    
    
    [self addMembers:users toSpaces:spaces withCustoms:nil];
    [self subscribeOnObjectChannels:@[channel]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addUserHandlerForClient:self.client2
                            withBlock:^(PubNub *client, PNUserEventResult *event, BOOL *remove) {
            *remove = YES;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            XCTAssertEqualObjects(event.data.event, @"update");
            XCTAssertEqualObjects(event.data.identifier, users[0][@"id"]);
            XCTAssertNotNil(event.data.updated);
            XCTAssertNotNil(event.data.timestamp);
                                
            handler();
#pragma GCC diagnostic pop
        }];
        
        self.client1.updateUser().userId(users[0][@"id"]).custom(customs[0])
            .performWithCompletion(^(PNUpdateUserStatus *status) { });
    }];
}

- (void)testUser_ShouldTriggerDeleteEventOnSpaceChannel_WhenUserFromSpaceMembersRemoved {
    NSArray<NSDictionary *> *spaces = [self createTestSpaces];
    NSArray<NSDictionary *> *users = [self createTestUsers];
    NSString *channel = spaces[0][@"id"];
    [self.client2 addListener:self];
    
    
    [self addMembers:users toSpaces:spaces withCustoms:nil];
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
