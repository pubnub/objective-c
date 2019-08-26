#import "PNAcknowledgmentStatus.h"
#import "PNServiceData.h"
#import "PNSpace.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Objects API response for \c update \c space request.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNUpdateSpaceData : PNServiceData


#pragma mark - Information

/**
 * @brief Updated space object.
 */
@property (nonatomic, nullable, readonly, strong) PNSpace *space;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to processed \c update \c space request results.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNUpdateSpaceStatus : PNAcknowledgmentStatus


#pragma mark - Information

/**
 * @brief \c Update \c space request processed information.
 */
@property (nonatomic, readonly, strong) PNUpdateSpaceData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
