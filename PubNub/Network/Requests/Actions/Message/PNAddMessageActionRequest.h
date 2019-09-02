#import "PNBaseMessageActionRequest.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Add \c message \c action request.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNAddMessageActionRequest : PNBaseMessageActionRequest


#pragma mark - Information

/**
 * @brief What feature this \c message \c action represents.
 *
 * @note Maximum \b 15 characters.
 */
@property (nonatomic, copy) NSString *type;

/**
 * @brief Value which should be added with \c message \c action \b type.
 */
@property (nonatomic, copy) NSString *value;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c add \c message \c action request.
 *
 * @param channel Name of channel which store \c message for which \c action should be added.
 * @param messageTimetoken Timetoken (\b PubNub's high precision timestamp) of \c message to which
 * \c action should be added.
 *
 * @return Configured and ready to use \c add \c message \c action request.
 */
+ (instancetype)requestWithChannel:(NSString *)channel messageTimetoken:(NSNumber *)messageTimetoken
    NS_SWIFT_NAME(init(channel:messageTimetoken:));

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
