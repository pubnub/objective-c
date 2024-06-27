#import "PNErrorData.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Error status object additional information private extension.
@interface PNErrorData (Private)


#pragma mark - Initialization and Configuration

/// Create error status data from error.
///
/// - Parameter error: Transport or parser error object.
/// - Returns: Ready to use error status data object.
+ (instancetype)dataWithError:(NSError *)error;

#pragma mark -

@end

NS_ASSUME_NONNULL_END
