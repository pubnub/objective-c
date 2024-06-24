#import "PubNub+MessageActions.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"

// Deprecated
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PubNub (MessageActions)


#pragma mark - Message Actions API builder interdace (deprecated)

- (PNAddMessageActionAPICallBuilder * (^)(void))addMessageAction {
    PNAddMessageActionAPICallBuilder *builder = nil;
    
    PNWeakify(self);
    builder = [PNAddMessageActionAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                            NSDictionary *parameters) {
        PNStrongify(self);
        NSNumber *timetoken = parameters[NSStringFromSelector(@selector(messageTimetoken))];
        NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
        PNAddMessageActionRequest *request = nil;
        
        request = [PNAddMessageActionRequest requestWithChannel:channel messageTimetoken:timetoken];
        request.value = parameters[NSStringFromSelector(@selector(value))];
        request.type = parameters[NSStringFromSelector(@selector(type))];

        [self addMessageActionWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNAddMessageActionAPICallBuilder * {
        return builder;
    };
}

- (PNRemoveMessageActionAPICallBuilder * (^)(void))removeMessageAction {
    PNRemoveMessageActionAPICallBuilder *builder = nil;
    
    PNWeakify(self);
    builder = [PNRemoveMessageActionAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                               NSDictionary *parameters) {
        PNStrongify(self);
        NSNumber *actionTimetoken = parameters[NSStringFromSelector(@selector(actionTimetoken))];
        NSNumber *timetoken = parameters[NSStringFromSelector(@selector(messageTimetoken))];
        NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
        PNRemoveMessageActionRequest *request = nil;
        
        request = [PNRemoveMessageActionRequest requestWithChannel:channel
                                                  messageTimetoken:timetoken
                                                   actionTimetoken:actionTimetoken];

        [self removeMessageActionWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNRemoveMessageActionAPICallBuilder * {
        return builder;
    };
}

- (PNFetchMessagesActionsAPICallBuilder * (^)(void))fetchMessageActions {
    PNFetchMessagesActionsAPICallBuilder *builder = nil;
    
    PNWeakify(self);
    builder = [PNFetchMessagesActionsAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                                NSDictionary *parameters) {
        PNStrongify(self);
        NSNumber *limit = parameters[NSStringFromSelector(@selector(limit))] ?: @100;
        NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
        PNFetchMessageActionsRequest *request = nil;
        
        request = [PNFetchMessageActionsRequest requestWithChannel:channel];
        request.start = parameters[NSStringFromSelector(@selector(start))];
        request.end = parameters[NSStringFromSelector(@selector(end))];
        request.limit = limit.unsignedIntegerValue;

        [self fetchMessageActionsWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNFetchMessagesActionsAPICallBuilder * {
        return builder;
    };
}


#pragma mark - Message actions

- (void)addMessageActionWithRequest:(PNAddMessageActionRequest *)userRequest
                         completion:(PNAddMessageActionCompletionBlock)handlerBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNAddMessageActionStatus class]];
    PNAddMessageActionCompletionBlock block = [handlerBlock copy];
    PNParsedRequestCompletionBlock handler; 
    
    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNAddMessageActionStatus *, PNAddMessageActionStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self addMessageActionWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)removeMessageActionWithRequest:(PNRemoveMessageActionRequest *)userRequest
                            completion:(PNRemoveMessageActionCompletionBlock)handlerBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNAcknowledgmentStatus class]];
    PNRemoveMessageActionCompletionBlock block = [handlerBlock copy];
    PNParsedRequestCompletionBlock handler; 
    

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNAcknowledgmentStatus *, PNAcknowledgmentStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self removeMessageActionWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)fetchMessageActionsWithRequest:(PNFetchMessageActionsRequest *)userRequest
                            completion:(PNFetchMessageActionsCompletionBlock)handlerBlock {
    PNOperationDataParser *responseParser = [self parserWithResult:[PNFetchMessageActionsResult class]
                                                            status:[PNErrorStatus class]];
    PNFetchMessageActionsCompletionBlock block = [handlerBlock copy];
    PNParsedRequestCompletionBlock handler;

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNFetchMessageActionsResult *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self fetchMessageActionsWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self callBlock:block status:NO withResult:result.result andStatus:result.status];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

#pragma mark -


@end
