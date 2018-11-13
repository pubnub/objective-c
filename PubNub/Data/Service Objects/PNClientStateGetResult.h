#import "PNResult.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Class which allow to get access to client state for channel / groups processed result.
 *
 * @author Serhii Mamontov
 * @since 4.8.3
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNClientStateData : PNServiceData


#pragma mark Information

/**
 * @brief State information for each channel from requested channels / chanel groups channels.
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, NSDictionary *> *channels;

#pragma mark -


@end


/**
 * @brief Class which is used to provide access to request processing results.
 *
 * @author Serhii Mamontov
 * @since 4.8.3
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNClientStateGetResult : PNResult


#pragma mark - Information

/**
 * @brief Client state processing information for channels / chanel groups channels.
 */
@property (nonatomic, readonly, strong) PNClientStateData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
