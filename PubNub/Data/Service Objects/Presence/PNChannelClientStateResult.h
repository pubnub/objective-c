#import <PubNub/PNOperationResult.h>
#import <PubNub/PNServiceData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `User presence state for channel` response.
@interface PNChannelClientStateData :NSObject


#pragma mark - Properties

/// User presence state information for channel.
@property (nonatomic, readonly, strong) NSDictionary<NSString *, id> *state;

#pragma mark -


@end


#pragma mark - Interface declaration

/// `Fetch user presence state for channel` request processing result.
@interface PNChannelClientStateResult : PNOperationResult


#pragma mark - Properties

/// `User presence state for channel` request processing information.
@property (nonatomic, readonly, strong) PNChannelClientStateData *data;

#pragma mark - 


@end

NS_ASSUME_NONNULL_END
