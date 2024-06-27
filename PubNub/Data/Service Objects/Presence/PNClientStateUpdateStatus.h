#import <PubNub/PNErrorStatus.h>
#import <PubNub/PNPresenceUserStateSetData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `User presence state update` request processing status.
@interface PNClientStateUpdateStatus : PNErrorStatus


#pragma mark - Properties

/// `User presence state update` processed information.
@property(strong, nonatomic, readonly, strong) PNPresenceUserStateSetData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
