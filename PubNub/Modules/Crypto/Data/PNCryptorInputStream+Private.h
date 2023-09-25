#import "PNCryptorInputStream.h"
#import "PNCryptorHeader.h"
#import "PNResult.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface implementation

/// Crypto module data input stream private extension.
@interface PNCryptorInputStream (Private)


#pragma mark - Information

/// Length of data in provided stream.
@property(nonatomic, readonly, assign) NSUInteger inputDataLength;


#pragma mark - Initialization and configuration

/// Create cryptor input stream.
///
/// Extension, which allows pre-processing portions of stream data to identify the `cryptor` data header.
///
/// - Parameters:
///   - stream: Input stream with data for pre-processing.
///   - length: Length of data in provided stream.
/// - Returns: Initialized cryptor input stream.
+ (instancetype)inputStreamWithInputStream:(NSInputStream *)stream dataLength:(NSUInteger)length;


#pragma mark - Pre-processing

/// Try parse header data from input stream.
///
/// - Returns: Header parse result or `nil` in case if header not found.
- (nullable PNResult<PNCryptorHeader *> *)parseHeader;

/// Try to read cryptor metadata.
///
/// - Parameter length: How many bytes of cryptor metadata should be read from input stream.
/// - Returns: Cryptor-defined metadata.
- (PNResult<NSData *> *)readCryptorMetadataWithLength:(NSUInteger)length;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
