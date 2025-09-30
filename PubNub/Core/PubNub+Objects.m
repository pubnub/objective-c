#import "PubNub+Objects.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNDictionaryLogEntry+Private.h"
#import "PNStringLogEntry+Private.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNFunctions.h"
#import "PNHelpers.h"

// Deprecated
#import "PNAPICallBuilder+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PubNub (ObjectsProtected)


#pragma mark - App Context API builder interface (deprecated)

/// Process information provider by user with builder API call and use it to send request which will set UUID's
/// metadata.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)sendSetUUIDMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to send request which will remove UUID's
/// metadata.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)sendRemoveUUIDMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to send request which will fetch specific
/// UUID's metadata.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)sendFetchUUIDMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to send request which will fetch all UUIDs
/// metadata.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)sendFetchAllUUIDsMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to send request which will set channel's
/// metadata.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)sendSetChannelMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to send request which will remove channel's
/// metadata.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)sendRemoveChannelMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to send request which will fetch specific
/// channel's metadata.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)sendFetchChannelMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to send request which will fetch all channels
/// metadata.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)sendFetchAllChannelsMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to send request which will set UUID's
/// memberships.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)sendSetMembershipsRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to send request which will remove UUID's
/// memberships.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)sendRemoveMembershipsRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to send request  which will manage UUID's
/// memberships.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)sendManageMembershipsRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to send request which will fetch UUID's
/// memberships.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)sendFetchMembershipsRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to send request which will set channel's
/// members.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)sendSetChannelMembersRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to send request which will remove channel's
/// members.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)sendRemoveChannelMembersRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to send request which will manage channel's
/// members.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)sendManageChannelMembersRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to send request which will fetch channel's
/// members.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)sendFetchChannelMembersRequestUsingBuilderParameters:(NSDictionary *)parameters;


#pragma mark - Misc

/// Add common parameters for multi-paged request suing information passed to builder-based API.
///
/// - Parameters:
///   - request: Request for which properties should be set.
///   - parameters: Dictionary with information passed to builder-based API.
- (void)addObjectsPaginationOptionsToRequest:(PNObjectsPaginatedRequest *)request
                      usingBuilderParameters:(NSDictionary *)parameters;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (Objects)


#pragma mark - App Context API builder interface (deprecated)

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
    
    if (includeFields) request.includeFields = (PNUUIDFields)includeFields.unsignedIntegerValue;

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
    
    if (includeFields) request.includeFields = (PNUUIDFields)includeFields.unsignedIntegerValue;

    [self uuidMetadataWithRequest:request completion:parameters[@"block"]];
}

- (void)sendFetchAllUUIDsMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    PNFetchAllUUIDMetadataRequest *request = [PNFetchAllUUIDMetadataRequest new];
    request.arbitraryQueryParameters = parameters[@"queryParam"];
    
    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeFields) request.includeFields = (PNUUIDFields)includeFields.unsignedIntegerValue;
    if (includeCount) {
        if (includeCount.boolValue) request.includeFields |= PNUUIDTotalCountField;
        else request.includeFields ^= PNUUIDTotalCountField;
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
    
    if (includeFields) request.includeFields = (PNChannelFields)includeFields.unsignedIntegerValue;

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
    
    if (includeFields) request.includeFields = (PNChannelFields)includeFields.unsignedIntegerValue;

    [self channelMetadataWithRequest:request completion:parameters[@"block"]];
}

- (void)sendFetchAllChannelsMetadataRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
    PNFetchAllChannelsMetadataRequest *request = [PNFetchAllChannelsMetadataRequest new];
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeFields) request.includeFields = (PNChannelFields)includeFields.unsignedIntegerValue;
    if (includeCount) {
        if (includeCount.boolValue) request.includeFields |= PNChannelTotalCountField;
        else request.includeFields ^= PNChannelTotalCountField;
    }
    
    [self allChannelsMetadataWithRequest:request completion:parameters[@"block"]];
}


#pragma mark - Membership objects

- (void)sendSetMembershipsRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    NSArray *channels = parameters[NSStringFromSelector(@selector(channels))];
    NSString *uuid = parameters[NSStringFromSelector(@selector(uuid))];

    PNSetMembershipsRequest *request = [PNSetMembershipsRequest requestWithUUID:uuid channels:channels];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeFields) request.includeFields = (PNMembershipFields)includeFields.unsignedIntegerValue;
    if (includeCount) {
        if (includeCount.boolValue) request.includeFields |= PNMembershipsTotalCountField;
        else request.includeFields ^= PNMembershipsTotalCountField;
    }
    
    [self setMembershipsWithRequest:request completion:parameters[@"block"]];
}

- (void)sendRemoveMembershipsRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    NSArray *channels = parameters[NSStringFromSelector(@selector(channels))];
    NSString *uuid = parameters[NSStringFromSelector(@selector(uuid))];

    PNRemoveMembershipsRequest *request = [PNRemoveMembershipsRequest requestWithUUID:uuid channels:channels];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeFields) request.includeFields = (PNMembershipFields)includeFields.unsignedIntegerValue;
    if (includeCount) {
        if (includeCount.boolValue) request.includeFields |= PNMembershipsTotalCountField;
        else request.includeFields ^= PNMembershipsTotalCountField;
    }
    
    [self removeMembershipsWithRequest:request completion:parameters[@"block"]];
}

- (void)sendManageMembershipsRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    NSString *uuid = parameters[NSStringFromSelector(@selector(uuid))];

    PNManageMembershipsRequest *request = [PNManageMembershipsRequest requestWithUUID:uuid];
    request.removeChannels = parameters[NSStringFromSelector(@selector(remove))];
    request.setChannels = parameters[NSStringFromSelector(@selector(set))];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeFields) request.includeFields = (PNMembershipFields)includeFields.unsignedIntegerValue;
    if (includeCount) {
        if (includeCount.boolValue) request.includeFields |= PNMembershipsTotalCountField;
        else request.includeFields ^= PNMembershipsTotalCountField;
    }
    
    [self manageMembershipsWithRequest:request completion:parameters[@"block"]];
}

- (void)sendFetchMembershipsRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    NSString *uuid = parameters[NSStringFromSelector(@selector(uuid))];

    PNFetchMembershipsRequest *request = [PNFetchMembershipsRequest requestWithUUID:uuid];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeFields) request.includeFields = (PNMembershipFields)includeFields.unsignedIntegerValue;
    if (includeCount) {
        if (includeCount.boolValue) request.includeFields |= PNMembershipsTotalCountField;
        else request.includeFields ^= PNMembershipsTotalCountField;
    }
    
    [self membershipsWithRequest:request completion:parameters[@"block"]];
}

- (void)sendSetChannelMembersRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
    NSArray *uuids = parameters[NSStringFromSelector(@selector(uuids))];

    PNSetChannelMembersRequest *request = [PNSetChannelMembersRequest requestWithChannel:channel uuids:uuids];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeFields) request.includeFields = (PNChannelMemberFields)includeFields.unsignedIntegerValue;
    if (includeCount) {
        if (includeCount.boolValue) request.includeFields |= PNChannelMembersTotalCountField;
        else request.includeFields ^= PNChannelMembersTotalCountField;
    }

    [self setChannelMembersWithRequest:request completion:parameters[@"block"]];
}

- (void)sendRemoveChannelMembersRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
    NSArray *uuids = parameters[NSStringFromSelector(@selector(uuids))];

    PNRemoveChannelMembersRequest *request = [PNRemoveChannelMembersRequest requestWithChannel:channel uuids:uuids];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeFields) request.includeFields = (PNChannelMemberFields)includeFields.unsignedIntegerValue;
    if (includeCount) {
        if (includeCount.boolValue) request.includeFields |= PNChannelMembersTotalCountField;
        else request.includeFields ^= PNChannelMembersTotalCountField;
    }

    [self removeChannelMembersWithRequest:request completion:parameters[@"block"]];
}

- (void)sendManageChannelMembersRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    NSString *channel = parameters[NSStringFromSelector(@selector(channel))];

    PNManageChannelMembersRequest *request = [PNManageChannelMembersRequest requestWithChannel:channel];
    request.removeMembers = parameters[NSStringFromSelector(@selector(remove))];
    request.setMembers = parameters[NSStringFromSelector(@selector(set))];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeFields) request.includeFields = (PNChannelMemberFields)includeFields.unsignedIntegerValue;
    if (includeCount) {
        if (includeCount.boolValue) request.includeFields |= PNChannelMembersTotalCountField;
        else request.includeFields ^= PNChannelMembersTotalCountField;
    }

    [self manageChannelMembersWithRequest:request completion:parameters[@"block"]];
}

- (void)sendFetchChannelMembersRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
    NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
    NSString *channel = parameters[NSStringFromSelector(@selector(channel))];

    PNFetchChannelMembersRequest *request = [PNFetchChannelMembersRequest requestWithChannel:channel];
    request.arbitraryQueryParameters = parameters[@"queryParam"];

    [self addObjectsPaginationOptionsToRequest:request usingBuilderParameters:parameters];
    
    if (includeFields) request.includeFields = (PNChannelMemberFields)includeFields.unsignedIntegerValue;
    if (includeCount) {
        if (includeCount.boolValue) request.includeFields |= PNChannelMembersTotalCountField;
        else request.includeFields ^= PNChannelMembersTotalCountField;
    }

    [self channelMembersWithRequest:request completion:parameters[@"block"]];
}


#pragma mark - UUID metadata object

- (void)setUUIDMetadataWithRequest:(PNSetUUIDMetadataRequest *)userRequest
                        completion:(PNSetUUIDMetadataCompletionBlock)handleBlock {
    userRequest.identifier = userRequest.identifier.length ? userRequest.identifier : self.configuration.userID;
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNSetUUIDMetadataStatus class]];
    PNSetUUIDMetadataCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;
                           
    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNSetUUIDMetadataStatus *, PNSetUUIDMetadataStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Set UUID metadata object success. "
                                                                         "Removed '%@' UUID metadata object.",
                                                                         userRequest.identifier)
                                                operation:PNAppContextLogMessageOperation];
            }];
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };
                            
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Remove UUID metadata object with parameters:"
                                            operation:PNAppContextLogMessageOperation];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)removeUUIDMetadataWithRequest:(PNRemoveUUIDMetadataRequest *)userRequest
                           completion:(PNRemoveUUIDMetadataCompletionBlock)handleBlock {
    userRequest.identifier = userRequest.identifier.length ? userRequest.identifier : self.configuration.userID;
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNAcknowledgmentStatus class]];
    PNRemoveUUIDMetadataCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;
                           
    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNAcknowledgmentStatus *, PNAcknowledgmentStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                NSString *identifier = userRequest.identifier;
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Set UUID metadata object success. Updated "
                                                                         "'%@' UUID metadata object.", identifier)
                                                operation:PNAppContextLogMessageOperation];
            }];
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };
                               
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Set UUID metadata object with parameters:"
                                            operation:PNAppContextLogMessageOperation];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)uuidMetadataWithRequest:(PNFetchUUIDMetadataRequest *)userRequest
                     completion:(PNFetchUUIDMetadataCompletionBlock)handleBlock {
    userRequest.identifier = userRequest.identifier.length ? userRequest.identifier : self.configuration.userID;
    PNOperationDataParser *responseParser = [self parserWithResult:[PNFetchUUIDMetadataResult class]
                                                            status:[PNErrorStatus class]];
    PNFetchUUIDMetadataCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;
                           
    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNFetchUUIDMetadataResult *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Fetch UUID metadata object success. "
                                                                         "Received '%@' UUID metadata object.",
                                                                         userRequest.identifier)
                                                operation:PNAppContextLogMessageOperation];
            }];
        }

        [self callBlock:block status:NO withResult:result.result andStatus:result.status];
    };
                         
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Fetch UUID metadata object with parameters:"
                                            operation:PNAppContextLogMessageOperation];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)allUUIDMetadataWithRequest:(PNFetchAllUUIDMetadataRequest *)userRequest
                        completion:(PNFetchAllUUIDMetadataCompletionBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithResult:[PNFetchAllUUIDMetadataResult class]
                                                            status:[PNErrorStatus class]];
    PNFetchAllUUIDMetadataCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;
                           
    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNFetchAllUUIDMetadataResult *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Fetch all UUID metadata success. Received "
                                                                         "%@ UUID metadata objects.",
                                                                         @(result.result.data.metadata.count))
                                                operation:PNAppContextLogMessageOperation];
            }];
        }

        [self callBlock:block status:NO withResult:result.result andStatus:result.status];
    };
                            
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Fetch all UUID metadata objects with parameters:"
                                            operation:PNAppContextLogMessageOperation];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

#pragma mark - Channel metadata object

- (void)setChannelMetadataWithRequest:(PNSetChannelMetadataRequest *)userRequest
                           completion:(PNSetChannelMetadataCompletionBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNSetChannelMetadataStatus class]];
    PNSetChannelMetadataCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;
                           
    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNSetChannelMetadataStatus *, PNSetChannelMetadataStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Set Channel metadata object success. "
                                                                         "Updated '%@' Channel metadata object.",
                                                                         userRequest.identifier)
                                                operation:PNAppContextLogMessageOperation];
            }];
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };
                               
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Set Channel metadata object with parameters:"
                                            operation:PNAppContextLogMessageOperation];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)removeChannelMetadataWithRequest:(PNRemoveChannelMetadataRequest *)userRequest
                              completion:(PNRemoveChannelMetadataCompletionBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNAcknowledgmentStatus class]];
    PNRemoveChannelMetadataCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;
                           
    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNAcknowledgmentStatus *, PNAcknowledgmentStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Remove Channel metadata object success. "
                                                                         "Removed '%@' Channel metadata object.",
                                                                         userRequest.identifier)
                                                operation:PNAppContextLogMessageOperation];
            }];
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };
                                  
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Remove Channel metadata object with parameters:"
                                            operation:PNAppContextLogMessageOperation];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)channelMetadataWithRequest:(PNFetchChannelMetadataRequest *)userRequest
                        completion:(PNFetchChannelMetadataCompletionBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithResult:[PNFetchChannelMetadataResult class]
                                                            status:[PNErrorStatus class]];
    PNFetchChannelMetadataCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;
                           
    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNFetchChannelMetadataResult *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Fetch Channel metadata object success. "
                                                                         "Received '%@' Channel metadata object.",
                                                                         userRequest.identifier)
                                                operation:PNAppContextLogMessageOperation];
            }];
        }

        [self callBlock:block status:NO withResult:result.result andStatus:result.status];
    };
                            
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Fetch Channel metadata object with parameters:"
                                            operation:PNAppContextLogMessageOperation];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)allChannelsMetadataWithRequest:(PNFetchAllChannelsMetadataRequest *)userRequest
                            completion:(PNFetchAllChannelsMetadataCompletionBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithResult:[PNFetchAllChannelsMetadataResult class]
                                                            status:[PNErrorStatus class]];
    PNFetchAllChannelsMetadataCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;
                           
    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNFetchAllChannelsMetadataResult *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Fetch all Channel metadata objects success. "
                                                                         "Received %@ Channel metadata objects.",
                                                                         @(result.result.data.metadata.count))
                                                operation:PNAppContextLogMessageOperation];
            }];
        }

        [self callBlock:block status:NO withResult:result.result andStatus:result.status];
    };
                                
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Fetch all Channel metadata objects with parameters:"
                                            operation:PNAppContextLogMessageOperation];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}


#pragma mark - Membership objects

- (void)setMembershipsWithRequest:(PNSetMembershipsRequest *)userRequest
                       completion:(PNManageMembershipsCompletionBlock)handleBlock {
    userRequest.identifier = userRequest.identifier.length ? userRequest.identifier : self.configuration.userID;
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNManageMembershipsStatus class]];
    PNManageMembershipsCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;
                           
    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNManageMembershipsStatus *, PNManageMembershipsStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Set memberships success. There are %@ "
                                                                         "memberships now.",
                                                                         @(result.result.data.memberships.count))
                                                operation:PNAppContextLogMessageOperation];
            }];
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };
                           
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Set memberships with parameters:"
                                            operation:PNAppContextLogMessageOperation];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)removeMembershipsWithRequest:(PNRemoveMembershipsRequest *)userRequest
                          completion:(PNManageMembershipsCompletionBlock)handleBlock {
    userRequest.identifier = userRequest.identifier.length ? userRequest.identifier : self.configuration.userID;
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNManageMembershipsStatus class]];
    PNManageMembershipsCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;
                           
    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNManageMembershipsStatus *, PNManageMembershipsStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Remove memberships success. There are %@ "
                                                                         "memberships now.",
                                                                         @(result.result.data.memberships.count))
                                                operation:PNAppContextLogMessageOperation];
            }];
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };
                              
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Remove memberships with parameters:"
                                            operation:PNAppContextLogMessageOperation];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)manageMembershipsWithRequest:(PNManageMembershipsRequest *)userRequest
                          completion:(PNManageMembershipsCompletionBlock)handleBlock {
    userRequest.identifier = userRequest.identifier.length ? userRequest.identifier : self.configuration.userID;
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNManageMembershipsStatus class]];
    PNManageMembershipsCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;
                           
    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNManageMembershipsStatus *, PNManageMembershipsStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Manage memberships success. There are %@ "
                                                                         "memberships now.",
                                                                         @(result.result.data.memberships.count))
                                                operation:PNAppContextLogMessageOperation];
            }];
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };
                              
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Manage memberships with parameters:"
                                            operation:PNAppContextLogMessageOperation];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)membershipsWithRequest:(PNFetchMembershipsRequest *)userRequest
                    completion:(PNFetchMembershipsCompletionBlock)handleBlock {
    userRequest.identifier = userRequest.identifier.length ? userRequest.identifier : self.configuration.userID;
    PNOperationDataParser *responseParser = [self parserWithResult:[PNFetchMembershipsResult class]
                                                            status:[PNErrorStatus class]];
    PNFetchMembershipsCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;
                           
    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNFetchMembershipsResult *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Fetch memberships success. Received %@ "
                                                                         "memberships.",
                                                                         @(result.result.data.memberships.count))
                                                operation:PNAppContextLogMessageOperation];
            }];
        }

        [self callBlock:block status:NO withResult:result.result andStatus:result.status];
    };
                        
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Fetch memberships with parameters:"
                                            operation:PNAppContextLogMessageOperation];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)setChannelMembersWithRequest:(PNSetChannelMembersRequest *)userRequest
                          completion:(PNManageChannelMembersCompletionBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNManageChannelMembersStatus class]];
    PNManageChannelMembersCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;
                           
    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNManageChannelMembersStatus *, PNManageChannelMembersStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Set channel members success. There are %@ "
                                                                         "channel members now.",
                                                                         @(result.result.data.members.count))
                                                operation:PNAppContextLogMessageOperation];
            }];
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };
                              
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Set channel members with parameters:"
                                            operation:PNAppContextLogMessageOperation];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)removeChannelMembersWithRequest:(PNRemoveChannelMembersRequest *)userRequest
                             completion:(PNManageChannelMembersCompletionBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNManageChannelMembersStatus class]];
    PNManageChannelMembersCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;
                           
    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNManageChannelMembersStatus *, PNManageChannelMembersStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Remove channel members success. There are "
                                                                         "%@ channel members now.",
                                                                         @(result.result.data.members.count))
                                                operation:PNAppContextLogMessageOperation];
            }];
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };
                                 
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Remove channel members with parameters:"
                                            operation:PNAppContextLogMessageOperation];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)manageChannelMembersWithRequest:(PNManageChannelMembersRequest *)userRequest
                             completion:(PNManageChannelMembersCompletionBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNManageChannelMembersStatus class]];
    PNManageChannelMembersCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;
                           
    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNManageChannelMembersStatus *, PNManageChannelMembersStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Manage channel members success. There are "
                                                                         "%@ channel members now.",
                                                                         @(result.result.data.members.count))
                                                operation:PNAppContextLogMessageOperation];
            }];
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };
                                 
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Manage channel members with parameters:"
                                            operation:PNAppContextLogMessageOperation];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)channelMembersWithRequest:(PNFetchChannelMembersRequest *)userRequest
                       completion:(PNFetchChannelMembersCompletionBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithResult:[PNFetchChannelMembersResult class]
                                                            status:[PNErrorStatus class]];
    PNFetchChannelMembersCompletionBlock block = [handleBlock copy];
    [userRequest setupWithClientConfiguration:self.configuration];
    PNParsedRequestCompletionBlock handler;

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNFetchChannelMembersResult *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Fetch channel members success. Received %@ "
                                                                         "channel members.",
                                                                         @(result.result.data.members.count))
                                                operation:PNAppContextLogMessageOperation];
            }];
        }

        [self callBlock:block status:NO withResult:result.result andStatus:result.status];
    };
                           
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Fetch channel members with parameters:"
                                            operation:PNAppContextLogMessageOperation];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
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
    
    if (includeFields) request.includeFields = includeFields.unsignedIntegerValue;
}

#pragma mark -


@end
