#import "PNSendFileRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Upload file` request private extension.
@interface PNSendFileRequest (Private)


#pragma mark - Properties

/// Input stream with data which should be uploaded to remote storage server / service.
@property(strong, nonatomic, readonly) NSInputStream *stream;

/// Size of data which can be read from `stream`.
@property(assign, nonatomic, readonly) NSUInteger size;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
