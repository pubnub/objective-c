#import "PubNub+ChannelGroup.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"

// Deprecated
#import "PNAPICallBuilder+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// **PubNub** `Channel Group` APIs private extension.
@interface PubNub (ChannelGroupProtected)


#pragma mark - Channel group audition

/// Fetch list of channels which is registered in specified `group`.
///
/// - Parameters:
///   - group: Name of the group from which channels should be fetched.
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
///   - block: Channels audition completion block.
- (void)channelsForGroup:(NSString *)group
     withQueryParameters:(nullable NSDictionary *)queryParameters
              completion:(PNGroupChannelsAuditCompletionBlock)block;


#pragma mark - Channel group content manipulation

/// Add or remove channels to / from the `group`.
///
/// - Parameters:
///   - shouldAdd: Whether provided `channels` should be added to the `group` or removed.
///   - channels: List of channels names which should be used for `group` modification.
///   - group: Name of the group which should be modified with list of passed `objects`.
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
///   - block: Channel group list modification completion block.
- (void)add:(BOOL)shouldAdd
           channels:(nullable NSArray<NSString *> *)channels
            toGroup:(NSString *)group
    queryParameters:(nullable NSDictionary *)queryParameters
     withCompletion:(nullable PNChannelGroupChangeCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (ChannelGroup)


#pragma mark - API Builder support

- (PNStreamAPICallBuilder * (^)(void))stream {
    PNStreamAPICallBuilder *builder = nil;
    builder = [PNStreamAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags, NSDictionary *parameters){
        NSString *group = parameters[NSStringFromSelector(@selector(channelGroup))];
        id block = parameters[@"block"];
        
        if ([flags containsObject:NSStringFromSelector(@selector(audit))]) {
            PNChannelGroupFetchRequest *request;
            if (group.length == 0) request = [PNChannelGroupFetchRequest requestChannelGroups];
            else request = [PNChannelGroupFetchRequest requestWithChannelGroup:group];

            request.arbitraryQueryParameters = parameters[@"queryParam"];

            [self fetchChannelsForChannelGroupWithRequest:request completion:block];
        } else {
            NSArray<NSString *> *channels = parameters[NSStringFromSelector(@selector(channels))];
            BOOL adding = [flags containsObject:NSStringFromSelector(@selector(add))];
            
            PNChannelGroupManageRequest *request;
            if (channels.count == 0) request = [PNChannelGroupManageRequest requestToRemoveChannelGroup:group];
            else if (adding) request = [PNChannelGroupManageRequest requestToAddChannels:channels toChannelGroup:group];
            else if (!adding) {
                request = [PNChannelGroupManageRequest requestToRemoveChannels:channels fromChannelGroup:group];
            }

            request.arbitraryQueryParameters = parameters[@"queryParam"];

            [self manageChannelGroupWithRequest:request completion:block];
        }
    }];
    
    return ^PNStreamAPICallBuilder * {
        return builder;
    };
}


#pragma mark - Channel group audition

-(void)fetchChannelsForChannelGroupWithRequest:(PNChannelGroupFetchRequest *)userRequest
                                    completion:(PNGroupChannelsAuditCompletionBlock)handlerBlock {
    PNOperationDataParser *responseParser = [self parserWithResult:[PNChannelGroupChannelsResult class]
                                                            status:[PNErrorStatus class]];
    PNGroupChannelsAuditCompletionBlock block = [handlerBlock copy];
    PNParsedRequestCompletionBlock handler; 

#ifndef PUBNUB_DISABLE_LOGGER
    PNOperationType operation = userRequest.operation;
    if (operation == PNChannelGroupsOperation) {
        PNLogAPICall(self.logger, @"<PubNub::API> Request channels for '%@' channel group.", userRequest.channelGroup);
    } else PNLogAPICall(self.logger, @"<PubNub::API> Request channel groups list.");
#endif // PUBNUB_DISABLE_LOGGER

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNChannelGroupChannelsResult *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self fetchChannelsForChannelGroupWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self callBlock:block status:NO withResult:result.result andStatus:result.status];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)channelsForGroup:(NSString *)group withCompletion:(PNGroupChannelsAuditCompletionBlock)block {
    [self channelsForGroup:group withQueryParameters:nil completion:block];
}

- (void)channelsForGroup:(NSString *)group
     withQueryParameters:(NSDictionary *)queryParameters
              completion:(PNGroupChannelsAuditCompletionBlock)block {
    PNChannelGroupFetchRequest *request = nil;

    if (group.length == 0) request = [PNChannelGroupFetchRequest requestChannelGroups];
    else request = [PNChannelGroupFetchRequest requestWithChannelGroup:group];

    request.arbitraryQueryParameters = queryParameters;

    [self fetchChannelsForChannelGroupWithRequest:request completion:block];
}


#pragma mark - Channel group content manipulation

- (void)manageChannelGroupWithRequest:(PNChannelGroupManageRequest *)userRequest
                           completion:(PNChannelGroupChangeCompletionBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNAcknowledgmentStatus class]];
    PNChannelGroupChangeCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler; 

#ifndef PUBNUB_DISABLE_LOGGER
    PNOperationType operation = userRequest.operation;
    if (operation == PNRemoveGroupOperation) {
        PNLogAPICall(self.logger, @"<PubNub::API> Remove '%@' channel group", (userRequest.channelGroup?: @"<error>"));
    } else {
        BOOL shouldAdd = operation == PNAddChannelsToGroupOperation;
        PNLogAPICall(self.logger, @"<PubNub::API> %@ channels %@ '%@' channel group: %@",
                     (shouldAdd ? @"Add" : @"Remove"), (shouldAdd ? @"to" : @"from"),
                     (userRequest.channelGroup?: @"<error>"), (userRequest.channels?: @"<error>"));
    }
#endif // PUBNUB_DISABLE_LOGGER

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNAcknowledgmentStatus *, PNAcknowledgmentStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self manageChannelGroupWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)addChannels:(NSArray<NSString *> *)channels
            toGroup:(NSString *)group
     withCompletion:(PNChannelGroupChangeCompletionBlock)block {
    [self add:YES channels:channels toGroup:group queryParameters:nil withCompletion:block];
}

- (void)removeChannels:(NSArray<NSString *> *)channels
             fromGroup:(NSString *)group
        withCompletion:(PNChannelGroupChangeCompletionBlock)block {
    [self add:NO channels:channels.count ? channels : nil toGroup:group queryParameters:nil withCompletion:block];
}

- (void)removeChannelsFromGroup:(NSString *)group withCompletion:(PNChannelGroupChangeCompletionBlock)block {
    [self removeChannels:@[] fromGroup:group withCompletion:block];
}

- (void)add:(BOOL)shouldAdd
           channels:(NSArray<NSString *> *)channels
            toGroup:(NSString *)group
    queryParameters:(NSDictionary *)queryParameters
     withCompletion:(PNChannelGroupChangeCompletionBlock)block {
    PNChannelGroupManageRequest *request;
        
    if (!shouldAdd && !channels.count) request = [PNChannelGroupManageRequest requestToRemoveChannelGroup:group];
    else if (shouldAdd) request = [PNChannelGroupManageRequest requestToAddChannels:channels toChannelGroup:group];
    else request = [PNChannelGroupManageRequest requestToRemoveChannels:channels fromChannelGroup:group];
    request.arbitraryQueryParameters = [queryParameters copy];
         
    [self manageChannelGroupWithRequest:request completion:block];
}

#pragma mark -


@end

