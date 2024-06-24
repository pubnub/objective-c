#import <PubNub/PNOperationResult.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `User presence state for channel group` response.
@interface PNChannelGroupClientStateData : NSObject


#pragma mark - Properties

/// Multi channel client state information.
@property (nonatomic, readonly, strong) NSDictionary<NSString *, NSDictionary *> *channels;

#pragma mark -


@end


#pragma mark - Interface implementation

/// `Fetch user presence state for channel group` request processing result.
@interface PNChannelGroupClientStateResult : PNOperationResult


#pragma mark - Properties

/// `User presence state for channel group` request processing information.
@property (nonatomic, readonly, strong) PNChannelGroupClientStateData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
