#import "PNAcknowledgmentStatus.h"
#import "PNUUIDMetadata.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Objects API response for \c set \c UUID \c metadata
 * request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNSetUUIDMetadataData : PNServiceData


#pragma mark - Information

/**
 * @brief Updated \c UUID \c metadata object.
 */
@property (nonatomic, nullable, readonly, strong) PNUUIDMetadata *metadata;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to processed \c set \c UUID \c metadata request
 * results.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNSetUUIDMetadataStatus : PNAcknowledgmentStatus


#pragma mark - Information

/**
 * @brief \c Set \c UUID \c metadata request processed information.
 */
@property (nonatomic, readonly, strong) PNSetUUIDMetadataData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
