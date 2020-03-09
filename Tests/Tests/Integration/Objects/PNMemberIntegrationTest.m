/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import <PubNub/PNHelpers.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNMemberIntegrationTest : PNRecordableTestCase


#pragma mark - Misc

/**
 * @brief Flatten members objects by extracting from it name of user and creation date.
 *
 * @param members List of members which should be flattened.
 *
 * @return List of dictionaries which contain name of user and member addition date.
 */
- (NSArray<NSDictionary *> *)flattenedMembers:(NSArray<PNMember *> *)members;

/**
 * @brief Sort provided list of members.
 *
 * @param members List of members which should be stored.
 * @param sortDescriptors Descriptors which should be used during filter.
 *
 * @return Sorted list of members.
 */
- (NSArray<PNMember *> *)members:(NSArray<PNMember *> *)members
                      sortedWith:(NSArray<NSSortDescriptor *> *)sortDescriptors;


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNMemberIntegrationTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    [self completePubNubConfiguration:self.client];
    [self removeAllObjects];
}


#pragma mark - Tests :: Builder pattern-based add members

- (void)testItShouldAddMembersAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:nil];
    NSArray<NSDictionary *> *memberUsers = @[
        @{
            @"userId": users[0].identifier,
            @"custom": @{ @"user-member-custom": [@[users[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] }
        },
        @{
            @"userId": users[1].identifier,
            @"custom": @{ @"user-member-custom": [@[users[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
        }
    ];
    __block NSArray *members = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberCustomField)
            .add(memberUsers)
            .performWithCompletion(^(PNManageMembersStatus *status) {
                members = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(members);
                XCTAssertEqual(status.operation, PNManageMembersOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                for (PNMember *member in members) {
                    for (NSUInteger memberIdx = 0; memberIdx < users.count; memberIdx++) {
                        PNUser *user = users[memberIdx];
                        
                        if ([member.userId isEqualToString:user.identifier]) {
                            XCTAssertEqualObjects(member.custom, memberUsers[memberIdx][@"custom"]);
                            break;
                        }
                    }
                }
                
                handler();
            });
    }];
    
    [self deleteSpace:spaces.firstObject.identifier memberObjects:members usingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldAddMembersAndReturnFilteredUserInformationWhenFilterIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(users.lastObject.name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"user.name like '%@*'",
                                  [users.lastObject.name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    NSArray<NSDictionary *> *memberUsers = @[
        @{ @"userId": users[0].identifier },
        @{ @"userId": users[1].identifier }
    ];
    __block NSArray<PNMember *> *members = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .includeCount(YES)
            .filter(filterExpression)
            .add(memberUsers)
            .performWithCompletion(^(PNManageMembersStatus *status) {
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                members = status.data.members;
                XCTAssertEqual(status.data.totalCount, 1);
                XCTAssertNil(status.data.prev);
                XCTAssertNotNil(status.data.next);
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(members);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                  NSNotFound);
                XCTAssertNotNil(members.lastObject.user);
                XCTAssertEqualObjects(members.lastObject.user.custom, users.lastObject.custom);
                
                handler();
            });
    }];
    
    [self deleteSpace:spaces.firstObject.identifier memberObjects:members usingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldAddMembersAndReturnSortedUserInformationWhenSortIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:4 usingClient:nil];
    NSString *expectedSort = @"user.name%3Adesc";
    NSArray<NSDictionary *> *memberUsers = @[
        @{ @"userId": users[0].identifier },
        @{ @"userId": users[1].identifier },
        @{ @"userId": users[2].identifier },
        @{ @"userId": users[3].identifier }
    ];
    __block NSArray<PNMember *> *members = nil;
    
    NSArray<PNUser *> *expectedMembersUserOrder = [users sortedArrayUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]
    ]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .includeCount(YES)
            .sort(@[@"user.name:desc"])
            .add(memberUsers)
            .performWithCompletion(^(PNManageMembersStatus *status) {
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                members = status.data.members;
                XCTAssertNil(status.data.prev);
                XCTAssertNotNil(status.data.next);
                XCTAssertNotNil(members);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);
                
                for (NSUInteger fetchedMemberIdx = 0; fetchedMemberIdx < members.count; fetchedMemberIdx++) {
                    XCTAssertEqualObjects(members[fetchedMemberIdx].userId,
                                          expectedMembersUserOrder[fetchedMemberIdx].identifier);
                }
                
                XCTAssertNotEqualObjects([members valueForKeyPath:@"user.name"],
                                         [users valueForKeyPath:@"name"]);
                
                handler();
            });
    }];
    
    [self deleteSpace:spaces.firstObject.identifier memberObjects:members usingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldAddMembersAndReturnUserInformationWhenUserIncludeFlagIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:nil];
    NSArray<NSDictionary *> *memberUsers = @[
        @{ @"userId": users[0].identifier },
        @{ @"userId": users[1].identifier }
    ];
    __block NSArray *members = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .add(memberUsers)
            .performWithCompletion(^(PNManageMembersStatus *status) {
                members = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(members);
                
                for (PNMember *member in members) {
                    XCTAssertNotNil(member.user);
                    
                    for (NSUInteger userIdx = 0; userIdx < users.count; userIdx++) {
                        PNUser *user = users[userIdx];
                        
                        if ([member.user.identifier isEqualToString:user.identifier]) {
                            XCTAssertEqualObjects(member.user.custom, user.custom);
                            break;
                        }
                    }
                }
                
                handler();
            });
    }];
    
    [self deleteSpace:spaces.firstObject.identifier memberObjects:members usingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldAddMembersAndTriggerCreateEventOnSpaceChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:client1];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:client1];
    NSMutableArray *createdMembers = [NSMutableArray new];
    NSString *channel = spaces.firstObject.identifier;
    NSArray<NSDictionary *> *memberUsers = @[
        @{ @"userId": users[0].identifier },
        @{ @"userId": users[1].identifier }
    ];
    __block NSArray *members = nil;
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"create");
            XCTAssertNotNil(event.data.created);
            XCTAssertNotNil(event.data.timestamp);
            
            if ([createdMembers indexOfObject:event.data.userId] == NSNotFound) {
                [createdMembers addObject:event.data.userId];
            }
            
            if (createdMembers.count == users.count) {
                XCTAssertNotEqual([createdMembers indexOfObject:users[0].identifier], NSNotFound);
                XCTAssertNotEqual([createdMembers indexOfObject:users[1].identifier], NSNotFound);
                *remove = YES;
                
                handler();
            }
        }];
        
        client1.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .add(memberUsers)
            .performWithCompletion(^(PNManageMembersStatus *status) {
                members = status.data.members;
                XCTAssertFalse(status.isError);
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
    
    
    [self verifySpaceMembersCount:spaces.firstObject.identifier shouldEqualTo:users.count usingClient:client1];
    
    [self deleteSpace:spaces.firstObject.identifier memberObjects:members usingClient:client1];
    [self deleteUserObjectsUsingClient:client1];
    [self deleteSpaceObjectsUsingClient:client1];
}

- (void)testItShouldAddMembersAndTriggerCreateEventOnUserChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:client1];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:client1];
    NSString *channel = users.firstObject.identifier;
    NSArray<NSDictionary *> *memberUsers = @[
        @{ @"userId": users[0].identifier },
        @{ @"userId": users[1].identifier }
    ];
    __block NSArray *members = nil;
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"create");
            XCTAssertNotNil(event.data.created);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;
            
            handler();
        }];
        
        client1.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .add(memberUsers)
            .performWithCompletion(^(PNManageMembersStatus *status) {
                members = status.data.members;
                XCTAssertFalse(status.isError);
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
    
    [self deleteSpace:spaces.firstObject.identifier memberObjects:members usingClient:client1];
    [self deleteUserObjectsUsingClient:client1];
    [self deleteSpaceObjectsUsingClient:client1];
}

- (void)testItShouldNotAddMembersWhenSpaceAlreadyHasTargetUsersAsMembers {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:nil];
    NSArray<NSDictionary *> *memberUsers = @[
        @{ @"userId": users[0].identifier },
        @{ @"userId": users[1].identifier }
    ];
    __block NSArray *members = nil;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .add(memberUsers)
            .performWithCompletion(^(PNManageMembersStatus *status) {
                members = status.data.members;
                XCTAssertFalse(status.isError);
                handler();
            });
    }];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .add(@[memberUsers.firstObject])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 400);
                
                if (!retried) {
                    retried = YES;
                    [status retry];
                } else {
                    handler();
                }
            });
    }];
    
    [self verifySpaceMembersCount:spaces.firstObject.identifier shouldEqualTo:users.count usingClient:nil];
    
    [self deleteSpace:spaces.firstObject.identifier memberObjects:members usingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}


#pragma mark - Tests :: Builder pattern-based update members

- (void)testItShouldUpdateMembersAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:nil];
    NSArray<NSDictionary *> *membersCustom = @[
        @{ @"user-member-custom": [@[users[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"user-member-custom": [@[users[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    NSArray<NSDictionary *> *expectedMembersCustom = @[
        @{ @"user-member-custom": [@[users[0].identifier, @"custom", @"data", @"3"] componentsJoinedByString:@"-"] },
        @{ @"user-member-custom": [@[users[1].identifier, @"custom", @"data", @"4"] componentsJoinedByString:@"-"] }
    ];
    
    [self addMembers:users toSpaces:spaces withCustoms:membersCustom usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberCustomField)
            .update(@[
                @{ @"userId": users[0].identifier, @"custom": expectedMembersCustom[0] },
                @{ @"userId": users[1].identifier, @"custom": expectedMembersCustom[1] },
            ])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                NSArray<PNMember *> *members = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(members);
                XCTAssertEqual(status.operation, PNManageMembersOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                for (PNMember *member in members) {
                    for (NSUInteger userIdx = 0; userIdx < users.count; userIdx++) {
                        PNUser *user = users[userIdx];
                        
                        if ([member.userId isEqualToString:user.identifier]) {
                            XCTAssertEqualObjects(member.custom, expectedMembersCustom[userIdx]);
                            break;
                        }
                    }
                }
                
                handler();
            });
    }];

    [self deleteSpace:spaces.firstObject.identifier membersObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldUpdateMembersAndReturnFilteredUserInformationWhenFilterIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(users.lastObject.name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"user.name like '%@*'",
                                  [users.lastObject.name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    NSArray<NSDictionary *> *membershipCustom = @[
        @{ @"user-member-custom": [@[users[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"user-member-custom": [@[users[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    
    [self addMembers:users toSpaces:spaces withCustoms:nil usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .includeCount(YES)
            .filter(filterExpression)
            .update(@[
                @{ @"userId": users[0].identifier, @"custom": membershipCustom[0] },
                @{ @"userId": users[1].identifier, @"custom": membershipCustom[1] },
            ])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                NSArray<PNMember *> *members = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(members);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                  NSNotFound);
                XCTAssertNotNil(members.lastObject.user);
                XCTAssertEqualObjects(members.lastObject.user.custom, users.lastObject.custom);
                
                handler();
            });
    }];
    
    [self deleteSpace:spaces.firstObject.identifier membersObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldUpdateMembersAndReturnSortedUserInformationWhenSortIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:4 usingClient:nil];
    NSString *expectedSort = @"user.name%3Adesc,created";
    NSArray<NSDictionary *> *membershipCustom = @[
        @{ @"user-member-custom": [@[users[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"user-member-custom": [@[users[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    
    NSArray<PNMember *> *members = [self addMembers:users toSpaces:spaces withCustoms:nil
                                    userInformation:YES usingClient:nil];
    NSArray<PNMember *> *expectedMembersOrder = [self members:members sortedWith:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]
    ]];
    NSLog(@"INITIAL ORDER: %@", [members valueForKeyPath:@"user.name"]);
    NSLog(@"EXPECTED ORDER: %@", [expectedMembersOrder valueForKeyPath:@"user.name"]);
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .includeCount(YES)
            .sort(@[@"user.name:desc", @"created"])
            .update(@[
                @{ @"userId": users[0].identifier, @"custom": membershipCustom[0] },
                @{ @"userId": users[1].identifier, @"custom": membershipCustom[1] },
            ])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                NSArray<PNMember *> *fetchedMembers = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(fetchedMembers);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);

                for (NSUInteger fetchedMemberIdx = 0; fetchedMemberIdx < fetchedMembers.count; fetchedMemberIdx++) {
                    XCTAssertEqualObjects(fetchedMembers[fetchedMemberIdx].user.name,
                                          expectedMembersOrder[fetchedMemberIdx].user.name);
                }
                
                XCTAssertNotEqualObjects([fetchedMembers valueForKeyPath:@"user.name"],
                                         [members valueForKeyPath:@"user.name"]);
                
                handler();
            });
    }];
    
    [self deleteSpace:spaces.firstObject.identifier membersObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldUpdateMembersAndReturnUserInformationWhenUserIncludeFlagIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:nil];
    NSArray<NSDictionary *> *membershipCustom = @[
        @{ @"user-member-custom": [@[users[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"user-member-custom": [@[users[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    
    [self addMembers:users toSpaces:spaces withCustoms:nil usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .update(@[
                @{ @"userId": users[0].identifier, @"custom": membershipCustom[0] },
                @{ @"userId": users[1].identifier, @"custom": membershipCustom[1] },
            ])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                NSArray<PNMember *> *members = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(members);
                
                for (PNMember *member in members) {
                    XCTAssertNotNil(member.user);
                    
                    for (PNUser *user in users) {
                        if ([member.user.identifier isEqualToString:user.identifier]) {
                            XCTAssertEqualObjects(member.user.custom, user.custom);
                            break;
                        }
                    }
                }
                
                handler();
            });
    }];
    
    [self deleteSpace:spaces.firstObject.identifier membersObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldUpdateMembersAndTriggerUpdateEventOnSpaceChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:client1];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:client1];
    NSMutableArray *updatedMembers = [NSMutableArray new];
    NSString *channel = spaces.firstObject.identifier;
    NSArray<NSDictionary *> *membersCustom = @[
        @{ @"user-member-custom": [@[users[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"user-member-custom": [@[users[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    
    [self addMembers:users toSpaces:spaces withCustoms:nil usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"update");
            XCTAssertNotNil(event.data.updated);
            XCTAssertNotNil(event.data.timestamp);
            
            if ([updatedMembers indexOfObject:event.data.userId] == NSNotFound) {
                [updatedMembers addObject:event.data.userId];
            }
            
            if (updatedMembers.count == users.count) {
                XCTAssertNotEqual([updatedMembers indexOfObject:users[0].identifier], NSNotFound);
                XCTAssertNotEqual([updatedMembers indexOfObject:users[1].identifier], NSNotFound);
                *remove = YES;
                
                handler();
            }
        }];
        
        client1.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .update(@[
                @{ @"userId": users[0].identifier, @"custom": membersCustom[0] },
                @{ @"userId": users[1].identifier, @"custom": membersCustom[1] },
            ])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
    
    [self deleteSpace:spaces.firstObject.identifier membersObjectsUsingClient:client1];
    [self deleteUserObjectsUsingClient:client1];
    [self deleteSpaceObjectsUsingClient:client1];
}

- (void)testItShouldUpdateMembersAndTriggerUpdateEventOnUserChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:client1];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:client1];
    NSString *channel = users.firstObject.identifier;
    NSArray<NSDictionary *> *membersCustom = @[
        @{ @"user-member-custom": [@[users[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"user-member-custom": [@[users[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    
    [self addMembers:users toSpaces:spaces withCustoms:nil usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"update");
            XCTAssertEqualObjects(event.data.spaceId, spaces.firstObject.identifier);
            XCTAssertNotNil(event.data.updated);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;
            
            handler();
        }];
        
        client1.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .update(@[
                @{ @"userId": users[0].identifier, @"custom": membersCustom[0] },
                @{ @"userId": users[1].identifier, @"custom": membersCustom[1] },
            ])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
    
    [self deleteSpace:spaces.firstObject.identifier membersObjectsUsingClient:client1];
    [self deleteUserObjectsUsingClient:client1];
    [self deleteSpaceObjectsUsingClient:client1];
}

- (void)testItShouldNotUpdateMembersWhenSpaceNotHaveSpecifiedUsersAsMembers {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:nil];
    NSArray<NSDictionary *> *membersCustom = @[
        @{ @"user-member-custom": [@[users[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"user-member-custom": [@[users[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberCustomField)
            .update(@[
                @{ @"userId": users[0].identifier, @"custom": membersCustom[0] },
                @{ @"userId": users[1].identifier, @"custom": membersCustom[1] }
            ])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 400);
                handler();
            });
    }];
    
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}


#pragma mark - Tests :: Builder pattern-based delete members

/**
 * @brief To test 'retry' functionality
 *  'ItShouldDeleteMembersAndReceiveStatusWithExpectedOperationAndCategory.json' should
 *  be modified after cassette recording. Find first mention of member remove and copy paste
 *  4 entries which belong to it. For new entries change 'id' field to be different from source. For
 *  original response entry change status code to 404.
 */
- (void)testItShouldDeleteMembersAndReceiveStatusWithExpectedOperationAndCategory {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:nil];
    __block BOOL retried = NO;
    
    [self addMembers:users toSpaces:spaces withCustoms:nil usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberCustomField)
            .remove(@[users[0].identifier])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                if (!retried && !YHVVCR.cassette.isNewCassette) {
                    XCTAssertTrue(status.error);
                    XCTAssertEqual(status.operation, PNManageMembersOperation);
                    XCTAssertEqual(status.category, PNMalformedResponseCategory);

                    retried = YES;
                    [status retry];
                } else {
                    NSArray<PNMember *> *members = status.data.members;
                    XCTAssertFalse(status.isError);
                    XCTAssertNotNil(members);
                    XCTAssertEqual(members.count, 1);
                    XCTAssertEqualObjects(members.firstObject.userId, users[1].identifier);
                    XCTAssertEqual(status.operation, PNManageMembersOperation);
                    XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                    
                    [self deleteSpace:spaces.firstObject.identifier cachedMemberForUser:users[0].identifier];
                    
                    handler();
                }
            });
    }];

    [self deleteSpace:spaces.firstObject.identifier membersObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldDeleteMembersAndReturnFilteredUserInformationWhenFilterIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(users.lastObject.name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"user.name like '%@*'",
                                  [users.lastObject.name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    
    [self addMembers:users toSpaces:spaces withCustoms:nil usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .includeCount(YES)
            .filter(filterExpression)
            .remove(@[users[0].identifier])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                NSArray<PNMember *> *members = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(members);
                XCTAssertEqual(status.data.totalCount, 1);
                XCTAssertEqual(members.count, status.data.totalCount);
                XCTAssertNotNil(members.firstObject.user);
                XCTAssertEqualObjects(members.firstObject.user.identifier, users[1].identifier);
                XCTAssertEqualObjects(members.firstObject.user.custom, users[1].custom);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                  NSNotFound);
                
                [self deleteSpace:spaces.firstObject.identifier cachedMemberForUser:users[0].identifier];
                
                handler();
            });
    }];
    
    [self deleteSpace:spaces.firstObject.identifier membersObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldDeleteMembersAndReturnSortedUserInformationWhenSortIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:5 usingClient:nil];
    NSString *expectedSort = @"user.name%3Adesc,created";
    
    NSMutableArray<PNMember *> *members = [[self addMembers:users toSpaces:spaces withCustoms:nil
                                            userInformation:YES usingClient:nil] mutableCopy];
    [members removeObjectAtIndex:0];
    NSArray<PNMember *> *expectedMembersOrder = [self members:members sortedWith:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]
    ]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .includeCount(YES)
            .sort(@[@"user.name:desc", @"created"])
            .remove(@[users[0].identifier])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                NSArray<PNMember *> *fetchedMembers = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(fetchedMembers);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);
                
                for (NSUInteger fetchedMemberIdx = 0; fetchedMemberIdx < fetchedMembers.count; fetchedMemberIdx++) {
                    XCTAssertEqualObjects(fetchedMembers[fetchedMemberIdx].user.name,
                                          expectedMembersOrder[fetchedMemberIdx].user.name);
                }
                
                XCTAssertNotEqualObjects([fetchedMembers valueForKeyPath:@"user.name"],
                                         [members valueForKeyPath:@"user.name"]);
                
                [self deleteSpace:spaces.firstObject.identifier cachedMemberForUser:users[0].identifier];
                
                handler();
            });
    }];
    
    [self deleteSpace:spaces.firstObject.identifier membersObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldDeleteMembersAndReturnUserInformationWhenUserIncludeFlagIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:nil];
    
    [self addMembers:users toSpaces:spaces withCustoms:nil usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .remove(@[users[0].identifier])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                NSArray<PNMember *> *members = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(members);
                XCTAssertEqual(members.count, 1);
                XCTAssertNotNil(members.firstObject.user);
                XCTAssertEqualObjects(members.firstObject.user.identifier, users[1].identifier);
                XCTAssertEqualObjects(members.firstObject.user.custom, users[1].custom);
                
                [self deleteSpace:spaces.firstObject.identifier cachedMemberForUser:users[0].identifier];
                
                handler();
            });
    }];
    
    [self deleteSpace:spaces.firstObject.identifier membersObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldDeleteMembersAndTriggerDeleteEventOnSpaceChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:client1];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:client1];
    NSMutableArray *deletedMembers = [NSMutableArray new];
    NSString *channel = spaces.firstObject.identifier;
    
    [self addMembers:users toSpaces:spaces withCustoms:nil usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertNotNil(event.data.timestamp);
            
            if ([deletedMembers indexOfObject:event.data.userId] == NSNotFound) {
                [deletedMembers addObject:event.data.userId];
            }
            
            if (deletedMembers.count == users.count) {
                XCTAssertNotEqual([deletedMembers indexOfObject:users[0].identifier], NSNotFound);
                XCTAssertNotEqual([deletedMembers indexOfObject:users[1].identifier], NSNotFound);
                *remove = YES;
                
                handler();
            }
        }];
        
        client1.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .remove(@[users[0].identifier, users[1].identifier])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self deleteUserObjectsUsingClient:client1];
    [self deleteSpaceObjectsUsingClient:client1];
}

- (void)testItShouldDeleteMembersAndTriggerDeleteEventOnUserChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:client1];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:client1];
    NSString *channel = users.firstObject.identifier;
    
    [self addMembers:users toSpaces:spaces withCustoms:nil usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.userId, users.firstObject.identifier);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;
            
            handler();
        }];
        
        client1.manageMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .remove(@[users[0].identifier, users[1].identifier])
            .performWithCompletion(^(PNManageMembersStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self deleteUserObjectsUsingClient:client1];
    [self deleteSpaceObjectsUsingClient:client1];
}


#pragma mark - Tests :: Builder pattern-based fetch members

/**
 * @brief To test 'retry' functionality
 *  'ItShouldFetchMembersAndReceiveResultWithExpectedOperation.json' should
 *  be modified after cassette recording. Find first mention of members fetch and copy paste
 *  4 entries which belong to it. For new entries change 'id' field to be different from source. For
 *  original response entry change status code to 404.
 */
- (void)testItShouldFetchMembersAndReceiveResultWithExpectedOperation {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:6 usingClient:nil];
    __block BOOL retried = NO;
    
    [self addMembers:users toSpaces:spaces withCustoms:nil usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMembers()
            .spaceId(spaces.firstObject.identifier)
            .performWithCompletion(^(PNFetchMembersResult *result, PNErrorStatus *status) {
                if (!retried) {
                    XCTAssertTrue(status.error);
                    XCTAssertEqual(status.operation, PNFetchMembersOperation);
                    XCTAssertEqual(status.category, PNMalformedResponseCategory);
                    
                    retried = YES;
                    [status retry];
                } else {
                    NSArray<PNMember *> *members = result.data.members;
                    XCTAssertNil(status);
                    XCTAssertNotNil(members);
                    XCTAssertEqual(members.count, users.count);
                    XCTAssertEqual(result.data.totalCount, 0);
                    XCTAssertEqual(result.operation, PNFetchMembersOperation);
                    
                    handler();
                }
            });
    }];
      
    [self deleteSpace:spaces.firstObject.identifier membersObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldFetchFilteredMembersWhenFilterIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:6 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(users[3].name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"user.name like '%@*'",
                                  [users[3].name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    
    [self addMembers:users toSpaces:spaces withCustoms:nil usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeCount(YES)
            .filter(filterExpression)
            .performWithCompletion(^(PNFetchMembersResult *result, PNErrorStatus *status) {
                NSURLRequest *request = [result valueForKey:@"clientRequest"];
                NSArray<PNMember *> *members = result.data.members;
                XCTAssertNil(status);
                XCTAssertNotNil(members);
                XCTAssertEqual(result.data.totalCount, 1);
                XCTAssertEqual(members.count, result.data.totalCount);
                XCTAssertNil(result.data.prev);
                XCTAssertNotNil(result.data.next);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                  NSNotFound);
                
                handler();
            });
    }];
      
    [self deleteSpace:spaces.firstObject.identifier membersObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldFetchOrderedMembersWhenOrderIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:6 usingClient:nil];
    NSString *expectedSort = @"user.name%3Adesc,created";
    
    NSArray<PNMember *> *members =[self addMembers:users toSpaces:spaces withCustoms:nil
                                   userInformation:YES usingClient:nil];
    NSArray<PNMember *> *expectedMembersOrder = [self members:members sortedWith:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]
    ]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMembers()
            .spaceId(spaces.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberCustomField)
            .includeCount(YES)
            .sort(@[@"user.name:desc", @"created"])
            .performWithCompletion(^(PNFetchMembersResult *result, PNErrorStatus *status) {
                NSURLRequest *request = [result valueForKey:@"clientRequest"];
                NSArray<PNMember *> *fetchedMembers = result.data.members;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedMembers);
                XCTAssertNil(result.data.prev);
                XCTAssertNotNil(result.data.next);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);
                
                for (NSUInteger fetchedMemberIdx = 0; fetchedMemberIdx < fetchedMembers.count; fetchedMemberIdx++) {
                    XCTAssertEqualObjects(fetchedMembers[fetchedMemberIdx].user.name,
                                          expectedMembersOrder[fetchedMemberIdx].user.name);
                }
                
                XCTAssertNotEqualObjects([fetchedMembers valueForKeyPath:@"user.name"],
                                         [members valueForKeyPath:@"user.name"]);
                
                handler();
            });
    }];
      
    [self deleteSpace:spaces.firstObject.identifier membersObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldFetchMembersWhenLimitIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:6 usingClient:nil];
    NSArray<NSDictionary *> *membersCustom = @[
        @{ @"user-member-custom": [@[users[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"user-member-custom": [@[users[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    NSUInteger expectedCount = 2;
    
    [self addMembers:users toSpaces:spaces withCustoms:membersCustom usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMembers()
            .spaceId(spaces.firstObject.identifier)
            .limit(expectedCount)
            .includeFields(PNMemberCustomField)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchMembersResult *result, PNErrorStatus *status) {
                NSArray<PNMember *> *members = result.data.members;
                XCTAssertNil(status);
                XCTAssertNotNil(members);
                XCTAssertEqual(members.count, expectedCount);
                XCTAssertEqual(result.data.totalCount, users.count);
                XCTAssertNotNil(members.firstObject.custom);
                
                handler();
            });
    }];
    
    [self deleteSpace:spaces.firstObject.identifier membersObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldFetchNextMembershipPageWhenStartAndLimitIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:6 usingClient:nil];
    __block NSString *next = nil;
    
    [self addMembers:users toSpaces:spaces withCustoms:nil usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMembers()
            .spaceId(spaces.firstObject.identifier)
            .limit(users.count - 2)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchMembersResult *result, PNErrorStatus *status) {
                NSArray<PNMember *> *members = result.data.members;
                XCTAssertNil(status);
                XCTAssertNotNil(members);
                XCTAssertEqual(members.count, users.count - 2);
                next = result.data.next;
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMembers()
            .spaceId(spaces.firstObject.identifier)
            .start(next)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchMembersResult *result, PNErrorStatus *status) {
                NSArray<PNMember *> *members = result.data.members;
                XCTAssertNil(status);
                XCTAssertNotNil(members);
                XCTAssertEqual(members.count, 2);
                
                handler();
            });
    }];
    
    [self deleteSpace:spaces.firstObject.identifier membersObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldNotFetchMembersWhenSpaceObjectNotExists {
    NSString *spaceIdentifier = [self uuidForUser:@"not-existing-space"];
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMembers()
            .spaceId(spaceIdentifier)
            .performWithCompletion(^(PNFetchMembersResult *result, PNErrorStatus *status) {
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


#pragma mark - Tests :: Member events

- (void)testItShouldTriggerUpdateMemberEventOnSpaceChannelWhenUserDataChanged {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:client1];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:client1];
    NSString *channel = spaces.firstObject.identifier;
    NSArray<NSDictionary *> *membersCustom = @[
        @{ @"user-custom": [@[users[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"user-custom": [@[users[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    
    [self addMembers:users toSpaces:spaces withCustoms:nil usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addUserHandlerForClient:client2
                            withBlock:^(PubNub *client, PNUserEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"update");
            XCTAssertEqualObjects(event.data.identifier, users.firstObject.identifier);
            XCTAssertNotNil(event.data.updated);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;
            
            handler();
        }];
        
        client1.updateUser()
            .userId(users.firstObject.identifier)
            .includeFields(PNMemberUserField|PNMemberUserCustomField)
            .custom(membersCustom[0])
            .performWithCompletion(^(PNUpdateUserStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
    
    [self deleteSpace:spaces.firstObject.identifier membersObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldTriggerDeleteMemberEventOnSpaceChannelWhenUserRemoved {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:1 usingClient:client1];
    NSArray<PNUser *> *users = [self createObjectForUsers:2 usingClient:client1];
    NSString *channel = spaces.firstObject.identifier;
    
    [self addMembers:users toSpaces:spaces withCustoms:nil usingClient:client1];
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
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
    
    [self deleteSpace:spaces.firstObject.identifier membersObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}


#pragma mark - Misc

- (NSArray<NSDictionary *> *)flattenedMembers:(NSArray<PNMember *> *)members {
    NSMutableArray *flattenedMembers = [NSMutableArray new];
    
    for (PNMember *member in members) {
        [flattenedMembers addObject:@{
            @"name": member.user.name,
            @"created": member.created
        }];
    }
    
    return flattenedMembers;
}

- (NSArray<PNMember *> *)members:(NSArray<PNMember *> *)members
                      sortedWith:(NSArray<NSSortDescriptor *> *)sortDescriptors {
    
    NSMutableArray *sortedMembers = [NSMutableArray new];
    NSArray *flattenedMembers = [self flattenedMembers:members];
    NSArray *sortedFlattenedMembers = [flattenedMembers sortedArrayUsingDescriptors:sortDescriptors];
    
    for (NSDictionary *flattenedMember in sortedFlattenedMembers) {
        for (PNMember *member in members) {
            if ([member.user.name isEqualToString:flattenedMember[@"name"]]) {
                [sortedMembers addObject:member];
                break;
            }
        }
    }
    
    return sortedMembers;
}

#pragma mark -

#pragma clang diagnostic pop

@end
