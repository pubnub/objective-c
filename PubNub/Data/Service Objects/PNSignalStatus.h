#import "PNAcknowledgmentStatus.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Class which is used to provide access to additional data available to describe signal
 * sending status.
 *
 * @author Sergey Mamontov
 * @since 4.9.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNSignalData : PNServiceData


#pragma mark - Information

/**
 * @brief Service-provided time stamp at which signal has been sent to remote data object live feed.
 */
@property (nonatomic, readonly, strong) NSNumber *timetoken;

/**
 * @brief Service-provide information about service response message.
 */
@property (nonatomic, readonly, strong) NSString *information;

#pragma mark -


@end


/**
 * @brief Class which is used to provide information about request processing.
 *
 * @author Sergey Mamontov
 * @since 4.9.0
 * @copyright © 2010-2019 PubNub, Inc.
 */

@interface PNSignalStatus : PNAcknowledgmentStatus


#pragma mark - Information

/**
 * @brief Stores reference on publish request processing status information.
 */
@property (nonatomic, readonly, strong) PNSignalData *data;


#pragma mark -


@end

NS_ASSUME_NONNULL_END
