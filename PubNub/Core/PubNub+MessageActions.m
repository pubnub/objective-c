/**
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNAPICallBuilder+Private.h"
#import "PubNub+MessageActions.h"
#import "PubNub+CorePrivate.h"
#import "PNResult+Private.h"
#import "PNStatus+Private.h"


#pragma mark Interface implementation

@implementation PubNub (MessageActions)


#pragma mark - Message Actions API builder support

- (PNAddMessageActionAPICallBuilder * (^)(void))addMessageAction {
    PNAddMessageActionAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNAddMessageActionAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                     NSDictionary *parameters) {
        
        NSNumber *timetoken = parameters[NSStringFromSelector(@selector(messageTimetoken))];
        NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
        PNAddMessageActionRequest *request = nil;
        
        request = [PNAddMessageActionRequest requestWithChannel:channel messageTimetoken:timetoken];
        request.value = parameters[NSStringFromSelector(@selector(value))];
        request.type = parameters[NSStringFromSelector(@selector(type))];

        [weakSelf addMessageActionWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNAddMessageActionAPICallBuilder * {
        return builder;
    };
}

- (PNRemoveMessageActionAPICallBuilder * (^)(void))removeMessageAction {
    PNRemoveMessageActionAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNRemoveMessageActionAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                               NSDictionary *parameters) {
        
        NSNumber *timetoken = parameters[NSStringFromSelector(@selector(messageTimetoken))];
        NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
        PNRemoveMessageActionRequest *request = nil;
        
        request = [PNRemoveMessageActionRequest requestWithChannel:channel
                                                  messageTimetoken:timetoken];
        request.actionTimetoken = parameters[NSStringFromSelector(@selector(actionTimetoken))];

        [weakSelf removeMessageActionWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNRemoveMessageActionAPICallBuilder * {
        return builder;
    };
}

- (PNFetchMessagesActionsAPICallBuilder * (^)(void))fetchMessageActions {
    PNFetchMessagesActionsAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNFetchMessagesActionsAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                               NSDictionary *parameters) {
        
        NSNumber *limit = parameters[NSStringFromSelector(@selector(limit))] ?: @(100);
        NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
        PNFetchMessageActionsRequest *request = nil;
        
        request = [PNFetchMessageActionsRequest requestWithChannel:channel];
        request.start = parameters[NSStringFromSelector(@selector(start))];
        request.end = parameters[NSStringFromSelector(@selector(end))];
        request.limit = limit.unsignedIntegerValue;

        [weakSelf fetchMessageActionsWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNFetchMessagesActionsAPICallBuilder * {
        return builder;
    };
}


#pragma mark - Message actions

- (void)addMessageActionWithRequest:(PNAddMessageActionRequest *)request
                         completion:(nullable PNAddMessageActionCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNAddMessageActionStatus *status) {
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf addMessageActionWithRequest:request completion:block];
            };
        }

        if (block) {
            block(status);
        }
    }];
}

- (void)removeMessageActionWithRequest:(PNRemoveMessageActionRequest *)request
                            completion:(nullable PNRemoveMessageActionCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNAcknowledgmentStatus *status) {
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf removeMessageActionWithRequest:request completion:block];
            };
        }

        if (block) {
            block(status);
        }
    }];
}

- (void)fetchMessageActionsWithRequest:(PNFetchMessageActionsRequest *)request
                             completion:(PNFetchMessageActionsCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request
          withCompletion:^(PNFetchMessageActionsResult *result, PNErrorStatus *status) {
              
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf fetchMessageActionsWithRequest:request completion:block];
            };
        }

        block(result, status);
    }];
}

#pragma mark -


@end
