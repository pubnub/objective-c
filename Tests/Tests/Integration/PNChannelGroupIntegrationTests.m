/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import "NSString+PNTest.h"


#pragma mark Interface declaration

@interface PNChannelGroupIntegrationTests : PNRecordableTestCase


#pragma mark - Information

/**
 * @brief List of channel names used in tests.
 */
@property (nonatomic, copy) NSArray<NSString *> *channels;

/**
 * @brief Channel groups names used in tests.
 */
@property (nonatomic, copy) NSString *channelGroup;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNChannelGroupIntegrationTests

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    BOOL shouldSetupVCR = [super shouldSetupVCR];
    
    if (!shouldSetupVCR) {
        NSArray<NSString *> *testNames = @[
            @"ShouldNotRemoveChannelsFromGroupAndReceiveBadRequestStatusWhenChannelGroupIsNil",
            @"ShouldNotRemoveAllChannelsFromChannelGroupAndReceiveBadRequestStatusWhenChannelGroupIsNil"
        ];
        
        shouldSetupVCR = [self.name pnt_includesAnyString:testNames];
    }
    
    return shouldSetupVCR;
}

- (void)setUp {
    [super setUp];
    
    
    [self completePubNubConfiguration:self.client];
    
    self.channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    self.channelGroup = [self channelGroupWithName:@"test-channel-group"];
}

- (void)tearDown {
    [self removeChannelGroup:self.channelGroup usingClient:nil];
    
    [super tearDown];
}


#pragma mark - Tests :: add channels to group

- (void)testItShouldAddChannelsToChannelGroupAndReceiveStatusWithExpectedOperationAndCategory {
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addChannels:self.channels toGroup:self.channelGroup
                  withCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
    
    
    [self verifyChannels:self.channels inChannelGroup:self.channelGroup shouldEqual:YES usingClient:nil];
}

- (void)testItShouldAddChannelsToChannelGroupAndNotCrashWhenCompletionBlockIsNil {
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
            [self.client addChannels:self.channels toGroup:self.channelGroup withCompletion:nil];
        } @catch (NSException *exception) {
            handler();
        }
    }];
    
    
    [self verifyChannels:self.channels inChannelGroup:self.channelGroup shouldEqual:YES usingClient:nil];
}

- (void)testItShouldAddChannelsToExistingChannelGroup {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel3", @"test-channel4"]];
    NSMutableArray *expectedChannels = [self.channels mutableCopy];
    [expectedChannels addObjectsFromArray:channels];
    
    [self addChannels:self.channels toChannelGroup:self.channelGroup usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addChannels:channels toGroup:self.channelGroup
                  withCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
    
    
    [self verifyChannels:expectedChannels inChannelGroup:self.channelGroup shouldEqual:YES usingClient:nil];
}

- (void)testItShouldNotAddChannelsToChannelGroupAndReceiveBadRequestStatusWhenChannelGroupIsNil {
    NSString *channelGroup = nil;
    __block BOOL retried = NO;
        
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToAddChannels:self.channels
                                                                                  toChannelGroup:channelGroup];
        __block __weak PNChannelGroupChangeCompletionBlock weakBlock;
        __block PNChannelGroupChangeCompletionBlock block;
        
        block =^(PNAcknowledgmentStatus *status) {
            __strong PNChannelGroupChangeCompletionBlock strongBlock = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            
            if (!retried) {
                retried = YES;
                [self.client manageChannelGroupWithRequest:request completion:strongBlock];
            } else {
                handler();
            }
        };
        
        weakBlock = block;
        [self.client manageChannelGroupWithRequest:request completion:block];
    }];
}


#pragma mark - Tests :: Builder pattern-based add channels to group

- (void)testItShouldAddChannelsToChannelGroupUsingBuilderPatternInterface {
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.stream().add()
            .channels(self.channels)
            .channelGroup(self.channelGroup)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];
        
        
    [self verifyChannels:self.channels inChannelGroup:self.channelGroup shouldEqual:YES usingClient:nil];
}


#pragma mark - Tests :: remove channels from group

- (void)testItShouldRemoveChannelsFromChannelGroupAndReceiveStatusWithExpectedOperationAndCategory {
    [self addChannels:self.channels toChannelGroup:self.channelGroup usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removeChannels:@[self.channels.firstObject] fromGroup:self.channelGroup
                     withCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.operation, PNRemoveChannelsFromGroupOperation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
    
    
    [self verifyChannels:@[self.channels.lastObject] inChannelGroup:self.channelGroup shouldEqual:YES
             usingClient:nil];
}

- (void)testItShouldRemoveChannelsFromChannelGroupAndNotCrashWhenCompletionBlockIsNil {
    [self addChannels:self.channels toChannelGroup:self.channelGroup usingClient:nil];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
            [self.client removeChannels:@[self.channels.firstObject] fromGroup:self.channelGroup withCompletion:nil];
        } @catch (NSException *exception) {
            handler();
        }
    }];
    
    
    [self verifyChannels:@[self.channels.lastObject] inChannelGroup:self.channelGroup shouldEqual:YES
             usingClient:nil];
}

- (void)testItShouldNotRemoveChannelsFromGroupAndReceiveBadRequestStatusWhenChannelGroupIsNil {
    NSString *channelGroup = nil;
    __block BOOL retried = NO;
    
    [self addChannels:self.channels toChannelGroup:self.channelGroup usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToRemoveChannels:self.channels
                                                                                   fromChannelGroup:channelGroup];
        __block __weak PNChannelGroupChangeCompletionBlock weakBlock;
        __block PNChannelGroupChangeCompletionBlock block;
        
        block = ^(PNAcknowledgmentStatus *status) {
            __strong PNChannelGroupChangeCompletionBlock strongBlock = weakBlock;
            if (!weakBlock) XCTFail(@"Completion block invalidated.");
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemoveChannelsFromGroupOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            
            if (!retried) {
                retried = YES;
                [self.client manageChannelGroupWithRequest:request completion:strongBlock];
            } else {
                handler();
            }
        };
        
        weakBlock = block;
        [self.client manageChannelGroupWithRequest:request completion:block];
    }];
        
        
    [self verifyChannels:self.channels inChannelGroup:self.channelGroup shouldEqual:YES usingClient:nil];
}


#pragma mark - Tests :: Builder pattern-based remove channels from group

- (void)testItShouldRemoveChannelsFromChannelGroupUsingBuilderPatternInterface {
    [self addChannels:self.channels toChannelGroup:self.channelGroup usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.stream().remove()
            .channels(@[self.channels.firstObject])
            .channelGroup(self.channelGroup)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertEqual(status.operation, PNRemoveChannelsFromGroupOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];
    
    
    [self verifyChannels:@[self.channels.lastObject] inChannelGroup:self.channelGroup shouldEqual:YES
             usingClient:nil];
}


#pragma mark - Tests :: remove all channels from group

- (void)testItShouldRemoveAllChannelsFromChannelGroupAndReceiveStatusWithExpectedOperationAndCategory {
    [self addChannels:self.channels toChannelGroup:self.channelGroup usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removeChannelsFromGroup:self.channelGroup
                              withCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.operation, PNRemoveGroupOperation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
    
    
    [self verifyChannels:@[] inChannelGroup:self.channelGroup shouldEqual:YES usingClient:nil];
}

- (void)testItShouldRemoveAllChannelsFromChannelGroupAndNotCrashWhenCompletionBlockIsNil {
    [self addChannels:self.channels toChannelGroup:self.channelGroup usingClient:nil];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
            [self.client removeChannelsFromGroup:self.channelGroup withCompletion:nil];
        } @catch (NSException *exception) {
            handler();
        }
    }];
    
    
    [self verifyChannels:@[] inChannelGroup:self.channelGroup shouldEqual:YES usingClient:nil];
}

- (void)testItShouldNotRemoveAllChannelsFromChannelGroupAndReceiveBadRequestStatusWhenChannelGroupIsNil {
    NSString *channelGroup = nil;
    __block BOOL retried = NO;
    
    [self addChannels:self.channels toChannelGroup:self.channelGroup usingClient:nil];
        
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToRemoveChannelGroup:channelGroup];
        __block __weak PNChannelGroupChangeCompletionBlock weakBlock;
        __block PNChannelGroupChangeCompletionBlock block;
        
        block = ^(PNAcknowledgmentStatus *status) {
            __strong PNChannelGroupChangeCompletionBlock strongBlock = weakBlock;
            if (!weakBlock) XCTFail(@"Completion block invalidated.");
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemoveGroupOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            
            if (!retried) {
                retried = YES;
                [self.client manageChannelGroupWithRequest:request completion:strongBlock];
            } else {
                handler();
            }
        };
        
        weakBlock = block;
        [self.client manageChannelGroupWithRequest:request completion:block];
    }];
        
        
    [self verifyChannels:self.channels inChannelGroup:self.channelGroup shouldEqual:YES usingClient:nil];
}


#pragma mark - Tests :: Builder pattern-based remove all channels from group

- (void)testItShouldRemoveAllChannelsFromChannelGroupUsingBuilderPatternInterface {
    [self addChannels:self.channels toChannelGroup:self.channelGroup usingClient:nil];
   
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.stream().remove()
            .channelGroup(self.channelGroup)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertEqual(status.operation, PNRemoveGroupOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];
        
        
    [self verifyChannels:@[] inChannelGroup:self.channelGroup shouldEqual:YES usingClient:nil];
}


#pragma mark - Tests :: audit channels for group

/**
 * @brief To test 'retry' functionality
 *  'testItShouldAuditChannelsToChannelGroupAndReceiveStatusWithExpectedOperationAndCategory.json' should
 *  be modified after cassette recording and 5-8 elements should be copied and pasted as 9-12 elements.
 *  For 6 element status code should be modified to 404.
 *  'id' for 9-12 entries should be changed (to be different from 5-8 entries ids).
 */
- (void)testItShouldAuditChannelGroupChannelsAndReceiveResultWithExpectedOperationAndCategory {
    NSSet *addedChannelsSet = [NSSet setWithArray:self.channels];
    __block BOOL retried = NO;
    
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    [self addChannels:self.channels toChannelGroup:self.channelGroup usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNChannelGroupFetchRequest *request = [PNChannelGroupFetchRequest requestWithChannelGroup:self.channelGroup];
        __block __weak PNGroupChannelsAuditCompletionBlock weakBlock;
        __block PNGroupChannelsAuditCompletionBlock block;
        
        block = ^(PNChannelGroupChannelsResult *result, PNErrorStatus *status) {
            __strong PNGroupChannelsAuditCompletionBlock strongBlock = weakBlock;
            if (!retried) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.operation, PNChannelsForGroupOperation);
                XCTAssertEqual(status.category, PNMalformedResponseCategory);
                
                retried = YES;
                [self.client fetchChannelsForChannelGroupWithRequest:request completion:strongBlock];
            } else {
                NSSet *fetchedChannelsSet = [NSSet setWithArray:result.data.channels];
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedChannelsSet);
                XCTAssertEqual(result.operation, PNChannelsForGroupOperation);
                XCTAssertTrue([fetchedChannelsSet isEqualToSet:addedChannelsSet]);
                
                handler();
            }
        };
        
        weakBlock = block;
        [self.client fetchChannelsForChannelGroupWithRequest:request completion:block];
    }];
}

/**
 * @brief Global channel groups disabled by default and will return empty set.
 */
- (void)testItShouldAuditChannelGroupChannelsAndFetchEmptyGlobalWhenChannelGroupNotSpecified {
    NSString *channelGroup = nil;
    
    [self addChannels:self.channels toChannelGroup:self.channelGroup usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client channelsForGroup:channelGroup
                       withCompletion:^(PNChannelGroupChannelsResult *result, PNErrorStatus *status) {
            
            PNChannelGroupsResult *channelGroupsResult = (PNChannelGroupsResult *)result;
            XCTAssertNil(status);
            XCTAssertNotNil(channelGroupsResult);
            XCTAssertEqual(channelGroupsResult.operation, PNChannelGroupsOperation);
            XCTAssertEqualObjects(channelGroupsResult.data.groups, @[]);
            
            handler();
        }];
    }];
}


#pragma mark - Tests :: Builder pattern-based audit channels for group

- (void)testItShouldAuditChannelGroupChannelsUsingBuilderPatternInterface {
    NSSet *addedChannelsSet = [NSSet setWithArray:self.channels];
    
    [self addChannels:self.channels toChannelGroup:self.channelGroup usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.stream().audit()
            .channelGroup(self.channelGroup)
            .performWithCompletion(^(PNChannelGroupChannelsResult *result, PNErrorStatus *status) {
                NSSet *fetchedChannelsSet = [NSSet setWithArray:result.data.channels];
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedChannelsSet);
                XCTAssertEqual(result.operation, PNChannelsForGroupOperation);
                XCTAssertTrue([fetchedChannelsSet isEqualToSet:addedChannelsSet]);
                
                handler();
            });
    }];
}

#pragma mark -

#pragma clang diagnostic pop

@end
