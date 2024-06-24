#import "PNFile.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Shared file` data object private extension.
@interface PNFile (Private)


#pragma mark - Properties

/// URL which can be used to download file.
@property(strong, nonatomic) NSURL *downloadURL;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
