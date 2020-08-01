#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNAcknowledgmentStatus, PubNub;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface declaration

/**
 * @brief Files / data upload / download manager.
 *
 * @discussion Manager able to upload / download regular data or make encryption / decryption if
 * required.
 *
 * @author Sergey Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFilesManager : NSObject


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure files manager.
 *
 * @param client \b PubNub client for which files manager should be created.
 *
 * @return Configured and ready to use client files manager.
 */
+ (instancetype)filesManagerForClient:(PubNub *)client;


#pragma mark - Upload data

/**
 * @brief Upload user-provided data.
 *
 * @param request Request instance with configured URL and user-provided HTTP body stream.
 * @param formData List of fields which should be sent as \c multipart/form-data fields.
 * @param filename Name with which uploaded file should be stored.
 * @param dataSize Actual size of uploaded data (passes by user only for stream-based uploads).
 * @param cipherKey Key which should be used to encrypt data before upload.
 * @param block Data upload completion block.
 */
- (void)uploadWithRequest:(NSURLRequest *)request
                 formData:(nullable NSArray<NSDictionary *> *)formData
                 filename:(NSString *)filename
                 dataSize:(NSUInteger)dataSize
                cipherKey:(nullable NSString *)cipherKey
               completion:(void(^)(NSError * _Nullable error))block;


#pragma mark - Download data

/**
 * @brief Download file from specified URL.
 *
 * @param remoteURL Remote file URL which should be used during download.
 * @param localURL Location on local file system where file should be stored.
 * @param cipherKey Key which should be used to decrypt data after download.
 * @param block Data download completion block.
 */
- (void)downloadFileAtURL:(NSURL *)remoteURL
                    toURL:(NSURL *)localURL
            withCipherKey:(nullable NSString *)cipherKey
               completion:(void(^)(NSURLRequest *request, NSURL * _Nullable location,
                                   NSError * _Nullable error))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
