/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNAPICallBuilder+Private.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNConfiguration.h"
#import "PubNub+Objects.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PubNub (ObjectsProtected)


#pragma mark - API Builder support

/**
 * @brief Process information provider by user with builder API call and use it to send request
 * which will set UUID's metadata.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)sendSetUUIDMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to send request
 * which will remove UUID's metadata.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)sendRemoveUUIDMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to send request
 * which will fetch specific UUID's metadata.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)sendFetchUUIDMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to send request
 * which will fetch all UUIDs metadata.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)sendFetchAllUUIDsMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to send request
 * which will set channel's metadata.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)sendSetChannelMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to send request
 * which will remove channel's metadata.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)sendRemoveChannelMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to send request
 * which will fetch specific channel's metadata.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)sendFetchChannelMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to send request
 * which will fetch all channels metadata.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)sendFetchAllChannelsMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to send request
 * which will set UUID's memberships.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)sendSetMembershipsRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to send request
 * which will remove UUID's memberships.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)sendRemoveMembershipsRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to send request
 * which will manage UUID's memberships.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)sendManageMembershipsRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to send request
 * which will fetch UUID's memberships.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)sendFetchMembershipsRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to send request
 * which will set channel's members.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)sendSetChannelMembersRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to send request
 * which will remove channel's members.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)sendRemoveChannelMembersRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to send request
 * which will manage channel's members.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)sendManageChannelMembersRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to send request
 * which will fetch channel's members.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)sendFetchChannelMembersRequestUsingBuilderParameters:(NSDictionary *)parameters;


#pragma mark - Misc

/**
 * @brief Add common parameters for multi-paged request suing information passed to
 * builder-based API.
 *
 * @param request Request for which properties should be set.
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)addObjectsPaginationOptionsToRequest:(PNObjectsPaginatedRequest *)request
                      usingBuilderParameters:(NSDictionary *)parameters;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (Objects)


#pragma mark - API Builder support

- (PNObjectsAPICallBuilder *(^)(void))objects {
    PNObjectsAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;

    builder = [PNObjectsAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                   NSDictionary *parameters) {
        
        if ([flags containsObject:NSStringFromSelector(@selector(setUUIDMetadata))]) {
            [weakSelf sendSetUUIDMetadataRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(removeUUIDMetadata))]) {
            [weakSelf sendRemoveUUIDMetadataRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(uuidMetadata))]) {
            [weakSelf sendFetchUUIDMetadataRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(allUUIDMetadata))]) {
            [weakSelf sendFetchAllUUIDsMetadataRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(setChannelMetadata))]) {
            [weakSelf sendSetChannelMetadataRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(removeChannelMetadata))]) {
            [weakSelf sendRemoveChannelMetadataRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(channelMetadata))]) {
            [weakSelf sendFetchChannelMetadataRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(allChannelsMetadata))]) {
            [weakSelf sendFetchAllChannelsMetadataRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(setMemberships))]) {
            [weakSelf sendSetMembershipsRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(removeMemberships))]) {
            [weakSelf sendRemoveMembershipsRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(manageMemberships))]) {
            [weakSelf sendManageMembershipsRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(memberships))]) {
            [weakSelf sendFetchMembershipsRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(setChannelMembers))]) {
            [weakSelf sendSetChannelMembersRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(removeChannelMembers))]) {
            [weakSelf sendRemoveChannelMembersRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(manageChannelMembers))]) {
            [weakSelf sendManageChannelMembersRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(channelMembers))]) {
            [weakSelf sendFetchChannelMembersRequestUsingBuilderParameters:parameters];
        }
    }];

    return ^PNObjectsAPICallBuilder * {
        return builder;
    };
}

- (void)sendSetUUIDMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
    NSString *uuid = parameters[NSStringFromSelector(@selector(uuid))];

    PNSetUUIDMetadataRequest *request = [PNSetUUIDMetadataRequest requestWithUUID:uuid];
    request.externalId = parameters[NSStringFromSelector(@selector(externalId))];
    request.profileUrl = parameters[NSStringFromSelector(@selector(profileUrl))];
    request.custom = parameters[NSStringFromSelector(@selector(custom))];
    request.email = parameters[NSStringFromSelector(@selector(email))];
    request.name = parameters[NSStringFromSelector(@selector(name))];
    request.arbitraryQueryParameters = parameters[@"queryParam"];
    
    if (includeFields) {
        request.includeFields = (PNUUIDFields)includeFields.unsignedIntegerValue;
    }

    [self setUUIDMetadataWithRequest:request completion:parameters[@"block"]];
}

- (void)sendRemoveUUIDMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSString *uuid = parameters[NSStringFromSelector(@selector(uuid))];
    PNRemoveUUIDMetadataRequest *request = [PNRemoveUUIDMetadataRequest requestWithUUID:uuid];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self removeUUIDMetadataWithRequest:request completion:parameters[@"block"]];
}

- (void)sendFetchUUIDMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
    NSString *uuid = parameters[NSStringFromSelector(@selector(uuid))];

    PNFetchUUIDMetadataRequest *request = [PNFetchUUIDMetadataRequest requestWithUUID:uuid];
    request.arbitraryQueryParameters = parameters[@"queryParam"];
    
    if (includeFields) {
        request.includeFields = (PNUUIDFields)includeFields.unsignedIntegerValue;
    }

    [self uuidMetadataWithRequest:request completion:parameters[@"block"]];
}

- (void)sendFetchAllUUIDsMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    PNFetchAllUUIDMetadataRequest *request = [PNFetchAllUUIDMetadataRequest new];
    request.arbitraryQueryParameters = parameters[@"queryParam"];
    
    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeCount) {
        if (includeCount.boolValue) {
            request.includeFields |= PNUUIDTotalCountField;
        } else {
            request.includeFields ^= PNUUIDTotalCountField;
        }
    }

    [self allUUIDMetadataWithRequest:request completion:parameters[@"block"]];
}

- (void)sendSetChannelMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
    NSString *channel = parameters[NSStringFromSelector(@selector(channel))];

    PNSetChannelMetadataRequest *request = [PNSetChannelMetadataRequest requestWithChannel:channel];
    request.information = parameters[NSStringFromSelector(@selector(information))];
    request.custom = parameters[NSStringFromSelector(@selector(custom))];
    request.name = parameters[NSStringFromSelector(@selector(name))];
    request.arbitraryQueryParameters = parameters[@"queryParam"];
    
    if (includeFields) {
        request.includeFields = (PNChannelFields)includeFields.unsignedIntegerValue;
    }

    [self setChannelMetadataWithRequest:request completion:parameters[@"block"]];
}

- (void)sendRemoveChannelMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
    PNRemoveChannelMetadataRequest *request = [PNRemoveChannelMetadataRequest requestWithChannel:channel];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self removeChannelMetadataWithRequest:request completion:parameters[@"block"]];
}

- (void)sendFetchChannelMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
    NSString *channel = parameters[NSStringFromSelector(@selector(channel))];

    PNFetchChannelMetadataRequest *request = [PNFetchChannelMetadataRequest requestWithChannel:channel];
    request.arbitraryQueryParameters = parameters[@"queryParam"];
    
    if (includeFields) {
        request.includeFields = (PNChannelFields)includeFields.unsignedIntegerValue;
    }

    [self channelMetadataWithRequest:request completion:parameters[@"block"]];
}

- (void)sendFetchAllChannelsMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters {
    PNFetchAllChannelsMetadataRequest *request = [PNFetchAllChannelsMetadataRequest new];
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeCount) {
        if (includeCount.boolValue) {
            request.includeFields |= PNChannelTotalCountField;
        } else {
            request.includeFields ^= PNChannelTotalCountField;
        }
    }
    
    [self allChannelsMetadataWithRequest:request completion:parameters[@"block"]];
}


#pragma mark - Membership objects

- (void)sendSetMembershipsRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    NSArray *channels = parameters[NSStringFromSelector(@selector(channels))];
    NSString *uuid = parameters[NSStringFromSelector(@selector(uuid))];

    PNSetMembershipsRequest *request = [PNSetMembershipsRequest requestWithUUID:uuid channels:channels];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeCount) {
        if (includeCount.boolValue) {
            request.includeFields |= PNMembershipsTotalCountField;
        } else {
            request.includeFields ^= PNMembershipsTotalCountField;
        }
    }
    
    [self setMembershipsWithRequest:request completion:parameters[@"block"]];
}

- (void)sendRemoveMembershipsRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    NSArray *channels = parameters[NSStringFromSelector(@selector(channels))];
    NSString *uuid = parameters[NSStringFromSelector(@selector(uuid))];

    PNRemoveMembershipsRequest *request = [PNRemoveMembershipsRequest requestWithUUID:uuid channels:channels];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeCount) {
        if (includeCount.boolValue) {
            request.includeFields |= PNMembershipsTotalCountField;
        } else {
            request.includeFields ^= PNMembershipsTotalCountField;
        }
    }
    
    [self removeMembershipsWithRequest:request completion:parameters[@"block"]];
}

- (void)sendManageMembershipsRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    NSString *uuid = parameters[NSStringFromSelector(@selector(uuid))];

    PNManageMembershipsRequest *request = [PNManageMembershipsRequest requestWithUUID:uuid];
    request.removeChannels = parameters[NSStringFromSelector(@selector(remove))];
    request.setChannels = parameters[NSStringFromSelector(@selector(set))];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeCount) {
        if (includeCount.boolValue) {
            request.includeFields |= PNMembershipsTotalCountField;
        } else {
            request.includeFields ^= PNMembershipsTotalCountField;
        }
    }
    
    [self manageMembershipsWithRequest:request completion:parameters[@"block"]];
}

- (void)sendFetchMembershipsRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    NSString *uuid = parameters[NSStringFromSelector(@selector(uuid))];

    PNFetchMembershipsRequest *request = [PNFetchMembershipsRequest requestWithUUID:uuid];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeCount) {
        if (includeCount.boolValue) {
            request.includeFields |= PNMembershipsTotalCountField;
        } else {
            request.includeFields ^= PNMembershipsTotalCountField;
        }
    }
    
    [self membershipsWithRequest:request completion:parameters[@"block"]];
}

- (void)sendSetChannelMembersRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
    NSArray *uuids = parameters[NSStringFromSelector(@selector(uuids))];

    PNSetChannelMembersRequest *request = [PNSetChannelMembersRequest requestWithChannel:channel uuids:uuids];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeCount) {
        if (includeCount.boolValue) {
            request.includeFields |= PNChannelMembersTotalCountField;
        } else {
            request.includeFields ^= PNChannelMembersTotalCountField;
        }
    }

    [self setChannelMembersWithRequest:request completion:parameters[@"block"]];
}

- (void)sendRemoveChannelMembersRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
    NSArray *uuids = parameters[NSStringFromSelector(@selector(uuids))];

    PNRemoveChannelMembersRequest *request = [PNRemoveChannelMembersRequest requestWithChannel:channel uuids:uuids];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeCount) {
        if (includeCount.boolValue) {
            request.includeFields |= PNChannelMembersTotalCountField;
        } else {
            request.includeFields ^= PNChannelMembersTotalCountField;
        }
    }

    [self removeChannelMembersWithRequest:request completion:parameters[@"block"]];
}

- (void)sendManageChannelMembersRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    NSString *channel = parameters[NSStringFromSelector(@selector(channel))];

    PNManageChannelMembersRequest *request = [PNManageChannelMembersRequest requestWithChannel:channel];
    request.removeMembers = parameters[NSStringFromSelector(@selector(remove))];
    request.setMembers = parameters[NSStringFromSelector(@selector(set))];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeCount) {
        if (includeCount.boolValue) {
            request.includeFields |= PNChannelMembersTotalCountField;
        } else {
            request.includeFields ^= PNChannelMembersTotalCountField;
        }
    }

    [self manageChannelMembersWithRequest:request completion:parameters[@"block"]];
}

- (void)sendFetchChannelMembersRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    NSString *channel = parameters[NSStringFromSelector(@selector(channel))];

    PNFetchChannelMembersRequest *request = [PNFetchChannelMembersRequest requestWithChannel:channel];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeCount) {
        if (includeCount.boolValue) {
            request.includeFields |= PNChannelMembersTotalCountField;
        } else {
            request.includeFields ^= PNChannelMembersTotalCountField;
        }
    }

    [self channelMembersWithRequest:request completion:parameters[@"block"]];
}


#pragma mark - UUID metadata object

- (void)setUUIDMetadataWithRequest:(PNSetUUIDMetadataRequest *)request
                        completion:(PNSetUUIDMetadataCompletionBlock)block {

    request.identifier = request.identifier.length ? request.identifier : self.configuration.userID;
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNSetUUIDMetadataStatus *status) {
        if (block && status.isError) {
            status.retryBlock = ^{
                [weakSelf setUUIDMetadataWithRequest:request completion:block];
            };
        }
        
        [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
    }];
}

- (void)removeUUIDMetadataWithRequest:(PNRemoveUUIDMetadataRequest *)request
                           completion:(PNRemoveUUIDMetadataCompletionBlock)block {

    request.identifier = request.identifier.length ? request.identifier : self.configuration.userID;
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNAcknowledgmentStatus *status) {
        if (block && status.isError) {
            status.retryBlock = ^{
                [weakSelf removeUUIDMetadataWithRequest:request completion:block];
            };
        }
        
        [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
    }];
}

- (void)uuidMetadataWithRequest:(PNFetchUUIDMetadataRequest *)request
                     completion:(PNFetchUUIDMetadataCompletionBlock)block {

    request.identifier = request.identifier.length ? request.identifier : self.configuration.userID;
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request
          withCompletion:^(PNFetchUUIDMetadataResult *result, PNErrorStatus *status) {
              
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf uuidMetadataWithRequest:request completion:block];
            };
        }
        
        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
    }];
}

- (void)allUUIDMetadataWithRequest:(PNFetchAllUUIDMetadataRequest *)request
                        completion:(PNFetchAllUUIDMetadataCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request
          withCompletion:^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {
        
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf allUUIDMetadataWithRequest:request completion:block];
            };
        }
        
        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
    }];
}

#pragma mark - Channel metadata object

- (void)setChannelMetadataWithRequest:(PNSetChannelMetadataRequest *)request
                           completion:(nullable PNSetChannelMetadataCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNSetChannelMetadataStatus *status) {
        if (block && status.isError) {
            status.retryBlock = ^{
                [weakSelf setChannelMetadataWithRequest:request completion:block];
            };
        }
        
        [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
    }];
}

- (void)removeChannelMetadataWithRequest:(PNRemoveChannelMetadataRequest *)request
                              completion:(nullable PNRemoveChannelMetadataCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNAcknowledgmentStatus *status) {
        if (block && status.isError) {
            status.retryBlock = ^{
                [weakSelf removeChannelMetadataWithRequest:request completion:block];
            };
        }
        
        [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
    }];
}

- (void)channelMetadataWithRequest:(PNFetchChannelMetadataRequest *)request
                        completion:(PNFetchChannelMetadataCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request
          withCompletion:^(PNFetchChannelMetadataResult *result, PNErrorStatus *status) {
        
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf channelMetadataWithRequest:request completion:block];
            };
        }
        
        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
    }];
}

- (void)allChannelsMetadataWithRequest:(PNFetchAllChannelsMetadataRequest *)request
                            completion:(PNFetchAllChannelsMetadataCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request
          withCompletion:^(PNFetchAllChannelsMetadataResult *result, PNErrorStatus *status) {
        
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf allChannelsMetadataWithRequest:request completion:block];
            };
        }
        
        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
    }];
}


#pragma mark - Membership objects

- (void)setMembershipsWithRequest:(PNSetMembershipsRequest *)request
                       completion:(nullable PNManageMembershipsCompletionBlock)block {
    
    request.identifier = request.identifier.length ? request.identifier : self.configuration.userID;
    __weak __typeof(self) weakSelf = self;

    [self performRequest:request withCompletion:^(PNManageMembershipsStatus *status) {
        if (block && status.isError) {
            status.retryBlock = ^{
                [weakSelf setMembershipsWithRequest:request completion:block];
            };
        }
        
        [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
    }];
}

- (void)removeMembershipsWithRequest:(PNRemoveMembershipsRequest *)request
                          completion:(PNManageMembershipsCompletionBlock)block {
    
    request.identifier = request.identifier.length ? request.identifier : self.configuration.userID;
    __weak __typeof(self) weakSelf = self;

    [self performRequest:request withCompletion:^(PNManageMembershipsStatus *status) {
        if (block && status.isError) {
            status.retryBlock = ^{
                [weakSelf removeMembershipsWithRequest:request completion:block];
            };
        }
        
        [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
    }];
}

- (void)manageMembershipsWithRequest:(PNManageMembershipsRequest *)request
                          completion:(PNManageMembershipsCompletionBlock)block {
    
    request.identifier = request.identifier.length ? request.identifier : self.configuration.userID;
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNManageMembershipsStatus *status) {
        if (block && status.isError) {
            status.retryBlock = ^{
                [weakSelf manageMembershipsWithRequest:request completion:block];
            };
        }
        
        [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
    }];
}

- (void)membershipsWithRequest:(PNFetchMembershipsRequest *)request
                    completion:(PNFetchMembershipsCompletionBlock)block {
    
    request.identifier = request.identifier.length ? request.identifier : self.configuration.userID;
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request
          withCompletion:^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
        
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf membershipsWithRequest:request completion:block];
            };
        }
        
        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
    }];
}

- (void)setChannelMembersWithRequest:(PNSetChannelMembersRequest *)request
                          completion:(PNManageChannelMembersCompletionBlock)block {

    __weak __typeof(self) weakSelf = self;

    [self performRequest:request withCompletion:^(PNManageChannelMembersStatus *status) {
        if (block && status.isError) {
            status.retryBlock = ^{
                [weakSelf setChannelMembersWithRequest:request completion:block];
            };
        }
        
        [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
    }];
}

- (void)removeChannelMembersWithRequest:(PNRemoveChannelMembersRequest *)request
                             completion:(PNManageChannelMembersCompletionBlock)block {

    __weak __typeof(self) weakSelf = self;

    [self performRequest:request withCompletion:^(PNManageChannelMembersStatus *status) {
        if (block && status.isError) {
            status.retryBlock = ^{
                [weakSelf removeChannelMembersWithRequest:request completion:block];
            };
        }
        
        [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
    }];
}

- (void)manageChannelMembersWithRequest:(PNManageChannelMembersRequest *)request
                             completion:(PNManageChannelMembersCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNManageChannelMembersStatus *status) {
        if (block && status.isError) {
            status.retryBlock = ^{
                [weakSelf manageChannelMembersWithRequest:request completion:block];
            };
        }
        
        [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
    }];
}

- (void)channelMembersWithRequest:(PNFetchChannelMembersRequest *)request
                       completion:(PNFetchChannelMembersCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request
          withCompletion:^(PNFetchChannelMembersResult *result, PNErrorStatus *status) {
        
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf channelMembersWithRequest:request completion:block];
            };
        }
        
        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
    }];
}


#pragma mark - Misc

- (void)addObjectsPaginationOptionsToRequest:(PNObjectsPaginatedRequest *)request
                      usingBuilderParameters:(NSDictionary *)parameters {

    NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
    NSNumber *limit = parameters[NSStringFromSelector(@selector(limit))] ?: @(100);
    request.filter = parameters[NSStringFromSelector(@selector(filter))];
    request.start = parameters[NSStringFromSelector(@selector(start))];
    request.sort = parameters[NSStringFromSelector(@selector(sort))];
    request.end = parameters[NSStringFromSelector(@selector(end))];
    request.limit = limit.unsignedIntegerValue;
    
    if (includeFields) {
        request.includeFields = includeFields.unsignedIntegerValue;
    }
}

#pragma mark -


@end
