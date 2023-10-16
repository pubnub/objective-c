#import <PubNub/PNStructures.h>
#import <PubNub/PNRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Base class for `publish`-based API endpoints.
///
/// - Since: 4.15.0
/// - Copyright: 2010-2023 PubNub, Inc.
@interface PNBasePublishRequest : PNRequest


#pragma mark - Information

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property (nonatomic, nullable, strong) NSDictionary *arbitraryQueryParameters;

/// Whether `published` data should be stored and available with history API or not.
@property (nonatomic, assign, getter = shouldStore) BOOL store;

/// `NSDictionary` with values which should be used by **PubNub** service to filter messages.
@property (nonatomic, nullable, strong) NSDictionary *metadata;

/// Name of channel to which message should be published.
@property (nonatomic, readonly, copy) NSString *channel;

/// Message which will be published.
///
/// Provided object will be serialized into JSON (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) string before
/// pushing to the **PubNub** network. If client has been configured with cipher key message will be encrypted as well.
@property (nonatomic, nullable, strong) id message;

/// How long message should be stored in channel's storage. Pass \b 0 store message according to retention.
@property (nonatomic, assign) NSUInteger ttl;

/// Whether request is repeatedly sent to retry after recent failure.
@property (nonatomic, assign) BOOL retried;


#pragma mark - Initialization & Configuration

/// Forbids request initialization.
///
/// - Throws: Interface not available exception and requirement to use provided constructor method.
/// - Returns: Initialized request.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
