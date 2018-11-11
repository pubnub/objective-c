#import "PNAPICallBuilder.h"
#import "PNStructures.h"


#pragma mark Class forward

@class PNAPNSModificationAPICallBuilder, PNAPNSAuditAPICallBuilder;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief APNS API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNAPNSAPICallBuilder : PNAPICallBuilder


#pragma mark - APNS state manipulation

/**
 * @brief Push notifications state manipulation API access builder block.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder * (^enable)(void);

/**
 * @brief Push notifications state manipulation API access builder block.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder * (^disable)(void);


#pragma mark - APNS state audition

/**
 * @brief  Push notifications state audition API access builder block.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNAPNSAuditAPICallBuilder * (^audit)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
