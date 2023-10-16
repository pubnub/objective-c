#import "PNDownloadFileRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Download file` request private extension.
@interface PNDownloadFileRequest (Private)


#pragma mark - Information

/// Crypto module which should be used for uploaded data _encryption_.
///
/// This property allows setting up data _encryption_ using a different crypto module than the one set during **PubNub**
/// client instance configuration.
@property(nonatomic, nullable, strong) id<PNCryptoProvider> cryptoModule;

/// Unique `file` identifier which has been assigned during `file` upload.
@property (nonatomic, readonly, copy) NSString *identifier;

/// Name of channel from which `file` with `name` should be downloaded.
@property (nonatomic, readonly, copy) NSString *channel;

/// Name under which uploaded `file` is stored for `channel`.
@property (nonatomic, readonly, copy) NSString *name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
