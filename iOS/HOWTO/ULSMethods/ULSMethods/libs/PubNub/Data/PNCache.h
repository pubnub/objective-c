#pragma mark Class forward

@class PNChannel;


/**
 Cache class will store all crucial information which maybe used by \b PubNub client during lifetime of session.

 @since 3.6.0

 @author Sergey Mamontov
 @copyright © 2009-13 PubNub Inc.
 */
@interface PNCache : NSObject


#pragma mark - Instance methods

#pragma mark - Metadata management method

/**
 Method allow to fetch all metadata which has been cached while \b PubNub client has been used. Metadata will be
 returned in \b NSDictionary and each key will be the name of \b PNChannel and value which has been set by user in
 subscribe or metadata set methods.

 @return NSDictionary instance or \c nil (if there is no metadata in cache) with cached metadata which is stored
 individually for each channel who's name used as key.
 */
- (NSDictionary *)metadata;

/**
 Method allow to update cached metadata for concrete channel.

 @param metadata
 \b NSDictionary instance with list of parameters which should be bound to the client. If \c nil provided,
 then metadata for specified channel will be removed from cache.

 @param channel
 \b PNChannel instance for which provided metadata should bound.

 @warning Client metadata shouldn't contain any nesting and values should be one of: int, float or string.

 @since 3.6.0
 */
- (void)storeMetadata:(NSDictionary *)metadata forChannel:(PNChannel *)channel;

/**
 Method allow to update cached metadata for set of channels.

 @param metadata
 \b NSDictionary instance with list of parameters which should be bound to the channels. Existing data for cached
 channels will be overridden (but not deleted).

 @param channels
 List of \b PNChannel instances for which provided metadata should bound.

 @since 3.6.0
 */
- (void)storeMetadata:(NSDictionary *)metadata forChannels:(NSArray *)channels;

/**
 Method allow to fetch metadata for concrete channel.

 @param channel
 \b PNChannel instance for which metadata should be retrieved from cache.

 @return \b NSDictionary instance with metadata for specified channel or \c nil of there is no metadata for specified
 channel.
 */
- (NSDictionary *)metadataForChannel:(PNChannel *)channel;

/**
 Method allow to fetch metadata for set of channels.

 @param channels
 List of \b PNChannel instances for which metadata should be retrieved from cache.

 @return \b NSDictionary with metadata for all requested channels (for those which doesn't have cached metadata
 there will be no values).
 */
- (NSDictionary *)metadataForChannels:(NSArray *)channels;

/**
 Method allow to remove metadata from cache for concrete channels.

 @param channel
 \b PNChannel for which metadata should be removed from cache.
 */
- (void)purgeMetadataForChannel:(PNChannel *)channel;

/**
 Method allow to remove metadata from cache for set of channel.

 @param channels
 List of \b PNChannel instances for which metadata should be removed from cache.
 */
- (void)purgeMetadataForChannels:(NSArray *)channels;

/**
 Method allow to purge all metadata which is stored in cache.
 */
- (void)purgeAllMetadata;

#pragma mark -


@end
