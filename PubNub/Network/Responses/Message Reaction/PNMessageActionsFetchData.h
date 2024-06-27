#import <PubNub/PNBaseOperationData.h>
#import <PubNub/PNMessageAction.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Fetch message actions request response data.
@interface PNMessageActionsFetchData : PNBaseOperationData


#pragma mark - Properties

/// List of fetched `messages actions`.
@property(strong, nonatomic, readonly) NSArray<PNMessageAction *> *actions;

/// Fetched `message actions` time range start (oldest `message action` timetoken).
///
/// > Note: This timetoken can be used as `start` value to fetch older `message actions`.
@property (strong, nonatomic, readonly) NSNumber *start;

/// Fetched `message actions` time range end (newest `action` timetoken).
@property (strong, nonatomic, readonly) NSNumber *end;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
