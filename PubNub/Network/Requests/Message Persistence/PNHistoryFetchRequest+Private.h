#import "PNHistoryFetchRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Fetch history` request private extension.
@interface PNHistoryFetchRequest (Private)


#pragma mark - Properties

/// Whether request has been created to fetch history for multiple channels or not.
///
/// > Important: If set to `YES` requst will use `v3` `Message Persistence` REST API.
@property(assign, nonatomic, readonly) BOOL multipleChannels;

#pragma mark -

@end

NS_ASSUME_NONNULL_END
