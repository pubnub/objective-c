/**
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PubNub+History.h"
#import "PNAPICallBuilder+Private.h"
#import "PNServiceData+Private.h"
#import "PNErrorStatus+Private.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNSubscribeStatus.h"
#import "PNResult+Private.h"
#import "PNStatus+Private.h"
#import "PNHistoryResult.h"
#import "PNLogMacro.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PubNub (HistoryProtected)


#pragma mark - History audition

/**
 * @brief Allow to fetch events from specified \c channel's history within specified time frame.
 *
 * @param multipleChannels Whether history should be fetched for multiple \c object or not. If set
 *     to \c YES then \c object contain list of channel names for which history should be retrieved.
 * @param object Name of the channel for which events should be pulled out from storage.
 * @param startDate Reference on time token for oldest event starting from which next should be
 *     returned events. Value will be converted to required precision internally.
 * @param endDate Reference on time token for latest event till which events should be pulled out.
 *     Value will be converted to required precision internally.
 * @param limit Maximum number of events which should be returned in response (not more then
 *     \b 100).
 * @param shouldReverseOrder Whether events order in response should be reversed or not.
 * @param shouldIncludeTimeToken Whether event dates (time tokens) should be included in response or
 *     not.
 * @param shouldIncludeMessageActions Whether event actions should be included in response or not.
 * @param shouldIncludeMetadata Whether event metadata should be included in response or not.
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 * @param block History pull completion block.
 *
 * @since 4.8.2
 */
- (void)historyForChannels:(BOOL)multipleChannels
                    object:(id)object
                     start:(nullable NSNumber *)startDate
                       end:(nullable NSNumber *)endDate
                     limit:(nullable NSNumber *)limit
                   reverse:(nullable NSNumber *)shouldReverseOrder
          includeTimeToken:(nullable NSNumber *)shouldIncludeTimeToken
     includeMessageActions:(nullable NSNumber *)shouldIncludeMessageActions
           includeMetadata:(nullable NSNumber *)shouldIncludeMetadata
           queryParameters:(nullable NSDictionary *)queryParameters
            withCompletion:(PNHistoryCompletionBlock)block;

/**
 * @brief Allow to fetch number of messages for specified channels from specific dates (timetokens).
 *
 * @param channels List of channel names for which persist messages count should be fetched.
 * @param timetokens List with timetokens, where each timetoken's position in correspond to target
 *     \c channel location in channel names list.
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 * @param block Messages count pull completion block.
 *
 * @since 4.8.4
 */
- (void)messageCountForChannels:(NSArray<NSString *> *)channels
                     timetokens:(nullable NSArray<NSNumber *> *)timetokens
                queryParameters:(nullable NSDictionary *)queryParameters
                 withCompletion:(PNMessageCountCompletionBlock)block;


#pragma mark - History manipulation

/**
 * @brief Allow to remove events from specified \c channel's history within specified time frame.
 *
 * @param channel Name of the channel from which events should be removed.
 * @param startDate Reference on time token for oldest event starting from which events should be
 *     removed. Value will be converted to required precision internally. If no \c endDate value
 *     provided, will be removed all events till specified \c startDate date (not inclusive).
 * @param endDate Reference on time token for latest event till which events should be removed.
 *     Value will be converted to required precision internally. If no \c startDate value provided,
 *     will be removed all events starting from specified \c endDate date (inclusive).
 * @param block Events remove completion block.
 *
 * @since 4.8.2
 */
- (void)deleteMessagesFromChannel:(NSString *)channel
                            start:(nullable NSNumber *)startDate
                              end:(nullable NSNumber *)endDate
                  queryParameters:(nullable NSDictionary *)queryParameters
                   withCompletion:(nullable PNMessageDeleteCompletionBlock)block;


#pragma mark - Handlers

/**
 * @brief History request results handling and pre-processing before notify to completion blocks
 * (if required at all).
 *
 * @param result Reference on object which represent server useful response data.
 * @param status Reference on object which represent request processing results.
 * @param block  History pull completion block.
 *
 * @since 4.0
 */
- (void)handleHistoryResult:(nullable PNResult *)result
                 withStatus:(nullable PNStatus *)status
                 completion:(PNHistoryCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (History)


#pragma mark - API Builder support

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
        
        [self deleteMessagesFromChannel:channel
                                  start:start
                                    end:end
                        queryParameters:queryParam
                         withCompletion:block];
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
        
        [self messageCountForChannels:channels
                           timetokens:timetokens
                      queryParameters:queryParam
                       withCompletion:block];
    }];
    
    return ^PNMessageCountAPICallBuilder * {
        return builder;
    };
}


#pragma mark - Full history

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
       includeMessageActions:@(shouldIncludeMetadata)
             includeMetadata:@(shouldIncludeMessageActions)
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
     includeMessageActions:(NSNumber *)shouldIncludeMessageActions
           includeMetadata:(NSNumber *)shouldIncludeMetadata
           queryParameters:(NSDictionary *)queryParameters
            withCompletion:(PNHistoryCompletionBlock)block {

    PNRequestParameters *parameters = [PNRequestParameters new];
    [parameters addQueryParameters:queryParameters];

    if (startDate && endDate && [startDate compare:endDate] == NSOrderedDescending) {
        NSNumber *_startDate = startDate;
        startDate = endDate;
        endDate = _startDate;
    }
    
    if (!limit || limit.unsignedIntValue == 0) {
        limit = nil;
    }

    unsigned int limitValue = MIN(limit.unsignedIntValue, (multipleChannels ? 25 : 100));

    PNOperationType operation = (!multipleChannels ? PNHistoryOperation
                                                   : PNHistoryForChannelsOperation);
    
    if (shouldIncludeMessageActions && shouldIncludeMessageActions.boolValue) {
        operation = PNHistoryWithActionsOperation;
        
        if (limit) {
            limitValue = limit.unsignedIntValue;
        }
        
        if (multipleChannels) {
            NSArray<NSString *> *channels = object;
            object = channels.count ? channels.firstObject : nil;
            multipleChannels = NO;
            
            if (channels.count > 1) {
                NSString *reason = @"History can return actions data for a single channel only. "
                                    "Either pass a single channel or disable the "
                                    "includeMessageActions flag";
                
                @throw [NSException exceptionWithName:@"PNUnacceptableParametersInput"
                                               reason:reason
                                             userInfo:nil];
            }
        }
    }
    
    if (startDate) {
        [parameters addQueryParameter:[PNNumber timeTokenFromNumber:startDate].stringValue
                         forFieldName:@"start"];
    }
    
    if (endDate) {
        [parameters addQueryParameter:[PNNumber timeTokenFromNumber:endDate].stringValue
                         forFieldName:@"end"];
    }
    
    if (shouldReverseOrder && shouldReverseOrder.boolValue) {
        [parameters addQueryParameter:@"true" forFieldName:@"reverse"];
    }
    
    if (shouldIncludeMetadata && shouldIncludeMetadata.boolValue) {
        [parameters addQueryParameter:@"true" forFieldName:@"include_meta"];
    }
    
    if (!multipleChannels) {
        if (limit) {
            [parameters addQueryParameter:[NSString stringWithFormat:@"%d", limitValue]
                             forFieldName:(operation == PNHistoryOperation ? @"count" : @"max")];
        }
        
        if (shouldIncludeTimeToken && shouldIncludeTimeToken.boolValue) {
            [parameters addQueryParameter:@"true" forFieldName:@"include_token"];
        }
        
        NSString *channel = object;
        
        if (channel.length) {
            [parameters addPathComponent:[PNString percentEscapedString:channel]
                          forPlaceholder:@"{channel}"];
        }
        
        PNLogAPICall(self.logger, @"<PubNub::API> %@ for '%@' channel%@%@ with %@ limit%@.",
            (shouldReverseOrder ? @"Reversed history" : @"History"), (channel?: @"<error>"),
            (startDate ? [NSString stringWithFormat:@" from %@", startDate] : @""),
            (endDate ? [NSString stringWithFormat:@" to %@", endDate] : @""), @(limitValue),
            (shouldIncludeTimeToken.boolValue ? @" (including: message time tokens" : @""));
    } else {
        NSArray<NSString *> *channels = object;
        
        if (limit) {
            [parameters addQueryParameter:[NSString stringWithFormat:@"%d", limitValue]
                             forFieldName:@"max"];
        }
        
        if (channels.count) {
            [parameters addPathComponent:[PNChannel namesForRequest:channels]
                          forPlaceholder:@"{channels}"];
        }
        
        PNLogAPICall(self.logger, @"<PubNub::API> History for '%@' channels%@%@ with %@ limit.",
            (channels != nil ? [channels componentsJoinedByString:@", "] : @"<error>"),
            (startDate ? [NSString stringWithFormat:@" from %@", startDate] : @""),
            (endDate ? [NSString stringWithFormat:@" to %@", endDate] : @""), @(limitValue));
    }

    __weak __typeof(self) weakSelf = self;
    [self processOperation:operation
            withParameters:parameters
           completionBlock:^(PNResult *result, PNStatus *status) {
               
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf historyForChannels:multipleChannels
                                      object:object
                                       start:startDate
                                         end:endDate
                                       limit:limit
                                     reverse:shouldReverseOrder
                            includeTimeToken:shouldIncludeTimeToken
                       includeMessageActions:shouldIncludeMessageActions
                             includeMetadata:shouldIncludeMetadata
                             queryParameters:queryParameters
                              withCompletion:block];
            };
        }

        [weakSelf handleHistoryResult:result withStatus:status completion:block];
    }];
}

- (void)messageCountForChannels:(NSArray<NSString *> *)channels
                     timetokens:(NSArray<NSNumber *> *)timetokens
                queryParameters:(NSDictionary *)queryParameters
                 withCompletion:(PNMessageCountCompletionBlock)block {
    
    PNRequestParameters *parameters = [PNRequestParameters new];
    NSUInteger timetokensCount = timetokens.count;
    NSNumber *timetoken = timetokens.firstObject;
    
    [parameters addQueryParameters:queryParameters];
    
    if (channels.count && (timetokensCount == 1 || timetokensCount == channels.count)) {
        [parameters addPathComponent:[PNChannel namesForRequest:channels]
                      forPlaceholder:@"{channels}"];
    }
    
    if (timetokensCount > 0) {
        if (timetokensCount == 1) {
            [parameters addQueryParameter:[PNNumber timeTokenFromNumber:timetoken].stringValue
                             forFieldName:@"timetoken"];
        } else {
            NSMutableArray *pubNubTimetokens = [NSMutableArray arrayWithCapacity:timetokensCount];
            
            for (NSNumber *timetoken in timetokens) {
                [pubNubTimetokens addObject:[PNNumber timeTokenFromNumber:timetoken].stringValue];
            }
            
            [parameters addQueryParameter:[pubNubTimetokens componentsJoinedByString:@","]
                             forFieldName:@"channelsTimetoken"];
        }
    }
    
    PNLogAPICall(self.logger, @"<PubNub::API> Messages count fetch for '%@' channels%@%@.",
        (channels != nil ? [channels componentsJoinedByString:@", "] : @"<error>"),
        (timetokensCount == 1 ? [NSString stringWithFormat:@" starting from %@", timetoken] : @""),
        (timetokensCount > 1 ? [NSString stringWithFormat:@" with per-channel starting point %@",
                                [timetokens componentsJoinedByString:@","]] : @""));
    
    __weak __typeof(self) weakSelf = self;
    [self processOperation:PNMessageCountOperation
            withParameters:parameters
           completionBlock:^(PNResult *result, PNStatus *status) {

        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf messageCountForChannels:channels
                                       timetokens:timetokens
                                  queryParameters:queryParameters
                                   withCompletion:block];
            };
        }

        [weakSelf callBlock:block status:NO withResult:(status ? nil : result) andStatus:status];
    }];
}

#pragma mark - History manipulation

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
    
    // Swap time frame dates if required.
    if (startDate && endDate && [startDate compare:endDate] == NSOrderedDescending) {
        NSNumber *_startDate = startDate;
        startDate = endDate;
        endDate = _startDate;
    }
    
    PNRequestParameters *parameters = [PNRequestParameters new];
    [parameters addQueryParameters:queryParameters];
    parameters.HTTPMethod = @"DELETE";
    
    if (startDate) {
        [parameters addQueryParameter:[PNNumber timeTokenFromNumber:startDate].stringValue
                         forFieldName:@"start"];
    }
    
    if (endDate) {
        [parameters addQueryParameter:[PNNumber timeTokenFromNumber:endDate].stringValue
                         forFieldName:@"end"];
    }
    
    if (channel.length) {
        [parameters addPathComponent:[PNString percentEscapedString:channel]
                      forPlaceholder:@"{channel}"];
    }
    
    PNLogAPICall(self.logger, @"<PubNub::API> Delete messages from '%@' channel%@%@.",
        (channel?: @"<error>"),
        (startDate ? [NSString stringWithFormat:@" %@ %@",
                      endDate ? @"from" : @"till", startDate] : @""),
        (endDate ? [NSString stringWithFormat:@" %@ %@",
                    startDate ? @"to" : @"from", endDate] : @""));
    
    __weak __typeof(self) weakSelf = self;
    [self processOperation:PNDeleteMessageOperation
            withParameters:parameters
           completionBlock:^(PNStatus *status) {
               
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf deleteMessagesFromChannel:channel
                                              start:startDate
                                                end:endDate
                                    queryParameters:queryParameters
                                     withCompletion:block];
            };
        }
               
        [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
    }];
}


#pragma mark - Handlers

- (void)handleHistoryResult:(PNHistoryResult *)result
                 withStatus:(PNErrorStatus *)status
                 completion:(PNHistoryCompletionBlock)block {

    if (result && result.serviceData[@"decryptError"]) {
        status = [PNErrorStatus statusForOperation:PNHistoryOperation
                category:PNDecryptionErrorCategory
                               withProcessingError:nil];

        NSMutableDictionary *updatedData = [result.serviceData mutableCopy];
        [updatedData removeObjectsForKeys:@[@"decryptError", @"envelope"]];
        status.associatedObject = [PNHistoryData dataWithServiceResponse:updatedData];
        [status updateData:updatedData];
    }

    [self callBlock:block status:NO withResult:(status ? nil : result) andStatus:status];
}

#pragma mark -


@end
