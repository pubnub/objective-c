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
 * @brief Flatten membership objects by extracting from channel metadata name and update date.
 *
 * @param memberships List of memberships which should be flattened.
 *
 * @return List of dictionaries which contain name from channel metadata and membership update date.
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


#pragma mark - Tests :: Builder pattern-based set membership

- (void)testItShouldSetMembershipAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    NSArray<NSDictionary *> *channels = @[
        @{
            @"channel": channelsMetadata[0].channel,
            @"custom": @{ @"uuid-membership-custom": [@[channelsMetadata[0].channel, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] }
        },
        @{
            @"channel": channelsMetadata[1].channel,
            @"custom": @{ @"uuid-membership-custom": [@[channelsMetadata[1].channel, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
        }
    ];
    __block NSArray *memberships = nil;


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().setMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipCustomField)
            .channels(channels)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(status.operation, PNSetMembershipsOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);

                for (PNMembership *membership in memberships) {
                    for (NSUInteger idx = 0; idx < channelsMetadata.count; idx++) {
                        PNChannelMetadata *metadata = channelsMetadata[idx];

                        if ([membership.channel isEqualToString:metadata.channel]) {
                            XCTAssertEqualObjects(membership.custom, channels[idx][@"custom"]);
                            break;
                        }
                    }
                }

                handler();
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjects:memberships usingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldSetMembershipAndReturnFilteredMembershipsInformationWhenFilterIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(channelsMetadata.lastObject.name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"channel.name like '%@*'",
                                  [channelsMetadata.lastObject.name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    NSArray<NSDictionary *> *channels = @[
        @{ @"channel": channelsMetadata[0].channel },
        @{ @"channel": channelsMetadata[1].channel }
    ];
    __block NSArray<PNMembership *> *memberships = nil;


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().setMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .includeCount(YES)
            .filter(filterExpression)
            .channels(channels)
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
                XCTAssertNotEqual([memberships.debugDescription rangeOfString:@"eTag"].location, NSNotFound);
                XCTAssertNotNil(memberships.firstObject.metadata);
                XCTAssertEqualObjects(memberships.firstObject.metadata.custom, channelsMetadata.lastObject.custom);

                handler();
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjects:memberships usingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

/**
 * @brief To test 'retry' functionality
 *  'ItShouldSetMembershipAndReturnSortedMembershipsInformationWhenSortIsSet.json' should
 *  be modified after cassette recording. Find first mention of membership set and copy paste
 *  4 entries which belong to it. For new entries change 'id' field to be different from source. For
 *  original response entry change status code to 404.
 */
- (void)testItShouldSetMembershipAndReturnSortedMembershipsInformationWhenSortIsSet {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    NSString *expectedSort = @"channel.name%3Adesc";
    NSArray<NSDictionary *> *channels = @[
        @{ @"channel": channelsMetadata[0].channel },
        @{ @"channel": channelsMetadata[1].channel }
    ];
    __block NSArray<PNMembership *> *memberships = nil;
    __block BOOL retried = NO;

    NSArray<PNChannelMetadata *> *expectedMembershipMembershipsOrder = [channelsMetadata sortedArrayUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]
    ]];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().setMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .includeCount(YES)
            .sort(@[@"channel.name:desc"])
            .channels(channels)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                if (!retried && !YHVVCR.cassette.isNewCassette) {
                    XCTAssertTrue(status.error);
                    XCTAssertEqual(status.operation, PNSetMembershipsOperation);
                    XCTAssertEqual(status.category, PNMalformedResponseCategory);

                    retried = YES;
                    [status retry];
                } else {
                    NSURLRequest *request = [status valueForKey:@"clientRequest"];
                    memberships = status.data.memberships;
                    XCTAssertNil(status.data.prev);
                    XCTAssertNotNil(status.data.next);
                    XCTAssertNotNil(memberships);
                    XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                      NSNotFound);

                    for (NSUInteger idx = 0; idx < memberships.count; idx++) {
                        XCTAssertEqualObjects(memberships[idx].channel,
                                              expectedMembershipMembershipsOrder[idx].channel);
                    }

                    XCTAssertNotEqualObjects([memberships valueForKeyPath:@"metadata.name"],
                                             [channelsMetadata valueForKeyPath:@"name"]);

                    handler();
                }
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjects:memberships usingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldSetMembershipAndReturnMembershipInformationWhenIncludeFlagIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    NSArray<NSDictionary *> *channels = @[
        @{ @"channel": channelsMetadata[0].channel },
        @{ @"channel": channelsMetadata[1].channel }
    ];
    __block NSArray *memberships = nil;


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().setMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .channels(channels)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(memberships);

                for (PNMembership *membership in memberships) {
                    XCTAssertNotNil(membership.metadata);

                    for (NSUInteger idx = 0; idx < channelsMetadata.count; idx++) {
                        PNChannelMetadata *metadata = channelsMetadata[idx];

                        if ([membership.metadata.channel isEqualToString:metadata.channel]) {
                            XCTAssertEqualObjects(membership.metadata.custom, metadata.custom);
                            break;
                        }
                    }
                }

                handler();
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjects:memberships usingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldSetMembershipAndTriggerSetEventOnUUIDChannel {
    NSMutableArray *createdMemberships = [NSMutableArray new];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:client1];
    NSString *channel = uuidsMetadata.firstObject.uuid;
    NSArray<NSDictionary *> *channels = @[
        @{ @"channel": channelsMetadata[0].channel },
        @{ @"channel": channelsMetadata[1].channel }
    ];
    __block NSArray *memberships = nil;

    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"set");
            XCTAssertEqualObjects(event.data.type, @"membership");
            XCTAssertNotNil(event.data.membership.updated);
            XCTAssertNotNil(event.data.timestamp);

            if ([createdMemberships indexOfObject:event.data.membership.channel] == NSNotFound) {
                [createdMemberships addObject:event.data.membership.channel];
            }

            if (createdMemberships.count == channelsMetadata.count) {
                XCTAssertNotEqual([createdMemberships indexOfObject:channelsMetadata[0].channel], NSNotFound);
                XCTAssertNotEqual([createdMemberships indexOfObject:channelsMetadata[1].channel], NSNotFound);
                *remove = YES;

                handler();
            }
        }];

        client1.objects().setMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .channels(channels)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];


    [self verifyUUIDMembershipsCount:uuidsMetadata.firstObject.uuid shouldEqualTo:channels.count
                         usingClient:client1];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjects:memberships usingClient:client1];
    [self removeAllUUIDMetadataUsingClient:client1];
    [self removeChannelsMetadataUsingClient:client1];
}

- (void)testItShouldSetMembershipAndTriggerSetEventOnChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:client1];
    NSString *channel = channelsMetadata.firstObject.channel;
    NSArray<NSDictionary *> *channels = @[
        @{ @"channel": channelsMetadata[0].channel },
        @{ @"channel": channelsMetadata[1].channel }
    ];
    __block NSArray *memberships = nil;

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

        client1.objects().setMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .channels(channels)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjects:memberships usingClient:client1];
    [self removeAllUUIDMetadataUsingClient:client1];
    [self removeChannelsMetadataUsingClient:client1];
}


#pragma mark - Tests :: Builder pattern-based manage set membership

- (void)testItShouldSetMembershipUsingManageAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    NSArray<NSDictionary *> *channels = @[
        @{
            @"channel": channelsMetadata[0].channel,
            @"custom": @{ @"uuid-membership-custom": [@[channelsMetadata[0].channel, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] }
        },
        @{
            @"channel": channelsMetadata[1].channel,
            @"custom": @{ @"uuid-membership-custom": [@[channelsMetadata[1].channel, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
        }
    ];
    __block NSArray *memberships = nil;


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipCustomField)
            .set(channels)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(status.operation, PNManageMembershipsOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);

                for (PNMembership *membership in memberships) {
                    for (NSUInteger idx = 0; idx < channelsMetadata.count; idx++) {
                        PNChannelMetadata *metadata = channelsMetadata[idx];

                        if ([membership.channel isEqualToString:metadata.channel]) {
                            XCTAssertEqualObjects(membership.custom, channels[idx][@"custom"]);
                            break;
                        }
                    }
                }

                handler();
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjects:memberships usingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldSetMembershipUsingManageAndReturnFilteredMembershipsInformationWhenFilterIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(channelsMetadata.lastObject.name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"channel.name like '%@*'",
                                  [channelsMetadata.lastObject.name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    NSArray<NSDictionary *> *channels = @[
        @{ @"channel": channelsMetadata[0].channel },
        @{ @"channel": channelsMetadata[1].channel }
    ];
    __block NSArray<PNMembership *> *memberships = nil;


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .includeCount(YES)
            .filter(filterExpression)
            .set(channels)
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
                XCTAssertNotNil(memberships.firstObject.metadata);
                XCTAssertEqualObjects(memberships.firstObject.metadata.custom, channelsMetadata.lastObject.custom);

                handler();
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjects:memberships usingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldSetMembershipUsingManageAndReturnSortedMembershipsInformationWhenSortIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    NSString *expectedSort = @"channel.name%3Adesc";
    NSArray<NSDictionary *> *channels = @[
        @{ @"channel": channelsMetadata[0].channel },
        @{ @"channel": channelsMetadata[1].channel }
    ];
    __block NSArray<PNMembership *> *memberships = nil;

    NSArray<PNChannelMetadata *> *expectedMembershipMembershipsOrder = [channelsMetadata sortedArrayUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]
    ]];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .includeCount(YES)
            .sort(@[@"channel.name:desc"])
            .set(channels)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                memberships = status.data.memberships;
                XCTAssertNil(status.data.prev);
                XCTAssertNotNil(status.data.next);
                XCTAssertNotNil(memberships);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);

                for (NSUInteger idx = 0; idx < memberships.count; idx++) {
                    XCTAssertEqualObjects(memberships[idx].channel,
                                          expectedMembershipMembershipsOrder[idx].channel);
                }

                XCTAssertNotEqualObjects([memberships valueForKeyPath:@"metadata.name"],
                                         [channelsMetadata valueForKeyPath:@"name"]);

                handler();
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjects:memberships usingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldSetMembershipUsingManageAndReturnMembershipInformationWhenIncludeFlagIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    NSArray<NSDictionary *> *channels = @[
        @{ @"channel": channelsMetadata[0].channel },
        @{ @"channel": channelsMetadata[1].channel }
    ];
    __block NSArray *memberships = nil;


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .set(channels)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(memberships);

                for (PNMembership *membership in memberships) {
                    XCTAssertNotNil(membership.metadata);

                    for (NSUInteger idx = 0; idx < channelsMetadata.count; idx++) {
                        PNChannelMetadata *metadata = channelsMetadata[idx];

                        if ([membership.metadata.channel isEqualToString:metadata.channel]) {
                            XCTAssertEqualObjects(membership.metadata.custom, metadata.custom);
                            break;
                        }
                    }
                }

                handler();
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjects:memberships usingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldSetMembershipUsingManageAndTriggerSetEventOnUUIDChannel {
    NSMutableArray *createdMemberships = [NSMutableArray new];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:client1];
    NSString *channel = uuidsMetadata.firstObject.uuid;
    NSArray<NSDictionary *> *channels = @[
        @{ @"channel": channelsMetadata[0].channel },
        @{ @"channel": channelsMetadata[1].channel }
    ];
    __block NSArray *memberships = nil;

    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"set");
            XCTAssertEqualObjects(event.data.type, @"membership");
            XCTAssertNotNil(event.data.membership.updated);
            XCTAssertNotNil(event.data.timestamp);

            if ([createdMemberships indexOfObject:event.data.membership.channel] == NSNotFound) {
                [createdMemberships addObject:event.data.membership.channel];
            }

            if (createdMemberships.count == channelsMetadata.count) {
                XCTAssertNotEqual([createdMemberships indexOfObject:channelsMetadata[0].channel], NSNotFound);
                XCTAssertNotEqual([createdMemberships indexOfObject:channelsMetadata[1].channel], NSNotFound);
                *remove = YES;

                handler();
            }
        }];

        client1.objects().manageMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .set(channels)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];


    [self verifyUUIDMembershipsCount:uuidsMetadata.firstObject.uuid shouldEqualTo:channels.count
                         usingClient:client1];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjects:memberships usingClient:client1];
    [self removeAllUUIDMetadataUsingClient:client1];
    [self removeChannelsMetadataUsingClient:client1];
}

- (void)testItShouldSetMembershipUsingManageAndTriggerSetEventOnChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:client1];
    NSString *channel = channelsMetadata.firstObject.channel;
    NSArray<NSDictionary *> *channels = @[
        @{ @"channel": channelsMetadata[0].channel },
        @{ @"channel": channelsMetadata[1].channel }
    ];
    __block NSArray *memberships = nil;

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

        client1.objects().manageMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .set(channels)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjects:memberships usingClient:client1];
    [self removeAllUUIDMetadataUsingClient:client1];
    [self removeChannelsMetadataUsingClient:client1];
}


#pragma mark - Tests :: Builder pattern-based remove membership

/**
 * @brief To test 'retry' functionality
 *  'ItShouldRemoveMembershipAndReceiveStatusWithExpectedOperationAndCategory.json' should
 *  be modified after cassette recording. Find first mention of membership remove and copy paste
 *  4 entries which belong to it. For new entries change 'id' field to be different from source. For
 *  original response entry change status code to 404.
 */
- (void)testItShouldRemoveMembershipAndReceiveStatusWithExpectedOperationAndCategory {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }

    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    __block BOOL retried = NO;

    [self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"]
                     inChannels:[channelsMetadata valueForKey:@"channel"]
                    withCustoms:nil
                    usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().removeMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipCustomField)
            .channels(@[channelsMetadata.firstObject.channel])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                if (!retried && !YHVVCR.cassette.isNewCassette) {
                    XCTAssertTrue(status.error);
                    XCTAssertEqual(status.operation, PNRemoveMembershipsOperation);
                    XCTAssertEqual(status.category, PNMalformedResponseCategory);

                    retried = YES;
                    [status retry];
                } else {
                    NSArray<PNMembership *> *memberships = status.data.memberships;
                    XCTAssertFalse(status.isError);
                    XCTAssertNotNil(memberships);
                    XCTAssertEqual(memberships.count, 1);
                    XCTAssertEqualObjects(memberships.firstObject.channel, channelsMetadata[1].channel);
                    XCTAssertEqual(status.operation, PNRemoveMembershipsOperation);
                    XCTAssertEqual(status.category, PNAcknowledgmentCategory);

                    [self removeUUID:uuidsMetadata.firstObject.uuid
          cachedMembershipForChannel:channelsMetadata[0].channel];

                    handler();
                }
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembershipAndReturnFilteredMembershipsInformationWhenFilterIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(channelsMetadata.lastObject.name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"channel.name like '%@*'",
                                  [channelsMetadata.lastObject.name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];

    [self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"]
                     inChannels:[channelsMetadata valueForKey:@"channel"]
                    withCustoms:nil
                    usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().removeMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .includeCount(YES)
            .filter(filterExpression)
            .channels(@[channelsMetadata[0].channel])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSArray<PNMembership *> *memberships = status.data.memberships;
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(status.data.totalCount, 1);
                XCTAssertEqual(memberships.count, status.data.totalCount);
                XCTAssertNotNil(memberships.firstObject.metadata);
                XCTAssertEqualObjects(memberships.firstObject.metadata.channel, channelsMetadata[1].channel);
                XCTAssertEqualObjects(memberships.firstObject.metadata.custom, channelsMetadata[1].custom);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                  NSNotFound);

                [self removeUUID:uuidsMetadata.firstObject.uuid
      cachedMembershipForChannel:channelsMetadata[0].channel];

                handler();
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembershipAndReturnSortedMembershipsInformationWhenSortedIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:5 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    NSString *expectedSort = @"channel.name%3Adesc,updated";

    NSMutableArray<PNMembership *> *memberships = [[self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"]
                                                                    inChannels:[channelsMetadata valueForKey:@"channel"]
                                                                   withCustoms:nil
                                                               channelMetadata:YES
                                                                   usingClient:nil] mutableCopy];
    [memberships removeObjectAtIndex:0];
    NSArray<PNMembership *> *expectedMembershipsOrder = [self memberships:memberships sortedWith:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:YES]
    ]];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().removeMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .includeCount(YES)
            .sort(@[@"channel.name:desc", @"updated"])
            .channels(@[channelsMetadata[0].channel])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSArray<PNMembership *> *fetchedMemberships = status.data.memberships;
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(fetchedMemberships);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);

                for (NSUInteger idx = 0; idx < fetchedMemberships.count; idx++) {
                    XCTAssertEqualObjects(fetchedMemberships[idx].metadata.name,
                                          expectedMembershipsOrder[idx].metadata.name);
                }

                XCTAssertNotEqualObjects([fetchedMemberships valueForKeyPath:@"metadata.name"],
                                         [memberships valueForKeyPath:@"metadata.name"]);

                [self removeUUID:uuidsMetadata.firstObject.uuid
      cachedMembershipForChannel:channelsMetadata[0].channel];

                handler();
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembershipAndReturnMembershipsInformationWhenIncludeFlagIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];

    [self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"]
                     inChannels:[channelsMetadata valueForKey:@"channel"]
                    withCustoms:nil
                    usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().removeMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .channels(@[channelsMetadata[0].channel])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSArray<PNMembership *> *memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(memberships.count, 1);
                XCTAssertNotNil(memberships.firstObject.metadata);
                XCTAssertEqualObjects(memberships.firstObject.metadata.channel, channelsMetadata[1].channel);
                XCTAssertEqualObjects(memberships.firstObject.metadata.custom, channelsMetadata[1].custom);

                [self removeUUID:uuidsMetadata.firstObject.uuid
      cachedMembershipForChannel:channelsMetadata[0].channel];

                handler();
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembershipAndTriggerDeleteEventOnUUIDChannel {
    NSMutableArray *deletedMemberships = [NSMutableArray new];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:client1];
    NSString *channel = uuidsMetadata.firstObject.uuid;

    [self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"]
                     inChannels:[channelsMetadata valueForKey:@"channel"]
                    withCustoms:nil
                    usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.type, @"membership");
            XCTAssertNotNil(event.data.timestamp);

            if ([deletedMemberships indexOfObject:event.data.membership.channel] == NSNotFound) {
                [deletedMemberships addObject:event.data.membership.channel];
            }

            if (deletedMemberships.count == channelsMetadata.count) {
                XCTAssertNotEqual([deletedMemberships indexOfObject:channelsMetadata[0].channel], NSNotFound);
                XCTAssertNotEqual([deletedMemberships indexOfObject:channelsMetadata[1].channel], NSNotFound);
                *remove = YES;

                handler();
            }
        }];

        client1.objects().removeMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .channels(@[channelsMetadata[0].channel, channelsMetadata[1].channel])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self removeAllUUIDMetadataUsingClient:client1];
    [self removeChannelsMetadataUsingClient:client1];
}

- (void)testItShouldRemoveMembershipAndTriggerDeleteEventOnChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:client1];
    NSString *channel = channelsMetadata.firstObject.channel;

    [self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"]
                     inChannels:[channelsMetadata valueForKey:@"channel"]
                    withCustoms:nil
                    usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {

            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.type, @"membership");
            XCTAssertEqualObjects(event.data.channel, channelsMetadata.firstObject.channel);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;

            handler();
        }];

        client1.objects().removeMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .channels(@[channelsMetadata[0].channel, channelsMetadata[1].channel])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self removeAllUUIDMetadataUsingClient:client1];
    [self removeChannelsMetadataUsingClient:client1];
}


#pragma mark - Tests :: Builder pattern-based remove membership

/**
 * @brief To test 'retry' functionality
 *  'ItShouldRemoveMembershipUsingManageAndReceiveStatusWithExpectedOperationAndCategory.json' should
 *  be modified after cassette recording. Find first mention of membership remove and copy paste
 *  4 entries which belong to it. For new entries change 'id' field to be different from source. For
 *  original response entry change status code to 404.
 */
- (void)testItShouldRemoveMembershipUsingManageAndReceiveStatusWithExpectedOperationAndCategory {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }

    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    __block BOOL retried = NO;

    [self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"]
                     inChannels:[channelsMetadata valueForKey:@"channel"]
                    withCustoms:nil
                    usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipCustomField)
            .remove(@[channelsMetadata.firstObject.channel])
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
                    XCTAssertEqualObjects(memberships.firstObject.channel, channelsMetadata[1].channel);
                    XCTAssertEqual(status.operation, PNManageMembershipsOperation);
                    XCTAssertEqual(status.category, PNAcknowledgmentCategory);

                    [self removeUUID:uuidsMetadata.firstObject.uuid
          cachedMembershipForChannel:channelsMetadata[0].channel];

                    handler();
                }
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembershipUsingManageAndReturnFilteredMembershipsInformationWhenFilterIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(channelsMetadata.lastObject.name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"channel.name like '%@*'",
                                  [channelsMetadata.lastObject.name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];

    [self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"]
                     inChannels:[channelsMetadata valueForKey:@"channel"]
                    withCustoms:nil
                    usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .includeCount(YES)
            .filter(filterExpression)
            .remove(@[channelsMetadata[0].channel])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSArray<PNMembership *> *memberships = status.data.memberships;
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(status.data.totalCount, 1);
                XCTAssertEqual(memberships.count, status.data.totalCount);
                XCTAssertNotNil(memberships.firstObject.metadata);
                XCTAssertEqualObjects(memberships.firstObject.metadata.channel, channelsMetadata[1].channel);
                XCTAssertEqualObjects(memberships.firstObject.metadata.custom, channelsMetadata[1].custom);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedFilterExpression].location,
                                  NSNotFound);

                [self removeUUID:uuidsMetadata.firstObject.uuid
      cachedMembershipForChannel:channelsMetadata[0].channel];

                handler();
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembershipUsingManageAndReturnSortedMembershipsInformationWhenSortedIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:5 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    NSString *expectedSort = @"channel.name%3Adesc,updated";

    NSMutableArray<PNMembership *> *memberships = [[self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"]
                                                                    inChannels:[channelsMetadata valueForKey:@"channel"]
                                                                   withCustoms:nil
                                                               channelMetadata:YES
                                                                   usingClient:nil] mutableCopy];
    [memberships removeObjectAtIndex:0];
    NSArray<PNMembership *> *expectedMembershipsOrder = [self memberships:memberships sortedWith:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:YES]
    ]];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .includeCount(YES)
            .sort(@[@"channel.name:desc", @"updated"])
            .remove(@[channelsMetadata[0].channel])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSArray<PNMembership *> *fetchedMemberships = status.data.memberships;
                NSURLRequest *request = [status valueForKey:@"clientRequest"];
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(fetchedMemberships);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);

                for (NSUInteger idx = 0; idx < fetchedMemberships.count; idx++) {
                    XCTAssertEqualObjects(fetchedMemberships[idx].metadata.name,
                                          expectedMembershipsOrder[idx].metadata.name);
                }

                XCTAssertNotEqualObjects([fetchedMemberships valueForKeyPath:@"metadata.name"],
                                         [memberships valueForKeyPath:@"metadata.name"]);

                [self removeUUID:uuidsMetadata.firstObject.uuid
      cachedMembershipForChannel:channelsMetadata[0].channel];

                handler();
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembershipUsingManageAndReturnMembershipsInformationWhenIncludeFlagIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];

    [self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"]
                     inChannels:[channelsMetadata valueForKey:@"channel"]
                    withCustoms:nil
                    usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .remove(@[channelsMetadata[0].channel])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                NSArray<PNMembership *> *memberships = status.data.memberships;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(memberships.count, 1);
                XCTAssertNotNil(memberships.firstObject.metadata);
                XCTAssertEqualObjects(memberships.firstObject.metadata.channel, channelsMetadata[1].channel);
                XCTAssertEqualObjects(memberships.firstObject.metadata.custom, channelsMetadata[1].custom);

                [self removeUUID:uuidsMetadata.firstObject.uuid
      cachedMembershipForChannel:channelsMetadata[0].channel];

                handler();
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldRemoveMembershipUsingManageAndTriggerDeleteEventOnUUIDChannel {
    NSMutableArray *deletedMemberships = [NSMutableArray new];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:client1];
    NSString *channel = uuidsMetadata.firstObject.uuid;

    [self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"]
                     inChannels:[channelsMetadata valueForKey:@"channel"]
                    withCustoms:nil
                    usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.type, @"membership");
            XCTAssertNotNil(event.data.timestamp);

            if ([deletedMemberships indexOfObject:event.data.membership.channel] == NSNotFound) {
                [deletedMemberships addObject:event.data.membership.channel];
            }

            if (deletedMemberships.count == channelsMetadata.count) {
                XCTAssertNotEqual([deletedMemberships indexOfObject:channelsMetadata[0].channel], NSNotFound);
                XCTAssertNotEqual([deletedMemberships indexOfObject:channelsMetadata[1].channel], NSNotFound);
                *remove = YES;

                handler();
            }
        }];

        client1.objects().manageMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .remove(@[channelsMetadata[0].channel, channelsMetadata[1].channel])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self removeAllUUIDMetadataUsingClient:client1];
    [self removeChannelsMetadataUsingClient:client1];
}

- (void)testItShouldRemoveMembershipUsingManageAndTriggerDeleteEventOnChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:client1];
    NSString *channel = channelsMetadata.firstObject.channel;

    [self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"]
                     inChannels:[channelsMetadata valueForKey:@"channel"]
                    withCustoms:nil
                    usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2
                              withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {

            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.type, @"membership");
            XCTAssertEqualObjects(event.data.channel, channelsMetadata.firstObject.channel);
            XCTAssertNotNil(event.data.timestamp);
            *remove = YES;

            handler();
        }];

        client1.objects().manageMemberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelCustomField)
            .remove(@[channelsMetadata[0].channel, channelsMetadata[1].channel])
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];

    [self removeAllUUIDMetadataUsingClient:client1];
    [self removeChannelsMetadataUsingClient:client1];
}


#pragma mark - Tests :: Builder pattern-based fetch membership

/**
 * @brief To test 'retry' functionality
 *  'ItShouldFetchMembershipsAndReceiveResultWithExpectedOperation.json' should
 *  be modified after cassette recording. Find first mention of memberships fetch and copy paste 4 entries
 *  which belong to it. For new entries change 'id' field to be different from source. For original
 *  response entry change status code to 404.
 */
- (void)testItShouldFetchMembershipsAndReceiveResultWithExpectedOperation {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:6 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    __block BOOL retried = NO;

    [self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"]
                     inChannels:[channelsMetadata valueForKey:@"channel"]
                    withCustoms:nil
                    usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().memberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                if (!retried && !YHVVCR.cassette.isNewCassette) {
                    XCTAssertTrue(status.error);
                    XCTAssertEqual(status.operation, PNFetchMembershipsOperation);
                    XCTAssertEqual(status.category, PNMalformedResponseCategory);

                    retried = YES;
                    [status retry];
                } else {
                    NSArray<PNMembership *> *memberships = result.data.memberships;
                    XCTAssertNil(status);
                    XCTAssertNotNil(memberships);
                    XCTAssertEqual(memberships.count, channelsMetadata.count);
                    XCTAssertEqual(result.data.totalCount, 0);

                    handler();
                }
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldFetchFilteredMembershipsWhenFilterIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:6 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    NSUInteger halfNameLength = (NSUInteger)(channelsMetadata[3].name.length * 0.5f);
    NSString *filterExpression = [NSString stringWithFormat:@"channel.name like '%@*'",
                                  [channelsMetadata[3].name substringToIndex:halfNameLength]];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];

    [self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"]
                     inChannels:[channelsMetadata valueForKey:@"channel"]
                    withCustoms:nil
                    usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().memberships()
            .uuid(uuidsMetadata.firstObject.uuid)
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

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldFetchSortedMembershipsWhenSortedIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:6 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    NSString *expectedSort = @"channel.name%3Adesc,updated";

    NSArray<PNMembership *> *memberships = [self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"]
                                                            inChannels:[channelsMetadata valueForKey:@"channel"]
                                                           withCustoms:nil
                                                       channelMetadata:YES
                                                           usingClient:nil];
    NSArray<PNMembership *> *expectedMembershipsOrder = [self memberships:memberships sortedWith:@[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:YES]
    ]];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().memberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .includeFields(PNMembershipChannelField|PNMembershipChannelField)
            .includeCount(YES)
            .sort(@[@"channel.name:desc", @"updated"])
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                NSArray<PNMembership *> *fetchedMemberships = result.data.memberships;
                NSURLRequest *request = [result valueForKey:@"clientRequest"];
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedMemberships);
                XCTAssertNil(result.data.prev);
                XCTAssertNotNil(result.data.next);
                XCTAssertNotEqual([request.URL.absoluteString rangeOfString:expectedSort].location,
                                  NSNotFound);

                for (NSUInteger idx = 0; idx < fetchedMemberships.count; idx++) {
                    XCTAssertEqualObjects(fetchedMemberships[idx].metadata.name,
                                          expectedMembershipsOrder[idx].metadata.name);
                }

                XCTAssertNotEqualObjects([fetchedMemberships valueForKeyPath:@"metadata.name"],
                                         [memberships valueForKeyPath:@"metadata.name"]);

                handler();
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldFetchMembershipWhenLimitIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:6 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    NSArray<NSDictionary *> *membershipCustom = @[
        @{ @"uuid-membership-custom": [@[channelsMetadata[0].channel, @"custom", @"data", @"1"] componentsJoinedByString:@"-"] },
        @{ @"uuid-membership-custom": [@[channelsMetadata[1].channel, @"custom", @"data", @"2"] componentsJoinedByString:@"-"] }
    ];
    NSUInteger expectedCount = 2;

    [self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"] inChannels:[channelsMetadata valueForKey:@"channel"] withCustoms:membershipCustom usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().memberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .limit(expectedCount)
            .includeFields(PNMembershipCustomField)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                NSArray<PNMembership *> *memberships = result.data.memberships;
                XCTAssertNil(status);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(memberships.count, expectedCount);
                XCTAssertEqual(result.data.totalCount, channelsMetadata.count);
                XCTAssertNotNil(memberships.firstObject.custom);

                handler();
            });
    }];

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}

- (void)testItShouldFetchNextMembershipPageWhenStartAndLimitIsSet {
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:6 usingClient:nil];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:nil];
    __block NSString *next = nil;

    [self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"]
                     inChannels:[channelsMetadata valueForKey:@"channel"]
                    withCustoms:nil
                    usingClient:nil];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().memberships()
            .uuid(uuidsMetadata.firstObject.uuid)
            .limit(channelsMetadata.count - 2)
            .includeCount(YES)
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                NSArray<PNMembership *> *memberships = result.data.memberships;
                XCTAssertNil(status);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(memberships.count, channelsMetadata.count - 2);
                next = result.data.next;

                handler();
            });
    }];

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().memberships()
            .uuid(uuidsMetadata.firstObject.uuid)
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

    [self removeUUID:uuidsMetadata.firstObject.uuid membershipObjectsUsingClient:nil];
    [self removeAllUUIDMetadataUsingClient:nil];
    [self removeChannelsMetadataUsingClient:nil];
}


#pragma mark - Tests :: Member events

- (void)testItShouldRemoveMemberAndTriggerUUIDDeleteOnChannel {
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray<PNChannelMetadata *> *channelsMetadata = [self setChannelsMetadata:2 usingClient:client1];
    NSArray<PNUUIDMetadata *> *uuidsMetadata = [self setUUIDMetadata:1 usingClient:client1];
    NSString *channel = channelsMetadata.firstObject.channel;

    [self createUUIDsMembership:[uuidsMetadata valueForKey:@"uuid"]
                     inChannels:[channelsMetadata valueForKey:@"channel"]
                    withCustoms:nil
                    usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addObjectHandlerForClient:client2 withBlock:^(PubNub *client, PNObjectEventResult *event, BOOL *remove) {
            
            XCTAssertEqualObjects(event.data.event, @"delete");
            XCTAssertEqualObjects(event.data.type, @"uuid");
            XCTAssertEqualObjects(event.data.channel, channelsMetadata.firstObject.channel);
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

    [self removeAllUUIDMetadataUsingClient:client1];
    [self removeChannelsMetadataUsingClient:client1];
}


#pragma mark - Misc

- (NSArray<NSDictionary *> *)flattenedMemberships:(NSArray<PNMembership *> *)memberships {
    NSMutableArray *flattenedMemberships = [NSMutableArray new];

    for (PNMembership *membership in memberships) {
        [flattenedMemberships addObject:@{
            @"name": membership.metadata.name,
            @"updated": membership.updated
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
            if ([membership.metadata.name isEqualToString:flattenedMembership[@"name"]]) {
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
