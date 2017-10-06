/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PubNub+ChannelGroup.h"
#import "PNAPICallBuilder+Private.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNLogMacro.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PubNub  (ChannelGroupProtected)


#pragma mark - Channel group content manipulation

/**
 @brief  Add or remove channels to/from the \c group.
 
 @param shouldAdd Whether provided \c channels should be added to the \c group or removed.
 @param channels  List of channels names which should be used for \c group modification.
 @param group     Name of the group which should be modified with list of passed \c objects.
 @param block     Channel group list modification process completion block which pass only one
                  argument - request processing status to report about how data pushing was successful or not.
 
 @since 4.0
 */
- (void)     add:(BOOL)shouldAdd channels:(nullable NSArray<NSString *> *)channels toGroup:(NSString *)group
  withCompletion:(nullable PNChannelGroupChangeCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (ChannelGroup)


#pragma mark - API Builder support

- (PNStreamAPICallBuilder *(^)(void))stream {
    
    PNStreamAPICallBuilder *builder = nil;
    builder = [PNStreamAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                  NSDictionary *parameters) {
                               
        NSString *group = parameters[NSStringFromSelector(@selector(channelGroup))];
        id block = parameters[@"block"];
        if ([flags containsObject:NSStringFromSelector(@selector(audit))]) {
            
            [self channelsForGroup:group withCompletion:block];
        }
        else {
            
            NSArray<NSString *> *channels = parameters[NSStringFromSelector(@selector(channels))];
            BOOL adding = [flags containsObject:NSStringFromSelector(@selector(add))];
            [self add:adding channels:(channels.count ? channels : nil) toGroup:group withCompletion:block];
        }
    }];
    
    return ^PNStreamAPICallBuilder *{ return builder; };
}


#pragma mark - Channel group audition

- (void)channelGroupsWithCompletion:(PNGroupAuditCompletionBlock)block {
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"
    [self channelsForGroup:nil withCompletion:(id)block];
    #pragma clang diagnostic pop
}

- (void)channelsForGroup:(NSString *)group withCompletion:(PNGroupChannelsAuditCompletionBlock)block {

    PNOperationType operationType = (group ? PNChannelsForGroupOperation : PNChannelGroupsOperation);
    PNRequestParameters *parameters = [PNRequestParameters new];
    if (group.length) {

        [parameters addPathComponent:[PNString percentEscapedString:group] forPlaceholder:@"{channel-group}"];
        PNLogAPICall(self.logger, @"<PubNub::API> Request channels for '%@' channel group.", group);
    }
    else { PNLogAPICall(self.logger, @"<PubNub::API> Request channel groups list."); }

    __weak __typeof(self) weakSelf = self;
    [self processOperation:operationType withParameters:parameters
           completionBlock:^(PNResult *result, PNStatus *status) {
        if (status.isError) {

            status.retryBlock = ^{ [weakSelf channelsForGroup:group withCompletion:block]; };
        }
        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
    }];
}


#pragma mark - Channel group content manipulation

- (void)addChannels:(NSArray<NSString *> *)channels toGroup:(NSString *)group
     withCompletion:(PNChannelGroupChangeCompletionBlock)block {
    
    [self add:YES channels:channels toGroup:group withCompletion:block];
}

- (void)removeChannels:(NSArray<NSString *> *)channels fromGroup:(NSString *)group
        withCompletion:(PNChannelGroupChangeCompletionBlock)block {
    
    [self add:NO channels:(channels.count ? channels : nil) toGroup:group withCompletion:block];
}

- (void)removeChannelsFromGroup:(NSString *)group withCompletion:(PNChannelGroupChangeCompletionBlock)block {
    
    [self removeChannels:@[] fromGroup:group withCompletion:block];
}

- (void)     add:(BOOL)shouldAdd channels:(NSArray<NSString *> *)channels toGroup:(NSString *)group
  withCompletion:(PNChannelGroupChangeCompletionBlock)block {

    BOOL removeAllObjects = (!shouldAdd && !channels.count);
    PNOperationType operationType = PNRemoveGroupOperation;
    PNRequestParameters *parameters = [PNRequestParameters new];
    if (group.length) {

        [parameters addPathComponent:[PNString percentEscapedString:group] forPlaceholder:@"{channel-group}"];
    }

    if (!removeAllObjects){

        operationType = (shouldAdd ? PNAddChannelsToGroupOperation : PNRemoveChannelsFromGroupOperation);
        if (channels.count) {

            [parameters addQueryParameter:[PNChannel namesForRequest:channels]
                             forFieldName:(shouldAdd ? @"add":@"remove")];
        }

        PNLogAPICall(self.logger, @"<PubNub::API> %@ channels %@ '%@' channel group: %@",
                     (shouldAdd ? @"Add" : @"Remove"), (shouldAdd ? @"to" : @"from"),
                     (group?: @"<error>"), ([PNChannel namesForRequest:channels]?: @"<error>"));
    }
    else { PNLogAPICall(self.logger, @"<PubNub::API> Remove '%@' channel group", (group?: @"<error>")); }

    __weak __typeof(self) weakSelf = self;
    [self processOperation:operationType withParameters:parameters completionBlock:^(PNStatus *status){
        if (status.isError) {

            status.retryBlock = ^{

                [weakSelf add:shouldAdd channels:channels toGroup:group withCompletion:block];
            };
        }
        [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
    }];
}

#pragma mark -


@end
