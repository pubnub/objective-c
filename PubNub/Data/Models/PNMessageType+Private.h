#import "PNMessageType.h"
#import "PNPrivateStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface extension declaration

/**
 * @brief Extension for public interface for parsers support.
 *
 * @author Serhii Mamontov
 * @version 5.2.0
 * @since 5.2.0
 * @copyright © 2010-2022 PubNub Inc. All Rights Reserved.
 */
@interface PNMessageType (Private)


#pragma mark - Initialization and configuration

/**
 * @brief Create and configure message type based on type provided by \b PubNub and user.
 *
 * @param userMessageType Custom message type which should be used when publish message.
 * @param pubNubMessageType One of pre-defined message / event types.
 *
 * @return Configured and ready to use message type instance.
 */
+ (instancetype)messageTypeFromString:(NSString *)userMessageType
                    pubNubMessageType:(PNServiceMessageType)pubNubMessageType;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
