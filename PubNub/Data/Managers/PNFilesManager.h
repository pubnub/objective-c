#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNAcknowledgmentStatus, PubNub;
@protocol PNCryptoProvider;


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Files / data upload / download manager.
///
/// Manager able to upload / download regular data or make encryption / decryption if required.
/// - Since: 4.15.0
/// - Copyright: 2010-2023 PubNub, Inc.
@interface PNFilesManager : NSObject


#pragma mark - Initialization and configuration

/// Create file manager instance.
///
/// - Parameter client: **PubNub** client for which files manager should be created.
/// - Returns: Initialized file manager instance.
+ (instancetype)filesManagerForClient:(PubNub *)client;


#pragma mark - Upload data

/// Upload user-provided data.
///
/// - Parameters:
///   - request: Request instance with configured URL and user-provided HTTP body stream.
///   - formData: List of fields which should be sent as `multipart/form-data` fields.
///   - filename: Name with which uploaded file should be stored.
///   - dataSize: Actual size of uploaded data (passes by user only for stream-based uploads).
///   - cryptoModule: Crypto module which should be used to _encrypt_ data before upload.
///   - block: Data upload completion block.
- (void)uploadWithRequest:(NSURLRequest *)request
                 formData:(nullable NSArray<NSDictionary *> *)formData
                 filename:(NSString *)filename
                 dataSize:(NSUInteger)dataSize
         withCryptoModule:(nullable id<PNCryptoProvider>)cryptoModule
               completion:(void(^)(NSError * _Nullable error))block;


#pragma mark - Download data

/// Download file from specified URL.
///
/// - Parameters:
///   - remoteURL: Remote file URL which should be used during download.
///   - localURL: Location on local file system where file should be stored.
///   - cryptoModule: Crypto module which should be used to _decrypt_ downloaded file.
///   - block Data download completion block.
- (void)downloadFileAtURL:(NSURL *)remoteURL
                    toURL:(NSURL *)localURL
         withCryptoModule:(nullable id<PNCryptoProvider>)cryptoModule
               completion:(void(^)(NSURLRequest *request, NSURL * _Nullable location, NSError * _Nullable error))block;

- (void)handleDownloadedFileAtURL:(nullable NSURL *)url withStoreURL:(nullable NSURL *)localURL cryptoModule:(nullable id<PNCryptoProvider>)cryptoModule completion:(void(^)( NSURL * _Nullable location, NSError * _Nullable error))block;


#pragma mark - Helpers

/// Invalidate and reclaim all resources allocated by files manager.
- (void)invalidate;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
