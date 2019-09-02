/**
 * @author Sergey Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNURLBuilder.h"
#import "PNRequestParameters.h"
#import "PNDictionary.h"


#pragma mark Static

/**
 * @brief API endpoints description basing on operation type.
 */
static NSString * const PNOperationRequestTemplate[45] = {
    [PNSubscribeOperation] = @"/v2/subscribe/{sub-key}/{channels}/0",
    [PNUnsubscribeOperation] = @"/v2/presence/sub_key/{sub-key}/channel/{channels}/leave",
    [PNPublishOperation] = @"/publish/{pub-key}/{sub-key}/0/{channel}/0/{message}",
    [PNSignalOperation] = @"/signal/{pub-key}/{sub-key}/0/{channel}/0/{message}",
    [PNAddMessageActionOperation] = @"/v1/message-actions/{sub-key}/channel/{channel}/message/{message-timetoken}",
    [PNRemoveMessageActionOperation] = @"/v1/message-actions/{sub-key}/channel/{channel}/message/{message-timetoken}/action/{action-timetoken}",
    [PNFetchMessagesActionsOperation] = @"/v1/message-actions/{sub-key}/channel/{channel}",
    [PNHistoryOperation] = @"/v2/history/sub-key/{sub-key}/channel/{channel}",
    [PNHistoryForChannelsOperation] = @"/v3/history/sub-key/{sub-key}/channel/{channels}",
    [PNHistoryWithActionsOperation] = @"/v3/history-with-actions/sub-key/{sub-key}/channel/{channel}",
    [PNDeleteMessageOperation] = @"/v3/history/sub-key/{sub-key}/channel/{channel}",
    [PNMessageCountOperation] = @"/v3/history/sub-key/{sub-key}/message-counts/{channels}",
    [PNWhereNowOperation] = @"/v2/presence/sub-key/{sub-key}/uuid/{uuid}",
    [PNHereNowGlobalOperation] = @"/v2/presence/sub-key/{sub-key}",
    [PNHereNowForChannelOperation] = @"/v2/presence/sub-key/{sub-key}/channel/{channel}",
    [PNHereNowForChannelGroupOperation] = @"/v2/presence/sub-key/{sub-key}/channel/{channel}",
    [PNHeartbeatOperation] = @"/v2/presence/sub-key/{sub-key}/channel/{channels}/heartbeat",
    [PNSetStateOperation] = @"/v2/presence/sub-key/{sub-key}/channel/{channel}/uuid/{uuid}/data",
    [PNGetStateOperation] = @"/v2/presence/sub-key/{sub-key}/channel/{channel}/uuid/{uuid}",
    [PNStateForChannelOperation] = @"/v2/presence/sub-key/{sub-key}/channel/{channel}/uuid/{uuid}",
    [PNStateForChannelGroupOperation] = @"/v2/presence/sub-key/{sub-key}/channel/{channel}/uuid/{uuid}",
    [PNAddChannelsToGroupOperation] = @"/v1/channel-registration/sub-key/{sub-key}/channel-group/{channel-group}",
    [PNRemoveChannelsFromGroupOperation] = @"/v1/channel-registration/sub-key/{sub-key}/channel-group/{channel-group}",
    [PNChannelGroupsOperation] = @"/v1/channel-registration/sub-key/{sub-key}/channel-group",
    [PNRemoveGroupOperation] = @"/v1/channel-registration/sub-key/{sub-key}/channel-group/{channel-group}/remove",
    [PNChannelsForGroupOperation] = @"/v1/channel-registration/sub-key/{sub-key}/channel-group/{channel-group}",
    [PNPushNotificationEnabledChannelsOperation] = @"/v1/push/sub-key/{sub-key}/devices/{token}",
    [PNAddPushNotificationsOnChannelsOperation] = @"/v1/push/sub-key/{sub-key}/devices/{token}",
    [PNRemovePushNotificationsFromChannelsOperation] = @"/v1/push/sub-key/{sub-key}/devices/{token}",
    [PNRemoveAllPushNotificationsOperation] = @"/v1/push/sub-key/{sub-key}/devices/{token}/remove",
    [PNCreateUserOperation] = @"/v1/objects/{sub-key}/users",
    [PNUpdateUserOperation] = @"/v1/objects/{sub-key}/users/{user-id}",
    [PNDeleteUserOperation] = @"/v1/objects/{sub-key}/users/{user-id}",
    [PNFetchUserOperation] = @"/v1/objects/{sub-key}/users/{user-id}",
    [PNFetchUsersOperation] = @"/v1/objects/{sub-key}/users",
    [PNCreateSpaceOperation] = @"/v1/objects/{sub-key}/spaces",
    [PNUpdateSpaceOperation] = @"/v1/objects/{sub-key}/spaces/{space-id}",
    [PNDeleteSpaceOperation] = @"/v1/objects/{sub-key}/spaces/{space-id}",
    [PNFetchSpaceOperation] = @"/v1/objects/{sub-key}/spaces/{space-id}",
    [PNFetchSpacesOperation] = @"/v1/objects/{sub-key}/spaces",
    [PNManageMembershipsOperation] = @"/v1/objects/{sub-key}/users/{user-id}/spaces",
    [PNFetchMembershipsOperation] = @"/v1/objects/{sub-key}/users/{user-id}/spaces",
    [PNManageMembersOperation] = @"/v1/objects/{sub-key}/spaces/{space-id}/users",
    [PNFetchMembersOperation] = @"/v1/objects/{sub-key}/spaces/{space-id}/users",
    [PNTimeOperation] = @"/time/0"
};


#pragma mark - Inerface implementation

@implementation PNURLBuilder


#pragma mark - API URL constructor

+ (NSURL *)URLForOperation:(PNOperationType)operation withParameters:(PNRequestParameters *)parameters {
    
    NSURL *requestURL = nil;
    NSMutableString *requestURLString = [PNOperationRequestTemplate[operation] mutableCopy];
    [parameters.pathComponents enumerateKeysAndObjectsUsingBlock:^(NSString *placeholder, NSString *component,
                                                                   __unused BOOL *componentsEnumeratorStop) {

        [requestURLString replaceOccurrencesOfString:placeholder withString:component
                                             options:NSCaseInsensitiveSearch
                                               range:NSMakeRange(0, requestURLString.length)];
    }];
    
    if ([requestURLString rangeOfString:@"{"].location == NSNotFound) {
        if ([requestURLString hasSuffix:@"/"]) {
            NSRange lastSlashRange = NSMakeRange(requestURLString.length - 2, 2);
            [requestURLString replaceOccurrencesOfString:@"/" withString:@"" options:NSBackwardsSearch 
                                                   range:lastSlashRange];
        }
        
        if (parameters.query.count) {
            [requestURLString appendFormat:@"?%@", [PNDictionary queryStringFrom:parameters.query]];
        }
        
        requestURL = [NSURL URLWithString:requestURLString];
    }
    
    return requestURL;
}


#pragma mark - API URL verificator

+ (BOOL)isURL:(NSURL *)url forOperation:(PNOperationType)operation {
    
    BOOL result = NO;
    
    if (url) {
        NSString *requestURLPrefixString = [PNOperationRequestTemplate[operation] componentsSeparatedByString:@"{"].firstObject;
        result = ([url.absoluteString rangeOfString:requestURLPrefixString].location != NSNotFound);
    }
    
    return result;
}

#pragma mark -


@end
