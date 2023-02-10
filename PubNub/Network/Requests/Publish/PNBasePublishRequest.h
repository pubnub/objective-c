#import "PNStructures.h"
#import "PNRequest.h"


#pragma mark Class forward

@class PNMessageType, PNSpaceId;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface declaration

/**
 * @brief Base class for all 'Publish' API endpoints which has shared query options.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNBasePublishRequest : PNRequest


#pragma mark - Information

/**
 * @brief Arbitrary percent encoded query parameters which should be sent along with original API call.
 */
@property (nonatomic, nullable, strong) NSDictionary *arbitraryQueryParameters;

/**
 * @brief Whether \c published data should be stored and available with history API or not.
 */
@property (nonatomic, assign, getter = shouldStore) BOOL store;

/**
 * @brief \a NSDictionary with values which should be used by \b PubNub service to filter messages.
 */
@property (nonatomic, nullable, strong) NSDictionary *metadata;

/**
 * @brief Name of channel to which message should be published.
 */
@property (nonatomic, readonly, copy) NSString *channel;

/**
 * @brief Identifier of the space to which message should be published.
 *
 * @since 5.2.0
 */
@property (nonatomic, nullable, strong) PNSpaceId *spaceId;

/**
 * @brief Message which will be published.
 *
 * @discussion Provided object will be serialized into JSON (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) string
 * before pushing to \b PubNub service. If client has been configured with cipher key message will be encrypted as well.
 */
@property (nonatomic, nullable, strong) id message;

/**
 * @brief Custom type with which message should be published.
 *
 * @since 5.2.0
 */
@property (nonatomic, nullable, strong) PNMessageType *messageType;

/**
 * @brief How long message should be stored in channel's storage. Pass \b 0 store message according to retention.
 */
@property (nonatomic, assign) NSUInteger ttl;

/**
 * @brief Whether request is repeatedly sent to retry after recent failure.
 */
@property (nonatomic, assign) BOOL retried;


#pragma mark - Initialization & Configuration

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
