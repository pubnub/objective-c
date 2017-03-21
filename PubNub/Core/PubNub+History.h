#import <Foundation/Foundation.h>
#import "PNHistoryAPICallBuilder.h"
#import "PubNub+Core.h"


#pragma mark Class forward

@class PNHistoryResult, PNErrorStatus;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - API group interface

/**
 @brief      \b PubNub client core class extension to provide access to 'history' API group.
 @discussion Set of API which allow to fetch events which has been moved from remote data object live feed to 
             persistent storage.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PubNub (History)


///------------------------------------------------
/// @name API Builder support
///------------------------------------------------

/**
 @brief      Stores reference on history / storage API access \c builder construction block.
 @discussion On block call return builder which allow to configure parameters for history / storage API
             access.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder *(^history)(void);


///------------------------------------------------
/// @name Full history
///------------------------------------------------

/**
 @brief      Allow to fetch up to \b 100 events from specified \c channel's events storage.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client historyForChannel:@"storage" withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {

       // Handle downloaded history using: 
       //   result.data.start - oldest message time stamp in response
       //   result.data.end - newest message time stamp in response
       //   result.data.messages - list of messages
    }
    // Request processing failed.
    else {
    
       // Handle message history download error. Check 'category' property to find out possible 
       // issue because of which request did fail.
       //
       // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param channel Name of the channel for which events should be pulled out from storage.
 @param block   History pull processing completion block which pass two arguments: \c result - in case of 
                successful request processing \c data field will contain results of history request operation;
                \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)historyForChannel:(NSString *)channel withCompletion:(PNHistoryCompletionBlock)block NS_SWIFT_NAME(historyForChannel(_:withCompletion:));


///------------------------------------------------
/// @name History in specified frame
///------------------------------------------------

/**
 @brief      Allow to fetch events from specified \c channel's history within specified time frame.
 @note       All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified time 
             frame there is more then 100 events paging may be required. For paging use last event time token
             from response and some distant future date for next portion of events.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
[self.client historyForChannel:@"storage" start:startDate end:endDate
                withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {

       // Handle downloaded history using: 
       //   result.data.start - oldest message time stamp in response
       //   result.data.end - newest message time stamp in response
       //   result.data.messages - list of messages
    }
    // Request processing failed.
    else {
    
       // Handle message history download error. Check 'category' property to find out possible 
       // issue because of which request did fail.
       //
       // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param channel   Name of the channel for which events should be pulled out from storage.
 @param startDate Reference on time token for oldest event starting from which next should be returned events.
                  Value will be converted to required precision internally.
 @param endDate   Reference on time token for latest event till which events should be pulled out. Value will
                  be converted to required precision internally.
 @param block     History pull processing completion block which pass two arguments: \c result - in case of 
                  successful request processing \c data field will contain results of history request 
                  operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)historyForChannel:(NSString *)channel start:(nullable NSNumber *)startDate 
                      end:(nullable NSNumber *)endDate withCompletion:(PNHistoryCompletionBlock)block NS_SWIFT_NAME(historyForChannel(_:start:end:withCompletion:));

/**
 @brief      Allow to fetch events from specified \c channel's history within specified time frame.
 @note       All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified time 
             frame there is more then 100 events paging may be required. For paging use last event time token
             from response and some distant future date for next portion of events.
 @discussion Extension to \c -historyForChannel:start:end:withCompletion: and allow to specify maximum number
             of events which should be returned with response, but not more then \b 100.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
[self.client historyForChannel:@"storage" start:startDate end:endDate limit:50
                withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {

       // Handle downloaded history using: 
       //   result.data.start - oldest message time stamp in response
       //   result.data.end - newest message time stamp in response
       //   result.data.messages - list of messages
    }
    // Request processing failed.
    else {
    
       // Handle message history download error. Check 'category' property to find out possible 
       // issue because of which request did fail.
       //
       // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param channel   Name of the channel for which events should be pulled out from storage.
 @param startDate Reference on time token for oldest event starting from which next should be returned events.
                  Value will be converted to required precision internally.
 @param endDate   Reference on time token for latest event till which events should be pulled out. Value will 
                  be converted to required precision internally.
 @param limit     Maximum number of events which should be returned in response (not more then \b 100).
 @param block     History pull processing completion block which pass two arguments: \c result - in case of 
                  successful request processing \c data field will contain results of history request 
                  operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)historyForChannel:(NSString *)channel start:(nullable NSNumber *)startDate 
                      end:(nullable NSNumber *)endDate limit:(NSUInteger)limit 
           withCompletion:(PNHistoryCompletionBlock)block NS_SWIFT_NAME(historyForChannel(_:start:end:limit:withCompletion:));


///------------------------------------------------
/// @name History in frame with extended response
///------------------------------------------------

/**
 @brief      Allow to fetch events from specified \c channel's history within specified time frame.
 @note       All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified time 
             frame there is more then 100 events paging may be required. For paging use last event time token 
             from response and some distant future date for next portion of events.
 @discussion Extension to \c -historyForChannel:start:end:withCompletion: and allow to specify whether event 
             dates (time tokens) should be included in response or not.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
[self.client historyForChannel:@"storage" start:startDate end:endDate includeTimeToken:YES
                withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {

       // Handle downloaded history using: 
       //   result.data.start - oldest message time stamp in response
       //   result.data.end - newest message time stamp in response
       //   result.data.messages - list of dictionaries. Each entry will include two keys: 
       //                          "message" - for body and "timetoken" for date when message has
       //                          been sent.
    }
    // Request processing failed.
    else {
    
       // Handle message history download error. Check 'category' property to find out possible 
       // issue because of which request did fail.
       //
       // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param channel                Name of the channel for which events should be pulled out from storage.
 @param startDate              Reference on time token for oldest event starting from which next should be 
                               returned events. Value will be converted to required precision internally.
 @param endDate                Reference on time token for latest event till which events should be pulled 
                               out. Value will be converted to required precision internally.
 @param shouldIncludeTimeToken Whether event dates (time tokens) should be included in response or not.
 @param block                  History pull processing completion block which pass two arguments:
                               \c result - in case of successful request processing \c data field will contain
                               results of history request operation; \c status - in case if error occurred
                               during request processing.
 
 @since 4.0
 */
- (void)historyForChannel:(NSString *)channel start:(nullable NSNumber *)startDate 
                      end:(nullable NSNumber *)endDate includeTimeToken:(BOOL)shouldIncludeTimeToken 
           withCompletion:(PNHistoryCompletionBlock)block NS_SWIFT_NAME(historyForChannel(_:start:end:includeTimeToken:withCompletion:));

/**
 @brief      Allow to fetch events from specified \c channel's history within specified time frame.
 @note       All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified time 
             frame there is more then 100 events paging may be required. For paging use last event time token 
             from response and some distant future date for next portion of events.
 @discussion Extension to \c -historyForChannel:start:end:includeTimeToken:withCompletion: and allow to 
             specify maximum number of events which should be returned with response, but not more then 
             \b 100.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
[self.client historyForChannel:@"storage" start:startDate end:endDate limit:35 includeTimeToken:YES
                withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {

       // Handle downloaded history using: 
       //   result.data.start - oldest message time stamp in response
       //   result.data.end - newest message time stamp in response
       //   result.data.messages - list of dictionaries. Each entry will include two keys: 
       //                          "message" - for body and "timetoken" for date when message has
       //                          been sent.
    }
    // Request processing failed.
    else {
    
       // Handle message history download error. Check 'category' property to find out possible 
       // issue because of which request did fail.
       //
       // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param channel                Name of the channel for which events should be pulled out from storage.
 @param startDate              Reference on time token for oldest event starting from which next should be 
                               returned events. Value will be converted to required precision internally.
 @param endDate                Reference on time token for latest event till which events should be pulled 
                               out. Value will be converted to required precision internally.
 @param limit                  Maximum number of events which should be returned in response (not more then 
                               \b 100).
 @param shouldIncludeTimeToken Whether event dates (time tokens) should be included in response or not.
 @param block                  History pull processing completion block which pass two arguments:
                               \c result - in case of successful request processing \c data field will contain
                               results of history request operation; \c status - in case if error occurred 
                               during request processing.
 
 @since 4.0
 */
- (void)historyForChannel:(NSString *)channel start:(nullable NSNumber *)startDate 
                      end:(nullable NSNumber *)endDate limit:(NSUInteger)limit
         includeTimeToken:(BOOL)shouldIncludeTimeToken withCompletion:(PNHistoryCompletionBlock)block NS_SWIFT_NAME(historyForChannel(_:start:end:limit:includeTimeToken:withCompletion:));

/**
 @brief      Allow to fetch events from specified \c channel's history within specified time frame.
 @note       All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified time 
             frame there is more then 100 events paging may be required. For paging use last event time token 
             from response and some distant future date for next portion of events.
 @discussion Extension to \c -historyForChannel:start:end:limit:withCompletion: and allow to specify whether
             events order in response should be reversed or not.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
[self.client historyForChannel:@"storage" start:startDate end:endDate limit:35 reverse:YES
                withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {

       // Handle downloaded history using: 
       //   result.data.start - oldest message time stamp in response
       //   result.data.end - newest message time stamp in response
       //   result.data.messages - list of messages
    }
    // Request processing failed.
    else {
    
       // Handle message history download error. Check 'category' property to find out possible 
       // issue because of which request did fail.
       //
       // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param channel            Name of the channel for which events should be pulled out from storage.
 @param startDate          Reference on time token for oldest event starting from which next should be 
                           returned events. Value will be converted to required precision internally.
 @param endDate            Reference on time token for latest event till which events should be pulled out. 
                           Value will be converted to required precision internally.
 @param limit              Maximum number of events which should be returned in response (not more then 
                           \b 100).
 @param shouldReverseOrder Whether events order in response should be reversed or not.
 @param block              History pull processing completion block which pass two arguments: \c result - in 
                           case of successful request processing \c data field will contain results of history
                           request operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)historyForChannel:(NSString *)channel start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate limit:(NSUInteger)limit 
                  reverse:(BOOL)shouldReverseOrder withCompletion:(PNHistoryCompletionBlock)block NS_SWIFT_NAME(historyForChannel(_:start:end:limit:reverse:withCompletion:));

/**
 @brief      Allow to fetch events from specified \c channel's history within specified time frame.
 @note       All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified time
             frame there is more then 100 events paging may be required. For paging use last event time token
             from response and some distant future date for next portion of events.
 @discussion Extension to \c -historyForChannel:start:end:limit:reverse:withCompletion: and allow to specify 
 whether events order in response should be reversed or not.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
[self.client historyForChannel:@"storage" start:startDate end:endDate limit:35 reverse:YES 
              includeTimeToken:YES withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {

       // Handle downloaded history using: 
       //   result.data.start - oldest message time stamp in response
       //   result.data.end - newest message time stamp in response
       //   result.data.messages - list of dictionaries. Each entry will include two keys: 
       //                          "message" - for body and "timetoken" for date when message has
       //                          been sent.
    }
    // Request processing failed.
    else {
    
       // Handle message history download error. Check 'category' property to find out possible 
       // issue because of which request did fail.
       //
       // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param channel                Name of the channel for which events should be pulled out from storage.
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
 
 @since 4.0
 */
- (void)historyForChannel:(NSString *)channel start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate limit:(NSUInteger)limit 
                  reverse:(BOOL)shouldReverseOrder includeTimeToken:(BOOL)shouldIncludeTimeToken 
           withCompletion:(PNHistoryCompletionBlock)block NS_SWIFT_NAME(historyForChannel(_:start:end:limit:reverse:includeTimeToken:withCompletion:));

#pragma mark -


@end

NS_ASSUME_NONNULL_END
