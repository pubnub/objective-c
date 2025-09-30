#import "PNRemoveMessageActionRequest.h"


NS_ASSUME_NONNULL_BEGIN

/// `Remove message action` request private extension.
@interface PNRemoveMessageActionRequest (Private)


#pragma mark - Properties

/// `Message action` addition timetoken (**PubNub**'s high precision timestamp).
@property(strong, nonatomic, readonly) NSNumber *messageActionTimetoken;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
