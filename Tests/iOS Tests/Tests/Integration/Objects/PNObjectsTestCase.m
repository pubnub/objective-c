/**
 * @author Serhii Mamontov
 * @copyright © 2009-2019 PubNub, Inc.
 */
#import "PNObjectsTestCase.h"
#import <PubNub/PubNub.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNObjectsTestCase ()

#pragma mark - Information

/**
 * @brief Client which can be used to generate events.
 */
@property (nonatomic, strong) PubNub *client1;

/**
 * @brief Client which can be used to handle and verify actions of first client.
 */
@property (nonatomic, strong) PubNub *client2;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNObjectsTestCase

- (void)setUp {
    [super setUp];
    
    
    dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:self.publishKey
                                                                     subscribeKey:self.subscribeKey];
    
    self.client1 = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
    self.client2 = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
}

- (void)tearDown {
    [self removeAllHandlersForClient:self.client1];
    
    if (self.client2) {
        [self removeAllHandlersForClient:self.client2];
        [self.client2 removeListener:self];
    }
    
    [self.client1 removeListener:self];
    
    
    [super tearDown];
}


#pragma mark - Objects helper

- (void)subscribeOnObjectChannels:(NSArray<NSString *> *)channels {
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client2
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {

            if (status.category == PNConnectedCategory) {
                *remove = YES;
                
                handler();
            }
        }];
        
        self.client2.subscribe().channels(channels).perform();
    }];
}

- (NSArray<NSDictionary *> *)createTestSpaces {
    NSMutableArray<NSDictionary *> *spaces = [NSMutableArray new];
    
    for (NSUInteger spaceIdx = 0; spaceIdx < self.testSpacesCount; spaceIdx++) {
        [spaces addObject:@{
            @"id": [NSUUID UUID].UUIDString,
            @"name": [NSUUID UUID].UUIDString,
            @"custom": @{
                @"space-custom1": [NSUUID UUID].UUIDString,
                @"space-custom2": [NSUUID UUID].UUIDString
            }
        }];
    }
    
    for (NSDictionary *space in spaces) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            self.client1.createSpace().spaceId(space[@"id"]).name(space[@"name"]).custom(space[@"custom"])
                .performWithCompletion(^(PNCreateSpaceStatus *status) {
                    
                    handler();
                });
        }];
    }
    
    return spaces;
}

- (NSArray<NSDictionary *> *)createTestUsers {
    NSMutableArray<NSDictionary *> *users = [NSMutableArray new];
    
    for (NSUInteger userIdx = 0; userIdx < self.testUsersCount; userIdx++) {
        [users addObject:@{
            @"id": [NSUUID UUID].UUIDString,
            @"name": [NSUUID UUID].UUIDString,
            @"custom": @{
                @"user-custom1": [NSUUID UUID].UUIDString,
                @"user-custom2": [NSUUID UUID].UUIDString
            }
        }];
    }
    
    for (NSDictionary *user in users) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            self.client1.createUser().userId(user[@"id"]).name(user[@"name"]).custom(user[@"custom"])
                .performWithCompletion(^(PNCreateUserStatus *status) {
                    
                    handler();
                });
        }];
    }
    
    return users;
}

- (void)createUsersMembership:(NSArray<NSDictionary *> *)users
                     inSpaces:(NSArray<NSDictionary *> *)spaces
                  withCustoms:(NSArray<NSDictionary *> *)customs {
    
    NSMutableArray *spacesForMembership = [NSMutableArray new];
    
    for (NSUInteger spaceIdx = 0; spaceIdx < spaces.count; spaceIdx++) {
        NSMutableDictionary *spaceData = [@{ @"spaceId": spaces[spaceIdx][@"id"] } mutableCopy];
        
        if (customs && spaceIdx < customs.count) {
            spaceData[@"custom"] = customs[spaceIdx];
        }
        
        [spacesForMembership addObject:spaceData];
    }
    
    for (NSDictionary *user in users) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            self.client1.memberships().userId(user[@"id"]).add(spacesForMembership)
                .performWithCompletion(^(PNUpdateMembershipsStatus *status) {
                    XCTAssertFalse(status.isError);
                    XCTAssertNotNil(status.data.memberships);
                    handler();
                });
        }];
    }
}

- (void)addMembers:(NSArray<NSDictionary *> *)members
          toSpaces:(NSArray<NSDictionary *> *)spaces
       withCustoms:(NSArray<NSDictionary *> *)customs {
    
    NSMutableArray *spaceMembers = [NSMutableArray new];
    
    for (NSUInteger memberIdx = 0; memberIdx < members.count; memberIdx++) {
        NSMutableDictionary *memberData = [@{ @"userId": members[memberIdx][@"id"] } mutableCopy];
        
        if (customs && memberIdx < customs.count) {
            memberData[@"custom"] = customs[memberIdx];
        }
        
        [spaceMembers addObject:memberData];
    }
    
    for (NSDictionary *space in spaces) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            self.client1.members().spaceId(space[@"id"]).add(spaceMembers)
                .performWithCompletion(^(PNUpdateMembersStatus *status) {
                    XCTAssertFalse(status.isError);
                    XCTAssertNotNil(status.data.members);
                    handler();
                });
        }];
    }
}

- (void)cleanUpSpaceObjects {
    NSMutableArray<PNSpace *> *spaces = [NSMutableArray new];
    __block BOOL shouldFetchMore = YES;
    __block NSString *start = nil;
    
    while(shouldFetchMore) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            self.client1.fetchSpaces().start(start).includeCount(YES)
                .performWithCompletion(^(PNFetchSpacesResult *result, PNErrorStatus *status) {
                    shouldFetchMore = result.data.spaces.count == 100;
                    start = result.data.next;
                    
                    [spaces addObjectsFromArray:(result.data.spaces ?: @[])];
                    
                    handler();
                });
        }];
    }
    
    for (PNSpace *space in spaces) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            self.client1.deleteSpace().spaceId(space.identifier)
                .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                    if (status.isError) {
                        NSLog(@"'%@' SPACE REMOVE ERROR: %@\n%@",
                              space.identifier, status.errorData.information,
                              [status valueForKey:@"clientRequest"]);
                    }
                    
                    handler();
                });
        }];
    }
}

- (void)cleanUpUserObjects {
    NSMutableArray<PNUser *> *users = [NSMutableArray new];
    __block BOOL shouldFetchMore = YES;
    __block NSString *start = nil;
    
    while(shouldFetchMore) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            self.client1.fetchUsers().start(start).includeCount(YES)
                .performWithCompletion(^(PNFetchUsersResult *result, PNErrorStatus *status) {
                    shouldFetchMore = result.data.users.count == 100;
                    start = result.data.next;
                    
                    [users addObjectsFromArray:(result.data.users ?: @[])];
                    
                    handler();
                });
        }];
    }
    
    for (PNUser *user in users) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            self.client1.deleteUser().userId(user.identifier)
                .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                    if (status.isError) {
                        NSLog(@"'%@' USER REMOVE ERROR: %@\n%@",
                              user.identifier, status.errorData.information,
                              [status valueForKey:@"clientRequest"]);
                    }
                    
                    handler();
                });
        }];
    }
}

#pragma mark -


@end
