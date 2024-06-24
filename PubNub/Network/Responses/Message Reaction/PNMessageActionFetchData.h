#import <PubNub/PNBaseOperationData.h>
#import <PubNub/PNMessageAction.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Add message action request response data.
@interface PNMessageActionFetchData : PNBaseOperationData


#pragma mark - Properties

/// Added `messages action`.
@property(strong, nonatomic, readonly) PNMessageAction *action;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
