#import <PubNub/PubNub.h>
#import <PubNub/PNPresenceHereNowFetchData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Channels presence` request result.
@interface PNPresenceHereNowResult : PNOperationResult


#pragma mark - Properties

/// Processed channel presence information.
@property(strong, nonatomic, readonly) PNPresenceHereNowFetchData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
