#import "PNErrorStatus.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Operation error status object private extension.
@interface PNErrorStatus () <NSCopying>


#pragma mark - Properties

/// Additional error information.
///
/// Additional information related to the context can be stored here. For example, source message will be stored here
/// if decryption will fail.
@property (nonatomic, nullable, strong) id associatedObject;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
