#import "PNAppContextObjectMetadataContractTestSteps.h"


#pragma mark Interface implementation

@implementation PNAppContextObjectMetadataContractTestSteps


#pragma mark - Initialization and Configuration

- (void)setup {
    [self startCucumberHookEventsListening];

    When(@"^I (get|set|remove) (the|all) (UUID|channel) metadata( with custom)?( for current user)?$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        __block BOOL isUUIDMetadata = NO;
        __block BOOL currentUser = NO;
        __block BOOL allObjects = NO;
        __block BOOL withCustom = NO;
        [args enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger __unused idx, BOOL *stop) {
            if (!isUUIDMetadata) isUUIDMetadata = [obj containsString:@"UUID"];
            if (!currentUser) currentUser = [obj containsString:@"current user"];
            if (!withCustom) withCustom = [obj containsString:@"with custom"];
            if (!allObjects) allObjects = [obj containsString:@"all"];
        }];
        NSString *metadataId = currentUser ? nil : self.metadata[@"id"];
        __weak __typeof(self) weakSelf = self;

        [self callCodeSynchronously:^(dispatch_block_t completion) {
            if([args.firstObject isEqualToString:@"get"]) {
                if (!allObjects) {
                    if (isUUIDMetadata) {
                        PNFetchUUIDMetadataRequest *request = [PNFetchUUIDMetadataRequest requestWithUUID:metadataId];
                        if (withCustom) request.includeFields = PNUUIDCustomField;

                        [self.client uuidMetadataWithRequest:request
                                                  completion:^(PNFetchUUIDMetadataResult *result, PNErrorStatus *status) {
                            [weakSelf storeRequestResult:result];
                            [weakSelf storeRequestStatus:status];
                            completion();
                        }];
                    } else {
                        PNFetchChannelMetadataRequest *request = [PNFetchChannelMetadataRequest requestWithChannel:metadataId];
                        if (withCustom) request.includeFields = PNChannelCustomField;

                        [self.client channelMetadataWithRequest:request
                                                     completion:^(PNFetchChannelMetadataResult *result, PNErrorStatus *status) {
                            [weakSelf storeRequestResult:result];
                            [weakSelf storeRequestStatus:status];
                            completion();
                        }];
                    }
                } else {
                    if (isUUIDMetadata) {
                        PNFetchAllUUIDMetadataRequest *request = [PNFetchAllUUIDMetadataRequest new];
                        if (withCustom) request.includeFields = PNUUIDCustomField;

                        [self.client allUUIDMetadataWithRequest:request
                                                     completion:^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {
                            [weakSelf storeRequestResult:result];
                            [weakSelf storeRequestStatus:status];
                            completion();
                        }];
                    } else {
                        PNFetchAllChannelsMetadataRequest *request = [PNFetchAllChannelsMetadataRequest new];
                        if (withCustom) request.includeFields = PNChannelCustomField;

                        [self.client allChannelsMetadataWithRequest:request
                                                         completion:^(PNFetchAllChannelsMetadataResult *result, PNErrorStatus *status) {
                            [weakSelf storeRequestResult:result];
                            [weakSelf storeRequestStatus:status];
                            completion();
                        }];
                    }
                }
            } else if([args.firstObject isEqualToString:@"set"]) {
                if (isUUIDMetadata) {
                    PNSetUUIDMetadataRequest *request = [PNSetUUIDMetadataRequest requestWithUUID:metadataId];
                    if (withCustom) request.includeFields = PNUUIDCustomField;

                    [self.client setUUIDMetadataWithRequest:request completion:^(PNSetUUIDMetadataStatus *status) {
                        [weakSelf storeRequestStatus:status];
                        completion();
                    }];
                } else {
                    PNSetChannelMetadataRequest *request = [PNSetChannelMetadataRequest requestWithChannel:metadataId];
                    if (withCustom) request.includeFields = PNChannelCustomField;

                    [self.client setChannelMetadataWithRequest:request completion:^(PNSetChannelMetadataStatus *status) {
                        [weakSelf storeRequestStatus:status];
                        completion();
                    }];
                }
            } else if([args.firstObject isEqualToString:@"remove"]) {
                if (isUUIDMetadata) {
                    PNRemoveUUIDMetadataRequest *request = [PNRemoveUUIDMetadataRequest requestWithUUID:metadataId];
                    [self.client removeUUIDMetadataWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
                        [weakSelf storeRequestStatus:status];
                        completion();
                    }];
                } else {
                    PNRemoveChannelMetadataRequest *request = [PNRemoveChannelMetadataRequest requestWithChannel:metadataId];
                    [self.client removeChannelMetadataWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
                        [weakSelf storeRequestStatus:status];
                        completion();
                    }];
                }
            }

        }];
    });

    And(@"^the (UUID|channel) metadata for '(.*)' (persona|channel)( contains updated)?$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        __block BOOL shouldIncludeUpdated = NO;
        __block BOOL isUUIDMetadata = NO;

        [args enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger __unused idx, BOOL *stop) {
            if (!shouldIncludeUpdated ) shouldIncludeUpdated = [obj containsString:@"contains updated"];
            if (!isUUIDMetadata ) isUUIDMetadata = [obj containsString:@"UUID"];
        }];

        if (!shouldIncludeUpdated) {
            NSString *metadataId = args[1];

            if (isUUIDMetadata) {
                PNFetchUUIDMetadataResult *result = (PNFetchUUIDMetadataResult *)[self lastResult];
                XCTAssertEqualObjects(result.data.metadata.name, metadataId);
            } else {
                PNFetchChannelMetadataResult *result = (PNFetchChannelMetadataResult *)[self lastResult];
                XCTAssertEqualObjects(result.data.metadata.name, metadataId);
            }
        } else {
            if (isUUIDMetadata) {
                PNSetUUIDMetadataStatus *status = (PNSetUUIDMetadataStatus *)[self lastStatus];
                XCTAssertNotNil(status.data.metadata.updated);
            } else {
                PNSetChannelMetadataStatus *status = (PNSetChannelMetadataStatus *)[self lastStatus];
                XCTAssertNotNil(status.data.metadata.updated);
            }
        }
    });

    And(@"^the response contains list with '(.*)' and '(.*)' (UUID|channel) metadata$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        BOOL isUUIDMetadata = [args.lastObject containsString:@"UUID"];
        NSMutableArray *notFetchedMetadata = [args mutableCopy];
        [notFetchedMetadata removeLastObject];

        if (isUUIDMetadata) {
            PNFetchAllUUIDMetadataResult *result = (PNFetchAllUUIDMetadataResult *)[self lastResult];

            [result.data.metadata enumerateObjectsUsingBlock:^(PNUUIDMetadata *obj, NSUInteger idx, BOOL *stop) {
                [notFetchedMetadata removeObject:obj.name];
            }];
        } else {
            PNFetchAllChannelsMetadataResult *result = (PNFetchAllChannelsMetadataResult *)[self lastResult];
            [result.data.metadata enumerateObjectsUsingBlock:^(PNChannelMetadata *obj, NSUInteger idx, BOOL *stop) {
                [notFetchedMetadata removeObject:obj.name];
                // To cover error in mock file.
                [notFetchedMetadata removeObject:obj.type];
            }];
        }

        XCTAssertTrue(notFetchedMetadata.count == 0, @"%@ not fetched", notFetchedMetadata);
    });

}

#pragma mark -


@end
