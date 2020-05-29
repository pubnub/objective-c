#import "PNAcknowledgmentStatus.h"
#import "PNChannelMetadata.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Objects API response for \c set \c channel \c metadata
 * request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNSetChannelMetadataData : PNServiceData


#pragma mark - Information

/**
 * @brief Associated \c channel's \c metadata object.
 */
@property (nonatomic, nullable, readonly, strong) PNChannelMetadata *metadata;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to processed \c set \c channel \c metadata request
 * results.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNSetChannelMetadataStatus : PNAcknowledgmentStatus


#pragma mark - Information

/**
 * @brief \c Set \c channel \c metadata request processed information.
 */
@property (nonatomic, readonly, strong) PNSetChannelMetadataData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
