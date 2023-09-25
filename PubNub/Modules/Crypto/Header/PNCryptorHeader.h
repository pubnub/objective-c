#import <Foundation/Foundation.h>
#import "PNCryptorHeaderV1Data.h"
#import "PNResult.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Types and structs

/// Enum with set of known header versions.
///
/// - Since: 5.1.4
/// - Copyright: 2010-2023 PubNub, Inc.
typedef NS_ENUM(NSInteger, PNCryptorHeaderVersion) {
    /// Initial header schema.
    ///
    /// **v1** header consists of the following positional data:
    /// * 4 byte sentinel
    /// * 1 byte header version
    /// * 4 byte cryptor identifier
    /// * 1 to 3 bytes with length of cryptor-defined data
    /// * any cryptor defined data (metadata).
    PNCryptorHeaderV1 = 1,
};


#pragma mark - Interface declaration

/// Cryptor data header.
///
/// The `cryptor` data header is a binary prefix designed to make cryptor module more flexible and identify a concrete
/// cryptor to use for decryption.
///
/// - Since: 5.1.4
/// - Copyright: 2010-2023 PubNub, Inc.
@interface PNCryptorHeader : NSObject


#pragma mark - Information

/// Header type.
@property(nonatomic, readonly, assign) PNCryptorHeaderVersion version;

/// Parsed header data.
///
/// Actual data type corresponds to the parsed version.
@property(nonatomic, readonly, strong) id headerData;

/// Identified the cryptor that encrypted the data.
///
/// This is shortcut getter which access `identifier` field from `headerData` which correspond to parsed `version`.
@property(nonatomic, readonly, strong) NSData *identifier;

/// Length of cryptor-defined data that should be put in a header.
///
/// This is shortcut getter which access `metadataLength` field from `headerData` which correspond to parsed `version`.
@property(nonatomic, readonly, assign) NSInteger metadataLength;

/// Overall cryptor header length.
@property(nonatomic, readonly, assign) NSUInteger length;


#pragma mark - Initialization and configuration

/// Create cryptor header object from received data.
///
/// Parse provided binary data using scheme corresponding to the **version** specified in the cryptor data header.
///
/// - Parameter data: Source data from which cryptor data header should be parsed.
/// - Returns: Header object with information which corresponds to the **version** field in header or `nil` if header is
/// missing.
+ (nullable PNResult<PNCryptorHeader *> *)headerFromData:(NSData *)data;

/// Create a cryptor header object with cryptor-related data.
///
/// - Parameters:
///   - identifier: Identified the cryptor that encrypted the data.
///   - metadata: Cryptor-defined data that should be put in a header.
/// - Returns: Cryptor data header object, which can be added to the resulting data.
+ (nullable instancetype)headerWithCryptorIdentifier:(nullable NSData *)identifier metadata:(nullable NSData *)metadata;


#pragma mark - Serialization

/// Serialize header information into binary data.
///
/// - Returns: Binary representation of cryptor data header.
- (NSData *)toData;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
