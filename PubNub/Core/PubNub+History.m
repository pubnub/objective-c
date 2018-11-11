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


#pragma mark - History in frame with extended response

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
           queryParameters:(nullable NSDictionary *)queryParameters
            withCompletion:(PNHistoryCompletionBlock)block;


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
        NSDictionary *queryParam = parameters[@"queryParam"];
        id block = parameters[@"block"];

        [self historyForChannels:(channels != nil)
                          object:(channels?: channel)
                           start:start
                             end:end
                           limit:limit
                         reverse:reverse
                includeTimeToken:includeTimeToken
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


#pragma mark - Full history

- (void)historyForChannel:(NSString *)channel withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannel:channel start:nil end:nil withCompletion:block];
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
           queryParameters:(NSDictionary *)queryParameters
            withCompletion:(PNHistoryCompletionBlock)block {

    PNRequestParameters *parameters = [PNRequestParameters new];

    if (startDate && endDate && [startDate compare:endDate] == NSOrderedDescending) {
        NSNumber *_startDate = startDate;
        startDate = endDate;
        endDate = _startDate;
    }

    limit = (limit?: @(multipleChannels ? 1 : 100));
    unsigned int limitValue = MIN(limit.unsignedIntValue, (multipleChannels ? 25 : 100));


    [parameters addQueryParameters:queryParameters];
    
    if (startDate) {
        [parameters addQueryParameter:[PNNumber timeTokenFromNumber:startDate].stringValue
                         forFieldName:@"start"];
    }
    
    if (endDate) {
        [parameters addQueryParameter:[PNNumber timeTokenFromNumber:endDate].stringValue
                         forFieldName:@"end"];
    }
    
    if (!multipleChannels) {
        [parameters addQueryParameter:[NSString stringWithFormat:@"%d", limitValue]
                         forFieldName:@"count"];
        [parameters addQueryParameter:(shouldReverseOrder.boolValue ? @"true" : @"false")
                         forFieldName:@"reverse"];
        [parameters addQueryParameter:(shouldIncludeTimeToken.boolValue ? @"true" : @"false")
                         forFieldName:@"include_token"];
        NSString *channel = object;
        
        if (channel.length) {
            [parameters addPathComponent:[PNString percentEscapedString:channel]
                          forPlaceholder:@"{channel}"];
        }
        
        PNLogAPICall(self.logger, @"<PubNub::API> %@ for '%@' channel%@%@ with %@ limit%@.",
            (shouldReverseOrder ? @"Reversed history" : @"History"), (channel?: @"<error>"),
            (startDate ? [NSString stringWithFormat:@" from %@", startDate] : @""),
            (endDate ? [NSString stringWithFormat:@" to %@", endDate] : @""), @(limitValue),
            (shouldIncludeTimeToken ? @" (including message time tokens)" : @""));
    } else {
        NSArray<NSString *> *channels = object;

        [parameters addQueryParameter:[NSString stringWithFormat:@"%d", limitValue]
                         forFieldName:@"max"];
        
        if (channels.count) {
            [parameters addPathComponent:[PNChannel namesForRequest:channels]
                          forPlaceholder:@"{channels}"];
        }
        
        PNLogAPICall(self.logger, @"<PubNub::API> History for '%@' channels%@%@ with %@ limit.",
            (channels != nil ? [channels componentsJoinedByString:@", "] : @"<error>"),
            (startDate ? [NSString stringWithFormat:@" from %@", startDate] : @""),
            (endDate ? [NSString stringWithFormat:@" to %@", endDate] : @""), @(limitValue));
    }
    
    PNOperationType operation = (!multipleChannels ? PNHistoryOperation
                                                   : PNHistoryForChannelsOperation);

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
                             queryParameters:queryParameters
                              withCompletion:block];
            };
        }

        [weakSelf handleHistoryResult:result withStatus:status completion:block];
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
