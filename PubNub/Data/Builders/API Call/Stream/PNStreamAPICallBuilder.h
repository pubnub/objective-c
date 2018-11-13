#import "PNAPICallBuilder.h"
#import "PNStructures.h"


#pragma mark Class forward

@class PNStreamModificationAPICallBuilder, PNStreamAuditAPICallBuilder;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Stream API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNStreamAPICallBuilder : PNAPICallBuilder


#pragma mark - Stream state manipulation

/**
 * @brief Stream state modification API access builder block.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStreamModificationAPICallBuilder * (^add)(void);

/**
 * @brief Stream state modification API access builder block.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStreamModificationAPICallBuilder * (^remove)(void);


#pragma mark - Stream state audit

/**
 * @brief Stream state audit API access builder block.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStreamAuditAPICallBuilder * (^audit)(void);

#pragma mark - 


@end

NS_ASSUME_NONNULL_END
