#import <PubNub/PNBaseRequest.h>


#pragma mark Protocols forwarding

@protocol PNCryptoProvider;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface declaration

/// `Upload file` request.
@interface PNSendFileRequest : PNBaseRequest


#pragma mark - Properties

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

/// `NSDictionary` with values which should be used by **PubNub** service to filter `file messages`.
@property(strong, nullable, nonatomic) NSDictionary *fileMessageMetadata;

/// Crypto module which should be used for uploaded data _encryption_.
///
/// This property allows setting up data _encryption_ using a different crypto module than the one set during **PubNub**
/// client instance configuration.
@property(strong, nullable, nonatomic) id<PNCryptoProvider> cryptoModule;

/// User-specified message type.
///
/// > Important: string limited by **3**-**50** case-sensitive alphanumeric characters with only `-` and `_` special
/// characters allowed.
@property(copy, nullable, nonatomic) NSString *customMessageType;

/// Key which should be used for uploaded data `encryption`.
///
/// This property allows setting up data _encryption_ using a different cipher key than the one set during **PubNub**
/// client instance configuration.
@property(copy, nullable, nonatomic) NSString *cipherKey
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with next major update. Please use "
                             "`cryptoModule` instead.");

/// How long message should be stored in channel's storage.
///
/// > Note: Pass `0` store message according to retention.
@property(assign, nonatomic) NSUInteger fileMessageTTL;

/// Name of channel to which `data` should be uploaded.
@property(copy, readonly, nonatomic) NSString *channel;

/// Whether **PubNub** published `file message` should be stored in `channel` history.
@property(assign, nonatomic) BOOL fileMessageStore;

/// Message which should be sent along with file to specified `channel`.
///
/// Provided object will be serialized into JSON string before pushing to the **PubNub** network.
///
/// > Note: If client has been configured with cipher key message will be encrypted as well.
@property(strong, nullable, nonatomic) id message;

/// Name which should be used to store uploaded data.
@property(copy, nonatomic) NSString *filename;


#pragma mark - Initialization and configuration

/// Create `file upload` request instance.
///
/// Request can upload file from local storage by `URL`.
///
/// - Parameters:
///   - channel: Name of channel to which file at `url` should be uploaded.
///   - url: URL of file which should be uploaded (on the file system).
/// - Returns: Ready to use `file upload` request.
+ (instancetype)requestWithChannel:(NSString *)channel fileURL:(NSURL *)url;

/// Create `data upload` request instance.
///
/// Request can upload `binary` data.
///
/// - Parameters:
///   - channel: Name of channel to which `data` should be uploaded.
///   - name: File name which will be used to store uploaded `data`.
///   - data: Binary data which should be uploaded.
/// - Returns: Ready to use `data upload` request.
+ (instancetype)requestWithChannel:(NSString *)channel fileName:(NSString *)name data:(NSData *)data;

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
