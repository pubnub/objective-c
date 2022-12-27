#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Published message representation model.
 *
 * @discussion This type let identify message received from subscriber later.
 * There is five types which is set by \b PubNub service depending from used API endpoint:
 * - \c message
 * - \c signal
 * - \c object
 * - \c messageAction
 * - \c file
 *
 * Additionally it is possible to specify custom type for published message using \b PNMessageType method
 *
 * @author Serhii Mamontov
 * @version 5.2.0
 * @since 5.2.0
 * @copyright © 2010-2022 PubNub Inc. All Rights Reserved.
 */
@interface PNMessageType : NSObject


#pragma mark - Information

/**
 * @brief One of types associated with message when it has been published.
 *
 * @discussion This property may store \b PubNub defined types (like: message, signal, file, object, messageAction
 */
@property(nonatomic, readonly, copy) NSString *value;


#pragma mark - Initialization and configuration

/**
 * @brief Create and configure message type instance.
 *
 * @param type Custom message type which should be used when publish message.
 *
 * @return Configured and ready to use message type instance.
 */
+ (instancetype)messageTypeFromString:(NSString *)type;

/**
 * @brief Initialize message type instance.
 *
 * @note This method can't be used directly and will throw an exception.
 *
 * @return Message type instance.
 */
- (nullable instancetype)init NS_UNAVAILABLE;


#pragma mark - Helper

/**
 * @brief Check whether receiving message type is equal to another instance.
 *
 * @param otherMessageType Second instance against which check should be done.
 *
 * @return \c YES if \c otherMessageType is equal to receiver.
 */
- (BOOL)isEqualToMessageType:(PNMessageType *)otherMessageType;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
