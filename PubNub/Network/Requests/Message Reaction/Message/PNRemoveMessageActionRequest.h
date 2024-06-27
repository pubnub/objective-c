#import <PubNub/PNBaseMessageActionRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Remove message action` request.
///
/// Removes message reaction from the message identified by its and reaction timetokens.
@interface PNRemoveMessageActionRequest : PNBaseMessageActionRequest


#pragma mark - Properties

/// `Message action` addition timetoken (**PubNub**'s high precision timestamp).
@property(strong, nonatomic) NSNumber *actionTimetoken
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with next major update. Instead please use "
                             "PNRemoveMessageActionRequest constructor with 'actionTimetoken' argument.");


#pragma mark - Initialization and Configuration

/// Create `remove message action` request.
///
/// - Parameters:
///   - channel: Name of channel which store `message` for which `action` should be removed.
///   - messageTimetoken: Timetoken (**PubNub**'s high precision timestamp) of `message` from which `action` should be
///   removed.
/// - Returns: Ready to use `remove message action` request.
+ (instancetype)requestWithChannel:(NSString *)channel messageTimetoken:(NSNumber *)messageTimetoken
    NS_SWIFT_NAME(init(channel:messageTimetoken:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Instead please use "
                         "PNRemoveMessageActionRequest constructor with 'actionTimetoken' argument.");

/// Create `remove message action` request.
///
/// - Parameters:
///   - channel: Name of channel which store `message` for which `action` should be removed.
///   - messageTimetoken: Timetoken (**PubNub**'s high precision timestamp) of `message` from which `action` should be
///   removed.
///   - actionTimetoken: Message action addition timetoken (**PubNub**'s high precision timestamp).
/// - Returns: Ready to use `remove message action` request.
+ (instancetype)requestWithChannel:(NSString *)channel 
                  messageTimetoken:(NSNumber *)messageTimetoken
                   actionTimetoken:(NSNumber *)actionTimetoken
    NS_SWIFT_NAME(init(channel:messageTimetoken:actionTimetoken:));

#pragma mark -


@end

NS_ASSUME_NONNULL_END
