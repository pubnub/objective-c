/**
 @author Sergey Mamontov
 @since 4.4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "NSURLSessionConfiguration+PNConfiguration.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface NSURLSessionConfiguration (PNConfigurationPrivate)


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief      Create and configure shared \c NSURLSession configuration instance.
 @discussion This instance will be used by \b PubNub client every time when new \c NSURLSession instance 
             should be created. Shared instance also stores additional user-provided adjustments which will be
             used by new \c NSURLSession instance.
 
 @since 4.4.0
 
 @param identifier Unique identifier to identify session configuration among other.
 
 @return Configured and ready to use \c NSURLSession configuration instance.
 */
+ (instancetype)pn_ephemeralSessionConfigurationWithIdentifier:(NSString *)identifier;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
