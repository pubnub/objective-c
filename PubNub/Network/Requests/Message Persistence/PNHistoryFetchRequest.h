#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface implementation

/// `Fetch history` request.
@interface PNHistoryFetchRequest : PNBaseRequest


#pragma mark - Properties

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

///  List of channel names for which events should be pulled out from storage.
///
///  > Notes: Maximum 500 channels.
@property(copy, nonatomic, readonly) NSArray<NSString *> *channels;

/// Include events' actions presence flag.
///
/// Each fetched entry will contain published data under `message` key and added `message actions` will be available
/// under `actions` key.
///
/// > Important: This option can't be used if `channels` contains multiple entries.
@property(assign, nonatomic) BOOL includeMessageActions;

/// Search interval start timetoken.
///
/// Timetoken for the oldest event starting from which next should be returned events.
///
/// > Note: Value will be converted to required precision internally.
@property(strong, nullable, nonatomic) NSNumber *start;

/// Search interval end timetoken.
///
/// Timetoken for latest event till which events should be pulled out.
///
/// > Note: Value will be converted to required precision internally.
@property(strong, nullable, nonatomic) NSNumber *end;

/// Include events' type presence flag.
///
/// Each fetched entry will contain published data under `message` key and published message `message type` will be
/// available under `messageType` key.
///
/// > Note: By default set to `YES`.
@property(assign, nonatomic) BOOL includeMessageType;

/// Include events' timetoken flag.
///
/// Each fetched entry will contain published data under `message` key and added `publish time` will be available
/// under `timetoken` key.
///
/// > Important: This option can't be used if `channels` contains multiple entries.
@property(assign, nonatomic) BOOL includeTimeToken;

/// Include events' metadata presence flag.
///
/// Each fetched entry will contain published data under `message` key and published message `meta` will be available
/// under `metadata` key.
@property(assign, nonatomic) BOOL includeMetadata;

/// Include events' publisher user ID presence flag.
///
/// Each fetched entry will contain published data under `message` key and published message `message publisher` will be
/// available under `uuid` key.
///
/// > Note: By default set to `YES`.
@property(assign, nonatomic) BOOL includeUUID;

/// Maximum number of events.
///
/// Maximum number of events which should be returned in response.
///
/// > Note: Maximum `100` if `channels` contains only one name or `25` if `channels` contains multiple names or
/// `includeMessageActions` is set to `YES`.
@property(assign, nonatomic) NSUInteger limit;

/// Whether events order in response should be reversed or not.
@property(assign, nonatomic) BOOL reverse;


#pragma mark - Initialization and Constructor

/// Create `Fetch history` request.
///
/// - Parameter channel: Channel for which events should be pulled out from storage.
/// - Returns: Ready to use `Fetch history` request.
+ (instancetype)requestWithChannel:(NSString *)channel;

/// Create `Fetch history` request.
///
/// - Parameter channels: List of channel names for which events should be pulled out from storage. Maximum 500 channels.
/// - Returns: Ready to use `Fetch history` request.
+ (instancetype)requestWithChannels:(NSArray<NSString *> *)channels;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
