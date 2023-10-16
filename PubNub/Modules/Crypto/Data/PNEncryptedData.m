#import "PNEncryptedData.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// The cryptor's result private extension.
@interface PNEncryptedData ()


#pragma mark - Initialization and configuration

/// Initiate encrypted data object.
///
/// An object used to keep track of the results of data encryption and the additional data the `cryptor` needs to handle
/// it later.
///
/// - Parameters:
///   - data: Outcome of successful cryptor encrypt method call.
///   - metadata: Additional information is provided by `cryptor` so that encrypted data can be handled later.
/// - Returns: A data object with encrypted data and metadata.
- (instancetype)initWithData:(NSData *)data metadata:(nullable NSData *)metadata;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNEncryptedData


#pragma mark - Initialization and configuration

+ (instancetype)encryptedDataWithData:(NSData *)data metadata:(nullable NSData *)metadata {
    return [[self alloc] initWithData:data metadata:metadata];
}

- (instancetype)initWithData:(NSData *)data metadata:(nullable NSData *)metadata {
    if ((self = [super init])) {
        _metadata = metadata;
        _data = data;
    }
    
    return self;
}


#pragma mark - Helpers

- (NSString *)description {
    return [NSString stringWithFormat:@"<PNEncryptedData: %p>\n\t- metadata: %@\n\t- data: %@",
            self, self.metadata.debugDescription, self.data.debugDescription];
}

#pragma mark -


@end
