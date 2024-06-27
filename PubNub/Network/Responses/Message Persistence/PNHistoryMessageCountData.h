#import <PubNub/PNBaseOperationData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Channels messages count` request response.
@interface PNHistoryMessageCountData : PNBaseOperationData


#pragma mark - Properties

/// Dictionary with channel as keys and number of messages as value.
@property(strong, nonatomic, readonly) NSDictionary<NSString *, NSNumber *> *channels;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
