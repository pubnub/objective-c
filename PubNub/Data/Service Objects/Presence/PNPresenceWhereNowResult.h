#import <PubNub/PNOperationResult.h>
#import <PubNub/PNPresenceWhereNowFetchData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `User presence` request result.
@interface PNPresenceWhereNowResult : PNOperationResult


#pragma mark - Properties

/// User presence request processing information.
@property (nonatomic, readonly, strong) PNPresenceWhereNowFetchData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
