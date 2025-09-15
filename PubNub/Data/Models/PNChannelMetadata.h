#import <PubNub/PNBaseAppContextObject.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Channel Metadata` object.
@interface PNChannelMetadata : PNBaseAppContextObject


#pragma mark - Properties

/// Channel Description which should be stored in `metadata` associated with specified `channel`.
@property(copy, nullable, nonatomic, readonly) NSString *information;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-property-synthesis"
/// `Channel`'s object status.
@property(copy, nullable, nonatomic, readonly) NSString *status;
#pragma clang diagnostic pop

/// Name which should be stored in `metadata` associated with specified `channel`.
@property(copy, nullable, nonatomic, readonly) NSString *name;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-property-synthesis"
/// `Channel`'s object type information.
@property(copy, nullable, nonatomic, readonly) NSString *type;
#pragma clang diagnostic pop

/// `Channel` name with which `metadata` has been associated.
@property(copy, nonatomic, readonly) NSString *channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
