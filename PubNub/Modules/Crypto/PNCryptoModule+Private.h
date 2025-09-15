#import "PNCryptoModule.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Crypto module private extension.
@interface PNCryptoModule (Private)


#pragma mark - Misc

/// Serialize crypto module object.
///
/// - Returns: Crypto object represented as `NSDictionary`.
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
