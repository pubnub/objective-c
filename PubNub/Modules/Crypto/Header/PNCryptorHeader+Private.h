#import "PNCryptorHeader.h"


NS_ASSUME_NONNULL_BEGIN

/// Cryptor header private extension.
@interface PNCryptorHeader ()


#pragma mark - Information

/// Maximum length of current header version in encrypted data.
@property(nonatomic, readonly, class, assign) NSUInteger maximumHeaderLength;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
