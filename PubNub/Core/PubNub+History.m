/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
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
 @brief      Allow to fetch events from specified \c channel's history within specified time frame.
 @note       All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified time
             frame there is more then 100 events paging may be required. For paging use last event time token
             from response and some distant future date for next portion of events.
 
 @param multipleChannels       Whether history should be fetched for multiple \c object or not. If set to 
                               \c YES then \c object contain list of channel names for which history should be
                               retrieved.
 @param object                 Name of the channel for which events should be pulled out from storage.
 @param startDate              Reference on time token for oldest event starting from which next should be 
                               returned events. Value will be converted to required precision internally.
 @param endDate                Reference on time token for latest event till which events should be pulled 
                               out. Value will be converted to required precision internally.
 @param limit                  Maximum number of events which should be returned in response (not more then 
                               \b 100).
 @param shouldReverseOrder     Whether events order in response should be reversed or not.
 @param shouldIncludeTimeToken Whether event dates (time tokens) should be included in response or not.
 @param block                  History pull processing completion block which pass two arguments: 
                               \c result - in case of successful request processing \c data field will contain
                               results of history request operation; \c status - in case if error occurred 
                               during request processing.
 
 @since 4.5.6
 */
- (void)historyForChannels:(BOOL)multipleChannels object:(id)object start:(nullable NSNumber *)startDate
                       end:(nullable NSNumber *)endDate limit:(nullable NSNumber *)limit 
                   reverse:(nullable NSNumber *)shouldReverseOrder 
          includeTimeToken:(nullable NSNumber *)shouldIncludeTimeToken  
            withCompletion:(PNHistoryCompletionBlock)block;


#pragma mark - Handlers

/**
 @brief  History request results handling and pre-processing before notify to completion blocks (if required 
         at all).
 
 @param result Reference on object which represent server useful response data.
 @param status Reference on object which represent request processing results.
 @param block  History pull processing completion block which pass two arguments: \c result - in case of
               successful request processing \c data field will contain results of history request operation;
               \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)handleHistoryResult:(nullable PNResult *)result withStatus:(nullable PNStatus *)status
                 completion:(PNHistoryCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (History)


#pragma mark - API Builder support

- (PNHistoryAPICallBuilder *(^)(void))history {
    
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
        id block = parameters[@"block"];

        [self historyForChannels:(channels != nil) object:(channels?: channel) start:start end:end 
                           limit:limit reverse:reverse includeTimeToken:includeTimeToken withCompletion:block];
    }];
    
    return ^PNHistoryAPICallBuilder *{ return builder; };
}


#pragma mark - Full history

- (void)historyForChannel:(NSString *)channel withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannel:channel start:nil end:nil withCompletion:block];
}


#pragma mark - History in specified frame

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate 
           withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannel:channel start:startDate end:endDate limit:100 withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate 
                    limit:(NSUInteger)limit withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannel:channel start:startDate end:endDate limit:limit includeTimeToken:NO
             withCompletion:block];
}


#pragma mark - History in frame with extended response

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate 
         includeTimeToken:(BOOL)shouldIncludeTimeToken withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannel:channel start:startDate end:endDate limit:100
           includeTimeToken:shouldIncludeTimeToken withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate 
                    limit:(NSUInteger)limit includeTimeToken:(BOOL)shouldIncludeTimeToken 
           withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannel:channel start:startDate end:endDate limit:limit reverse:NO
           includeTimeToken:shouldIncludeTimeToken withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate 
                    limit:(NSUInteger)limit reverse:(BOOL)shouldReverseOrder 
           withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannel:channel start:startDate end:endDate limit:limit reverse:shouldReverseOrder 
           includeTimeToken:NO withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate 
                    limit:(NSUInteger)limit reverse:(BOOL)shouldReverseOrder 
         includeTimeToken:(BOOL)shouldIncludeTimeToken withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannels:NO object:channel start:startDate end:endDate limit:@(limit) 
                     reverse:@(shouldReverseOrder) includeTimeToken:@(shouldIncludeTimeToken) 
              withCompletion:block];
}

- (void)historyForChannels:(BOOL)multipleChannels object:(id)object start:(NSNumber *)startDate
                       end:(NSNumber *)endDate limit:(NSNumber *)limit reverse:(NSNumber *)shouldReverseOrder 
          includeTimeToken:(NSNumber *)shouldIncludeTimeToken withCompletion:(PNHistoryCompletionBlock)block {
    
    // Swap time frame dates if required.
    if (startDate && endDate && [startDate compare:endDate] == NSOrderedDescending) {
        
        NSNumber *_startDate = startDate;
        startDate = endDate;
        endDate = _startDate;
    }
    // Clamp limit to allowed values.
    limit = (limit?: @(multipleChannels ? 1 : 100));
    unsigned int limitValue = MIN(limit.unsignedIntValue, (multipleChannels ? 25 : 100));

    PNRequestParameters *parameters = [PNRequestParameters new];
    if (startDate) {
        
        [parameters addQueryParameter:[PNNumber timeTokenFromNumber:startDate].stringValue
                         forFieldName:@"start"];
    }
    
    if (endDate) {
        
        [parameters addQueryParameter:[PNNumber timeTokenFromNumber:endDate].stringValue
                         forFieldName:@"end"];
    }
    
    if (!multipleChannels) {
        
        [parameters addQueryParameter:[NSString stringWithFormat:@"%d", limitValue] forFieldName:@"count"];
        [parameters addQueryParameter:(shouldReverseOrder.boolValue ? @"true" : @"false")
                         forFieldName:@"reverse"];
        [parameters addQueryParameter:(shouldIncludeTimeToken.boolValue ? @"true" : @"false")
                         forFieldName:@"include_token"];
        NSString *channel = object;
        if (channel.length) {
            
            [parameters addPathComponent:[PNString percentEscapedString:channel] forPlaceholder:@"{channel}"];
        }
        
        DDLogAPICall(self.logger, @"<PubNub::API> %@ for '%@' channel%@%@ with %@ limit%@.",
                     (shouldReverseOrder ? @"Reversed history" : @"History"), (channel?: @"<error>"),
                     (startDate ? [NSString stringWithFormat:@" from %@", startDate] : @""),
                     (endDate ? [NSString stringWithFormat:@" to %@", endDate] : @""), @(limitValue),
                     (shouldIncludeTimeToken ? @" (including message time tokens)" : @""));
    }
    else {
        
        [parameters addQueryParameter:[NSString stringWithFormat:@"%d", limitValue] forFieldName:@"max"];
        NSArray<NSString *> *channels = object;
        if (channels.count) {
            
            [parameters addPathComponent:[PNChannel namesForRequest:channels] forPlaceholder:@"{channels}"];
        }
        
        DDLogAPICall(self.logger, @"<PubNub::API> History for '%@' channels%@%@ with %@ limit.",
                     (channels != nil ? [channels componentsJoinedByString:@", "] : @"<error>"),
                     (startDate ? [NSString stringWithFormat:@" from %@", startDate] : @""),
                     (endDate ? [NSString stringWithFormat:@" to %@", endDate] : @""), @(limitValue));
    }
    PNOperationType operation = (!multipleChannels ? PNHistoryOperation : PNHistoryForChannelsOperation);

    __weak __typeof(self) weakSelf = self;
    [self processOperation:operation withParameters:parameters 
           completionBlock:^(PNResult *result, PNStatus *status) {

        // Silence static analyzer warnings.
        // Code is aware about this case and at the end will simply call on 'nil' object
        // method. In most cases if referenced object become 'nil' it mean what there is no
        // more need in it and probably whole client instance has been deallocated.
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wreceiver-is-weak"
        if (status.isError) {

            status.retryBlock = ^{

                [weakSelf historyForChannels:multipleChannels object:object start:startDate end:endDate 
                                       limit:limit reverse:shouldReverseOrder 
                            includeTimeToken:shouldIncludeTimeToken withCompletion:block];
            };
        }
        [weakSelf handleHistoryResult:result withStatus:status completion:block];
        #pragma clang diagnostic pop
    }];
}


#pragma mark - Handlers

- (void)handleHistoryResult:(PNHistoryResult *)result withStatus:(PNErrorStatus *)status
                 completion:(PNHistoryCompletionBlock)block {

    if (result && result.serviceData[@"decryptError"]) {
        
        status = [PNErrorStatus statusForOperation:PNHistoryOperation category:PNDecryptionErrorCategory
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
