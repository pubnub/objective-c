#import "PNErrorStatus.h"


/**
 @brief  Error status class extension to expose private information to subclasses.
 
 @since 4.0
 */
@interface PNErrorStatus ()


///------------------------------------------------
/// @name Information
///------------------------------------------------

@property (nonatomic, strong) id associatedObject;

@property (nonatomic, strong) PNErrorData *errorData;

#pragma mark -


@end