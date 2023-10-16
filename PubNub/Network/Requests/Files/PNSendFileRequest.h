#import <PubNub/PNStructures.h>
#import <PubNub/PNRequest.h>


#pragma mark Protocols forwarding

@protocol PNCryptoProvider;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface declaration

/// `Upload file` request.
///
/// The **PubNub** client will use information from the provided request object to _upload_ files or data to the remote
/// storage.
///
/// - Since: 4.15.0
/// - Copyright: 2010-2023 PubNub, Inc.
@interface PNSendFileRequest : PNRequest


#pragma mark - Information

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property (nonatomic, nullable, strong) NSDictionary *arbitraryQueryParameters;

/// `NSDictionary` with values which should be used by **PubNub** service to filter `file messages`.
@property (nonatomic, nullable, strong) NSDictionary *fileMessageMetadata;

/// Key which should be used for uploaded data _encryption_.
///
/// This property allows setting up data _encryption_ using a different cipher key than the one set during **PubNub**
/// client instance configuration.
@property (nonatomic, nullable, copy) NSString *cipherKey;

/// How long message should be stored in channel's storage.
///
/// > Note: Pass `0` store message according to retention.
@property (nonatomic, assign) NSUInteger fileMessageTTL;

/// Name of channel to which `data` should be uploaded.
@property (nonatomic, readonly, copy) NSString *channel;

/// Whether **PubNub** published `file message` should be stored in `channel` history.
@property (nonatomic, assign) BOOL fileMessageStore;

/// Message which should be sent along with file to specified `channel`.
///
/// Provided object will be serialized into JSON string before pushing to the **PubNub** network.
///
/// > Note: If client has been configured with cipher key message will be encrypted as well.
@property (nonatomic, nullable, strong) id message;

/// Name which should be used to store uploaded data.
@property (nonatomic, copy) NSString *filename;


#pragma mark - Initialization and configuration

/// Create `file upload` request instance.
///
/// Request can upload file from local storage by `URL`.
///
/// - Parameters:
///   - channel: Name of channel to which file at `url` should be uploaded.
///   - url: URL of file which should be uploaded (on the file system).
/// - Returns: Initialized `file upload` request.
+ (instancetype)requestWithChannel:(NSString *)channel fileURL:(NSURL *)url;

/// Create `data upload` request instance.
///
/// Request can upload `binary` data.
///
/// - Parameters:
///   - channel: Name of channel to which `data` should be uploaded.
///   - name: File name which will be used to store uploaded `data`.
///   - data: Binary data which should be uploaded.
/// - Returns: Initialized `data upload` request.
+ (instancetype)requestWithChannel:(NSString *)channel
                          fileName:(NSString *)name
                              data:(NSData *)data;

/// Create `stream data upload` request instance.
///
/// Request can upload `stream` data.
///
/// - Parameters:
///   - channel: Name of channel to which `stream data` should be uploaded.
///   - name: File name which will be used to store uploaded `stream data`.
///   - stream: Stream to file on local file system or memory which should be uploaded.
///   - size: Size of data which can be read from `stream`.
/// - Returns: Initialized `stream data upload` request.
+ (instancetype)requestWithChannel:(NSString *)channel
                          fileName:(NSString *)name
                            stream:(NSInputStream *)stream
                              size:(NSUInteger)size;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
