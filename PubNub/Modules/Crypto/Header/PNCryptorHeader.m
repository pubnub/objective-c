#import "PNCryptorHeader+Private.h"
#import "PNError.h"


#pragma mark Contants

/// Null cryptor identifier for legacy cryptors.
extern NSData *kPNCryptorLegacyIdentifier;

/// PubNub-defined sentinel for cryptor header identification.
static const NSData *kPNCryptorHeaderSentinel;

/// Length of cryptor sentinel.
static NSUInteger kPNCryptorHeaderSentinelSize = 4;

/// Length of cryptor identifier.
static NSUInteger kPNCryptorHeaderIdentifierSize = 4;

/// Offset in byte array at which `sentinel` value is expected to be.
static NSUInteger kPNCryptorHeaderSentinelOffset;

/// Offset in byte array at which `version` value is expected to be.
static NSUInteger kPNCryptorHeaderVersionOffset;

/// Offset in byte array at which `cryptor identifier` value is expected to be.
static NSUInteger kPNCryptorHeaderIdentifierOffset;

/// Offset in byte array at which `cryptor-defined data size` value is expected to be.
static NSUInteger kPNCryptorHeaderSizeOffset;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

/// Cryptor header private extension.
@interface PNCryptorHeader ()


#pragma mark - Information

/// Header type.
@property(nonatomic, assign) PNCryptorHeaderVersion version;

/// Parsed header data.
///
/// Actual data type corresponds to the parsed version.
@property(nonatomic, strong) id headerData;


#pragma mark - Initialization and configuration

/// Initialize a cryptor header object with cryptor-related data.
///
/// - Parameters:
///   - version: Cryptor data header version.
///   - headerData: Version-based header data.
/// - Returns: Cryptor data header object, which can be added to the resulting data.
- (instancetype)initWithVersion:(PNCryptorHeaderVersion)version header:(nullable id)headerData;


#pragma mark - Helpers

/// Extract `sentinel` from the provided data.
///
/// - Parameter data: Binary data from which information should be retrieved.
/// - Returns: The first four bytes, which should represent `sentinel` or `nil` in case if `data` is too short.
+ (nullable NSData *)sentinelFromData:(NSData *)data;

/// Extract header version from the provided data.
///
/// - Parameter data: Binary data from which information should be retrieved.
/// - Returns: Cryptor header version information.
+ (PNResult<NSNumber *> *)versionFromData:(NSData *)data;

/// Extract cryptor identifier from the provided data.
///
/// - Parameter data: Binary data from which information should be retrieved.
/// - Returns: Cryptor identifier.
+ (PNResult<NSData *> *)identifierFromData:(NSData *)data;

/// Extract the cryptor-defined data length from the provided data.
///
/// - Parameter data: Binary data from which information should be retrieved.
/// - Returns: Cryptor-defined data length or `nil` if this information can't be retrieved from the header.
+ (nullable PNResult<NSNumber *> *)metadataLengthFromData:(NSData *)data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNCryptorHeader


#pragma mark - Information

+ (NSUInteger)maximumHeaderLength {
    return kPNCryptorHeaderSentinelSize + 1 + kPNCryptorHeaderIdentifierSize + 3;
}

- (NSData *)identifier {
    // Currently only `v1` header version supported.
    return ((PNCryptorHeaderV1Data *)self.headerData).identifier;
}

- (NSInteger)metadataLength {
    // Currently only `v1` header version supported.
    return ((PNCryptorHeaderV1Data *)self.headerData).metadataLength;
}

- (NSUInteger)length {
    NSUInteger length = kPNCryptorHeaderSentinelSize + 1 + kPNCryptorHeaderIdentifierSize;
    NSInteger metadataLength = ((PNCryptorHeaderV1Data* )self.headerData).metadataLength;

    return length + (metadataLength < 255 ? 1 : 3) + metadataLength;
}


#pragma mark - Initialization and configuration

+ (void)initialize {
    if (self == [PNCryptorHeader class]) {
        kPNCryptorHeaderSentinel = [@"PNED" dataUsingEncoding:NSUTF8StringEncoding];
        kPNCryptorHeaderSentinelOffset = 0;
        kPNCryptorHeaderVersionOffset = kPNCryptorHeaderSentinelOffset + kPNCryptorHeaderSentinelSize;
        kPNCryptorHeaderIdentifierOffset = kPNCryptorHeaderVersionOffset + 1;
        kPNCryptorHeaderSizeOffset = kPNCryptorHeaderIdentifierOffset + kPNCryptorHeaderIdentifierSize;
    }
}

+ (PNResult<PNCryptorHeader *> *)headerFromData:(NSData *)data {
    // The data may have been created using a legacy cryptor if it is too short or doesn't match `sentinel`.
    if (![[self sentinelFromData:data] isEqual:kPNCryptorHeaderSentinel]) return nil;
    
    PNResult<NSNumber *> *version = [self versionFromData:data];
    if (version.isError) return (PNResult<PNCryptorHeader *> *)version;
    
    PNResult<NSData *> *identifier = [self identifierFromData:data];
    if (identifier.isError) return (PNResult<PNCryptorHeader *> *)identifier;
    
    PNResult<NSNumber *> *metadataLength = [self metadataLengthFromData:data];
    if (!metadataLength) return nil;
    
    id headerData = [[PNCryptorHeaderV1Data alloc] initWithIdentifier:identifier.data
                                                       metadataLength:metadataLength.data.integerValue];
    return [PNResult resultWithData:[[self alloc] initWithVersion:PNCryptorHeaderV1 header:headerData]
                              error:nil];
}

+ (instancetype)headerWithCryptorIdentifier:(NSData *)identifier metadata:(NSData *)metadata {
    if (!identifier || [identifier isEqual:kPNCryptorLegacyIdentifier]) return nil;
    
    id headerData = [[PNCryptorHeaderV1Data alloc] initWithIdentifier:identifier metadataLength:metadata.length];
    return [[self alloc] initWithVersion:PNCryptorHeaderV1 header:headerData];
}


#pragma mark - Initialization and configuration

- (instancetype)initWithVersion:(PNCryptorHeaderVersion)version header:(nullable id)headerData {
    if ((self = [super init])) {
        _headerData = headerData;
        _version = version;
    }
    
    return self;
}


#pragma mark - Serialization

- (NSData *)toData {
    PNCryptorHeaderV1Data *headerData = (PNCryptorHeaderV1Data* )self.headerData;
    
    NSData *identifier = headerData.identifier;
    if (!identifier || [identifier  isEqual:kPNCryptorLegacyIdentifier]) return [NSData new];
    
    NSMutableData *data = [NSMutableData dataWithLength:(self.length - headerData.metadataLength)];
    [data replaceBytesInRange:NSMakeRange(kPNCryptorHeaderSentinelOffset, kPNCryptorHeaderSentinelSize)
                    withBytes:kPNCryptorHeaderSentinel.bytes];
    
    NSInteger version = PNCryptorHeaderV1;
    [data replaceBytesInRange:NSMakeRange(kPNCryptorHeaderVersionOffset, 1) withBytes:&version];
    
    [data replaceBytesInRange:NSMakeRange(kPNCryptorHeaderIdentifierOffset, kPNCryptorHeaderIdentifierSize)
                    withBytes:identifier.bytes];
    
    NSInteger metadataLength = headerData.metadataLength;
    if (metadataLength < 255) {
        [data replaceBytesInRange:NSMakeRange(kPNCryptorHeaderSizeOffset, 1) withBytes:&metadataLength];
    } else {
        char lengthNumberBuffer[3] = {255, (metadataLength >> 8), (metadataLength & 0xFF)};
        [data replaceBytesInRange:NSMakeRange(kPNCryptorHeaderSizeOffset, 3) withBytes:&lengthNumberBuffer];
    }

    
    return data;
}


#pragma mark - Helpers

+ (NSData *)sentinelFromData:(NSData *)data {
    if (data.length < kPNCryptorHeaderSentinelSize) return nil;
    return [data subdataWithRange:NSMakeRange(kPNCryptorHeaderSentinelOffset, kPNCryptorHeaderSentinelSize)];
}

+ (PNResult<NSNumber *> *)versionFromData:(NSData *)data {
    NSNumber *version = nil;
    NSError *error = nil;
    
    if (data.length < kPNCryptorHeaderIdentifierOffset) {
        error = [NSError errorWithDomain:PNCryptorErrorDomain
                                    code:PNCryptorErrorDecryption
                                userInfo:@{ NSLocalizedDescriptionKey: @"Decrypted data header is malformed." }];
        
        return [PNResult resultWithData:version error:error];
    }
    
    int8_t type;
    [data getBytes:&type range:NSMakeRange(kPNCryptorHeaderVersionOffset, 1)];

    switch (type) {
        case 1:
            version = @(PNCryptorHeaderV1);
            break;
        default:
            error = [NSError errorWithDomain:PNCryptorErrorDomain
                                        code:PNCryptorErrorUnknownCryptor
                                    userInfo:@{
                NSLocalizedDescriptionKey: @"Decrypting data created by unknown cryptor."
            }];
    }
    
    return [PNResult resultWithData:version error:error];
}

+ (PNResult<NSData *> *)identifierFromData:(NSData *)data {
    NSData *identifier = nil;
    NSError *error = nil;
    
    if (data.length < kPNCryptorHeaderSizeOffset) {
        error = [NSError errorWithDomain:PNCryptorErrorDomain
                                    code:PNCryptorErrorDecryption
                                userInfo:@{ NSLocalizedDescriptionKey: @"Decrypted data header is malformed." }];
    } else {
        NSRange identifierRange = NSMakeRange(kPNCryptorHeaderIdentifierOffset, kPNCryptorHeaderIdentifierSize);
        identifier = [data subdataWithRange:identifierRange];
    }
    
    return [PNResult resultWithData:identifier error:error];
}

+ (PNResult<NSNumber *> *)metadataLengthFromData:(NSData *)data {
    NSNumber *length = nil;
    
    if (data.length < kPNCryptorHeaderSizeOffset + 1) return nil;
    
    uint8_t size;
    [data getBytes:&size range:NSMakeRange(kPNCryptorHeaderSizeOffset, 1)];
    
    if (size == 255) {
        if (data.length >= kPNCryptorHeaderSizeOffset + 3) {
            unsigned char sizeBuffer[2];
            [data getBytes:&sizeBuffer range:NSMakeRange(kPNCryptorHeaderSizeOffset + 1, 2)];
            length = @((sizeBuffer[0] << 8) | sizeBuffer[1]);
        } else {
            return nil;
        }
    } else {
        length = @(size);
    }
    
    return [PNResult resultWithData:length error:nil];
}

#pragma mark -


@end
