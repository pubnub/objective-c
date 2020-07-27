#import "PNBasePublishRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Private \c base request extension to provide access to initializers and helper methods.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNBasePublishRequest (Private)


#pragma mark - Information

/**
 * @brief Pre-process message content basing on request's requirements.
 */
@property (nonatomic, nullable, readonly, strong) id preFormattedMessage;

/**
 * @brief Whether message should be compressed before sending or not.
 */
@property (nonatomic, assign, getter = shouldCompress) BOOL compress;

/**
 * @brief Dictionary with payloads for different vendors (Apple with "apns" key and Google with "gcm").
 */
@property (nonatomic, nullable, strong) NSDictionary *payloads;

/**
 * @brief Key which should be used to encrypt message.
 */
@property (nonatomic, nullable, copy) NSString *cipherKey;

/**
 * @brief Publish request sequence number.
 */
@property (nonatomic, assign) NSUInteger sequenceNumber;

/**
 * @brief Whether request is repeatedly sent to retry after recent failure.
 */
@property (nonatomic, assign) BOOL retried;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c publish   request.
 *
 * @param channel Name of channel to which message should be published.
 *
 * @return Initialized and ready to use \c publish  request.
 */
- (instancetype)initWithChannel:(NSString *)channel;


#pragma mark - Misc

/**
 * @brief Create JSON objects which should be published to specified \c channel.
 *
 * @param message User-provided message which should be sent to channel and available for rest subscribers.
 * @param payloads Mobile notification payloads which should be merged with original \c message.
 *
 * @return JSON string (encrypted if required) which will be published to specified \c channel.
 */
- (NSString *)JSONFromMessage:(id)message withPushNotificationsPayload:(NSDictionary *)payloads;

/**
 * @brief Merge user-specified message with push payloads into single message which will be processed on \b PubNub service.
 *
 * @discussion In case if aside from \c message has been passed \c payloads this method will merge them into format known
 * by \b PubNub service and will cause further push distribution to specified vendors.
 *
 * @param message Message which should be merged with \c payloads.
 * @param payloads \a NSDictionary with payloads for different push notification services (Apple with "apns" key and Google
 * with "gcm").
 *
 * @return Merged message or original message if there is no data in \c payloads.
 */
- (NSDictionary<NSString *, id> *)mergedMessage:(nullable id)message
                          withMobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads;

/**
 * @brief Try perform encryption of data which should be pushed to \b PubNub services.
 *
 * @param message Data which \b PNAES should try to encrypt.
 * @param key Cipher key which should be used during encryption.
 * @param error Pointer into which data encryption error will be passed.
 *
 * @return Encrypted Base64-encoded string or original message, if there is no \c key has been passed.
 */
- (nullable NSString *)encryptedMessage:(NSString *)message
                          withCipherKey:(NSString *)key
                                  error:(NSError **)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
