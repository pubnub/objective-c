#import "PNBaseMessageActionRequest.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Remove \c message \c action request.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNRemoveMessageActionRequest : PNBaseMessageActionRequest


#pragma mark - Information

/**
 * @brief \c Message \c action addition timetoken (\b PubNub's high precision timestamp).
 */
@property (nonatomic, strong) NSNumber *actionTimetoken;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c remove \c message \c action request.
 *
 * @param channel Name of channel which store \c message for which \c action should be removed.
 * @param messageTimetoken Timetoken (\b PubNub's high precision timestamp) of \c message from which
 * \c action should be removed.
 *
 * @return Configured and ready to use \c remove \c message \c action request.
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
