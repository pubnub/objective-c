#import <PubNub/PNOperationResult.h>
#import <PubNub/PNPresenceUserStateFetchData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Fetch associated presence state request processing result.
@interface PNPresenceStateFetchResult : PNOperationResult


#pragma mark - Properties

/// `Fetch user presence state` processed information.
@property(strong, nonatomic, readonly) PNPresenceUserStateFetchData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
