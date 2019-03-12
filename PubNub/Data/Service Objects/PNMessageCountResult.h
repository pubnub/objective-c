#import "PNResult.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  Class which allow to get access to channel history processed result.
 *
 * @since 4.8.4
 *
 * @author Sergey Mamontov
 * @version 4.8.3
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNMessageCountData : PNServiceData


#pragma mark Information

/**
 * @brief Dictionary where each key is name of channel and value is number of messages in it.
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, NSNumber *> *channels;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Get number of messages passed-in channels.
 *
 * @since 4.8.4
 *
 * @author Sergey Mamontov
 * @version 4.8.3
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNMessageCountResult : PNResult


#pragma mark - Information

/**
 * @brief Message count request processing information.
 */
@property (nonatomic, readonly, strong) PNMessageCountData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
