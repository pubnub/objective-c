#import "PNResult.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent History API response for \c channel(s) request.
 *
 * @author Sergey Mamontov
 * @version 4.11.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNHistoryData : PNServiceData


#pragma mark - Information

/**
 * @brief Channel history messages.
 *
 * @note Set only for \c PNHistoryOperation operation and will be \c empty array for other operation
 * types.
 */
@property (nonatomic, readonly, strong) NSArray *messages;

/**
 * @brief Channels history.
 *
 * @discussion Each key represent name of \c channel for which messages has been received and values
 * is list of messages from channel's storage.
 *
 * @note For \c PNHistoryOperation operation this property always will be \c empty dictionary.
 *
 * @since 4.5.6
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, NSArray *> *channels;

/**
 * @brief Fetched history time frame start time.
 *
 * @note Set only for \c PNHistoryOperation operation and will be \b 0 for other operation types.
 */
@property (nonatomic, readonly, strong) NSNumber *start;

/**
 * @brief Fetched history time frame end time.
 *
 * @note Set only for \c PNHistoryOperation operation and will be \b 0 for other operation types.
 */
@property (nonatomic, readonly, strong) NSNumber *end;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to processed \c fetch \c history request results.
 *
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNHistoryResult : PNResult


#pragma mark -  Information

/**
 * @brief \c Fetch \c history request processed information.
 */
@property (nonatomic, readonly, strong) PNHistoryData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
