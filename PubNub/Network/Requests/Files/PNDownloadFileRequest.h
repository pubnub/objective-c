#import <PubNub/PNStructures.h>
#import <PubNub/PNRequest.h>


#pragma mark Protocols forwarding

@protocol PNCryptoProvider;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface declaration

/// `Download file` request.
///
/// The **PubNub** client will use information from the provided request object to _download_ files from the remote
/// storage.
///
/// - Since: 4.15.0
/// - Copyright: 2010-2023 PubNub, Inc.
@interface PNDownloadFileRequest : PNRequest


#pragma mark - Information

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property (nonatomic, nullable, strong) NSDictionary *arbitraryQueryParameters;

/// Key which should be used for downloaded data _decryption_.
///
/// This property allows setting up data _decryption_ using a different cipher key than the one set during **PubNub**
/// client instance configuration.
@property (nonatomic, nullable, copy) NSString *cipherKey;

/// File store url.
///
/// The URL where the downloaded file should be saved locally.
///
/// > Note: The file will be downloaded to a temporary location if the value is not set. The location will be passed
/// to the completion block, and the file will be removed on completion block exit.
@property (nonatomic, nullable, strong) NSURL *targetURL;


#pragma mark - Initialization and configuration

/// Create `file download` request instance.
///
/// - Parameters:
///   - channel: Name of channel from which `file` with `name` should be downloaded.
///   - identifier: Unique `file` identifier which has been assigned during `file` upload.
///   - name: Name under which uploaded `file` is stored for `channel`.
/// - Returns: Initialized `file download` request.
+ (instancetype)requestWithChannel:(NSString *)channel
                        identifier:(NSString *)identifier
                              name:(NSString *)name;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
