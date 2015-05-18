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
