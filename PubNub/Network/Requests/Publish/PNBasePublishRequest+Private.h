#import "PNBasePublishRequest.h"
#import "PNCryptoProvider.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General request for all `Publish` API endpoints private extension.
@interface PNBasePublishRequest (Private)


#pragma mark - Properties

/// Message which has been prepared for publish.
///
/// Depending from request configuration this object may store encrypted message with mobile push payloads.
@property(strong, nullable, nonatomic, readonly) NSString *preparedMessage;

/// Crypto module for data processing.
///
/// **PubNub** client uses this instance to _encrypt_ and _decrypt_ data that has been sent and received from the
/// **PubNub** network.
@property(strong, nullable, nonatomic) id<PNCryptoProvider> cryptoModule;

/// Pre-process message content basing on request's requirements.
@property(strong, nullable, nonatomic, readonly) id preFormattedMessage;

/// Whether message should be compressed before sending or not.
@property(assign, nonatomic, getter = shouldCompress) BOOL compress;

/// Dictionary with payloads for different vendors (Apple with `'apns'` key and Google with `'gcm'`).
@property(strong, nullable, nonatomic) NSDictionary *payloads;

/// Publish request sequence number.
@property(assign, nonatomic) NSUInteger sequenceNumber;

/// Whether request is repeatedly sent to retry after recent failure.
@property(assign, nonatomic) BOOL retried;


#pragma mark - Initialization and Configuration

/// Initialize `publish` request.
///
/// - Parameter channel: Name of channel to which message should be published.
/// - Returns: Initialized `publish` request instance.
- (instancetype)initWithChannel:(NSString *)channel;


#pragma mark - Helpers

/// Merge user-specified message with push payloads into single message which will be processed on the **PubNub**
/// service.
///
/// In case if aside from `message` has been passed `payloads` this method will merge them into format known by the
/// **PubNub** service and will cause further push distribution to specified vendors.
///
/// - Parameters:
///   - message: Message which should be merged with `payloads`.
///   - payloads: `NSDictionary` with payloads for different push notification services (Apple with `'apns'` key and
///   Google with `'gcm'`).
/// - Returns: Merged message or original message if there is no data in `payloads`.
- (NSDictionary<NSString *, id> *)mergedMessage:(nullable id)message
                          withMobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads;

/// Try perform encryption of data which should be pushed to **PubNub** services.
///
/// - Parameters:
///   - message: Data which crypto module should try to encrypt.
///   - error: Pointer into which data encryption error will be passed.
/// - Returns: Encrypted Base64-encoded string or original message.
- (nullable NSString *)encryptedMessage:(NSString *)message error:(NSError **)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
