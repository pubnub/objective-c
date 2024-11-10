#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface implementation

/// `Signal data` request.
///
/// `Signal` is small chunk of data which can be sent by sensors to update their status.
@interface PNSignalRequest : PNBaseRequest


#pragma mark - Properties

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

/// User-specified message type.
///
/// > Important: string limited by **3**-**50** case-sensitive alphanumeric characters with only `-` and `_` special
/// characters allowed.
@property(copy, nullable, nonatomic) NSString *customMessageType;

/// Name of channel to which signal should be send.
@property(copy, nonatomic, readonly) NSString *channel;


#pragma mark - Initialization and Configuration

/// Create `Signal data` request.
///
/// - Parameters:
///   - channel: Name of channel to which signal should be sent.
///   - signalData: Signal payload data.
/// - Returns: Ready to use `signal data` request.
+ (instancetype)requestWithChannel:(NSString *)channel signal:(id)signalData;

/// Forbids request initialization.
///
/// - Throws: Interface not available exception and requirement to use provided constructor method.
/// - Returns: Initialized request.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
