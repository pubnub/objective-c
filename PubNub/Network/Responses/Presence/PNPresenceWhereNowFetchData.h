#import <PubNub/PNBaseOperationData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Here now presence request response.
@interface PNPresenceWhereNowFetchData : PNBaseOperationData


#pragma mark - Properties

/// List of channels where requested user is present.
@property(strong, nonatomic, readonly) NSArray<NSString *> *channels;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
