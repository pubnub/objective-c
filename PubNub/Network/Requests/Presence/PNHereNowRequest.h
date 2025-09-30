#import <PubNub/PNBaseRequest.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Presence` request.
@interface PNHereNowRequest : PNBaseRequest


#pragma mark - Properties

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

/// List of channel groups for which here now information should be received.
@property(copy, nonatomic, readonly) NSArray<NSString *> *channelGroups;

/// One of **PNHereNowVerbosityLevel** fields to instruct what exactly data it expected in response.
@property(assign, nonatomic) PNHereNowVerbosityLevel verbosityLevel;

/// List of channels for which here now information should be received.
@property(copy, nonatomic, readonly) NSArray<NSString *> *channels;

/// Maximum number of users that can be returned with a single response.
///
/// **Default:** `1000`
///
/// > Important: 1000 is the maximum number of users that can be returned with a single response. Use ``offset`` for
/// pagination.
@property(assign, nonatomic) NSUInteger limit;


#pragma mark - Initialization and Configuration

/// Create `Channel presence` request.
///
/// - Parameter channelGroups: List of channel group for which here now information should be received.
/// - Returns: Ready to use `Channel group presence` request.
+ (instancetype)requestForChannelGroups:(NSArray<NSString *> *)channelGroups;

/// Create `Channel presence` request.
///
/// - Parameter channels: List of channel for which presence information should be received.
/// - Returns: Ready to use `Channel presence` request.
+ (instancetype)requestForChannels:(NSArray<NSString *> *)channels;

/// Create `Global presence` request.
///
/// Global presence checks presence on subscription key level.
///
/// - Returns: Ready to use `Global presence` request.
+ (instancetype)requestGlobal;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
