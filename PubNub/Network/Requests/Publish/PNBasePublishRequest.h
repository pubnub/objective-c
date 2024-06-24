#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// General request for all `Publish` API endpoints.
@interface PNBasePublishRequest : PNBaseRequest


#pragma mark - Properties

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

/// Serialized `NSDictionary` with values which should be used by **PubNub** service to filter messages.
@property(strong, nullable, nonatomic, readonly) NSString *preparedMetadata;

/// Whether `published` data should be stored and available with history API or not.
@property(assign, nonatomic, getter = shouldStore) BOOL store;

/// `NSDictionary` with values which should be used by **PubNub** service to filter messages.
@property(strong, nullable, nonatomic) NSDictionary *metadata;

/// Name of channel to which message should be published.
@property(copy, nonatomic, readonly) NSString *channel;

/// Message which will be published.
///
/// Provided object will be serialized into JSON (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) string before
/// pushing to the **PubNub** network. If client has been configured with cipher key message will be encrypted as well.
@property(strong, nullable, nonatomic) id message;

/// How long message should be stored in channel's storage. Pass \b 0 store message according to retention.
@property(assign, nonatomic) NSUInteger ttl;

/// Whether request is repeatedly sent to retry after recent failure.
@property(assign, nonatomic) BOOL retried;


#pragma mark - Initialization and Configuration

/// Forbids request initialization.
///
/// - Throws: Interface not available exception and requirement to use provided constructor method.
/// - Returns: Initialized request.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
