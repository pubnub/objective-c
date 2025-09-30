#import "PNPresenceLeaveRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface implementation

/// `Leave` request private extension.
@interface PNPresenceLeaveRequest (Private)


#pragma mark - Properties

/// Whether presence change should be done only for presence channels or not.
///
/// > Note: Actual `leave` won't be triggered, and only the list of active channels will be modified if set to `NO`.
@property(assign, nonatomic, readonly) BOOL presenceOnly;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
