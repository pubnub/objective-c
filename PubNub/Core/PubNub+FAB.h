#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


/**
 @brief      \b PubNub client core class extension to provide access to features powered by Fabric.
 @discussion \b Fabric provides simplified frameworks integration and configuration. This category 
             give ability to construct instance using default keys stored in application's 
             Info.plist file.
 
 @author Sergey Mamontov
 @since 4.2.2
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PubNub (FAB)


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief      Construct new \b PubNub client instance with Fabric pre-defined configuration.
 @discussion This method will create \b PubNub instance using configuration provided by \b Fabric.
 @note       This method is similar to \c +clientWithConfiguration: but configuration of the client done by
             \b Fabric.
 
 @return Configured and ready to use \b PubNub client.
 */
+ (instancetype)client;

#pragma mark -


@end
