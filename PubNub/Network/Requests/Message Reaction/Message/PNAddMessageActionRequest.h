#import <PubNub/PNBaseMessageActionRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Add message action` request.
///
/// Attach message reaction to the target message identified by its timetoken.
@interface PNAddMessageActionRequest : PNBaseMessageActionRequest


#pragma mark - Properties

/// Value which should be added with `message action` ``type``.
@property(copy, nonatomic) NSString *value;

/// What feature this `message action` represents.
///
/// > Important: Maximum **15** characters.
@property(copy, nonatomic) NSString *type;


#pragma mark - Initialization and Configuration

/// Create `add message action` request.
///
/// - Parameters:
///   - channel: Name of channel which store `message` for which `action` should be added.
///   - messageTimetoken: Timetoken (**PubNub**'s high precision timestamp) of `message` to which `action` should be
///   added.
/// - Returns: Ready to use `add message action` request.
+ (instancetype)requestWithChannel:(NSString *)channel messageTimetoken:(NSNumber *)messageTimetoken
    NS_SWIFT_NAME(init(channel:messageTimetoken:));

#pragma mark -


@end

NS_ASSUME_NONNULL_END
