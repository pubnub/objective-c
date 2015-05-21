#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


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
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client historyForChannel:@"storage" withCompletion:^(PNResult *result, PNStatus *status) {
    
     // Check whether request successfully completed or not.
     if (!status.isError) {
            
         // Message from history available in result.data[@"messages"].
         // result.data will look like this:
         // {
         //     "messages": [
         //         id,
         //         ...
         //     ],
         //     "start": Number,
         //     "data": Number
         // }
     }
     // Request processing failed.
     else {
            
         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         // status.data for PNAccessDeniedCategory it will look like this:
         // {
         //     "information": String (description),
         //     "channels": [
         //         String,
         //         ...
         //     ]
         // }
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param channel Name of the channel for hich events should be pulled out from storage.
 @param block   History pull processing completion block which pass two arguments: \c result - in
                case of successful request processing \c data field will contain results of history
                request operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)historyForChannel:(NSString *)channel withCompletion:(PNCompletionBlock)block;


///------------------------------------------------
/// @name History in specified frame
///------------------------------------------------

/**
 @brief  Allow to fetch events from specified \c channel's history within specified time frame.
 @note   All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified
         time frame there is more then 100 events paging may be required. For paging use last event
         time token from respone and some distant future date for next portion of events.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 NSNumber *startDate = @(((NSUInteger)[[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970])*10000000);
 NSNumber *endDate = @(((NSUInteger)[[NSDate date] timeIntervalSince1970])*10000000);
 [client historyForChannel:@"storage" start:startDate end:endDate
            withCompletion:^(PNResult *result, PNStatus *status) {
    
     // Check whether request successfully completed or not.
     if (!status.isError) {
            
         // Message from history available in result.data[@"messages"].
         // result.data will look like this:
         // {
         //     "messages": [
         //         id,
         //         ...
         //     ],
         //     "start": Number,
         //     "data": Number
         // }
     }
     // Request processing failed.
     else {
            
         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         // status.data for PNAccessDeniedCategory it will look like this:
         // {
         //     "information": String (description),
         //     "channels": [
         //         String,
         //         ...
         //     ]
         // }
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param channel   Name of the channel for hich events should be pulled out from storage.
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
           withCompletion:(PNCompletionBlock)block;

/**
 @brief  Allow to fetch events from specified \c channel's history within specified time frame.
 @note   All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified
         time frame there is more then 100 events paging may be required. For paging use last event
         time token from respone and some distant future date for next portion of events.
 
 @code
 @endcode
 Extension to \c -historyForChannel:start:end:withCompletion: and allow to specify maximum number of
 events which should be returned with response, but not more then \b 100.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 NSNumber *startDate = @(((NSUInteger)[[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970])*10000000);
 NSNumber *endDate = @(((NSUInteger)[[NSDate date] timeIntervalSince1970])*10000000);
 [client historyForChannel:@"storage" start:startDate end:endDate limit:50
            withCompletion:^(PNResult *result, PNStatus *status) {
    
     // Check whether request successfully completed or not.
     if (!status.isError) {
            
         // Message from history available in result.data[@"messages"].
         // result.data will look like this:
         // {
         //     "messages": [
         //         id,
         //         ...
         //     ],
         //     "start": Number,
         //     "data": Number
         // }
     }
     // Request processing failed.
     else {
            
         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         // status.data for PNAccessDeniedCategory it will look like this:
         // {
         //     "information": String (description),
         //     "channels": [
         //         String,
         //         ...
         //     ]
         // }
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param channel   Name of the channel for hich events should be pulled out from storage.
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
                    limit:(NSUInteger)limit withCompletion:(PNCompletionBlock)block;


///------------------------------------------------
/// @name Hisotry in frame with extended response
///------------------------------------------------

/**
 @brief  Allow to fetch events from specified \c channel's history within specified time frame.
 @note   All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified
         time frame there is more then 100 events paging may be required. For paging use last event
         time token from respone and some distant future date for next portion of events.
 
 @code
 @endcode
 Extension to \c -historyForChannel:start:end:withCompletion: and allow to specify whether event 
 dates (time tokens) should be included in response or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 NSNumber *startDate = @(((NSUInteger)[[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970])*10000000);
 NSNumber *endDate = @(((NSUInteger)[[NSDate date] timeIntervalSince1970])*10000000);
 [client historyForChannel:@"storage" start:startDate end:endDate includeTimeToken:YES
            withCompletion:^(PNResult *result, PNStatus *status) {
    
     // Check whether request successfully completed or not.
     if (!status.isError) {
            
         // Message from history available in result.data[@"messages"].
         // result.data will look like this in case if time token for messages has been requested:
         // {
         //     "messages": [
         //         {
         //             "message": id,
         //             "tt": Number
         //         },
         //         ...
         //     ],
         //     "start": Number,
         //     "data": Number
         // }
     }
     // Request processing failed.
     else {
            
         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         // status.data for PNAccessDeniedCategory it will look like this:
         // {
         //     "information": String (description),
         //     "channels": [
         //         String,
         //         ...
         //     ]
         // }
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param channel                Name of the channel for hich events should be pulled out from 
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
         includeTimeToken:(BOOL)shouldIncludeTimeToken withCompletion:(PNCompletionBlock)block;

/**
 @brief  Allow to fetch events from specified \c channel's history within specified time frame.
 @note   All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified
         time frame there is more then 100 events paging may be required. For paging use last event
         time token from respone and some distant future date for next portion of events.
 
 @code
 @endcode
 Extension to \c -historyForChannel:start:end:includeTimeToken:withCompletion: and allow to specify 
 maximum number of events which should be returned with response, but not more then \b 100.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 NSNumber *startDate = @(((NSUInteger)[[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970])*10000000);
 NSNumber *endDate = @(((NSUInteger)[[NSDate date] timeIntervalSince1970])*10000000);
 [client historyForChannel:@"storage" start:startDate end:endDate limit:35 includeTimeToken:YES
            withCompletion:^(PNResult *result, PNStatus *status) {
    
     // Check whether request successfully completed or not.
     if (!status.isError) {
            
         // Message from history available in result.data[@"messages"].
         // result.data will look like this in case if time token for messages has been requested:
         // {
         //     "messages": [
         //         {
         //             "message": id,
         //             "tt": Number
         //         },
         //         ...
         //     ],
         //     "start": Number,
         //     "data": Number
         // }
     }
     // Request processing failed.
     else {
            
         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         // status.data for PNAccessDeniedCategory it will look like this:
         // {
         //     "information": String (description),
         //     "channels": [
         //         String,
         //         ...
         //     ]
         // }
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param channel                Name of the channel for hich events should be pulled out from 
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
           withCompletion:(PNCompletionBlock)block;

/**
 @brief  Allow to fetch events from specified \c channel's history within specified time frame.
 @note   All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified
         time frame there is more then 100 events paging may be required. For paging use last event
         time token from respone and some distant future date for next portion of events.
 
 @code
 @endcode
 Extension to \c -historyForChannel:start:end:limit:withCompletion: and allow to specify whether
 events order in response should be reversed or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 NSNumber *startDate = @(((NSUInteger)[[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970])*10000000);
 NSNumber *endDate = @(((NSUInteger)[[NSDate date] timeIntervalSince1970])*10000000);
 [client historyForChannel:@"storage" start:startDate end:endDate limit:35 reverse:YES
            withCompletion:^(PNResult *result, PNStatus *status) {
    
     // Check whether request successfully completed or not.
     if (!status.isError) {
            
         // Message from history available in result.data[@"messages"].
         // result.data will look like this:
         // {
         //     "messages": [
         //         id,
         //         ...
         //     ],
         //     "start": Number,
         //     "data": Number
         // }
     }
     // Request processing failed.
     else {
            
         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         // status.data for PNAccessDeniedCategory it will look like this:
         // {
         //     "information": String (description),
         //     "channels": [
         //         String,
         //         ...
         //     ]
         // }
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param channel            Name of the channel for hich events should be pulled out from storage.
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
           withCompletion:(PNCompletionBlock)block;

/**
 @brief  Allow to fetch events from specified \c channel's history within specified time frame.
 @note   All 'history' API group methods allow to fetch up to \b 100 events at once. If in specified
         time frame there is more then 100 events paging may be required. For paging use last event
         time token from respone and some distant future date for next portion of events.
 
 @code
 @endcode
 Extension to \c -historyForChannel:start:end:limit:reverse:withCompletion: and allow to specify 
 whether events order in response should be reversed or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 NSNumber *startDate = @(((NSUInteger)[[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970])*10000000);
 NSNumber *endDate = @(((NSUInteger)[[NSDate date] timeIntervalSince1970])*10000000);
 [client historyForChannel:@"storage" start:startDate end:endDate limit:35 reverse:YES 
          includeTimeToken:YES withCompletion:^(PNResult *result, PNStatus *status) {
    
     // Check whether request successfully completed or not.
     if (!status.isError) {
            
         // Message from history available in result.data[@"messages"].
         // result.data will look like this in case if time token for messages has been requested:
         // {
         //     "messages": [
         //         {
         //             "message": id,
         //             "tt": Number
         //         },
         //         ...
         //     ],
         //     "start": Number,
         //     "data": Number
         // }
     }
     // Request processing failed.
     else {
            
         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         // status.data for PNAccessDeniedCategory it will look like this:
         // {
         //     "information": String (description),
         //     "channels": [
         //         String,
         //         ...
         //     ]
         // }
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param channel                Name of the channel for hich events should be pulled out from 
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
         includeTimeToken:(BOOL)shouldIncludeTimeToken withCompletion:(PNCompletionBlock)block;

#pragma mark -


@end
