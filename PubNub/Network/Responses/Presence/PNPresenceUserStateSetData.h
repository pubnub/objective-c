#import <PubNub/PNBaseOperationData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `User presence state update` request response.
@interface PNPresenceUserStateSetData : PNBaseOperationData


#pragma mark - Properties

/// Presence state which has been associated with user.
@property(strong, nullable, nonatomic, readonly) NSDictionary<NSString *, id> *state;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
