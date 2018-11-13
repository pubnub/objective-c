#import <Foundation/Foundation.h>
#import "PNDeleteMessageAPICallBuilder.h"
#import "PNHistoryAPICallBuilder.h"
#import "PubNub+Core.h"


#pragma mark Class forward

@class PNHistoryResult, PNErrorStatus;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - API group interface

/**
 * @brief \b PubNub client core class extension to provide access to 'history' API group.
 *
 * @discussion Set of API which allow to fetch events which has been moved from remote data object
 * live feed to persistent storage.
 *
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PubNub (History)


#pragma mark - API builder support

/**
 * @brief History / storage API access builder.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^history)(void);

/**
 * @brief History / storage manipulation API access builder.
 *
 * @return API call configuration builder.
 *
 * @since 4.7.0
 */
@property (nonatomic, readonly, strong) PNDeleteMessageAPICallBuilder * (^deleteMessage)(void);


#pragma mark - Full history

/**
 * @brief Allow to fetch up to \b 100 events from specified \c channel's events storage.
 *
 * @code
 * [self.client historyForChannel:@"storage"
 *                 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *        //   result.data.start - oldest message time stamp in response
 *        //   result.data.end - newest message time stamp in response
 *        //   result.data.messages - list of messages
 *     } else {
 *        // Handle message history download error. Check 'category' property to find out possible
 *        // issue because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param channel Name of the channel for which events should be pulled out from storage.
 * @param block History pull completion block.
 *
 * @since 4.0
 */
- (void)historyForChannel:(NSString *)channel withCompletion:(PNHistoryCompletionBlock)block 
    NS_SWIFT_NAME(historyForChannel(_:withCompletion:));


#pragma mark - History in specified frame

/**
 * @brief Allow to fetch events from specified \c channel's history within specified time frame.
 *
 * @code
 * NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
 * NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
 *
 * [self.client historyForChannel:@"storage" start:startDate end:endDate
 *                 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle downloaded history using:
 *        //   result.data.start - oldest message time stamp in response
 *        //   result.data.end - newest message time stamp in response
 *        //   result.data.messages - list of messages
 *     } else {
 *        // Handle message history download error. Check 'category' property to find out possible
 *        // issue because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param channel Name of the channel for which events should be pulled out from storage.
 * @param startDate Timetoken for oldest event starting from which next should be returned events.
 *     Value will be converted to required precision internally.
 * @param endDate Timetoken for latest event till which events should be pulled out.
 *     Value will be converted to required precision internally.
 * @param block History pull completion block.
 *
 * @since 4.0
 */
- (void)historyForChannel:(NSString *)channel
                    start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate
           withCompletion:(PNHistoryCompletionBlock)block
    NS_SWIFT_NAME(historyForChannel(_:start:end:withCompletion:));

/**
 * @brief Allow to fetch events from specified \c channel's history within specified time frame.
 *
 * @code
 * NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
 * NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
 *
 * [self.client historyForChannel:@"storage" start:startDate end:endDate limit:50
 *                 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle downloaded history using:
 *        //   result.data.start - oldest message time stamp in response
 *        //   result.data.end - newest message time stamp in response
 *        //   result.data.messages - list of messages
 *     } else {
 *        // Handle message history download error. Check 'category' property to find out possible
 *        // issue because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param channel Name of the channel for which events should be pulled out from storage.
 * @param startDate Timetoken for oldest event starting from which next should be returned events.
 *     Value will be converted to required precision internally.
 * @param endDate Timetoken for latest event till which events should be pulled out.
 *     Value will be converted to required precision internally.
 * @param limit Maximum number of events which should be returned in response (not more then
 *     \b 100).
 * @param block History pull completion block.
 *
 * @since 4.0
 */
- (void)historyForChannel:(NSString *)channel
                    start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate
                    limit:(NSUInteger)limit
           withCompletion:(PNHistoryCompletionBlock)block 
    NS_SWIFT_NAME(historyForChannel(_:start:end:limit:withCompletion:));


#pragma mark - History in frame with extended response

/**
 * @brief Allow to fetch events from specified \c channel's history within specified time frame.
 *
 * @code
 * NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
 * NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
 *
 * [self.client historyForChannel:@"storage" start:startDate end:endDate includeTimeToken:YES
 *                 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *
 *        // Handle downloaded history using:
 *        //   result.data.start - oldest message time stamp in response
 *        //   result.data.end - newest message time stamp in response
 *        //   result.data.messages - list of dictionaries. Each entry will include two keys:
 *        //                          "message" - for body and "timetoken" for date when message has
 *        //                          been sent.
 *     } else {
 *        // Handle message history download error. Check 'category' property to find out possible
 *        // issue because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param channel Name of the channel for which events should be pulled out from storage.
 * @param startDate Timetoken for oldest event starting from which next should be returned events.
 *     Value will be converted to required precision internally.
 * @param endDate Timetoken for latest event till which events should be pulled out.
 *     Value will be converted to required precision internally.
 * @param shouldIncludeTimeToken Whether event dates (time tokens) should be included in response or
 *     not.
 * @param block History pull completion block which.
 *
 * @since 4.0
 */
- (void)historyForChannel:(NSString *)channel
                    start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate
         includeTimeToken:(BOOL)shouldIncludeTimeToken
           withCompletion:(PNHistoryCompletionBlock)block 
    NS_SWIFT_NAME(historyForChannel(_:start:end:includeTimeToken:withCompletion:));

/**
 * @brief Allow to fetch events from specified \c channel's history within specified time frame.
 *
 * @code
 * NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
 * NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
 *
 * [self.client historyForChannel:@"storage" start:startDate end:endDate
 *                          limit:35 includeTimeToken:YES
 *                 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle downloaded history using:
 *        //   result.data.start - oldest message time stamp in response
 *        //   result.data.end - newest message time stamp in response
 *        //   result.data.messages - list of dictionaries. Each entry will include two keys:
 *        //                          "message" - for body and "timetoken" for date when message has
 *        //                          been sent.
 *     } else {
 *        // Handle message history download error. Check 'category' property to find out possible
 *        // issue because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param channel Name of the channel for which events should be pulled out from storage.
 * @param startDate Timetoken for oldest event starting from which next should be returned events.
 *     Value will be converted to required precision internally.
 * @param endDate Timetoken for latest event till which events should be pulled out.
 *     Value will be converted to required precision internally.
 * @param limit Maximum number of events which should be returned in response (not more then
 *     \b 100).
 * @param shouldIncludeTimeToken Whether event dates (time tokens) should be included in response or
 *     not.
 * @param block History pull completion block.
 *
 * @since 4.0
 */
- (void)historyForChannel:(NSString *)channel
                    start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate
                    limit:(NSUInteger)limit
         includeTimeToken:(BOOL)shouldIncludeTimeToken
           withCompletion:(PNHistoryCompletionBlock)block
    NS_SWIFT_NAME(historyForChannel(_:start:end:limit:includeTimeToken:withCompletion:));

/**
 * @brief Allow to fetch events from specified \c channel's history within specified time frame.
 *
 * @code
 * NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
 * NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
 *
 * [self.client historyForChannel:@"storage" start:startDate end:endDate limit:35 reverse:YES
 *                 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle downloaded history using:
 *        //   result.data.start - oldest message time stamp in response
 *        //   result.data.end - newest message time stamp in response
 *        //   result.data.messages - list of messages
 *     } else {
 *        // Handle message history download error. Check 'category' property to find out possible
 *        // issue because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param channel Name of the channel for which events should be pulled out from storage.
 * @param startDate Timetoken for oldest event starting from which next should be returned events.
 *     Value will be converted to required precision internally.
 * @param endDate Timetoken for latest event till which events should be pulled out.
 *     Value will be converted to required precision internally.
 * @param limit Maximum number of events which should be returned in response (not more then
 *     \b 100).
 * @param shouldReverseOrder Whether events order in response should be reversed or not.
 * @param block History pull completion block.
 *
 * @since 4.0
 */
- (void)historyForChannel:(NSString *)channel
                    start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate
                    limit:(NSUInteger)limit
                  reverse:(BOOL)shouldReverseOrder
           withCompletion:(PNHistoryCompletionBlock)block
    NS_SWIFT_NAME(historyForChannel(_:start:end:limit:reverse:withCompletion:));

/**
 * @brief Allow to fetch events from specified \c channel's history within specified time frame.
 *
 * @code
 * NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
 * NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
 *
 * [self.client historyForChannel:@"storage" start:startDate end:endDate limit:35
 *                       reverse:YES includeTimeToken:YES
 *                 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle downloaded history using:
 *        //   result.data.start - oldest message time stamp in response
 *        //   result.data.end - newest message time stamp in response
 *        //   result.data.messages - list of dictionaries. Each entry will include two keys:
 *        //                          "message" - for body and "timetoken" for date when message has
 *        //                          been sent.
 *     } else {
 *        // Handle message history download error. Check 'category' property to find out possible
 *        // issue because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param channel Name of the channel for which events should be pulled out from storage.
 * @param startDate Timetoken for oldest event starting from which next should be returned events.
 *     Value will be converted to required precision internally.
 * @param endDate Timetoken for latest event till which events should be pulled out.
 *     Value will be converted to required precision internally.
 * @param limit Maximum number of events which should be returned in response (not more then
 *     \b 100).
 * @param shouldReverseOrder Whether events order in response should be reversed or not.
 * @param shouldIncludeTimeToken Whether event dates (time tokens) should be included in response or
 *     not.
 * @param block History pull completion block.
 *
 * @since 4.0
 */
- (void)historyForChannel:(NSString *)channel start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate limit:(NSUInteger)limit
                  reverse:(BOOL)shouldReverseOrder includeTimeToken:(BOOL)shouldIncludeTimeToken
           withCompletion:(PNHistoryCompletionBlock)block
    NS_SWIFT_NAME(historyForChannel(_:start:end:limit:reverse:includeTimeToken:withCompletion:));


#pragma mark - History manipulation

/**
 * @brief Allow to remove events from specified \c channel's history within specified time frame.
 *
 * @code
 * NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
 * NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
 *
 * [self.client deleteMessagesFromChannel:@"storage" start:startDate end:endDate
 *                         withCompletion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *        // Messages within specified time frame has been removed.
 *     } else {
 *        // Handle message history download error. Check 'category' property to find out possible
 *        // issue because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param channel Name of the channel from which events should be removed.
 * @param startDate Timetoken for oldest event starting from which events should be removed.
 *     Value will be converted to required precision internally. If no \c endDate value provided,
 *     will be removed all events till specified \c startDate date (not inclusive).
 * @param endDate Timetoken for latest event till which events should be removed.
 *     Value will be converted to required precision internally. If no \c startDate value provided,
 *     will be removed all events starting from specified \c endDate date (inclusive).
 * @param block Events remove completion block.
 *
 * @since 4.0
 */
- (void)deleteMessagesFromChannel:(NSString *)channel
                            start:(nullable NSNumber *)startDate
                              end:(nullable NSNumber *)endDate 
                   withCompletion:(nullable PNMessageDeleteCompletionBlock)block 
    NS_SWIFT_NAME(deleteMessagesFromChannel(_:start:end:withCompletion:));

#pragma mark -


@end

NS_ASSUME_NONNULL_END
