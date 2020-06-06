#import "PNAPICallBuilder.h"
#import "PNStructures.h"


#pragma mark Class forward

@class PNSetUUIDMetadataAPICallBuilder, PNRemoveUUIDMetadataAPICallBuilder, PNFetchUUIDMetadataAPICallBuilder, PNFetchAllUUIDMetadataAPICallBuilder, PNFetchMembershipsAPICallBuilder;
@class PNSetChannelMetadataAPICallBuilder, PNRemoveChannelMetadataAPICallBuilder, PNFetchChannelMetadataAPICallBuilder, PNFetchAllChannelsMetadataAPICallBuilder;
@class PNManageChannelMembersAPICallBuilder, PNRemoveChannelMembersAPICallBuilder, PNSetChannelMembersAPICallBuilder, PNFetchChannelMembersAPICallBuilder;
@class PNManageMembershipsAPICallBuilder, PNSetMembershipsAPICallBuilder, PNRemoveMembershipsAPICallBuilder;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface declaration

/**
 * @brief \c Objects API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNObjectsAPICallBuilder : PNAPICallBuilder


#pragma mark - UUID metadata management / audit

/**
 * @brief \c Metadata association with \c UUID API access builder block.
 *
 * @param uuid Identifier with which new \c metadata should be associated.
 * Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSetUUIDMetadataAPICallBuilder * (^setUUIDMetadata)(void);

/**
 * @brief Associated with \c UUID \c metadata remove API access builder block.
 *
 * @param uuid Identifier for which associated \c metadata should be removed.
 * Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveUUIDMetadataAPICallBuilder * (^removeUUIDMetadata)(void);

/**
 * @brief \c Fetch \c metadata associated with \c UUID API access builder block.
 *
 * @param uuid Identifier for which associated \c metadata should be fetched.
 * Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchUUIDMetadataAPICallBuilder * (^uuidMetadata)(void);

/**
 * @brief \c Fetch \c metadata associated with all \c UUIDs API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchAllUUIDMetadataAPICallBuilder * (^allUUIDMetadata)(void);


#pragma mark - Channel metadata management / audit

/**
 * @brief \c Metadata association with \c channel API access builder block.
 *
 * @param channel Name of channel with which new \c metadata should be associated.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSetChannelMetadataAPICallBuilder * (^setChannelMetadata)(NSString *channel);

/**
 * @brief Associated with \c channel \c metadata remove API access builder block.
 *
 * @param channel Name of channel for which associated \c metadata should be removed.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveChannelMetadataAPICallBuilder * (^removeChannelMetadata)(NSString *channel);

/**
 * @brief \c Fetch \c metadata associated with \c channel API access builder block.
 *
 * @param channel Name of channel for which associated \c metadata should be fetched.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchChannelMetadataAPICallBuilder * (^channelMetadata)(NSString *channel);

/**
 * @brief \c Fetch \c metadata associated with all \c channels API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchAllChannelsMetadataAPICallBuilder * (^allChannelsMetadata)(void);


#pragma mark - Members / memberships management / audit

/**
 * @brief Memberships management API call builder access block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^manageMemberships)(void);

/**
 * @brief Memberships set API call builder access block.
 *
 * @param uuid Identifier for which memberships should be set.
 * Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSetMembershipsAPICallBuilder * (^setMemberships)(void);

/**
 * @brief Memberships remove API call builder access block.
 *
 * @param uuid Identifier for which memberships should be removed.
 * Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveMembershipsAPICallBuilder * (^removeMemberships)(void);

/**
 * @brief Memberships fetch API call builder access block.
 *
 * @param uuid Identifier for which memberships should be fetched.
 * Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMembershipsAPICallBuilder * (^memberships)(void);

/**
 * @brief Members management API call builder access block.
 *
 * @param channel Name of channel from which members should be managed.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageChannelMembersAPICallBuilder * (^manageChannelMembers)(NSString *channel);

/**
 * @brief Members set API call builder access block.
 *
 * @param channel Name of channel from which members should be set.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSetChannelMembersAPICallBuilder * (^setChannelMembers)(NSString *channel);

/**
 * @brief Members remove API call builder access block.
 *
 * @param channel Name of channel from which members should be removed.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveChannelMembersAPICallBuilder * (^removeChannelMembers)(NSString *channel);

/**
 * @brief Members fetch API call builder access block.
 *
 * @param channel Name of channel from which members should be fetched.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchChannelMembersAPICallBuilder * (^channelMembers)(NSString *channel);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
