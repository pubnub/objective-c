#import "PNAppContextObjectsRelationMetadataContractTestSteps.h"


#pragma mark - Interface implementation

@implementation PNAppContextObjectsRelationMetadataContractTestSteps


#pragma mark - Initialization and Configuration

- (void)setup {
    [self startCucumberHookEventsListening];

    When(@"^I (get|set|remove|manage)( the| a)? (membership|memberships|channel member|channel members)( for current user)?( including custom and)?( channel custom)?( UUID custom)?( UUID with custom)?( information)?$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        __block BOOL isMemberships = NO;
        __block BOOL objectCustom = NO;
        __block BOOL currentUser = NO;
        __block BOOL withCustom = NO;
        [args enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger __unused idx, BOOL *stop) {
            if (!objectCustom) {
                objectCustom = [obj containsString:@"UUID custom"] ||
                                [obj containsString:@"UUID with custom"] ||
                                [obj containsString:@"channel custom"];
            }
            if (!withCustom) withCustom = [obj containsString:@"including custom"];
            if (!isMemberships) isMemberships = [obj containsString:@"membership"];
            if (!currentUser) currentUser = [obj containsString:@"current user"];
        }];
        NSString *metadataId = currentUser ? nil : self.metadata[@"id"];
        __weak __typeof(self) weakSelf = self;

        [self callCodeSynchronously:^(dispatch_block_t completion) {
            if([args.firstObject isEqualToString:@"get"]) {
                if (isMemberships) {
                    PNFetchMembershipsRequest *request = [PNFetchMembershipsRequest requestWithUUID:metadataId];
                    if (withCustom) request.includeFields |= PNMembershipCustomField;
                    if (objectCustom) request.includeFields |= PNMembershipChannelCustomField;

                    [self.client membershipsWithRequest:request
                                             completion:^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                        [weakSelf storeRequestResult:result];
                        [weakSelf storeRequestStatus:status];
                        completion();
                    }];
                } else {
                    PNFetchChannelMembersRequest *request = [PNFetchChannelMembersRequest requestWithChannel:metadataId];
                    if (withCustom) request.includeFields |= PNChannelMemberCustomField;
                    if (objectCustom) request.includeFields |= PNChannelMemberUUIDCustomField;

                    [self.client channelMembersWithRequest:request
                                                completion:^(PNFetchChannelMembersResult *result, PNErrorStatus *status) {
                        [weakSelf storeRequestResult:result];
                        [weakSelf storeRequestStatus:status];
                        completion();
                    }];
                }
            } else if([args.firstObject isEqualToString:@"set"]) {
                if (isMemberships) {
                    NSDictionary *channel = @{ @"channel": self.relationMetadata[@"channel"][@"id"] };
                    PNSetMembershipsRequest *request = [PNSetMembershipsRequest requestWithUUID:metadataId channels:@[channel]];
                    if (withCustom) request.includeFields |= PNMembershipCustomField;
                    if (objectCustom) request.includeFields |= PNMembershipChannelCustomField;

                    [self.client setMembershipsWithRequest:request completion:^(PNManageMembershipsStatus *status) {
                        [weakSelf storeRequestStatus:status];
                        completion();
                    }];
                } else {
                    NSDictionary *uuid = @{ @"uuid": self.relationMetadata[@"uuid"][@"id"] };
                    PNSetChannelMembersRequest *request = [PNSetChannelMembersRequest requestWithChannel:metadataId uuids:@[uuid]];
                    if (withCustom) request.includeFields |= PNChannelMemberCustomField;
                    if (objectCustom) request.includeFields |= PNChannelMemberUUIDCustomField;

                    [self.client setChannelMembersWithRequest:request completion:^(PNManageChannelMembersStatus *status) {
                        [weakSelf storeRequestStatus:status];
                        completion();
                    }];
                }
            } else if([args.firstObject isEqualToString:@"remove"]) {
                if (isMemberships) {
                    PNRemoveMembershipsRequest *request = [PNRemoveMembershipsRequest requestWithUUID:metadataId
                                                                                             channels:@[self.relationMetadata[@"channel"][@"id"]]];
                    if (withCustom) request.includeFields |= PNMembershipCustomField;
                    if (objectCustom) request.includeFields |= PNMembershipChannelCustomField;

                    [self.client removeMembershipsWithRequest:request completion:^(PNManageMembershipsStatus *status) {
                        [weakSelf storeRequestStatus:status];
                        completion();
                    }];
                } else {
                    PNRemoveChannelMembersRequest *request = [PNRemoveChannelMembersRequest requestWithChannel:metadataId
                                                                                                         uuids:@[self.relationMetadata[@"uuid"][@"id"]]];
                    if (withCustom) request.includeFields |= PNChannelMemberCustomField;
                    if (objectCustom) request.includeFields |= PNChannelMemberUUIDCustomField;

                    [self.client removeChannelMembersWithRequest:request completion:^(PNManageChannelMembersStatus *status) {
                        [weakSelf storeRequestStatus:status];
                        completion();
                    }];
                }
            } else if([args.firstObject isEqualToString:@"manage"]) {
                if (isMemberships) {
                    PNManageMembershipsRequest *request = [PNManageMembershipsRequest requestWithUUID:metadataId];
                    request.removeChannels = @[@{ @"channel": self.relationMetadata[@"channel"][@"id"] }];
                    if (withCustom) request.includeFields |= PNMembershipCustomField;
                    if (objectCustom) request.includeFields |= PNMembershipChannelCustomField;

                    [self.client manageMembershipsWithRequest:request completion:^(PNManageMembershipsStatus *status) {
                        [weakSelf storeRequestStatus:status];
                        completion();
                    }];
                } else {
                    PNManageChannelMembersRequest *request = [PNManageChannelMembersRequest requestWithChannel:metadataId];
                    request.removeMembers = @[@{ @"uuid": self.relationMetadata[@"uuid"][@"id"] }];
                    if (withCustom) request.includeFields |= PNChannelMemberCustomField;
                    if (objectCustom) request.includeFields |= PNChannelMemberUUIDCustomField;

                    [self.client manageChannelMembersWithRequest:request completion:^(PNManageChannelMembersStatus *status) {
                        [weakSelf storeRequestStatus:status];
                        completion();
                    }];
                }
            }
        }];
    });

    And(@"^the response (contains|does not contain) list with '(.*)' (membership|member)$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        NSDictionary *relationMetadata = [self mockForAppContextMetadataWithName:args[1]];
        BOOL isMemberships = [args.lastObject containsString:@"membership"];
        BOOL shouldContain = [args.firstObject containsString:@"contains"];
        __block BOOL found = NO;

        if (isMemberships) {
            PNManageMembershipsStatus *status = (PNManageMembershipsStatus *)[self lastStatus];
            [status.data.memberships enumerateObjectsUsingBlock:^(PNMembership *obj, NSUInteger idx, BOOL *stop) {
                found = [obj.metadata.channel isEqual:relationMetadata[@"channel"][@"id"]];
                *stop = found;
            }];
        } else {
            PNManageChannelMembersStatus *status = (PNManageChannelMembersStatus *)[self lastStatus];
            [status.data.members enumerateObjectsUsingBlock:^(PNChannelMember *obj, NSUInteger idx, BOOL *stop) {
                found = [obj.uuid isEqual:relationMetadata[@"uuid"][@"id"]];
                *stop = found;
            }];
        }

        if (shouldContain) XCTAssertTrue(found, @"%@ not fetched", args[1]);
        else XCTAssertTrue(!found, @"%@ should not be fetched", args[1]);

    });

    And(@"^the response contains list with '(.*)' and '(.*)' (memberships|members)$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        BOOL isMemberships = [args.lastObject containsString:@"memberships"];
        NSMutableArray *notFetchedMetadata = [args mutableCopy];
        [notFetchedMetadata removeLastObject];

        if (isMemberships) {
            PNFetchMembershipsResult *result = (PNFetchMembershipsResult *)[self lastResult];

            [result.data.memberships enumerateObjectsUsingBlock:^(PNMembership *obj, NSUInteger idx, BOOL *stop) {
                NSString *channelName;

                for (NSString *expectedName in notFetchedMetadata) {
                    NSDictionary *metadata = [self mockForAppContextMetadataWithName:expectedName];
                    if ([metadata[@"channel"][@"id"] isEqual:obj.channel]) channelName = expectedName;
                }

                if (channelName) [notFetchedMetadata removeObject:channelName];
            }];
        } else {
            PNFetchChannelMembersResult *result = (PNFetchChannelMembersResult *)[self lastResult];

            [result.data.members enumerateObjectsUsingBlock:^(PNChannelMember *obj, NSUInteger idx, BOOL *stop) {
                NSString *memberName;

                for (NSString *expectedName in notFetchedMetadata) {
                    NSDictionary *metadata = [self mockForAppContextMetadataWithName:expectedName];
                    if ([metadata[@"uuid"][@"id"] isEqual:obj.uuid]) memberName = expectedName;
                }

                if (memberName) [notFetchedMetadata removeObject:memberName];
            }];
        }

        XCTAssertTrue(notFetchedMetadata.count == 0, @"%@ not fetched", notFetchedMetadata);
    });

}

#pragma mark -


@end
