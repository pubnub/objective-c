#import "PNAcknowledgmentStatus.h"
#import "PNMessageAction.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent 'Message Actions' API response for \c add \c message
 * \c action request.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNAddMessageActionData : PNServiceData


#pragma mark - Information

/**
 * @brief Added \c message \c action.
 */
@property (nonatomic, nullable, readonly, strong) PNMessageAction *action;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to processed \c add \c message \c action request
 * results.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNAddMessageActionStatus : PNAcknowledgmentStatus


#pragma mark - Information

/**
 * @brief \c Add \c message \c action request processed information.
 */
@property (nonatomic, readonly, strong) PNAddMessageActionData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
