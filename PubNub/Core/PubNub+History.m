#import "PubNub+History.h"
#import "PNHistoryFetchRequest+Private.h"
#import "PNBaseOperationData+Private.h"
#import "PNHistoryFetchData+Private.h"
#import "PNErrorStatus+Private.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"

// Deprecated
#import "PNAPICallBuilder+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PubNub (HistoryProtected)


#pragma mark - History audition

/// Allow to fetch events from specified `channel`'s history within specified time frame.
///
/// - Parameters:
///   - multipleChannels: Whether history should be fetched for multiple ``object`` or not. If set `YES` then ``object``
///   contain list of channel names for which history should be retrieved.
///   - object: Name of the channel for which events should be pulled out from storage.
///   - startDate: Reference on time token for oldest event starting from which next should be returned events. 
///   Value will be converted to required precision internally.
///   - endDate: Reference on time token for latest event till which events should be pulled out.
///   Value will be converted to required precision internally.
///   - limit: Maximum number of events which should be returned in response (not more then **100**).
///   - shouldReverseOrder: Whether events order in response should be reversed or not.
///   - shouldIncludeTimeToken: Whether event dates (time tokens) should be included in response or not.
///   - includeMessageType: Whether event type should be included in response or not.
///   By default set to: `YES`.
///   - includeUUID: Whether event publisher UUID should be included in response or not.
///   By default set to: `YES`.
///   - shouldIncludeMessageActions: Whether event actions should be included in response or not.
///   - shouldIncludeMetadata: Whether event metadata should be included in response or not.
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
///   - block History pull completion block.
- (void)historyForChannels:(BOOL)multipleChannels
                    object:(id)object
                     start:(nullable NSNumber *)startDate
                       end:(nullable NSNumber *)endDate
                     limit:(nullable NSNumber *)limit
                   reverse:(nullable NSNumber *)shouldReverseOrder
          includeTimeToken:(nullable NSNumber *)shouldIncludeTimeToken
        includeMessageType:(nullable NSNumber *)includeMessageType
               includeUUID:(nullable NSNumber *)includeUUID
     includeMessageActions:(nullable NSNumber *)shouldIncludeMessageActions
           includeMetadata:(nullable NSNumber *)shouldIncludeMetadata
           queryParameters:(nullable NSDictionary *)queryParameters
            withCompletion:(PNHistoryCompletionBlock)block;

/// Allow to fetch number of messages for specified channels from specific dates (timetokens).
///
/// - Parameters:
///   - channels: List of channel names for which persist messages count should be fetched.
///   - timetokens: List with timetokens, where each timetoken's position in correspond to target `channel` location in
///   channel names list.
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
///   - block: Messages count pull completion block.
- (void)messageCountForChannels:(NSArray<NSString *> *)channels
                     timetokens:(nullable NSArray<NSNumber *> *)timetokens
                queryParameters:(nullable NSDictionary *)queryParameters
                 withCompletion:(PNMessageCountCompletionBlock)block;


#pragma mark - History manipulation

/// Allow to remove events from specified `channel`'s history within specified time frame.
///
/// - Parameters:
///   - channel: Name of the channel from which events should be removed.
///   - startDate: Reference on time token for oldest event starting from which events should be  removed.
///   Value will be converted to required precision internally. If no ``endDate`` value provided, will be removed all
///   events till specified ``startDate`` date (not inclusive).
///   - endDate: Reference on time token for latest event till which events should be removed. Value will be converted
///   to required precision internally. If no ``startDate`` value provided, will be removed all events starting from
///   specified ``endDate`` date (inclusive).
///   - block: Events remove completion block.
- (void)deleteMessagesFromChannel:(NSString *)channel
                            start:(nullable NSNumber *)startDate
                              end:(nullable NSNumber *)endDate
                  queryParameters:(nullable NSDictionary *)queryParameters
                   withCompletion:(nullable PNMessageDeleteCompletionBlock)block;


#pragma mark - Handlers

/// History request results handling and pre-processing before notify to completion blocks (if required at all).
///
/// - Parameters:
///   - result: Reference on object which represent server useful response data.
///   - status: Reference on object which represent request processing results.
///   - block: History pull completion block.
- (void)handleHistoryResult:(nullable PNOperationResult *)result
                 withStatus:(nullable PNStatus *)status
                 completion:(PNHistoryCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (History)


#pragma mark - Message persistence API builder interdace (deprecated)

- (PNHistoryAPICallBuilder * (^)(void))history {
    PNHistoryAPICallBuilder *builder = nil;
    builder = [PNHistoryAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                   NSDictionary *parameters) {
        NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
        NSArray<NSString*> *channels = parameters[NSStringFromSelector(@selector(channels))];
        NSNumber *limit = parameters[NSStringFromSelector(@selector(limit))];
        NSNumber *start = parameters[NSStringFromSelector(@selector(start))];
        NSNumber *end = parameters[NSStringFromSelector(@selector(end))];
        NSNumber *reverse = parameters[NSStringFromSelector(@selector(reverse))];
        NSNumber *includeTimeToken = parameters[NSStringFromSelector(@selector(includeTimeToken))];
        NSNumber *includeMessageType = parameters[NSStringFromSelector(@selector(includeMessageType))];
        NSNumber *includeUUID = parameters[NSStringFromSelector(@selector(includeUUID))];
        NSNumber *includeMetadata = parameters[NSStringFromSelector(@selector(includeMetadata))];
        NSNumber *includeActions = parameters[NSStringFromSelector(@selector(includeMessageActions))];
        NSDictionary *queryParam = parameters[@"queryParam"];
        id block = parameters[@"block"];

        [self historyForChannels:(channels != nil)
                          object:(channels ?: channel)
                           start:start
                             end:end
                           limit:limit
                         reverse:reverse
                includeTimeToken:includeTimeToken
              includeMessageType:includeMessageType
                     includeUUID:includeUUID
           includeMessageActions:includeActions
                 includeMetadata:includeMetadata
                 queryParameters:queryParam
                  withCompletion:block];
    }];
    
    return ^PNHistoryAPICallBuilder * {
        return builder;
    };
}

- (PNDeleteMessageAPICallBuilder * (^)(void))deleteMessage {
    PNDeleteMessageAPICallBuilder *builder = nil;
    builder = [PNDeleteMessageAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                         NSDictionary *parameters) {
        NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
        NSNumber *start = parameters[NSStringFromSelector(@selector(start))];
        NSNumber *end = parameters[NSStringFromSelector(@selector(end))];
        NSDictionary *queryParam = parameters[@"queryParam"];
        id block = parameters[@"block"];
        
        [self deleteMessagesFromChannel:channel start:start end:end queryParameters:queryParam withCompletion:block];
    }];
    
    return ^PNDeleteMessageAPICallBuilder * {
        return builder;
    };
}

- (PNMessageCountAPICallBuilder * (^)(void))messageCounts {
    PNMessageCountAPICallBuilder *builder = nil;
    builder = [PNMessageCountAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                              NSDictionary *parameters) {
        NSArray<NSNumber *> *timetokens = parameters[NSStringFromSelector(@selector(timetokens))];
        NSArray<NSString *> *channels = parameters[NSStringFromSelector(@selector(channels))];
        NSDictionary *queryParam = parameters[@"queryParam"];
        id block = parameters[@"block"];
        
        [self messageCountForChannels:channels timetokens:timetokens queryParameters:queryParam withCompletion:block];
    }];
    
    return ^PNMessageCountAPICallBuilder * {
        return builder;
    };
}


#pragma mark - Full history

- (void)fetchHistoryWithRequest:(PNHistoryFetchRequest *)userRequest completion:(PNHistoryCompletionBlock)handlerBlock {
    PNOperationDataParser *responseParser = [self parserWithResult:[PNHistoryResult class] status:[PNErrorStatus class]];
    PNHistoryCompletionBlock block = [handlerBlock copy];
    PNParsedRequestCompletionBlock handler;

    if (userRequest.multipleChannels) {
        PNLogAPICall(self.logger, @"<PubNub::API> History for '%@' channels%@%@ with %@ limit.",
                     (userRequest.channels != nil ? [userRequest.channels componentsJoinedByString:@", "] : @"<error>"),
                     (userRequest.start ? [NSString stringWithFormat:@" from %@", userRequest.start] : @""),
                     (userRequest.end ? [NSString stringWithFormat:@" to %@", userRequest.end] : @""),
                     @(userRequest.limit));
    } else {
        PNLogAPICall(self.logger, @"<PubNub::API> %@ for '%@' channel%@%@ with %@ limit%@.",
                     (userRequest.reverse ? @"Reversed history" : @"History"),
                     (userRequest.channels.firstObject?: @"<error>"),
                     (userRequest.start ? [NSString stringWithFormat:@" from %@", userRequest.start] : @""),
                     (userRequest.end ? [NSString stringWithFormat:@" to %@", userRequest.end] : @""),
                     @(userRequest.limit), (userRequest.includeTimeToken ? @" (including: message time tokens" : @""));
    }

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNHistoryResult *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self fetchHistoryWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        } else if (result.result && !userRequest.multipleChannels && userRequest.channels.count == 1) {
            [result.result.data setSingleChannelName:userRequest.channels.firstObject];
        }

        [self handleHistoryResult:result.result withStatus:result.status completion:block];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];

}

- (void)historyForChannel:(NSString *)channel withCompletion:(PNHistoryCompletionBlock)block {
    [self historyForChannel:channel start:nil end:nil withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel
             withMetadata:(BOOL)shouldIncludeMetadata
               completion:(PNHistoryCompletionBlock)block {
    [self historyForChannel:channel withMetadata:shouldIncludeMetadata messageActions:NO completion:block];
}

- (void)historyForChannel:(NSString *)channel
       withMessageActions:(BOOL)shouldIncludeMessageActions
               completion:(PNHistoryCompletionBlock)block {
    [self historyForChannel:channel
               withMetadata:NO
             messageActions:shouldIncludeMessageActions
                 completion:block];
}

- (void)historyForChannel:(NSString *)channel
             withMetadata:(BOOL)shouldIncludeMetadata
           messageActions:(BOOL)shouldIncludeMessageActions
               completion:(PNHistoryCompletionBlock)block {
    [self historyForChannel:channel
                      start:nil
                        end:nil
            includeMetadata:shouldIncludeMetadata
      includeMessageActions:shouldIncludeMessageActions
             withCompletion:block];
}


#pragma mark - History in specified frame

- (void)historyForChannel:(NSString *)channel
                    start:(NSNumber *)startDate
                      end:(NSNumber *)endDate
           withCompletion:(PNHistoryCompletionBlock)block {
    [self historyForChannel:channel start:startDate end:endDate limit:100 withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel
                    start:(NSNumber *)startDate
                      end:(NSNumber *)endDate
          includeMetadata:(BOOL)shouldIncludeMetadata
           withCompletion:(PNHistoryCompletionBlock)block {
    [self historyForChannel:channel
                      start:startDate
                        end:endDate
            includeMetadata:shouldIncludeMetadata
      includeMessageActions:NO
             withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel
                    start:(NSNumber *)startDate
                      end:(NSNumber *)endDate
    includeMessageActions:(BOOL)shouldIncludeMessageActions
           withCompletion:(PNHistoryCompletionBlock)block {
    [self historyForChannel:channel
                      start:startDate
                        end:endDate
            includeMetadata:NO
      includeMessageActions:shouldIncludeMessageActions
             withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel
                    start:(NSNumber *)startDate
                      end:(NSNumber *)endDate
          includeMetadata:(BOOL)shouldIncludeMetadata
    includeMessageActions:(BOOL)shouldIncludeMessageActions
           withCompletion:(PNHistoryCompletionBlock)block {
    [self historyForChannels:NO
                      object:channel
                       start:startDate
                         end:endDate
                       limit:nil
                     reverse:@NO
            includeTimeToken:@NO
          includeMessageType:@YES
                 includeUUID:@YES
       includeMessageActions:@(shouldIncludeMessageActions)
             includeMetadata:@(shouldIncludeMetadata)
             queryParameters:nil
              withCompletion:block];
    
}

- (void)historyForChannel:(NSString *)channel
                    start:(NSNumber *)startDate
                      end:(NSNumber *)endDate
                    limit:(NSUInteger)limit
           withCompletion:(PNHistoryCompletionBlock)block {
    [self historyForChannel:channel
                      start:startDate
                        end:endDate
                      limit:limit
           includeTimeToken:NO
             withCompletion:block];
}


#pragma mark - History in frame with extended response

- (void)historyForChannel:(NSString *)channel
                    start:(NSNumber *)startDate
                      end:(NSNumber *)endDate
         includeTimeToken:(BOOL)shouldIncludeTimeToken
           withCompletion:(PNHistoryCompletionBlock)block {
    [self historyForChannel:channel
                      start:startDate
                        end:endDate
                      limit:100
           includeTimeToken:shouldIncludeTimeToken
             withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel
                    start:(NSNumber *)startDate
                      end:(NSNumber *)endDate
                    limit:(NSUInteger)limit
         includeTimeToken:(BOOL)shouldIncludeTimeToken
           withCompletion:(PNHistoryCompletionBlock)block {
    [self historyForChannel:channel
                      start:startDate
                        end:endDate
                      limit:limit
                    reverse:NO
           includeTimeToken:shouldIncludeTimeToken
             withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel
                    start:(NSNumber *)startDate
                      end:(NSNumber *)endDate
                    limit:(NSUInteger)limit
                  reverse:(BOOL)shouldReverseOrder
           withCompletion:(PNHistoryCompletionBlock)block {
    [self historyForChannel:channel
                      start:startDate
                        end:endDate
                      limit:limit
                    reverse:shouldReverseOrder
           includeTimeToken:NO
             withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel
                    start:(NSNumber *)startDate
                      end:(NSNumber *)endDate
                    limit:(NSUInteger)limit
                  reverse:(BOOL)shouldReverseOrder
         includeTimeToken:(BOOL)shouldIncludeTimeToken
           withCompletion:(PNHistoryCompletionBlock)block {
    [self historyForChannels:NO
                      object:channel
                       start:startDate
                         end:endDate
                       limit:@(limit)
                     reverse:@(shouldReverseOrder)
            includeTimeToken:@(shouldIncludeTimeToken)
          includeMessageType:@YES
                 includeUUID:@YES
       includeMessageActions:nil
             includeMetadata:nil
             queryParameters:nil
              withCompletion:block];
}

- (void)historyForChannels:(BOOL)multipleChannels
                    object:(id)object
                     start:(NSNumber *)startDate
                       end:(NSNumber *)endDate
                     limit:(NSNumber *)limit
                   reverse:(NSNumber *)shouldReverseOrder
          includeTimeToken:(NSNumber *)shouldIncludeTimeToken
        includeMessageType:(NSNumber *)includeMessageType
               includeUUID:(NSNumber *)includeUUID
     includeMessageActions:(NSNumber *)shouldIncludeMessageActions
           includeMetadata:(NSNumber *)shouldIncludeMetadata
           queryParameters:(NSDictionary *)queryParameters
            withCompletion:(PNHistoryCompletionBlock)block {
    PNHistoryFetchRequest *request;
    if (!multipleChannels) request = [PNHistoryFetchRequest requestWithChannel:object];
    else request = [PNHistoryFetchRequest requestWithChannels:object];
    if (startDate) request.start = startDate;
    if (endDate) request.end = endDate;
    if (limit) request.limit = limit.unsignedIntegerValue;
    if (shouldReverseOrder) request.reverse = shouldReverseOrder.boolValue;
    if (shouldIncludeTimeToken) request.includeTimeToken = shouldIncludeTimeToken.boolValue;
    if (includeMessageType) request.includeMessageType = includeMessageType.boolValue;
    if (includeUUID) request.includeUUID = includeUUID.boolValue;
    if (shouldIncludeMessageActions) request.includeMessageActions = shouldIncludeMessageActions.boolValue;
    if (shouldIncludeMetadata) request.includeMetadata = shouldIncludeMetadata.boolValue;
    request.arbitraryQueryParameters = queryParameters;
                
    [self fetchHistoryWithRequest:request completion:block];
}

- (void)messageCountForChannels:(NSArray<NSString *> *)channels
                     timetokens:(NSArray<NSNumber *> *)timetokens
                queryParameters:(NSDictionary *)queryParameters
                 withCompletion:(PNMessageCountCompletionBlock)block {
    PNHistoryMessagesCountRequest *request = [PNHistoryMessagesCountRequest requestWithChannels:channels
                                                                                     timetokens:timetokens];
    request.arbitraryQueryParameters = queryParameters;
                     
    [self fetchMessagesCountWithRequest:request completion:block];
}

#pragma mark - History manipulation

- (void)deleteMessagesWithRequest:(PNHistoryMessagesDeleteRequest *)userRequest 
                       completion:(PNMessageDeleteCompletionBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNAcknowledgmentStatus class]];
    PNMessageDeleteCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler; 

    PNLogAPICall(self.logger, @"<PubNub::API> Delete messages from '%@' channel%@%@.",
                 (userRequest.channel?: @"<error>"),
                 (userRequest.start 
                  ? [NSString stringWithFormat:@" %@ %@", userRequest.end ? @"from" : @"till", userRequest.start]
                  : @""),
                 (userRequest.end 
                  ? [NSString stringWithFormat:@" %@ %@", userRequest.start ? @"to" : @"from", userRequest.end]
                  : @""));

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNAcknowledgmentStatus *, PNAcknowledgmentStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self deleteMessagesWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)deleteMessagesFromChannel:(NSString *)channel
                            start:(NSNumber *)startDate
                              end:(NSNumber *)endDate
                   withCompletion:(PNMessageDeleteCompletionBlock)block {
    [self deleteMessagesFromChannel:channel
                              start:startDate
                                end:endDate
                    queryParameters:nil
                     withCompletion:block];
}

- (void)deleteMessagesFromChannel:(NSString *)channel
                            start:(NSNumber *)startDate
                              end:(NSNumber *)endDate
                  queryParameters:(NSDictionary *)queryParameters
                   withCompletion:(PNMessageDeleteCompletionBlock)block {
    PNHistoryMessagesDeleteRequest *request = [PNHistoryMessagesDeleteRequest requestWithChannel:channel];
    request.start = startDate;
    request.end = endDate;
    request.arbitraryQueryParameters = queryParameters;

    [self deleteMessagesWithRequest:request completion:block];
}


#pragma mark - Messages count


- (void)fetchMessagesCountWithRequest:(PNHistoryMessagesCountRequest *)userRequest
                           completion:(PNMessageCountCompletionBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithResult:[PNMessageCountResult class]
                                                            status:[PNErrorStatus class]];
    PNMessageCountCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler; 

    PNLogAPICall(self.logger, @"<PubNub::API> Messages count fetch for '%@' channels%@%@.",
                 [userRequest.channels componentsJoinedByString:@", "],
                 (userRequest.timetokens.count == 1
                  ? [NSString stringWithFormat:@" starting from %@", userRequest.timetokens.firstObject]
                  : @""),
                 (userRequest.timetokens.count > 1
                  ? [NSString stringWithFormat:@" with per-channel starting point %@", [userRequest.timetokens componentsJoinedByString:@","]]
                  : @""));

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNMessageCountResult *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self fetchMessagesCountWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self callBlock:block status:NO withResult:result.result andStatus:result.status];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}


#pragma mark - Handlers

- (void)handleHistoryResult:(PNHistoryResult *)result
                 withStatus:(PNErrorStatus *)status
                 completion:(PNHistoryCompletionBlock)block {

    if (result.data.decryptError) {
        status = [PNErrorStatus objectWithOperation:PNHistoryOperation category:PNDecryptionErrorCategory response:nil];
        status.associatedObject = result.data;
    }

    [self callBlock:block status:NO withResult:status ? nil : result andStatus:status];
}

#pragma mark -


@end
