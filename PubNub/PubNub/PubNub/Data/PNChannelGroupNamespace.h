#import "PNChannelGroup.h"

/**
 This class used to represent one of channel registry entities which hold set of channel groupss registered under 
 unique name inside one of created namespace.
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PNChannelGroupNamespace : PNChannelGroup


#pragma mark - Class methods

/**
 @brief Construct namespace instance which will represent all namespaces registered under subscription key.
 
 @return Initialized and ready to use instance.
 
 @since 3.7.0
 */
+ (PNChannelGroupNamespace *)allNamespaces;

/**
 @brief Construct channel group namespace instance.
 
 @param name Name which represent one of namespaces created in \b PubNub channel registry.
 
 @return Initialized and ready to use instance.
 
 @since 3.7.0
 */
+ (PNChannelGroupNamespace *)namespaceWithName:(NSString *)name;

#pragma mark -


@end
