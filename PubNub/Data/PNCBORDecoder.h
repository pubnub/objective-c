#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief CBOR decoder.
 *
 * @discussion Encoded CBOR data processor.
 *
 * @author Serhii Mamontov
 * @version 4.17.0
 * @since 4.17.0
 * @copyright © 2010-2021 PubNub, Inc.
 */
@interface PNCBORDecoder : NSObject


#pragma mark Initialization & Configuration

/**
 * @brief Create and configure decoder for provided CBOR data.
 *
 * @param data Previously encoded well-formed CBOR data item.
 *
 * @return Configured and ready to use CBOR decoder.
 */
+ (instancetype)decoderWithCBORData:(NSData *)data;


#pragma mark - CBOR data decoding

- (nullable id)decodeWithError:(NSError * __autoreleasing *)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
