#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// **v1** header data.
///
/// Header contains information about used cryptor identifier and length of cryptor-defined metadata.
///
/// - Since: 5.1.4
/// - Copyright: 2010-2023 PubNub, Inc.
@interface PNCryptorHeaderV1Data : NSObject


#pragma mark - Information

/// Identified the cryptor that encrypted the data.
@property(nonatomic, readonly, strong) NSData *identifier;

/// Length of cryptor-defined metadata in a header.
@property(nonatomic, readonly, assign) NSInteger metadataLength;


#pragma mark - Initialization and configuration

/// Initialize cryptor header data.
///
/// - Parameters:
///   - identifier: Identified the cryptor that encrypted the data.
///   - length: Length of cryptor-defined data that should be put in a header.
/// - Returns: **v1** cryptor header data.
- (instancetype)initWithIdentifier:(NSData *)identifier metadataLength:(NSInteger)length;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
