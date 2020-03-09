/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import <PubNub/PNHelpers.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNMembershipIntegrationTest : PNRecordableTestCase


#pragma mark - Misc

/**
 * @brief Flatten membership objects by extracting from it name of space and creation date.
 *
 * @param memberships List of memberships which should be flattened.
 *
 * @return List of dictionaries which contain name of space and membership creation date.
 */
- (NSArray<NSDictionary *> *)flattenedMemberships:(NSArray<PNMembership *> *)memberships;

/**
 * @brief Sort provided list of memberships.
 *
 * @param memberships List of memberships which should be stored.
 * @param sortDescriptors Descriptors which should be used during filter.
 *
 * @return Sorted list of memberships.
 */
- (NSArray<PNMembership *> *)memberships:(NSArray<PNMembership *> *)memberships
                              sortedWith:(NSArray<NSSortDescriptor *> *)sortDescriptors;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNMembershipIntegrationTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    [self completePubNubConfiguration:self.client];
    [self removeAllObjects];
}


#pragma mark - Tests :: Builder pattern-based create membership

- (void)testItShouldCreateMembershipAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    NSArray<NSDictionary *> *membershipSpaces = @[
        @{
            @"spaceId": spaces[0].identifier,
            @"custom": @{ @"user-membership-custom": [@[spaces[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] }
        },
        @{
            @"spaceId": spaces[1].identifier,
            @"custom": @{ @"user-membership-custom": [@[spaces[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
        }
    ];
    __block NSArray *memberships = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipCustomField)
            .add(membershipSpaces).performWithCompletion(^(PNManageMembershipsStatus *status) {
                memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(status.operation, PNManageMembershipsOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                for (PNMembership *membership in memberships) {
                    for (NSUInteger spaceIdx = 0; spaceIdx < spaces.count; spaceIdx++) {
                        PNSpace *space = spaces[spaceIdx];
                        
                        if ([membership.spaceId isEqualToString:space.identifier]) {
                            XCTAssertEqualObjects(membership.custom, membershipSpaces[spaceIdx][@"custom"]);
                            break;
                        }
                    }
                }
                
                handler();
            });
    }];
    
    [self deleteUser:users.firstObject.identifier membershipObjects:memberships usingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldCreateMembershipAndReturnFilteredSpacesInformationWhenFilterIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(spaces.lastObject.name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"space.name like '%@*'",
                                  [spaces.lastObject.name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    NSArray<NSDictionary *> *membershipSpaces = @[
        @{ @"spaceId": spaces[0].identifier },
        @{ @"spaceId": spaces[1].identifier }
    ];
    __block NSArray<PNMembership *> *memberships = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .includeCount(YES)
            .filter(filterExpression)
            .add(membershipSpaces)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                memberships = status.data.memberships;
                XCTAssertEqual(status.data.totalCount, 1);
                XCTAssertEqual(memberships.count, status.data.totalCount);
                XCTAssertNil(status.data.prev);
                XCTAssertNotNil(status.data.next);
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(memberships);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                  NSNotFound);
                XCTAssertNotNil(memberships.firstObject.space);
                XCTAssertEqualObjects(memberships.firstObject.space.custom, spaces.lastObject.custom);
                
                handler();
            });
    }];
    
    [self deleteUser:users.firstObject.identifier membershipObjects:memberships usingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldCreateMembershipAndReturnSortedSpacesInformationWhenSortIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    NSString *expectedSort = @"space.name%3Adesc";
    NSArray<NSDictionary *> *membershipSpaces = @[
        @{ @"spaceId": spaces[0].identifier },
        @{ @"spaceId": spaces[1].identifier }
    ];
    __block NSArray<PNMembership *> *memberships = nil;
    
    NSArray<PNSpace *> *expectedMembershipSpacesOrder = [spaces sortedArrayUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]
    ]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .includeCount(YES)
            .sort(@[@"space.name:desc"])
            .add(membershipSpaces)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                memberships = status.data.memberships;
                XCTAssertNil(status.data.prev);
                XCTAssertNotNil(status.data.next);
                XCTAssertNotNil(memberships);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);
                
                for (NSUInteger fetchedMembershipIdx = 0; fetchedMembershipIdx < memberships.count; fetchedMembershipIdx++) {
                    XCTAssertEqualObjects(memberships[fetchedMembershipIdx].spaceId,
                                          expectedMembershipSpacesOrder[fetchedMembershipIdx].identifier);
                }
                
                XCTAssertNotEqualObjects([memberships valueForKeyPath:@"space.name"],
                                         [spaces valueForKeyPath:@"name"]);
                
                handler();
            });
    }];
    
    [self deleteUser:users.firstObject.identifier membershipObjects:memberships usingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldCreateMembershipAndReturnSpaceInformationWhenSpaceIncludeFlagIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    NSArray<NSDictionary *> *membershipSpaces = @[
        @{ @"spaceId": spaces[0].identifier },
        @{ @"spaceId": spaces[1].identifier }
    ];
    __block NSArray *memberships = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .add(membershipSpaces)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(memberships);
                
                for (PNMembership *membership in memberships) {
                    XCTAssertNotNil(membership.space);
                    
                    for (NSUInteger spaceIdx = 0; spaceIdx < spaces.count; spaceIdx++) {
                        PNSpace *space = spaces[spaceIdx];
                        
                        if ([membership.space.identifier isEqualToString:space.identifier]) {
                            XCTAssertEqualObjects(membership.space.custom, space.custom);
                            break;
                        }
                    }
                }
                
                handler();
            });
    }];
    
    [self deleteUser:users.firstObject.identifier membershipObjects:memberships usingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldCreateMembershipAndTriggerCreateEventOnUserChannel {
    NSMutableArray *createdMemberships = [NSMutableArray new];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:client1];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:client1];
    NSString *channel = users.firstObject.identifier;
    NSArray<NSDictionary *> *membershipSpaces = @[
        @{ @"spaceId": spaces[0].identifier },
        @{ @"spaceId": spaces[1].identifier }
    ];
    __block NSArray *memberships = nil;
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"create");
            XCTAssertNotNil(event.data.created);
            XCTAssertNotNil(event.data.timestamp);
            
            if ([createdMemberships indexOfObject:event.data.spaceId] == NSNotFound) {
                [createdMemberships addObject:event.data.spaceId];
            }
            
            if (createdMemberships.count == spaces.count) {
                XCTAssertNotEqual([createdMemberships indexOfObject:spaces[0].identifier], NSNotFound);
                XCTAssertNotEqual([createdMemberships indexOfObject:spaces[1].identifier], NSNotFound);
                *remove = YES;
                
                handler();
            }
        }];
        
        client1.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .add(membershipSpaces)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
    
    
    [self verifyUserMembershipsCount:users.firstObject.identifier shouldEqualTo:membershipSpaces.count
                         usingClient:client1];
    
    [self deleteUser:users.firstObject.identifier membershipObjects:memberships usingClient:client1];
    [self deleteUserObjectsUsingClient:client1];
    [self deleteSpaceObjectsUsingClient:client1];
}

- (void)testItShouldCreateMembershipAndTriggerCreateEventOnSpaceChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:client1];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:client1];
    NSString *channel = spaces.firstObject.identifier;
    NSArray<NSDictionary *> *membershipSpaces = @[
        @{ @"spaceId": spaces[0].identifier },
        @{ @"spaceId": spaces[1].identifier }
    ];
    __block NSArray *memberships = nil;
    
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
        
        client1.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .add(membershipSpaces)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
    
    [self deleteUser:users.firstObject.identifier membershipObjects:memberships usingClient:client1];
    [self deleteUserObjectsUsingClient:client1];
    [self deleteSpaceObjectsUsingClient:client1];
}

- (void)testItShouldNotCreateMembershipWhenUserAlreadyHasMembershipWithTargetSpace {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    NSArray<NSDictionary *> *membershipSpaces = @[
        @{ @"spaceId": spaces[0].identifier },
        @{ @"spaceId": spaces[1].identifier }
    ];
    __block NSArray *memberships = nil;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .add(membershipSpaces)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
                handler();
            });
    }];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .add(@[membershipSpaces.firstObject])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
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
    
    
    [self verifyUserMembershipsCount:users.firstObject.identifier shouldEqualTo:membershipSpaces.count
                         usingClient:nil];
    
    [self deleteUser:users.firstObject.identifier membershipObjects:memberships usingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}


#pragma mark - Tests :: Builder pattern-based update membership

- (void)testItShouldUpdateMembershipAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    NSArray<NSDictionary *> *membershipCustom = @[
        @{ @"user-membership-custom": [@[spaces[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"user-membership-custom": [@[spaces[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    NSArray<NSDictionary *> *expectedMembershipCustom = @[
        @{ @"user-membership-custom": [@[spaces[0].identifier, @"custom", @"data", @"3"] componentsJoinedByString:@"-"] },
        @{ @"user-membership-custom": [@[spaces[1].identifier, @"custom", @"data", @"4"] componentsJoinedByString:@"-"] }
    ];
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:membershipCustom usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipCustomField)
            .update(@[
                @{ @"spaceId": spaces[0].identifier, @"custom": expectedMembershipCustom[0] },
                @{ @"spaceId": spaces[1].identifier, @"custom": expectedMembershipCustom[1] },
            ])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSArray<PNMembership *> *memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(status.operation, PNManageMembershipsOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                for (PNMembership *membership in memberships) {
                    for (NSUInteger spaceIdx = 0; spaceIdx < spaces.count; spaceIdx++) {
                        PNSpace *space = spaces[spaceIdx];
                        
                        if ([membership.spaceId isEqualToString:space.identifier]) {
                            XCTAssertEqualObjects(membership.custom, expectedMembershipCustom[spaceIdx]);
                            break;
                        }
                    }
                }
                
                handler();
            });
    }];

    [self deleteUser:users.firstObject.identifier membershipObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldUpdateMembershipAndReturnFilteredSpaceInformationWhenFilterIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(spaces.lastObject.name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"space.name like '%@*'",
                                  [spaces.lastObject.name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    NSArray<NSDictionary *> *membershipCustom = @[
        @{ @"user-membership-custom": [@[spaces[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"user-membership-custom": [@[spaces[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .includeCount(YES)
            .filter(filterExpression)
            .update(@[
                @{ @"spaceId": spaces[0].identifier, @"custom": membershipCustom[0] },
                @{ @"spaceId": spaces[1].identifier, @"custom": membershipCustom[1] },
            ])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSArray<PNMembership *> *memberships = status.data.memberships;
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(memberships);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                  NSNotFound);
                XCTAssertNotNil(memberships.lastObject.space);
                XCTAssertEqualObjects(memberships.lastObject.space.custom, spaces.lastObject.custom);
                
                handler();
            });
    }];

    [self deleteUser:users.firstObject.identifier membershipObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldUpdateMembershipAndReturnSortedSpaceInformationWhenSortIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:4 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    NSString *expectedSort = @"space.name%3Adesc,created";
    NSArray<NSDictionary *> *membershipCustom = @[
        @{ @"user-membership-custom": [@[spaces[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"user-membership-custom": [@[spaces[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    
    NSArray<PNMembership *> *memberships = [self createUsersMembership:users inSpaces:spaces withCustoms:nil
                                                      spaceInformation:YES usingClient:nil];
    NSArray<PNMembership *> *expectedMembershipsOrder = [self memberships:memberships sortedWith:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]
    ]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .includeCount(YES)
            .sort(@[@"space.name:desc", @"created"])
            .update(@[
                @{ @"spaceId": spaces[0].identifier, @"custom": membershipCustom[0] },
                @{ @"spaceId": spaces[1].identifier, @"custom": membershipCustom[1] },
            ])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSArray<PNMembership *> *fetchedMemberships = status.data.memberships;
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(fetchedMemberships);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);
                
                for (NSUInteger fetchedMembershipIdx = 0; fetchedMembershipIdx < fetchedMemberships.count; fetchedMembershipIdx++) {
                    XCTAssertEqualObjects(fetchedMemberships[fetchedMembershipIdx].space.name,
                                          expectedMembershipsOrder[fetchedMembershipIdx].space.name);
                }
                
                XCTAssertNotEqualObjects([fetchedMemberships valueForKeyPath:@"space.name"],
                                         [memberships valueForKeyPath:@"space.name"]);
                
                handler();
            });
    }];

    [self deleteUser:users.firstObject.identifier membershipObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldUpdateMembershipAndReturnSpaceInformationWhenSpaceIncludeFlagIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    NSArray<NSDictionary *> *membershipCustom = @[
        @{ @"user-membership-custom": [@[spaces[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"user-membership-custom": [@[spaces[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .update(@[
                @{ @"spaceId": spaces[0].identifier, @"custom": membershipCustom[0] },
                @{ @"spaceId": spaces[1].identifier, @"custom": membershipCustom[1] },
            ])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSArray<PNMembership *> *memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(memberships);
                
                for (PNMembership *membership in memberships) {
                    XCTAssertNotNil(membership.space);
                    
                    for (PNSpace *space in spaces) {
                        if ([membership.space.identifier isEqualToString:space.identifier]) {
                            XCTAssertEqualObjects(membership.space.custom, space.custom);
                            break;
                        }
                    }
                }
                
                handler();
            });
    }];

    [self deleteUser:users.firstObject.identifier membershipObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldUpdateMembershipAndTriggerUpdateEventOnUserChannel {
    NSMutableArray *updatedMemberships = [NSMutableArray new];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:client1];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:client1];
    NSString *channel = users.firstObject.identifier;
    NSArray<NSDictionary *> *membershipCustom = @[
        @{ @"user-membership-custom": [@[spaces[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"user-membership-custom": [@[spaces[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"update");
            XCTAssertNotNil(event.data.updated);
            XCTAssertNotNil(event.data.timestamp);
            
            if ([updatedMemberships indexOfObject:event.data.spaceId] == NSNotFound) {
                [updatedMemberships addObject:event.data.spaceId];
            }
            
            if (updatedMemberships.count == spaces.count) {
                XCTAssertNotEqual([updatedMemberships indexOfObject:spaces[0].identifier], NSNotFound);
                XCTAssertNotEqual([updatedMemberships indexOfObject:spaces[1].identifier], NSNotFound);
                *remove = YES;
                
                handler();
            }
        }];
        
        client1.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .update(@[
                @{ @"spaceId": spaces[0].identifier, @"custom": membershipCustom[0] },
                @{ @"spaceId": spaces[1].identifier, @"custom": membershipCustom[1] },
            ])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self deleteUser:users.firstObject.identifier membershipObjectsUsingClient:client1];
    [self deleteUserObjectsUsingClient:client1];
    [self deleteSpaceObjectsUsingClient:client1];
}

- (void)testItShouldUpdateMembershipAndTriggerUpdateEventOnSpaceChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:client1];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:client1];
    NSString *channel = spaces.firstObject.identifier;
    NSArray<NSDictionary *> *membershipCustom = @[
        @{ @"user-membership-custom": [@[spaces[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"user-membership-custom": [@[spaces[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil usingClient:client1];
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
        
        client1.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .update(@[
                @{ @"spaceId": spaces[0].identifier, @"custom": membershipCustom[0] },
                @{ @"spaceId": spaces[1].identifier, @"custom": membershipCustom[1] },
            ])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self deleteUser:users.firstObject.identifier membershipObjectsUsingClient:client1];
    [self deleteUserObjectsUsingClient:client1];
    [self deleteSpaceObjectsUsingClient:client1];
}

- (void)testItShouldNotUpdateMembershipWhenUserNotHaveMembershipWithSpecifiedSpaces {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    NSArray<NSDictionary *> *membershipCustom = @[
        @{ @"user-membership-custom": [@[spaces[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"user-membership-custom": [@[spaces[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipCustomField)
            .update(@[
                @{ @"spaceId": spaces[0].identifier, @"custom": membershipCustom[0] },
                @{ @"spaceId": spaces[1].identifier, @"custom": membershipCustom[1] }
            ])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 400);
                handler();
            });
    }];
    
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}


#pragma mark - Tests :: Builder pattern-based delete membership

/**
 * @brief To test 'retry' functionality
 *  'ItShouldDeleteMembershipAndReceiveStatusWithExpectedOperationAndCategory.json' should
 *  be modified after cassette recording. Find first mention of membership remove and copy paste
 *  4 entries which belong to it. For new entries change 'id' field to be different from source. For
 *  original response entry change status code to 404.
 */
- (void)testItShouldDeleteMembershipAndReceiveStatusWithExpectedOperationAndCategory {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    __block BOOL retried = NO;
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipCustomField)
            .remove(@[spaces.firstObject.identifier])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                if (!retried && !YHVVCR.cassette.isNewCassette) {
                    XCTAssertTrue(status.error);
                    XCTAssertEqual(status.operation, PNManageMembershipsOperation);
                    XCTAssertEqual(status.category, PNMalformedResponseCategory);

                    retried = YES;
                    [status retry];
                } else {
                    NSArray<PNMembership *> *memberships = status.data.memberships;
                    XCTAssertFalse(status.isError);
                    XCTAssertNotNil(memberships);
                    XCTAssertEqual(memberships.count, 1);
                    XCTAssertEqualObjects(memberships.firstObject.spaceId, spaces[1].identifier);
                    XCTAssertEqual(status.operation, PNManageMembershipsOperation);
                    XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                    
                    [self deleteUser:users.firstObject.identifier cachedMembershipForSpace:spaces[0].identifier];
                    
                    handler();
                }
            });
    }];
                       
    [self deleteUser:users.firstObject.identifier membershipObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldDeleteMembershipAndReturnFilteredSpaceInformationWhenFilterIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(spaces.lastObject.name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"space.name like '%@*'",
                                  [spaces.lastObject.name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .includeCount(YES)
            .filter(filterExpression)
            .remove(@[spaces[0].identifier])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSArray<PNMembership *> *memberships = status.data.memberships;
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(status.data.totalCount, 1);
                XCTAssertEqual(memberships.count, status.data.totalCount);
                XCTAssertNotNil(memberships.firstObject.space);
                XCTAssertEqualObjects(memberships.firstObject.space.identifier, spaces[1].identifier);
                XCTAssertEqualObjects(memberships.firstObject.space.custom, spaces[1].custom);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                  NSNotFound);
                
                [self deleteUser:users.firstObject.identifier cachedMembershipForSpace:spaces[0].identifier];
                
                handler();
            });
    }];
                       
    [self deleteUser:users.firstObject.identifier membershipObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldDeleteMembershipAndReturnSortedSpaceInformationWhenSortedIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:5 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    NSString *expectedSort = @"space.name%3Adesc,created";
    
    NSMutableArray<PNMembership *> *memberships = [[self createUsersMembership:users inSpaces:spaces withCustoms:nil
                                                              spaceInformation:YES usingClient:nil] mutableCopy];
    [memberships removeObjectAtIndex:0];
    NSArray<PNMembership *> *expectedMembershipsOrder = [self memberships:memberships sortedWith:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]
    ]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .includeCount(YES)
            .sort(@[@"space.name:desc", @"created"])
            .remove(@[spaces[0].identifier])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSArray<PNMembership *> *fetchedMemberships = status.data.memberships;
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(fetchedMemberships);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);
                
                for (NSUInteger fetchedMembershipIdx = 0; fetchedMembershipIdx < fetchedMemberships.count; fetchedMembershipIdx++) {
                    XCTAssertEqualObjects(fetchedMemberships[fetchedMembershipIdx].space.name,
                                          expectedMembershipsOrder[fetchedMembershipIdx].space.name);
                }
                
                XCTAssertNotEqualObjects([fetchedMemberships valueForKeyPath:@"space.name"],
                                         [memberships valueForKeyPath:@"space.name"]);
                
                [self deleteUser:users.firstObject.identifier cachedMembershipForSpace:spaces[0].identifier];
                
                handler();
            });
    }];
                       
    [self deleteUser:users.firstObject.identifier membershipObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldDeleteMembershipAndReturnSpaceInformationWhenSpaceIncludeFlagIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .remove(@[spaces[0].identifier])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSArray<PNMembership *> *memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(memberships.count, 1);
                XCTAssertNotNil(memberships.firstObject.space);
                XCTAssertEqualObjects(memberships.firstObject.space.identifier, spaces[1].identifier);
                XCTAssertEqualObjects(memberships.firstObject.space.custom, spaces[1].custom);
                
                [self deleteUser:users.firstObject.identifier cachedMembershipForSpace:spaces[0].identifier];
                
                handler();
            });
    }];
                       
    [self deleteUser:users.firstObject.identifier membershipObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldDeleteMembershipAndTriggerDeleteEventOnUserChannel {
    NSMutableArray *deletedMemberships = [NSMutableArray new];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:client1];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:client1];
    NSString *channel = users.firstObject.identifier;
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertNotNil(event.data.timestamp);
            
            if ([deletedMemberships indexOfObject:event.data.spaceId] == NSNotFound) {
                [deletedMemberships addObject:event.data.spaceId];
            }
            
            if (deletedMemberships.count == spaces.count) {
                XCTAssertNotEqual([deletedMemberships indexOfObject:spaces[0].identifier], NSNotFound);
                XCTAssertNotEqual([deletedMemberships indexOfObject:spaces[1].identifier], NSNotFound);
                *remove = YES;
                
                handler();
            }
        }];
        
        client1.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .remove(@[spaces[0].identifier, spaces[1].identifier])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
    
    [self deleteUserObjectsUsingClient:client1];
    [self deleteSpaceObjectsUsingClient:client1];
}

- (void)testItShouldDeleteMembershipAndTriggerDeleteEventOnSpaceChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:client1];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:client1];
    NSString *channel = spaces.firstObject.identifier;
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMembershipHandlerForClient:client2
                                  withBlock:^(PubNub *client, PNMembershipEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.spaceId, spaces.firstObject.identifier);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;
            
            handler();
        }];
        
        client1.manageMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceCustomField)
            .remove(@[spaces[0].identifier, spaces[1].identifier])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self deleteUserObjectsUsingClient:client1];
    [self deleteSpaceObjectsUsingClient:client1];
}


#pragma mark - Tests :: Builder pattern-based fetch membership

- (void)testItShouldFetchMembershipsAndReceiveResultWithExpectedOperation {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:6 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMemberships()
            .userId(users.firstObject.identifier)
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                NSArray<PNMembership *> *memberships = result.data.memberships;
                XCTAssertNil(status);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(memberships.count, spaces.count);
                XCTAssertEqual(result.data.totalCount, 0);
                
                handler();
            });
    }];
      
    [self deleteUser:users.firstObject.identifier membershipObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldFetchFilteredMembershipsWhenFilterIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:6 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(spaces[3].name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"space.name like '%@*'",
                                  [spaces[3].name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMemberships()
            .userId(users.firstObject.identifier)
            .includeCount(YES)
            .filter(filterExpression)
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                NSArray<PNMembership *> *memberships = result.data.memberships;
                NSURLRequest *request = [result valueForKey:@"clientRequest"];
                XCTAssertNil(status);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(result.data.totalCount, 1);
                XCTAssertEqual(memberships.count, result.data.totalCount);
                XCTAssertNil(result.data.prev);
                XCTAssertNotNil(result.data.next);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                  NSNotFound);
                
                handler();
            });
    }];
      
    [self deleteUser:users.firstObject.identifier membershipObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldFetchSortedMembershipsWhenSortedIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:6 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    NSString *expectedSort = @"space.name%3Adesc,created";
    
    NSArray<PNMembership *> *memberships = [self createUsersMembership:users inSpaces:spaces withCustoms:nil
                                                      spaceInformation:YES usingClient:nil];
    NSArray<PNMembership *> *expectedMembershipsOrder = [self memberships:memberships sortedWith:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]
    ]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMemberships()
            .userId(users.firstObject.identifier)
            .includeFields(PNMembershipSpaceField|PNMembershipSpaceField)
            .includeCount(YES)
            .sort(@[@"space.name:desc", @"created"])
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                NSArray<PNMembership *> *fetchedMemberships = result.data.memberships;
                NSURLRequest *request = [result valueForKey:@"clientRequest"];
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedMemberships);
                XCTAssertNil(result.data.prev);
                XCTAssertNotNil(result.data.next);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);
                
                for (NSUInteger fetchedMembershipIdx = 0; fetchedMembershipIdx < fetchedMemberships.count; fetchedMembershipIdx++) {
                    XCTAssertEqualObjects(fetchedMemberships[fetchedMembershipIdx].space.name,
                                          expectedMembershipsOrder[fetchedMembershipIdx].space.name);
                }
                
                XCTAssertNotEqualObjects([fetchedMemberships valueForKeyPath:@"space.name"],
                                         [memberships valueForKeyPath:@"space.name"]);
                
                handler();
            });
    }];
      
    [self deleteUser:users.firstObject.identifier membershipObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldFetchMembershipWhenLimitIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:6 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    NSArray<NSDictionary *> *membershipCustom = @[
        @{ @"user-membership-custom": [@[spaces[0].identifier, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"user-membership-custom": [@[spaces[1].identifier, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    NSUInteger expectedCount = 2;
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:membershipCustom usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMemberships()
            .userId(users.firstObject.identifier)
            .limit(expectedCount)
            .includeFields(PNMembershipCustomField)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                NSArray<PNMembership *> *memberships = result.data.memberships;
                XCTAssertNil(status);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(memberships.count, expectedCount);
                XCTAssertEqual(result.data.totalCount, spaces.count);
                XCTAssertNotNil(memberships.firstObject.custom);
                
                handler();
            });
    }];
      
    [self deleteUser:users.firstObject.identifier membershipObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldFetchNextMembershipPageWhenStartAndLimitIsSet {
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:6 usingClient:nil];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:nil];
    __block NSString *next = nil;
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMemberships()
            .userId(users.firstObject.identifier)
            .limit(spaces.count - 2)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                NSArray<PNMembership *> *memberships = result.data.memberships;
                XCTAssertNil(status);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(memberships.count, spaces.count - 2);
                next = result.data.next;
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMemberships()
            .userId(users.firstObject.identifier)
            .start(next)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                NSArray<PNMembership *> *memberships = result.data.memberships;
                XCTAssertNil(status);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(memberships.count, 2);
                
                handler();
            });
    }];
      
    [self deleteUser:users.firstObject.identifier membershipObjectsUsingClient:nil];
    [self deleteUserObjectsUsingClient:nil];
    [self deleteSpaceObjectsUsingClient:nil];
}

- (void)testItShouldNotFetchMembershipsWhenUserObjectNotExists {
    NSString *userIdentifier = [self uuidForUser:@"not-existing-user"];
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMemberships()
            .userId(userIdentifier)
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
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

- (void)testItShouldDeleteMemberAndTriggerUserDeleteOnSpaceChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNSpace *> *spaces = [self createObjectForSpaces:2 usingClient:client1];
    NSArray<PNUser *> *users = [self createObjectForUsers:1 usingClient:client1];
    NSString *channel = spaces.firstObject.identifier;
    
    [self createUsersMembership:users inSpaces:spaces withCustoms:nil usingClient:client1];
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

    [self deleteUserObjectsUsingClient:client1];
    [self deleteSpaceObjectsUsingClient:client1];
}


#pragma mark - Misc

- (NSArray<NSDictionary *> *)flattenedMemberships:(NSArray<PNMembership *> *)memberships {
    NSMutableArray *flattenedMemberships = [NSMutableArray new];
    
    for (PNMembership *membership in memberships) {
        [flattenedMemberships addObject:@{
            @"name": membership.space.name,
            @"created": membership.created
        }];
    }
    
    return flattenedMemberships;
}

- (NSArray<PNMembership *> *)memberships:(NSArray<PNMembership *> *)memberships
                              sortedWith:(NSArray<NSSortDescriptor *> *)sortDescriptors {
    
    NSMutableArray *sortedMemberships = [NSMutableArray new];
    NSArray *flattenedMemberships = [self flattenedMemberships:memberships];
    NSArray *sortedFlattenedMemberships = [flattenedMemberships sortedArrayUsingDescriptors:sortDescriptors];
    
    for (NSDictionary *flattenedMembership in sortedFlattenedMemberships) {
        for (PNMembership *membership in memberships) {
            if ([membership.space.name isEqualToString:flattenedMembership[@"name"]]) {
                [sortedMemberships addObject:membership];
                break;
            }
        }
    }
    
    return sortedMemberships;
}

#pragma mark -

#pragma clang diagnostic pop

@end
