#import "PNAPICallBuilder.h"
#import "PNStructures.h"


#pragma mark Class forward

@class PNStateModificationAPICallBuilder, PNStateAuditAPICallBuilder;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief State API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNStateAPICallBuilder : PNAPICallBuilder


#pragma mark - Presence state manipulation

/**
 * @brief Presence state modification API access builder block.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStateModificationAPICallBuilder * (^set)(void);


#pragma mark - Presence state audition

/**
 * @brief Presence state audition API access builder block.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStateAuditAPICallBuilder * (^audit)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
