/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+ChannelGroup.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNLogMacro.h"
#import "PNHelpers.h"


#pragma mark Protected interface declaration

@interface PubNub  (ChannelGroupProtected)


#pragma mark - Channel group content manipulation

/**
 @brief  Add or remove channels to/from the \c group.
 
 @param shouldAdd Whether provided \c channels should be added to the \c group or removed.
 @param channels  List of channels names which should be used for \c group modification.
 @param group     Name of the group which should be modified with list of passed \c objects.
 @param block     Channel group list modification process completion block which pass only one
                  argument - request processing status to report about how data pushing was 
                  successful or not.
 
 @since 4.0
 */
- (void)     add:(BOOL)shouldAdd channels:(NSArray *)channels toGroup:(NSString *)group
  withCompletion:(PNChannelGroupChangeCompletionBlock)block;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PubNub (ChannelGroup)


#pragma mark - Channel group audition

- (void)channelGroupsWithCompletion:(PNGroupAuditCompletionBlock)block {
    
    [self channelsForGroup:nil withCompletion:(id)block];
}

- (void)channelsForGroup:(NSString *)group withCompletion:(PNGroupChannelsAuditCompletionBlock)block {

    PNOperationType operationType = (group ? PNChannelsForGroupOperation :
                                     PNChannelGroupsOperation);

    PNRequestParameters *parameters = [PNRequestParameters new];
    if ([group length]) {

        [parameters addPathComponent:[PNString percentEscapedString:group]
                      forPlaceholder:@"{channel-group}"];
        DDLogAPICall([[self class] ddLogLevel], @"<PubNub> Request channels for '%@' channel group.",
                     group);
    }
    else {

        DDLogAPICall([[self class] ddLogLevel], @"<PubNub> Request channel groups list.");
    }

    __weak __typeof(self) weakSelf = self;
    [self processOperation:operationType withParameters:parameters
           completionBlock:^(PNResult *result, PNStatus *status) {
               
               // Silence static analyzer warnings.
               // Code is aware about this case and at the end will simply call on 'nil' object
               // method. In most cases if referenced object become 'nil' it mean what there is no
               // more need in it and probably whole client instance has been deallocated.
               #pragma clang diagnostic push
               #pragma clang diagnostic ignored "-Wreceiver-is-weak"
               if (status.isError) {
                    
                   status.retryBlock = ^{
                        
                       [weakSelf channelsForGroup:group withCompletion:block];
                   };
               }
               [weakSelf callBlock:block status:NO withResult:result andStatus:status];
               #pragma clang diagnostic pop
           }];
}


#pragma mark - Channel group content manipulation

- (void)addChannels:(NSArray *)channels toGroup:(NSString *)group
     withCompletion:(PNChannelGroupChangeCompletionBlock)block {
    
    [self add:YES channels:channels toGroup:group withCompletion:block];
}

- (void)removeChannels:(NSArray *)channels fromGroup:(NSString *)group
        withCompletion:(PNChannelGroupChangeCompletionBlock)block {
    
    [self add:NO channels:channels toGroup:group withCompletion:block];
}

- (void)removeChannelsFromGroup:(NSString *)group
                 withCompletion:(PNChannelGroupChangeCompletionBlock)block {
    
    [self removeChannels:nil fromGroup:group withCompletion:block];
}

- (void)     add:(BOOL)shouldAdd channels:(NSArray *)channels toGroup:(NSString *)group
  withCompletion:(PNChannelGroupChangeCompletionBlock)block {

    BOOL removeAllObjects = (!shouldAdd && channels == nil);
    PNOperationType operationType = PNRemoveGroupOperation;
    PNRequestParameters *parameters = [PNRequestParameters new];
    if ([group length]) {

        [parameters addPathComponent:[PNString percentEscapedString:group]
                      forPlaceholder:@"{channel-group}"];
    }

    if (!removeAllObjects){

        operationType = (shouldAdd ? PNAddChannelsToGroupOperation :
                         PNRemoveChannelsFromGroupOperation);
        if ([channels count]) {

            [parameters addQueryParameter:[PNChannel namesForRequest:channels]
                             forFieldName:(shouldAdd ? @"add":@"remove")];
        }

        DDLogAPICall([[self class] ddLogLevel], @"<PubNub> %@ channels %@ '%@' channel group: %@",
                (shouldAdd ? @"Add" : @"Remove"), (shouldAdd ? @"to" : @"from"),
                (group?: @"<error>"), ([PNChannel namesForRequest:channels]?: @"<error>"));
    }
    else {

        DDLogAPICall([[self class] ddLogLevel], @"<PubNub> Remove '%@' channel group",
                     (group?: @"<error>"));
    }

    __weak __typeof(self) weakSelf = self;
    [self processOperation:operationType withParameters:parameters
           completionBlock:^(PNStatus *status){
               
               // Silence static analyzer warnings.
               // Code is aware about this case and at the end will simply call on 'nil' object
               // method. In most cases if referenced object become 'nil' it mean what there is no
               // more need in it and probably whole client instance has been deallocated.
               #pragma clang diagnostic push
               #pragma clang diagnostic ignored "-Wreceiver-is-weak"
               if (status.isError) {
                    
                   status.retryBlock = ^{
                        
                       [weakSelf add:shouldAdd channels:channels toGroup:group
                      withCompletion:block];
                   };
               }
               [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
               #pragma clang diagnostic pop
           }];
}

#pragma mark -


@end
