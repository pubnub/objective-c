#import <PubNub/PNBaseAppContextObject.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Channel Metadata` object.
@interface PNChannelMetadata : PNBaseAppContextObject


#pragma mark - Properties

/// Channel Description which should be stored in `metadata` associated with specified `channel`.
@property(copy, nullable, nonatomic, readonly) NSString *information;

/// `Channel`'s object status.
@property(copy, nullable, nonatomic, readonly) NSString *status;

/// Name which should be stored in `metadata` associated with specified `channel`.
@property(copy, nullable, nonatomic, readonly) NSString *name;

/// `Channel`'s object type information.
@property(copy, nullable, nonatomic, readonly) NSString *type;

/// `Channel` name with which `metadata` has been associated.
@property(copy, nonatomic, readonly) NSString *channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
