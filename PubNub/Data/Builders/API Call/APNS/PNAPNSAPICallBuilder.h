#import <PubNub/PNAPICallBuilder.h>
#import <PubNub/PNStructures.h>


#pragma mark Class forward

@class PNAPNSModificationAPICallBuilder, PNAPNSAuditAPICallBuilder;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief APNS API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.5.4
 * @copyright © 2010-2019 PubNub, Inc.
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

/**
 * @brief Push notifications state manipulation API access builder block.
 *
 * @return API call configuration builder.
 *
 * @since 4.12.0
 */
@property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder * (^disableAll)(void);


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
