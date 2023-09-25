#import "PNSendFileRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Upload file` request private extension.
@interface PNSendFileRequest (Private)


#pragma mark - Information

/// Crypto module which should be used for uploaded data _encryption_.
///
/// This property allows setting up data _encryption_ using a different crypto module than the one set during **PubNub**
/// client instance configuration.
@property(nonatomic, nullable, strong) id<PNCryptoProvider> cryptoModule;

/// Input stream with data which should be uploaded to remote storage server / service.
@property (nonatomic, readonly, strong) NSInputStream *stream;

/// Size of data which can be read from `stream`.
@property (nonatomic, readonly, assign) NSUInteger size;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
