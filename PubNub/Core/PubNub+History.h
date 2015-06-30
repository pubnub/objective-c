#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


#pragma mark Class forward

@class PNHistoryResult, PNErrorStatus;


#pragma mark - Types

/**
 @brief  Channel history fetch completion block.
 
 @param result Reference on result object which describe service response on history request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNHistoryCompletionBlock)(PNHistoryResult *result, PNErrorStatus *status);


#pragma mark - API group interface

/**
 @brief      \b PubNub client core class extension to provide access to 'history' API group.
 @discussion Set of API which allow to fetch events which has been moved from remote data object
             live feed to persistent storage.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PubNub (History)


///------------------------------------------------
/// @name Full history
///------------------------------------------------

/**
 @brief  Allow to fetch up to \b 100 events from specified \c channel's events storage.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client historyForChannel:@"storage" withCompletion:^(PNHistoryResult *result,
                                                            PNErrorStatus *status) {
 
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
 @param block   History pull processing completion block which pass two arguments: \c result - in
                case of successful request processing \c data field will contain results of history
                request operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)historyForChannel:(NSString *)channel withCompletion:(PNHistoryCompletionBlock)block;


///------------------------------------------------
/// @name History in specified frame
///------------------------------------------------

/**
 @brief  Allow to fetch events from specified \c channel's history within specified time frame.
 @note   All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified
         time frame there is more then 100 events paging may be required. For paging use last event
         time token from response and some distant future date for next portion of events.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 NSNumber *startDate = @((unsigned long long)([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]*10000000));
 NSNumber *endDate = @((unsigned long long)([[NSDate date] timeIntervalSince1970]*10000000));
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
 @param startDate Reference on time token for oldest event starting from which next should be 
                  returned events.
 @param endDate   Reference on time token for latest event till which events should be pulled out.
 @param block     History pull processing completion block which pass two arguments: \c result - in
                  case of successful request processing \c data field will contain results of 
                  history request operation; \c status - in case if error occurred during request 
                  processing.
 
 @since 4.0
 */
- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate
           withCompletion:(PNHistoryCompletionBlock)block;

/**
 @brief  Allow to fetch events from specified \c channel's history within specified time frame.
 @note   All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified
         time frame there is more then 100 events paging may be required. For paging use last event
         time token from response and some distant future date for next portion of events.
 
 @code
 @endcode
 Extension to \c -historyForChannel:start:end:withCompletion: and allow to specify maximum number of
 events which should be returned with response, but not more then \b 100.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 NSNumber *startDate = @((unsigned long long)([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]*10000000));
 NSNumber *endDate = @((unsigned long long)([[NSDate date] timeIntervalSince1970]*10000000));
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
 @param startDate Reference on time token for oldest event starting from which next should be 
                  returned events.
 @param endDate   Reference on time token for latest event till which events should be pulled out.
 @param limit     Maximum number of events which should be returned in response (not more then 
                  \b 100).
 @param block     History pull processing completion block which pass two arguments: \c result - in
                  case of successful request processing \c data field will contain results of 
                  history request operation; \c status - in case if error occurred during request 
                  processing.
 
 @since 4.0
 */
- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate
                    limit:(NSUInteger)limit withCompletion:(PNHistoryCompletionBlock)block;


///------------------------------------------------
/// @name History in frame with extended response
///------------------------------------------------

/**
 @brief  Allow to fetch events from specified \c channel's history within specified time frame.
 @note   All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified
         time frame there is more then 100 events paging may be required. For paging use last event
         time token from response and some distant future date for next portion of events.
 
 @code
 @endcode
 Extension to \c -historyForChannel:start:end:withCompletion: and allow to specify whether event 
 dates (time tokens) should be included in response or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 NSNumber *startDate = @((unsigned long long)([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]*10000000));
 NSNumber *endDate = @((unsigned long long)([[NSDate date] timeIntervalSince1970]*10000000));
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
 
 @param channel                Name of the channel for which events should be pulled out from
                               storage.
 @param startDate              Reference on time token for oldest event starting from which next 
                               should be returned events.
 @param endDate                Reference on time token for latest event till which events should be 
                               pulled out.
 @param shouldIncludeTimeToken Whether event dates (time tokens) should be included in response or 
                               not.
 @param block                  History pull processing completion block which pass two arguments:
                               \c result - in case of successful request processing \c data field 
                               will contain results of history request operation; \c status - in
                               case if error occurred during request processing.
 
 @since 4.0
 */
- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate
         includeTimeToken:(BOOL)shouldIncludeTimeToken withCompletion:(PNHistoryCompletionBlock)block;

/**
 @brief  Allow to fetch events from specified \c channel's history within specified time frame.
 @note   All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified
         time frame there is more then 100 events paging may be required. For paging use last event
         time token from response and some distant future date for next portion of events.
 
 @code
 @endcode
 Extension to \c -historyForChannel:start:end:includeTimeToken:withCompletion: and allow to specify 
 maximum number of events which should be returned with response, but not more then \b 100.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 NSNumber *startDate = @((unsigned long long)([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]*10000000));
 NSNumber *endDate = @((unsigned long long)([[NSDate date] timeIntervalSince1970]*10000000));
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
 
 @param channel                Name of the channel for which events should be pulled out from
                               storage.
 @param startDate              Reference on time token for oldest event starting from which next 
                               should be returned events.
 @param endDate                Reference on time token for latest event till which events should be 
                               pulled out.
 @param limit                  Maximum number of events which should be returned in response (not 
                               more then \b 100).
 @param shouldIncludeTimeToken Whether event dates (time tokens) should be included in response or 
                               not.
 @param block                  History pull processing completion block which pass two arguments:
                               \c result - in case of successful request processing \c data field 
                               will contain results of history request operation; \c status - in
                               case if error occurred during request processing.
 
 @since 4.0
 */
- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate
                    limit:(NSUInteger)limit includeTimeToken:(BOOL)shouldIncludeTimeToken
           withCompletion:(PNHistoryCompletionBlock)block;

/**
 @brief  Allow to fetch events from specified \c channel's history within specified time frame.
 @note   All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified
         time frame there is more then 100 events paging may be required. For paging use last event
         time token from response and some distant future date for next portion of events.
 
 @code
 @endcode
 Extension to \c -historyForChannel:start:end:limit:withCompletion: and allow to specify whether
 events order in response should be reversed or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 NSNumber *startDate = @((unsigned long long)([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]*10000000));
 NSNumber *endDate = @((unsigned long long)([[NSDate date] timeIntervalSince1970]*10000000));
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
 @param startDate          Reference on time token for oldest event starting from which next should
                           be returned events.
 @param endDate            Reference on time token for latest event till which events should be
                           pulled out.
 @param limit              Maximum number of events which should be returned in response (not more 
                           then \b 100).
 @param shouldReverseOrder Whether events order in response should be reversed or not.
 @param block              History pull processing completion block which pass two arguments:
                           \c result - in case of successful request processing \c data field will 
                           contain results of history request operation; \c status - in case if 
                           error occurred during request processing.
 
 @since 4.0
 */
- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate
                    limit:(NSUInteger)limit reverse:(BOOL)shouldReverseOrder
           withCompletion:(PNHistoryCompletionBlock)block;

/**
 @brief  Allow to fetch events from specified \c channel's history within specified time frame.
 @note   All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified
         time frame there is more then 100 events paging may be required. For paging use last event
         time token from response and some distant future date for next portion of events.
 
 @code
 @endcode
 Extension to \c -historyForChannel:start:end:limit:reverse:withCompletion: and allow to specify 
 whether events order in response should be reversed or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 NSNumber *startDate = @((unsigned long long)([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]*10000000));
 NSNumber *endDate = @((unsigned long long)([[NSDate date] timeIntervalSince1970]*10000000));
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
 
 @param channel                Name of the channel for which events should be pulled out from
                               storage.
 @param startDate              Reference on time token for oldest event starting from which next 
                               should be returned events.
 @param endDate                Reference on time token for latest event till which events should be 
                               pulled out.
 @param limit                  Maximum number of events which should be returned in response (not 
                               more then \b 100).
 @param shouldReverseOrder     Whether events order in response should be reversed or not.
 @param shouldIncludeTimeToken Whether event dates (time tokens) should be included in response or
                               not.
 @param block                  History pull processing completion block which pass two arguments: 
                               \c result - in case of successful request processing \c data field 
                               will contain results of history request operation; \c status - in
                               case if error occurred during request processing.
 
 @since 4.0
 */
- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate
                    limit:(NSUInteger)limit reverse:(BOOL)shouldReverseOrder
         includeTimeToken:(BOOL)shouldIncludeTimeToken withCompletion:(PNHistoryCompletionBlock)block;

#pragma mark -


@end
