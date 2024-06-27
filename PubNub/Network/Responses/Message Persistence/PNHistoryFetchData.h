#import <PubNub/PNBaseOperationData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Fetch history request response data.
@interface PNHistoryFetchData : PNBaseOperationData


#pragma mark - Properties

/// List of messages received for single channel.
///
/// > Note: Property will be set if history has been requested for single channel.
@property(strong, nonatomic, readonly) NSArray<NSDictionary *> *messages;

/// Batch messages fetch.
///
/// Each key represent name of the channel and value is list of messages for that channel.
///
/// > Note: Property will be set if history has been requested for multiple single channel.
@property (nonatomic, readonly, strong) NSDictionary<NSString *, NSArray<NSDictionary *> *> *channels;

/// Fetched messages timeframe start.
///
/// > Note: Property will be set if history has been requested for single channel.
@property(strong, nullable, nonatomic, readonly) NSNumber *start;

/// Fetched messages timeframe emd.
///
/// > Note: Property will be set if history has been requested for single channel.
@property(strong, nullable, nonatomic, readonly) NSNumber *end;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
