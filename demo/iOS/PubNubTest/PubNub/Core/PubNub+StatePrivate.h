/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+State.h"


#pragma mark Private interface declaration

@interface PubNub (StatePrivate)


///------------------------------------------------
/// @name Client state cache
///------------------------------------------------

/**
 @brief      Retrieve state information stored in cache.
 @discussion State cache updated every time when client successfully subscribe on remote data object
             feeds with pre-defined state or modify state using corresponding API group.
 
 @return Cached dictionary which store reference between remote data object names and values bound
         for client. \c nil will be returned in case if state cache is empty.
 
 @since 4.0
 */
- (NSDictionary *)state;

/**
 @brief  Provide merged client state using new \c state information which should be bound to remote
         data \c object.
 
 @param state   State which should be merged into client state stored in cache.
 @param objects List of object names for which merged data is composed. In case if merged state will
                have names of objects not presented in \c objects their data will be removed.
 
 @return Merged client state information
 
 @since 4.0
 */
- (NSDictionary *)stateMergedWith:(NSDictionary *)state forObjects:(NSArray *)objects;

/**
 @brief  Merge cached client state information with the one which has been passed.
 
 @param state Reference on client state information which should be merged into cached version.
 
 @since 4.0
 */
- (void)mergeWithState:(NSDictionary *)state;

#pragma mark -


@end
