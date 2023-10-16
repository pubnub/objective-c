#import <PubNub/PNBaseObjectsRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Set \c channel \c metadata request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNSetChannelMetadataRequest : PNBaseObjectsRequest


#pragma mark - Information

/**
 * @brief Additional / complex attributes which should be stored in \c metadata associated with
 * specified \c channel.
 */
@property (nonatomic, nullable, strong) NSDictionary *custom;

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Supported keys specified in \b PNChannelFields enum.
 * @note Default value (\b PNChannelCustomField ) can be reset by setting \c 0. 
 */
@property (nonatomic, assign) PNChannelFields includeFields;

/**
 * @brief Description which should be stored in \c metadata associated with specified \c channel.
 */
@property (nonatomic, nullable, copy) NSString *information;

/**
 * @brief Name which should be stored in \c metadata associated with specified \c channel.
 */
@property (nonatomic, copy) NSString *name;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c set \c channel \c metadata request.
 *
 * @param channel Name of channel for which \c metadata should be set.
 *
 * @return Configured and ready to use \c set \c channel \c metadata request.
 */
+ (instancetype)requestWithChannel:(NSString *)channel;

/**
 * @brief Forbids request initialization.
 *
 * @throws Interface not available exception and requirement to use provided constructor method.
 *
 * @return Initialized request.
 */
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
