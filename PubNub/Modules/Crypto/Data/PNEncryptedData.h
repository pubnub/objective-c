#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// The cryptor's result representation for data.
///
/// An object used to pass cryptor outcomes (encrypted data and cryptor-defined metadata) between crypto module
/// components.
///
/// - Since: 5.1.4
/// - Copyright: 2010-2023 PubNub, Inc.
@interface PNEncryptedData : NSObject


#pragma mark - Information

/// Cryptor-defined metadata.
///
/// Cryptor may provide here any information which will be useful when data should be decrypted.
///
/// For example `metadata` may contain:
/// * initialization vector
/// * cipher key identifier
/// * encrypted `data` length.
@property(nonatomic, readonly, nullable, strong) NSData *metadata;

/// Encrypted data.
@property(nonatomic, readonly, strong) NSData *data;


#pragma mark - Initialization and configuration

/// Create encrypted data object.
///
/// An object used to keep track of the results of data encryption and the additional data the `cryptor` needs to handle
/// it later.
///
/// - Parameters:
///   - data: Outcome of successful cryptor encrypt method call.
///   - metadata: Additional information is provided by `cryptor` so that encrypted data can be handled later.
/// - Returns: A data object with encrypted data and metadata.
+ (instancetype)encryptedDataWithData:(NSData *)data metadata:(nullable NSData *)metadata;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
