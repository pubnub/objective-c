#import <PubNub/PNBaseMessageActionRequest.h>
#import <PubNub/PNRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General request for all `Message Action` API endpoints private extension.
@interface PNBaseMessageActionRequest (Private) <PNRequest>


#pragma mark - Properties

/// Timetoken (**PubNub**'s high precision timestamp) of `message` for which `action` should be managed.
@property(strong, nonatomic, readonly) NSNumber *messageTimetoken;

/// Name of channel in which target `message` is stored.
@property(copy, nonatomic, readonly) NSString *channel;


#pragma mark - Initialization & Configuration

/// Initialize general `Message Action` request.
///
/// - Parameters:
///   - channel: Name of channel in which target `message` is stored.
///   - messageTimetoken: Timetoken of `message` for which action should be managed.
/// - Returns: Initialized general `Message Action` request.
- (instancetype)initWithChannel:(NSString *)channel messageTimetoken:(NSNumber *)messageTimetoken;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
