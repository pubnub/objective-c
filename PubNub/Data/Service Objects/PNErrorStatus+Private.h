#import "PNErrorStatus.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief  Error status class extension to expose private information to subclasses.
 
 @since 4.0
 */
@interface PNErrorStatus ()


///------------------------------------------------
/// @name Information
///------------------------------------------------

@property (nonatomic, nullable, strong) id associatedObject;
@property (nonatomic, strong) PNErrorData *errorData;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
