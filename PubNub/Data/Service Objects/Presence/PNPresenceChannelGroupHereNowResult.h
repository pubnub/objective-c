#import <PubNub/PNPresenceGlobalHereNowResult.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Channel group presence response.
@interface PNPresenceChannelGroupHereNowData : PNPresenceGlobalHereNowData


#pragma mark -


@end


#pragma mark - Interface declaration

/// Channel group presence request result.
@interface PNPresenceChannelGroupHereNowResult : PNOperationResult


#pragma mark - Information

/// Channel group presence request processing information.
@property (nonatomic, nonnull, readonly, strong) PNPresenceChannelGroupHereNowData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
