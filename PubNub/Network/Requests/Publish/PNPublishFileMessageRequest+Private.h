#import "PNPublishFileMessageRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Publish file message` request private.
@interface PNPublishFileMessageRequest (Private)


#pragma mark - Properties

/// Whether the file message was published as part of a file-sharing API call or not.
@property(assign, nonatomic) BOOL publishOnFileSharing;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
