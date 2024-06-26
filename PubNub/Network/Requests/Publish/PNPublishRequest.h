#import <PubNub/PNBasePublishRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Publish data` request.
@interface PNPublishRequest : PNBasePublishRequest


#pragma mark - Properties

/// Whether message should be compressed before sending or not.
@property(assign, nonatomic, getter = shouldCompress) BOOL compress;

/// Dictionary with payloads for different vendors (Apple with "apns" key and Google with "gcm").
@property(strong, nullable, nonatomic) NSDictionary *payloads;


#pragma mark - Initialization and Configuration

/// Create `Publish data` request.
///
/// - Parameter channel: Name of channel to which message should be published.
/// - Returns: Ready to use `publish message` request.
+ (instancetype)requestWithChannel:(NSString *)channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
