#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN

/// `Fetch messages count` request.
@interface PNHistoryMessagesCountRequest : PNBaseRequest


#pragma mark - Properties

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

/// List of channel names for which persist messages count should be fetched.
@property(copy, nonatomic, readonly) NSArray<NSString *> *channels;

///  List with single or multiple timetokens, where each timetoken position in correspond to target `channel` location
///  in channel names list.
///
///  > Importnat: Count of `timetokens` should match number of `channels`.
@property(copy, nonatomic, readonly) NSArray<NSNumber *> *timetokens;


#pragma mark - Initialization and Configuration

/// Create `Fetch messages count` request.
///
/// - Parameters:
///   - channels: List of channel names for which persist messages count should be fetched.
///   - timetokens: List with single or multiple timetokens, where each timetoken position in correspond to target 
///   `channel` location in channel names list.
/// - Returns: Ready to use `Fetch messages count` request.
+ (instancetype)requestWithChannels:(NSArray<NSString *> *)channels timetokens:(NSArray<NSNumber *> *)timetokens;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
