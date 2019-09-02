#import "PNMessageAction.h"
#import "PNServiceData.h"
#import "PNResult.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Message Action API response for \c fetch \c message
 * \c actions request.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchMessageActionsData : PNServiceData


#pragma mark - Information

/**
 * @brief List of fetched \c messages \c actions.
 */
@property (nonatomic, readonly, strong) NSArray<PNMessageAction *> *actions;

/**
 * @brief Fetched \c message \c actions time range start (oldest \c message \c action timetoken).
 *
 * @note This timetoken can be used as \c start value to fetch older \c message \c actions.
 */
@property (nonatomic, readonly, strong) NSNumber *start;

/**
 * @brief Fetched \c message \c actions time range end (newest \c action timetoken).
 */
@property (nonatomic, readonly, strong) NSNumber *end;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to processed \c fetch \c message \c actions
 * request results.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchMessageActionsResult : PNResult


#pragma mark - Information

/**
 * @brief \c Fetch \c message \c actions request processed information.
 */
@property (nonatomic, readonly, strong) PNFetchMessageActionsData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
