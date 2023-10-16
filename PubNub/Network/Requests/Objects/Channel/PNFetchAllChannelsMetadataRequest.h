#import <PubNub/PNObjectsPaginatedRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Fetch \c all \c channels \c metadata request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFetchAllChannelsMetadataRequest : PNObjectsPaginatedRequest


#pragma mark - Information

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Supported keys specified in \b PNChannelFields enum.
 * @note Default value (\B PNChannelTotalCountField) can be reset by setting 0.  
 */
@property (nonatomic, assign) PNChannelFields includeFields;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
