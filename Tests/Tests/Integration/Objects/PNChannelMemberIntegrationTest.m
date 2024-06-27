/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import <PubNub/PNHelpers.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNChannelMemberIntegrationTest : PNRecordableTestCase


#pragma mark - Misc

/**
 * @brief Flatten members objects by extracting from it name stored in UUID metadata and update date.
 *
 * @param members List of members which should be flattened.
 *
 * @return List of dictionaries which contain name from UUID metadata and member update date.
 */
- (NSArray<NSDictionary *> *)flattenedMembers:(NSArray<PNChannelMember *> *)members;

/**
 * @brief Sort provided list of members.
 *
 * @param members List of members which should be stored.
 * @param sortDescriptors Descriptors which should be used during filter.
 *
 * @return Sorted list of members.
 */
- (NSArray<PNChannelMember *> *)members:(NSArray<PNChannelMember *> *)members
                      sortedWith:(NSArray<NSSortDescriptor *> *)sortDescriptors;


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNChannelMemberIntegrationTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    [self completePubNubConfiguration:self.client];
    [self removeAllObjects];
}


#pragma mark - Tests :: Builder pattern-based set members

- (void)testItShouldSetMembersAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:nil];
    NSArray<NSDictionary *> *uuids = @[
        @{
            @"uuid": uuidsMetadata[0].uuid,
            @"custom": @{
                @"uuid-member-custom": [@[uuidsMetadata[0].uuid, @"custom", @"data", @"1"] componentsJoinedByString:@"-"]
            }
        },
        @{
            @"uuid": uuidsMetadata[1].uuid,
            @"custom": @{
                @"uuid-member-custom": [@[uuidsMetadata[1].uuid, @"custom", @"data", @"2"] componentsJoinedByString:@"-"]
            }
        }
    ];
    __block NSArray *members = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().setChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberCustomField)
            .uuids(uuids)
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                members = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(members);
                XCTAssertEqual(status.operation, PNSetChannelMembersOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                for (PNChannelMember *member in members) {
                    for (NSUInteger memberIdx = 0; memberIdx < uuidsMetadata.count; memberIdx++) {
                        PNUUIDMetadata *uuidMetadata = uuidsMetadata[memberIdx];
                        
                        if ([member.uuid isEqualToString:uuidMetadata.uuid]) {
                            XCTAssertEqualObjects(member.custom, uuids[memberIdx][@"custom"]);
                            break;
                        }
                    }
                }
                
                handler();
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel memberObjects:members usingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldSetMembersAndNotCrashWhenCompletionBlockIsNil {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:nil];
    NSArray<NSDictionary *> *uuids = @[
        @{
            @"uuid": uuidsMetadata[0].uuid,
            @"custom": @{
                @"uuid-member-custom": [@[uuidsMetadata[0].uuid, @"custom", @"data", @"1"] componentsJoinedByString:@"-"]
            }
        },
        @{
            @"uuid": uuidsMetadata[1].uuid,
            @"custom": @{
                @"uuid-member-custom": [@[uuidsMetadata[1].uuid, @"custom", @"data", @"2"] componentsJoinedByString:@"-"]
            }
        }
    ];
    __block NSArray *members = nil;
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
            self.client.objects().setChannelMembers(channelsMetadata.firstObject.channel)
                .includeFields(PNChannelMemberCustomField)
                .uuids(uuids)
                .performWithCompletion(nil);
#pragma clang diagnostic pop
        } @catch (NSException *exception) {
            handler();
        }
    }];
    
    [self removeChannel:channelsMetadata.firstObject.channel memberObjects:members usingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

/**
 * @brief To test 'retry' functionality
 *  'ItShouldSetMembersAndReturnFilteredMembersInformationWhenFilterIsSet.json' should
 *  be modified after cassette recording. Find first mention of member set and copy paste 4 entries
 *  which belong to it. For new entries change 'id' field to be different from source. For original
 *  response entry change status code to 404.
 */
- (void)testItShouldSetMembersAndReturnFilteredMembersInformationWhenFilterIsSet {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(uuidsMetadata.lastObject.name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"uuid.name like '%@*'",
                                  [uuidsMetadata.lastObject.name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    NSArray<NSDictionary *> *uuids = @[
        @{ @"uuid": uuidsMetadata[0].uuid },
        @{ @"uuid": uuidsMetadata[1].uuid }
    ];
    __block NSArray<PNChannelMember *> *members = nil;
    __block BOOL retried = NO;


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().setChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .includeCount(YES)
            .filter(filterExpression)
            .uuids(uuids)
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                if (!retried && !YHVVCR.cassette.isNewCassette) {
                    XCTAssertTrue(status.error);
                    XCTAssertEqual(status.operation, PNSetChannelMembersOperation);
                    XCTAssertEqual(status.category, PNMalformedResponseCategory);

                    retried = YES;
                    [status retry];
                } else {
                    NSURLRequest *request = [status valueForKey:@"clientRequest"];
                    members = status.data.members;
                    XCTAssertEqual(status.data.totalCount, 1);
                    XCTAssertNil(status.data.prev);
                    XCTAssertNotNil(status.data.next);
                    XCTAssertFalse(status.isError);
                    XCTAssertNotNil(members);
                    XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                      NSNotFound);
                    XCTAssertNotNil(members.lastObject.metadata);
                    XCTAssertEqualObjects(members.lastObject.metadata.custom, uuidsMetadata.lastObject.custom);

                    handler();
                }
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel memberObjects:members usingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldSetMembersAndReturnSortedMembersInformationWhenSortIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:4 usingClient:nil];
    NSString *expectedSort = @"uuid.name%3Adesc";
    NSArray<NSDictionary *> *uuids = @[
        @{ @"uuid": uuidsMetadata[0].uuid },
        @{ @"uuid": uuidsMetadata[1].uuid },
        @{ @"uuid": uuidsMetadata[2].uuid },
        @{ @"uuid": uuidsMetadata[3].uuid }
    ];
    __block NSArray<PNChannelMember *> *members = nil;

    NSArray<PNUUIDMetadata *> *expectedMembersOrder = [uuidsMetadata sortedArrayUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]
    ]];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().setChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .includeCount(YES)
            .sort(@[@"uuid.name:desc"])
            .uuids(uuids)
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                members = status.data.members;
                XCTAssertNil(status.data.prev);
                XCTAssertNotNil(status.data.next);
                XCTAssertNotNil(members);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);

                for (NSUInteger fetchedMemberIdx = 0; fetchedMemberIdx < members.count; fetchedMemberIdx++) {
                    XCTAssertEqualObjects(members[fetchedMemberIdx].uuid,
                                          expectedMembersOrder[fetchedMemberIdx].uuid);
                }

                XCTAssertNotEqualObjects([members valueForKeyPath:@"metadata.name"],
                                         [uuidsMetadata valueForKeyPath:@"name"]);

                handler();
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel memberObjects:members usingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldSetMembersAndReturnMemberInformationWhenIncludeFlagIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:nil];
    NSArray<NSDictionary *> *uuids = @[
        @{ @"uuid": uuidsMetadata[0].uuid },
        @{ @"uuid": uuidsMetadata[1].uuid }
    ];
    __block NSArray<PNChannelMember *> *members = nil;


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().setChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .uuids(uuids)
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                members = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(members);

                for (PNChannelMember *member in members) {
                    XCTAssertNotNil(member.uuid);

                    for (NSUInteger idx = 0; idx < uuidsMetadata.count; idx++) {
                        PNUUIDMetadata *metadata = uuidsMetadata[idx];

                        if ([member.metadata.uuid isEqualToString:metadata.uuid]) {
                            XCTAssertEqualObjects(member.metadata.custom, metadata.custom);
                            break;
                        }
                    }
                }

                handler();
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel memberObjects:members usingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldSetMembersAndTriggerSetEventOnChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:client1];
    NSMutableArray *createdMembers = [NSMutableArray new];
    NSString *channel = channelsMetadata.firstObject.channel;
    NSArray<NSDictionary *> *uuids = @[
        @{ @"uuid": uuidsMetadata[0].uuid },
        @{ @"uuid": uuidsMetadata[1].uuid }
    ];
    __block NSArray<PNChannelMember *> *members = nil;

    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2 withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {
            XCTAssertEqualObjects(event.data.event, @"set");
            XCTAssertEqualObjects(event.data.type, @"membership");
            XCTAssertNotNil(event.data.membership.updated);
            XCTAssertNotNil(event.data.timestamp);

            if ([createdMembers indexOfObject:event.data.uuidMetadata.uuid] == NSNotFound) {
                [createdMembers addObject:event.data.membership.uuid];
            }

            if (createdMembers.count == uuids.count) {
                XCTAssertNotEqual([createdMembers indexOfObject:uuidsMetadata[0].uuid], NSNotFound);
                XCTAssertNotEqual([createdMembers indexOfObject:uuidsMetadata[1].uuid], NSNotFound);
                *remove = YES;

                handler();
            }
        }];

        client1.objects().setChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .uuids(uuids)
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                members = status.data.members;
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];


    [self verifyChannelMembersCount:channelsMetadata.firstObject.channel
                      shouldEqualTo:uuidsMetadata.count
                        usingClient:client1];

    [self removeChannel:channelsMetadata.firstObject.channel memberObjects:members usingClient:client1];
    [self removeAllUUIDMetadataUsingClient:client1];
    [self removeChannelsMetadataUsingClient:client1];
}

- (void)testItShouldSetMembersAndTriggerSetEventOnUUIDChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:client1];
    NSString *channel = uuidsMetadata.firstObject.uuid;
    NSArray<NSDictionary *> *uuids = @[
        @{ @"uuid": uuidsMetadata[0].uuid },
        @{ @"uuid": uuidsMetadata[1].uuid }
    ];
    __block NSArray<PNChannelMember *> *members = nil;

    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"set");
            XCTAssertEqualObjects(event.data.type, @"membership");
            XCTAssertNotNil(event.data.membership.updated);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;

            handler();
        }];

        client1.objects().setChannelMembers(channelsMetadata.firstObject.channel)
        .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .uuids(uuids)
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                members = status.data.members;
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self removeChannel:channelsMetadata.firstObject.channel memberObjects:members usingClient:client1];
    [self removeAllUUIDMetadataUsingClient:client1];
    [self removeChannelsMetadataUsingClient:client1];
}


#pragma mark - Tests :: Builder pattern-based manage set members

- (void)testItShouldSetMembersUsingManageAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:nil];
    NSArray<NSDictionary *> *uuidsCustom = @[
        @{ @"uuid-member-custom": [@[uuidsMetadata[0].uuid, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"uuid-member-custom": [@[uuidsMetadata[1].uuid, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    NSArray<NSDictionary *> *expectedUUIDsCustom = @[
        @{ @"uuid-member-custom": [@[uuidsMetadata[0].uuid, @"custom", @"data", @"3"] componentsJoinedByString:@"-"] },
        @{ @"uuid-member-custom": [@[uuidsMetadata[1].uuid, @"custom", @"data", @"4"] componentsJoinedByString:@"-"] }
    ];

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:uuidsCustom usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberCustomField)
            .set(@[
                @{ @"uuid": uuidsMetadata[0].uuid, @"custom": expectedUUIDsCustom[0] },
                @{ @"uuid": uuidsMetadata[1].uuid, @"custom": expectedUUIDsCustom[1] },
            ])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                NSArray<PNChannelMember *> *members = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(members);
                XCTAssertEqual(status.operation, PNManageChannelMembersOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);

                for (PNChannelMember *member in members) {
                    for (NSUInteger idx = 0; idx < uuidsMetadata.count; idx++) {
                        PNUUIDMetadata *metadata = uuidsMetadata[idx];

                        if ([member.uuid isEqualToString:metadata.uuid]) {
                            XCTAssertEqualObjects(member.custom, expectedUUIDsCustom[idx]);
                            break;
                        }
                    }
                }

                handler();
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldSetMembersUsingManageAndNotCrashWhenCompletionBlockIsNil {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:nil];
    NSArray<NSDictionary *> *uuidsCustom = @[
        @{ @"uuid-member-custom": [@[uuidsMetadata[0].uuid, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"uuid-member-custom": [@[uuidsMetadata[1].uuid, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    NSArray<NSDictionary *> *expectedUUIDsCustom = @[
        @{ @"uuid-member-custom": [@[uuidsMetadata[0].uuid, @"custom", @"data", @"3"] componentsJoinedByString:@"-"] },
        @{ @"uuid-member-custom": [@[uuidsMetadata[1].uuid, @"custom", @"data", @"4"] componentsJoinedByString:@"-"] }
    ];

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:uuidsCustom usingClient:nil];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
            self.client.objects().manageChannelMembers(channelsMetadata.firstObject.channel)
                .includeFields(PNChannelMemberCustomField)
                .set(@[
                    @{ @"uuid": uuidsMetadata[0].uuid, @"custom": expectedUUIDsCustom[0] },
                    @{ @"uuid": uuidsMetadata[1].uuid, @"custom": expectedUUIDsCustom[1] },
                ])
                .performWithCompletion(nil);
#pragma clang diagnostic pop
        } @catch (NSException *exception) {
            handler();
        }
    }];
    
    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldSetMembersUsingManageAndReturnFilteredMembersInformationWhenFilterIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(uuidsMetadata.lastObject.name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"uuid.name like '%@*'",
                                  [uuidsMetadata.lastObject.name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    NSArray<NSDictionary *> *uuidsCustom = @[
        @{ @"uuid-member-custom": [@[uuidsMetadata[0].uuid, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"uuid-member-custom": [@[uuidsMetadata[1].uuid, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .includeCount(YES)
            .filter(filterExpression)
            .set(@[
                @{ @"uuid": uuidsMetadata[0].uuid, @"custom": uuidsCustom[0] },
                @{ @"uuid": uuidsMetadata[1].uuid, @"custom": uuidsCustom[1] },
            ])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                NSArray<PNChannelMember *> *members = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(members);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                  NSNotFound);
                XCTAssertNotNil(members.lastObject.uuid);
                XCTAssertEqualObjects(members.lastObject.metadata.custom, uuidsMetadata.lastObject.custom);

                handler();
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldSetMembersUsingManageAndReturnSortedMembersInformationWhenSortIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:4 usingClient:nil];
    NSString *expectedSort = @"uuid.name%3Adesc%2Cupdated";
    NSArray<NSDictionary *> *membershipCustom = @[
        @{ @"uuid-member-custom": [@[uuidsMetadata[0].uuid, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"uuid-member-custom": [@[uuidsMetadata[1].uuid, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];

    NSArray<PNChannelMember *> *members = [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
                                         toChannels:[channelsMetadata valueForKey:@"channel"]
                                        withCustoms:nil
                                       uuidMetadata:YES
                                        usingClient:nil];
    NSArray<PNChannelMember *> *expectedMembersOrder = [self members:members sortedWith:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:YES]
    ]];

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .includeCount(YES)
            .sort(@[@"uuid.name:desc", @"updated"])
            .set(@[
                @{ @"uuid": uuidsMetadata[0].uuid, @"custom": membershipCustom[0] },
                @{ @"uuid": uuidsMetadata[1].uuid, @"custom": membershipCustom[1] },
            ])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                NSArray<PNChannelMember *> *fetchedMembers = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(fetchedMembers);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);

                for (NSUInteger idx = 0; idx < fetchedMembers.count; idx++) {
                    XCTAssertEqualObjects(fetchedMembers[idx].metadata.name,
                                          expectedMembersOrder[idx].metadata.name);
                }

                XCTAssertNotEqualObjects([fetchedMembers valueForKeyPath:@"metadata.name"],
                                         [members valueForKeyPath:@"metadata.name"]);

                handler();
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldSetMembersUsingManageAndReturnMembersInformationWhenIncludeFlagIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:nil];
    NSArray<NSDictionary *> *membershipCustom = @[
        @{ @"uuid-member-custom": [@[uuidsMetadata[0].uuid, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"uuid-member-custom": [@[uuidsMetadata[1].uuid, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .set(@[
                @{ @"uuid": uuidsMetadata[0].uuid, @"custom": membershipCustom[0] },
                @{ @"uuid": uuidsMetadata[1].uuid, @"custom": membershipCustom[1] },
            ])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                NSArray<PNChannelMember *> *members = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(members);

                for (PNChannelMember *member in members) {
                    XCTAssertNotNil(member.metadata);

                    for (PNUUIDMetadata *metadata in uuidsMetadata) {
                        if ([member.metadata.uuid isEqualToString:metadata.uuid]) {
                            XCTAssertEqualObjects(member.metadata.custom, metadata.custom);
                            break;
                        }
                    }
                }

                handler();
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldSetMembersUsingManageAndTriggerSetEventOnChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:client1];
    NSMutableArray *updatedMembers = [NSMutableArray new];
    NSString *channel = channelsMetadata.firstObject.channel;
    NSArray<NSDictionary *> *membersCustom = @[
        @{ @"uuid-member-custom": [@[uuidsMetadata[0].uuid, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"uuid-member-custom": [@[uuidsMetadata[1].uuid, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"set");
            XCTAssertEqualObjects(event.data.type, @"membership");
            XCTAssertNotNil(event.data.membership.updated);
            XCTAssertNotNil(event.data.timestamp);

            if ([updatedMembers indexOfObject:event.data.membership.uuid] == NSNotFound) {
                [updatedMembers addObject:event.data.membership.uuid];
            }

            if (updatedMembers.count == uuidsMetadata.count) {
                XCTAssertNotEqual([updatedMembers indexOfObject:uuidsMetadata[0].uuid], NSNotFound);
                XCTAssertNotEqual([updatedMembers indexOfObject:uuidsMetadata[1].uuid], NSNotFound);
                *remove = YES;

                handler();
            }
        }];

        client1.objects().manageChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .set(@[
                @{ @"uuid": uuidsMetadata[0].uuid, @"custom": membersCustom[0] },
                @{ @"uuid": uuidsMetadata[1].uuid, @"custom": membersCustom[1] },
            ])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:client1];
    [self removeAllUUIDMetadataUsingClient:client1];
    [self removeChannelsMetadataUsingClient:client1];
}

- (void)testItShouldSetMembersUsingManageAndTriggerSetEventOnUUIDChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:client1];
    NSString *channel = uuidsMetadata.firstObject.uuid;
    NSArray<NSDictionary *> *membersCustom = @[
        @{ @"uuid-member-custom": [@[uuidsMetadata[0].uuid, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"uuid-member-custom": [@[uuidsMetadata[1].uuid, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {

            XCTAssertEqualObjects(event.data.event, @"set");
            XCTAssertEqualObjects(event.data.type, @"membership");
            XCTAssertEqualObjects(event.data.membership.channel, channelsMetadata.firstObject.channel);
            XCTAssertNotNil(event.data.membership.updated);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;

            handler();
        }];

        client1.objects().manageChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .set(@[
                @{ @"uuid": uuidsMetadata[0].uuid, @"custom": membersCustom[0] },
                @{ @"uuid": uuidsMetadata[1].uuid, @"custom": membersCustom[1] },
            ])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:client1];
    [self removeAllUUIDMetadataUsingClient:client1];
    [self removeChannelsMetadataUsingClient:client1];
}


#pragma mark - Tests :: Builder pattern-based remove members

/**
 * @brief To test 'retry' functionality
 *  'ItShouldRemoveMembersAndReceiveStatusWithExpectedOperationAndCategory.json' should
 *  be modified after cassette recording. Find first mention of member remove and copy paste
 *  4 entries which belong to it. For new entries change 'id' field to be different from source. For
 *  original response entry `Content-Type` code to `text/html`.
 */
- (void)testItShouldRemoveMembersAndReceiveStatusWithExpectedOperationAndCategory {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }

    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:nil];
    __block BOOL retried = NO;

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().removeChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberCustomField)
            .uuids(@[uuidsMetadata[0].uuid])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                if (!retried && !YHVVCR.cassette.isNewCassette) {
                    XCTAssertTrue(status.error);
                    XCTAssertEqual(status.operation, PNRemoveChannelMembersOperation);
                    XCTAssertEqual(status.category, PNMalformedResponseCategory);

                    retried = YES;
                    [status retry];
                } else {
                    NSArray<PNChannelMember *> *members = status.data.members;
                    XCTAssertFalse(status.isError);
                    XCTAssertNotNil(members);
                    XCTAssertEqual(members.count, 1);
                    XCTAssertEqualObjects(members.firstObject.uuid, uuidsMetadata[1].uuid);
                    XCTAssertEqual(status.operation, PNRemoveChannelMembersOperation);
                    XCTAssertEqual(status.category, PNAcknowledgmentCategory);

                    [self removeChannel:channelsMetadata.firstObject.channel
                    cachedMemberForUUID:uuidsMetadata[0].uuid];

                    handler();
                }
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembersAndNotCrashWhenCompletionBlockIsNil {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:nil];

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:nil];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
            self.client.objects().removeChannelMembers(channelsMetadata.firstObject.channel)
                .includeFields(PNChannelMemberCustomField)
                .uuids(@[uuidsMetadata[0].uuid])
                .performWithCompletion(nil);
#pragma clang diagnostic pop
        } @catch (NSException *exception) {
            handler();
        }
    }];
    
    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembersAndReturnFilteredMembersInformationWhenFilterIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(uuidsMetadata.lastObject.name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"uuid.name like '%@*'",
                                  [uuidsMetadata.lastObject.name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().removeChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .includeCount(YES)
            .filter(filterExpression)
            .uuids(@[uuidsMetadata[0].uuid])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                NSArray<PNChannelMember *> *members = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(members);
                XCTAssertEqual(status.data.totalCount, 1);
                XCTAssertEqual(members.count, status.data.totalCount);
                XCTAssertNotNil(members.firstObject.metadata);
                XCTAssertEqualObjects(members.firstObject.metadata.uuid, uuidsMetadata[1].uuid);
                XCTAssertEqualObjects(members.firstObject.metadata.custom, uuidsMetadata[1].custom);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                  NSNotFound);

                [self removeChannel:channelsMetadata.firstObject.channel cachedMemberForUUID:uuidsMetadata[0].uuid];

                handler();
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembersAndReturnSortedMembersInformationWhenSortIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:5 usingClient:nil];
    NSString *expectedSort = @"uuid.name%3Adesc%2Cupdated";

    NSMutableArray<PNChannelMember *> *members = [[self addMembers:[uuidsMetadata valueForKey:@"uuid"]
                                                 toChannels:[channelsMetadata valueForKey:@"channel"]
                                                withCustoms:nil
                                               uuidMetadata:YES
                                                usingClient:nil] mutableCopy];
    [members removeObjectAtIndex:0];
    NSArray<PNChannelMember *> *expectedMembersOrder = [self members:members sortedWith:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:YES]
    ]];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().removeChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .includeCount(YES)
            .sort(@[@"uuid.name:desc", @"updated"])
            .uuids(@[uuidsMetadata[0].uuid])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                NSArray<PNChannelMember *> *fetchedMembers = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(fetchedMembers);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);

                for (NSUInteger idx = 0; idx < fetchedMembers.count; idx++) {
                    XCTAssertEqualObjects(fetchedMembers[idx].metadata.name,
                                          expectedMembersOrder[idx].metadata.name);
                }

                XCTAssertNotEqualObjects([fetchedMembers valueForKeyPath:@"metadata.name"],
                                         [members valueForKeyPath:@"metadata.name"]);

                [self removeChannel:channelsMetadata.firstObject.channel cachedMemberForUUID:uuidsMetadata[0].uuid];

                handler();
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembersAndReturnMemberInformationWhenIncludeFlagIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:nil];

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().removeChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .uuids(@[uuidsMetadata[0].uuid])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                NSArray<PNChannelMember *> *members = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(members);
                XCTAssertEqual(members.count, 1);
                XCTAssertNotNil(members.firstObject.metadata);
                XCTAssertEqualObjects(members.firstObject.metadata.uuid, uuidsMetadata[1].uuid);
                XCTAssertEqualObjects(members.firstObject.metadata.custom, uuidsMetadata[1].custom);

                [self removeChannel:channelsMetadata.firstObject.channel cachedMemberForUUID:uuidsMetadata[0].uuid];

                handler();
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembersAndTriggerDeleteEventOnChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:client1];
    NSMutableArray *deletedMembers = [NSMutableArray new];
    NSString *channel = channelsMetadata.firstObject.channel;

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.type, @"membership");
            XCTAssertNotNil(event.data.timestamp);

            if ([deletedMembers indexOfObject:event.data.membership.uuid] == NSNotFound) {
                [deletedMembers addObject:event.data.membership.uuid];
            }

            if (deletedMembers.count == uuidsMetadata.count) {
                XCTAssertNotEqual([deletedMembers indexOfObject:uuidsMetadata[0].uuid], NSNotFound);
                XCTAssertNotEqual([deletedMembers indexOfObject:uuidsMetadata[1].uuid], NSNotFound);
                *remove = YES;

                handler();
            }
        }];

        client1.objects().removeChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .uuids(@[uuidsMetadata[0].uuid, uuidsMetadata[1].uuid])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self removeAllUUIDMetadataUsingClient:client1];
    [self removeChannelsMetadataUsingClient:client1];
}

- (void)testItShouldRemoveMembersAndTriggerDeleteEventOnUUIDChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:client1];
    NSString *channel = uuidsMetadata.firstObject.uuid;

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.type, @"membership");
            XCTAssertEqualObjects(event.data.membership.uuid, uuidsMetadata.firstObject.uuid);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;

            handler();
        }];

        client1.objects().removeChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .uuids(@[uuidsMetadata[0].uuid, uuidsMetadata[1].uuid])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self removeAllUUIDMetadataUsingClient:client1];
    [self removeChannelsMetadataUsingClient:client1];
}


#pragma mark - Tests :: Builder pattern-based manage remove members

/**
 * @brief To test 'retry' functionality
 *  'ItShouldRemoveMembersUsingManageAndReceiveStatusWithExpectedOperationAndCategory.json' should
 *  be modified after cassette recording. Find first mention of member remove and copy paste
 *  4 entries which belong to it. For new entries change 'id' field to be different from source. For
 *  original response entry change `Content-Type` to `text/html`.
 */
- (void)testItShouldRemoveMembersUsingManageAndReceiveStatusWithExpectedOperationAndCategory {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }

    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:nil];
    __block BOOL retried = NO;

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberCustomField)
            .remove(@[uuidsMetadata[0].uuid])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                if (!retried && !YHVVCR.cassette.isNewCassette) {
                    XCTAssertTrue(status.error);
                    XCTAssertEqual(status.operation, PNManageChannelMembersOperation);
                    XCTAssertEqual(status.category, PNMalformedResponseCategory);

                    retried = YES;
                    [status retry];
                } else {
                    NSArray<PNChannelMember *> *members = status.data.members;
                    XCTAssertFalse(status.isError);
                    XCTAssertNotNil(members);
                    XCTAssertEqual(members.count, 1);
                    XCTAssertEqualObjects(members.firstObject.uuid, uuidsMetadata[1].uuid);
                    XCTAssertEqual(status.operation, PNManageChannelMembersOperation);
                    XCTAssertEqual(status.category, PNAcknowledgmentCategory);

                    [self removeChannel:channelsMetadata.firstObject.channel
                    cachedMemberForUUID:uuidsMetadata[0].uuid];

                    handler();
                }
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembersUsingManageAndNotCrashWhenCompletionBlockIsNil {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:nil];

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:nil];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
            self.client.objects().manageChannelMembers(channelsMetadata.firstObject.channel)
                .includeFields(PNChannelMemberCustomField)
                .remove(@[uuidsMetadata[0].uuid])
                .performWithCompletion(nil);
#pragma clang diagnostic pop
        } @catch (NSException *exception) {
            handler();
        }
    }];
    
    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembersUsingManageAndReturnFilteredMembersInformationWhenFilterIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(uuidsMetadata.lastObject.name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"uuid.name like '%@*'",
                                  [uuidsMetadata.lastObject.name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .includeCount(YES)
            .filter(filterExpression)
            .remove(@[uuidsMetadata[0].uuid])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                NSArray<PNChannelMember *> *members = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(members);
                XCTAssertEqual(status.data.totalCount, 1);
                XCTAssertEqual(members.count, status.data.totalCount);
                XCTAssertNotNil(members.firstObject.metadata);
                XCTAssertEqualObjects(members.firstObject.metadata.uuid, uuidsMetadata[1].uuid);
                XCTAssertEqualObjects(members.firstObject.metadata.custom, uuidsMetadata[1].custom);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                  NSNotFound);

                [self removeChannel:channelsMetadata.firstObject.channel cachedMemberForUUID:uuidsMetadata[0].uuid];

                handler();
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembersUsingManageAndReturnSortedMembersInformationWhenSortIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:5 usingClient:nil];
    NSString *expectedSort = @"uuid.name%3Adesc%2Cupdated";

    NSMutableArray<PNChannelMember *> *members = [[self addMembers:[uuidsMetadata valueForKey:@"uuid"]
                                                 toChannels:[channelsMetadata valueForKey:@"channel"]
                                                withCustoms:nil
                                               uuidMetadata:YES
                                                usingClient:nil] mutableCopy];
    NSMutableArray<PNChannelMember *> *expectedMembersOrder = [[self members:members sortedWith:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:YES]
    ]] mutableCopy];
    [expectedMembersOrder removeObjectAtIndex:0];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .includeCount(YES)
            .sort(@[@"uuid.name:desc", @"updated"])
            .remove(@[uuidsMetadata[0].uuid])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                NSArray<PNChannelMember *> *fetchedMembers = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(fetchedMembers);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);

                for (NSUInteger idx = 0; idx < fetchedMembers.count; idx++) {
                    XCTAssertEqualObjects(fetchedMembers[idx].metadata.name,
                                          expectedMembersOrder[idx].metadata.name);
                }

                XCTAssertNotEqualObjects([fetchedMembers valueForKeyPath:@"metadata.name"],
                                         [members valueForKeyPath:@"metadata.name"]);

                [self removeChannel:channelsMetadata.firstObject.channel cachedMemberForUUID:uuidsMetadata[0].uuid];

                handler();
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembersUsingManageAndReturnMemberInformationWhenIncludeFlagIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:nil];

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .remove(@[uuidsMetadata[0].uuid])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                NSArray<PNChannelMember *> *members = status.data.members;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(members);
                XCTAssertEqual(members.count, 1);
                XCTAssertNotNil(members.firstObject.metadata);
                XCTAssertEqualObjects(members.firstObject.metadata.uuid, uuidsMetadata[1].uuid);
                XCTAssertEqualObjects(members.firstObject.metadata.custom, uuidsMetadata[1].custom);

                [self removeChannel:channelsMetadata.firstObject.channel cachedMemberForUUID:uuidsMetadata[0].uuid];

                handler();
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembersUsingManageAndTriggerDeleteEventOnChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:client1];
    NSMutableArray *deletedMembers = [NSMutableArray new];
    NSString *channel = channelsMetadata.firstObject.channel;

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.type, @"membership");
            XCTAssertNotNil(event.data.timestamp);

            if ([deletedMembers indexOfObject:event.data.membership.uuid] == NSNotFound) {
                [deletedMembers addObject:event.data.membership.uuid];
            }

            if (deletedMembers.count == uuidsMetadata.count) {
                XCTAssertNotEqual([deletedMembers indexOfObject:uuidsMetadata[0].uuid], NSNotFound);
                XCTAssertNotEqual([deletedMembers indexOfObject:uuidsMetadata[1].uuid], NSNotFound);
                *remove = YES;

                handler();
            }
        }];

        client1.objects().manageChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .remove(@[uuidsMetadata[0].uuid, uuidsMetadata[1].uuid])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self removeAllUUIDMetadataUsingClient:client1];
    [self removeChannelsMetadataUsingClient:client1];
}

- (void)testItShouldRemoveMembersUsingManageAndTriggerDeleteEventOnUUIDChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:client1];
    NSString *channel = uuidsMetadata.firstObject.uuid;

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.type, @"membership");
            XCTAssertEqualObjects(event.data.membership.uuid, uuidsMetadata.firstObject.uuid);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;

            handler();
        }];

        client1.objects().manageChannelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .remove(@[uuidsMetadata[0].uuid, uuidsMetadata[1].uuid])
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self removeAllUUIDMetadataUsingClient:client1];
    [self removeChannelsMetadataUsingClient:client1];
}


#pragma mark - Tests :: Builder pattern-based fetch members

/**
 * @brief To test 'retry' functionality
 *  'ItShouldFetchMembersAndReceiveResultWithExpectedOperation.json' should
 *  be modified after cassette recording. Find first mention of members fetch and copy paste
 *  4 entries which belong to it. For new entries change 'id' field to be different from source. For
 *  original response entry change `Content-Type` to `text/html`.
 */
- (void)testItShouldFetchMembersAndReceiveResultWithExpectedOperation {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }

    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:6 usingClient:nil];
    __block BOOL retried = NO;

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().channelMembers(channelsMetadata.firstObject.channel)
            .includeCount(NO)
            .performWithCompletion(^(PNFetchChannelMembersResult *result, PNErrorStatus *status) {
                if (!retried && !YHVVCR.cassette.isNewCassette) {
                    XCTAssertTrue(status.error);
                    XCTAssertEqual(status.operation, PNFetchChannelMembersOperation);
                    XCTAssertEqual(status.category, PNMalformedResponseCategory);

                    retried = YES;
                    [status retry];
                } else {
                    NSArray<PNChannelMember *> *members = result.data.members;
                    XCTAssertNil(status);
                    XCTAssertNotNil(members);
                    XCTAssertEqual(members.count, uuidsMetadata.count);
                    XCTAssertEqual(result.data.totalCount, 0);
                    XCTAssertEqual(result.operation, PNFetchChannelMembersOperation);

                    handler();
                }
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldFetchFilteredMembersWhenFilterIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:6 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(uuidsMetadata[3].name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"uuid.name like '%@*'",
                                  [uuidsMetadata[3].name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().channelMembers(channelsMetadata.firstObject.channel)
            .includeCount(YES)
            .filter(filterExpression)
            .performWithCompletion(^(PNFetchChannelMembersResult *result, PNErrorStatus *status) {
                NSURLRequest *request = [result valueForKey:@"clientRequest"];
                NSArray<PNChannelMember *> *members = result.data.members;
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

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldFetchOrderedMembersWhenOrderIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:6 usingClient:nil];
    NSString *expectedSort = @"uuid.name%3Adesc%2Cupdated";

    NSArray<PNChannelMember *> *members = [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
                                         toChannels:[channelsMetadata valueForKey:@"channel"]
                                        withCustoms:nil
                                       uuidMetadata:YES
                                        usingClient:nil];
    NSArray<PNChannelMember *> *expectedMembersOrder = [self members:members sortedWith:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:YES]
    ]];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().channelMembers(channelsMetadata.firstObject.channel)
            .includeFields(PNChannelMemberUUIDField|PNChannelMemberUUIDCustomField)
            .includeCount(YES)
            .sort(@[@"uuid.name:desc", @"updated"])
            .performWithCompletion(^(PNFetchChannelMembersResult *result, PNErrorStatus *status) {
                NSURLRequest *request = [result valueForKey:@"clientRequest"];
                NSArray<PNChannelMember *> *fetchedMembers = result.data.members;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedMembers);
                XCTAssertNil(result.data.prev);
                XCTAssertNotNil(result.data.next);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);

                for (NSUInteger idx = 0; idx < fetchedMembers.count; idx++) {
                    XCTAssertEqualObjects(fetchedMembers[idx].metadata.name,
                                          expectedMembersOrder[idx].metadata.name);
                }

                XCTAssertNotEqualObjects([fetchedMembers valueForKeyPath:@"metadata.name"],
                                         [members valueForKeyPath:@"metadata.name"]);

                handler();
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldFetchMembersWhenLimitIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:6 usingClient:nil];
    NSArray<NSDictionary *> *membersCustom = @[
        @{ @"uuid-member-custom": [@[uuidsMetadata[0].uuid, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"uuid-member-custom": [@[uuidsMetadata[1].uuid, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    NSUInteger expectedCount = 2;

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:membersCustom
         usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().channelMembers(channelsMetadata.firstObject.channel)
            .limit(expectedCount)
            .includeFields(PNChannelMemberCustomField)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchChannelMembersResult *result, PNErrorStatus *status) {
                NSArray<PNChannelMember *> *members = result.data.members;
                XCTAssertNil(status);
                XCTAssertNotNil(members);
                XCTAssertEqual(members.count, expectedCount);
                XCTAssertEqual(result.data.totalCount, uuidsMetadata.count);
                XCTAssertNotNil(members.firstObject.custom);

                handler();
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldFetchNextMembershipPageWhenStartAndLimitIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:6 usingClient:nil];
    __block NSString *next = nil;

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().channelMembers(channelsMetadata.firstObject.channel)
            .limit(uuidsMetadata.count - 2)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchChannelMembersResult *result, PNErrorStatus *status) {
                NSArray<PNChannelMember *> *members = result.data.members;
                XCTAssertNil(status);
                XCTAssertNotNil(members);
                XCTAssertEqual(members.count, uuidsMetadata.count - 2);
                next = result.data.next;

                handler();
            });
    }];

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().channelMembers(channelsMetadata.firstObject.channel)
            .start(next)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchChannelMembersResult *result, PNErrorStatus *status) {
                NSArray<PNChannelMember *> *members = result.data.members;
                XCTAssertNil(status);
                XCTAssertNotNil(members);
                XCTAssertEqual(members.count, 2);

                handler();
            });
    }];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}


#pragma mark - Tests :: Member events

- (void)testItShouldTriggerSetMemberEventOnChannelWhenUUIDMetadataDataChanged {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:client1];
    NSString *channel = channelsMetadata.firstObject.channel;
    NSArray<NSDictionary *> *membersCustom = @[
        @{ @"uuid-custom": [@[uuidsMetadata[0].uuid, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"uuid-custom": [@[uuidsMetadata[1].uuid, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"set");
            XCTAssertEqualObjects(event.data.type, @"uuid");
            XCTAssertEqualObjects(event.data.uuidMetadata.uuid, uuidsMetadata.firstObject.uuid);
            XCTAssertNotNil(event.data.uuidMetadata.updated);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;

            handler();
        }];

        client1.objects().setUUIDMetadata()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNUUIDCustomField)
            .custom(membersCustom[0])
            .performWithCompletion(^(PNSetUUIDMetadataStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldTriggerDeleteMemberEventOnChannelWhenUUIDMetadataRemoved {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:1 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:2 usingClient:client1];
    NSString *channel = channelsMetadata.firstObject.channel;

    [self addMembers:[uuidsMetadata valueForKey:@"uuid"]
          toChannels:[channelsMetadata valueForKey:@"channel"]
         withCustoms:nil
         usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.type, @"uuid");
            XCTAssertEqualObjects(event.data.uuidMetadata.uuid, uuidsMetadata.firstObject.uuid);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;

            handler();
        }];

        client1.objects().removeUUIDMetadata()
            .uuid(uuidsMetadata.firstObject.uuid)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self removeChannel:channelsMetadata.firstObject.channel membersObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}


#pragma mark - Misc

- (NSArray<NSDictionary *> *)flattenedMembers:(NSArray<PNChannelMember *> *)members {
    NSMutableArray *flattenedMembers = [NSMutableArray new];

    for (PNChannelMember *member in members) {
        [flattenedMembers addObject:@{
            @"name": member.metadata.name,
            @"updated": member.updated
        }];
    }

    return flattenedMembers;
}

- (NSArray<PNChannelMember *> *)members:(NSArray<PNChannelMember *> *)members
                      sortedWith:(NSArray<NSSortDescriptor *> *)sortDescriptors {

    NSMutableArray *sortedMembers = [NSMutableArray new];
    NSArray *flattenedMembers = [self flattenedMembers:members];
    NSArray *sortedFlattenedMembers = [flattenedMembers sortedArrayUsingDescriptors:sortDescriptors];

    for (NSDictionary *flattenedMember in sortedFlattenedMembers) {
        for (PNChannelMember *member in members) {
            if ([member.metadata.name isEqualToString:flattenedMember[@"name"]]) {
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
