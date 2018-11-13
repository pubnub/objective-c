/**
 @author Sergey Mamontov
 @since 4.4.0
 @copyright © 2010-2018 PubNub, Inc.
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

/**
 @brief      Create and configure shared \c NSURLSession configuration instance.
 @discussion This instance will be used by \b PubNub client every time when new \c NSURLSession instance 
             should be created to perform which can be handled by operating system in case if application will
             be suspended or crash. This kind of configuration allow \b PubNub client to be used in
             environment like application extensions which has really short life-cycle. Shared instance also 
             stores additional user-provided adjustments which will be used by new \c NSURLSession instance.
 
 @since 4.5.4
 
 @param identifier Unique identifier to identify session configuration among other.
 
 @return Configured and ready to use \c NSURLSession configuration instance.
 */
+ (nullable instancetype)pn_backgroundSessionConfigurationWithIdentifier:(NSString *)identifier NS_AVAILABLE(10_10, 8_0);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
