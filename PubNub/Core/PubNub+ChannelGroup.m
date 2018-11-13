/**
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PubNub+ChannelGroup.h"
#import "PNAPICallBuilder+Private.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PubNub  (ChannelGroupProtected)


#pragma mark - Channel group audition

/**
 * @brief Fetch list of channels which is registered in specified \c group.
 *
 * @param group Name of the group from which channels should be fetched.
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 * @param block Channels audition completion block.
 *
 * @since 4.8.2
 */
- (void)channelsForGroup:(NSString *)group
     withQueryParameters:(nullable NSDictionary *)queryParameters
              completion:(PNGroupChannelsAuditCompletionBlock)block;


#pragma mark - Channel group content manipulation

/**
 * @brief Add or remove channels to / from the \c group.
 *
 * @param shouldAdd Whether provided \c channels should be added to the \c group or removed.
 * @param channels List of channels names which should be used for \c group modification.
 * @param group Name of the group which should be modified with list of passed \c objects.
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 * @param block Channel group list modification completion block.
 *
 * @since 4.8.2
 */
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
    builder = [PNStreamAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                  NSDictionary *parameters) {
                               
        NSString *group = parameters[NSStringFromSelector(@selector(channelGroup))];
        NSDictionary *queryParam = parameters[@"queryParam"];
        id block = parameters[@"block"];
        
        if ([flags containsObject:NSStringFromSelector(@selector(audit))]) {
            [self channelsForGroup:group withQueryParameters:queryParam completion:block];
        } else {
            NSArray<NSString *> *channels = parameters[NSStringFromSelector(@selector(channels))];
            BOOL adding = [flags containsObject:NSStringFromSelector(@selector(add))];

            [self add:adding
                     channels:(channels.count ? channels : nil)
                      toGroup:group
              queryParameters:queryParam
               withCompletion:block];
        }
    }];
    
    return ^PNStreamAPICallBuilder * {
        return builder;
    };
}


#pragma mark - Channel group audition

- (void)channelsForGroup:(NSString *)group
          withCompletion:(PNGroupChannelsAuditCompletionBlock)block {

    [self channelsForGroup:group withQueryParameters:nil completion:block];
}

- (void)channelsForGroup:(NSString *)group
     withQueryParameters:(NSDictionary *)queryParameters
              completion:(PNGroupChannelsAuditCompletionBlock)block {
    
    PNOperationType operationType = (group ? PNChannelsForGroupOperation
                                           : PNChannelGroupsOperation);
    PNRequestParameters *parameters = [PNRequestParameters new];

    [parameters addQueryParameters:queryParameters];
    
    if (group.length) {
        [parameters addPathComponent:[PNString percentEscapedString:group]
                      forPlaceholder:@"{channel-group}"];

        PNLogAPICall(self.logger, @"<PubNub::API> Request channels for '%@' channel group.", group);
    } else {
        PNLogAPICall(self.logger, @"<PubNub::API> Request channel groups list.");
    }
    
    __weak __typeof(self) weakSelf = self;
    [self processOperation:operationType
            withParameters:parameters
           completionBlock:^(PNResult *result, PNStatus *status) {
               
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf channelsForGroup:group
                       withQueryParameters:queryParameters
                                completion:block];
            };
        }

        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
    }];
}


#pragma mark - Channel group content manipulation

- (void)addChannels:(NSArray<NSString *> *)channels
            toGroup:(NSString *)group
     withCompletion:(PNChannelGroupChangeCompletionBlock)block {
    
    [self add:YES channels:channels toGroup:group queryParameters:nil withCompletion:block];
}

- (void)removeChannels:(NSArray<NSString *> *)channels
             fromGroup:(NSString *)group
        withCompletion:(PNChannelGroupChangeCompletionBlock)block {
    
    [self add:NO
           channels:(channels.count ? channels : nil)
            toGroup:group
    queryParameters:nil
     withCompletion:block];
}

- (void)removeChannelsFromGroup:(NSString *)group
                 withCompletion:(PNChannelGroupChangeCompletionBlock)block {
    
    [self removeChannels:@[] fromGroup:group withCompletion:block];
}

- (void)add:(BOOL)shouldAdd
           channels:(NSArray<NSString *> *)channels
            toGroup:(NSString *)group
    queryParameters:(NSDictionary *)queryParameters
     withCompletion:(PNChannelGroupChangeCompletionBlock)block {

    PNRequestParameters *parameters = [PNRequestParameters new];
    PNOperationType operationType = PNRemoveGroupOperation;
    BOOL removeAllObjects = !shouldAdd && !channels.count;

    [parameters addQueryParameters:queryParameters];
    
    if (group.length) {
        [parameters addPathComponent:[PNString percentEscapedString:group]
                      forPlaceholder:@"{channel-group}"];
    }

    if (!removeAllObjects){
        operationType = (shouldAdd ? PNAddChannelsToGroupOperation
                                   : PNRemoveChannelsFromGroupOperation);
        
        if (channels.count) {
            [parameters addQueryParameter:[PNChannel namesForRequest:channels]
                             forFieldName:(shouldAdd ? @"add":@"remove")];
        }

        PNLogAPICall(self.logger, @"<PubNub::API> %@ channels %@ '%@' channel group: %@",
            (shouldAdd ? @"Add" : @"Remove"), (shouldAdd ? @"to" : @"from"),
            (group?: @"<error>"), ([PNChannel namesForRequest:channels]?: @"<error>"));
    } else {
        PNLogAPICall(self.logger, @"<PubNub::API> Remove '%@' channel group", (group?: @"<error>"));
    }

    __weak __typeof(self) weakSelf = self;
    [self processOperation:operationType
            withParameters:parameters
           completionBlock:^(PNStatus *status) {

        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf add:shouldAdd
                     channels:channels
                      toGroup:group
              queryParameters:queryParameters
               withCompletion:block];
            };
        }
        
        [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
    }];
}

#pragma mark -


@end
