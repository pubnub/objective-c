#import "PNAESGCMCryptor.h"
#import <CommonCrypto/CommonHMAC.h>
#import "PNCryptorInputStream+Private.h"
#import "PNCryptoKitWrapper.h"
#import "PNEncryptedStream.h"
#import "PNError.h"


#pragma mark Contants

/// C identifier for AES-GCM cryptors.
static NSData *kPNAESGCMCryptorIdentifier;

/// Expected AES-GCM nonce length in cryptor header.
static const NSUInteger kPNAESGCMNonceLength = 12;

/// Expected AES-GCM auth tag length in cryptor header.
static const NSUInteger kPNAESGCMTagLength = 16;


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// AES-256-GCM cryptor private extension.
@interface PNAESGCMCryptor ()


#pragma mark - Information

/// Prepared key for data _decryption_.
@property(nonatomic, strong) NSData *cipherKey;


#pragma mark - Initialization and configuration

/// Initialize cryptor instance.
///
/// - Parameter cipherKey: Key for data _decryption_.
/// - Returns: Initialized AES-256-GCM cryptor instance.
- (instancetype)initWithCipherKey:(NSString *)cipherKey;

#pragma mark -

@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNAESGCMCryptor


#pragma mark - Information

- (NSData *)identifier {
    return kPNAESGCMCryptorIdentifier;
}


#pragma mark - Initialization and configuration

+ (void)initialize {
    if (self == [PNAESGCMCryptor class]) {
        kPNAESGCMCryptorIdentifier = [@"ACGM" dataUsingEncoding:NSUTF8StringEncoding];
    }
}

+ (instancetype)cryptorWithCipherKey:(NSString *)cipherKey {
    return [[self alloc] initWithCipherKey:cipherKey];
}

- (instancetype)initWithCipherKey:(NSString *)cipherKey {
    if ((self = [super init])) {
        _cipherKey = [self digestForKey:cipherKey];
    }
    
    return self;
}


#pragma mark - Data processing

- (PNResult<PNEncryptedData *> *)encryptData:(NSData *)data {
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"AES-GCM encryption is not enabled." };
    NSError *error = [NSError errorWithDomain:PNCryptorErrorDomain code:PNAPIErrorFeatureNotEnabled userInfo:userInfo];
    
    return [PNResult resultWithData:nil error:error];
}

- (PNResult<NSData *> *)decryptData:(PNEncryptedData *)data {
    NSData *metadata = data.metadata;
    NSData *ciphertext = data.data;
    NSData *nonce = nil;
    NSData *tag = nil;
    
    if (metadata.length != (kPNAESGCMNonceLength + kPNAESGCMTagLength)) {
        return [self decryptionFailure];
    }
    nonce = [metadata subdataWithRange:NSMakeRange(0, kPNAESGCMNonceLength)];
    tag = [metadata subdataWithRange:NSMakeRange(kPNAESGCMNonceLength, kPNAESGCMTagLength)];
    
    NSError *error = nil;
    NSData *plaintext = [PNCryptoKitWrapper decryptWithKey:self.cipherKey
                                                     nonce:nonce
                                                       tag:tag
                                                ciphertext:ciphertext
                                                     error:&error];
    
    return plaintext ? [PNResult resultWithData:plaintext error:nil] : [self decryptionFailure];
}


#pragma mark - Stream processing

- (PNResult<PNEncryptedStream *> *)encryptStream:(NSInputStream *)stream dataLength:(NSUInteger)length {
    NSError *error = [NSError errorWithDomain:PNCryptorErrorDomain code:PNAPIErrorFeatureNotEnabled
                                     userInfo:@{NSLocalizedDescriptionKey: @"AES-GCM encryption is not enabled."}];
    
    return [PNResult resultWithData:nil error:error];
}

- (PNResult<NSInputStream *> *)decryptStream:(PNEncryptedStream *)stream dataLength:(NSUInteger)length {
    NSUInteger remaining = stream.stream.inputDataLength;
    NSData *metadata = stream.metadata;
    
    if (metadata.length != (kPNAESGCMNonceLength + kPNAESGCMTagLength)) {
        return [self decryptionFailure];
    }
    
    NSMutableData *encrypted = [NSMutableData data];
    uint8_t buffer[16384];
    while (remaining > 0) {
        NSInteger count = [stream.stream read:buffer maxLength:MIN(sizeof(buffer), remaining)];
        
        if (count <= 0) {
            return [self decryptionFailure];
        }
        
        [encrypted appendBytes:buffer length:(NSUInteger)count];
        remaining -= (NSUInteger)count;
    }
    
    PNResult<NSData *> *result = [self decryptData:[PNEncryptedData encryptedDataWithData:encrypted metadata:metadata]];
    if (result.isError) {
        return (PNResult<NSInputStream *> *)result;
    }
    
    return [PNResult resultWithData:[NSInputStream inputStreamWithData:result.data] error:nil];
}

- (PNResult *)decryptionFailure {
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Invalid AES-GCM payload or authentication tag." };
    NSError *error = [NSError errorWithDomain:PNCryptorErrorDomain code:PNCryptorErrorDecryption userInfo:userInfo];
    
    return [PNResult resultWithData:nil error:error];
}


#pragma mark - Helpers

- (NSData *)digestForKey:(NSString *)key {
    NSMutableData *digestData = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    NSData *data = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    CC_SHA256(data.bytes, (CC_LONG)data.length, digestData.mutableBytes);
    
    return digestData;
}

#pragma mark -


@end
