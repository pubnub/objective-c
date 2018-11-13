#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PubNub;


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Current client state cache manager.
 @discussion When client use \b state API which allow to pull and push client state, this manager stores all 
             information locally. Locally cached data used by \b PubNub subscriber and presence modules to 
             deliver actual client state information to \b PubNub network.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNClientState : NSObject


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Construct state cache manager.
 
 @param client Reference on client for which state manager should be created.
 
 @return Constructed and ready to use client state cache manager.
 
 @since 4.0
 */
+ (instancetype)stateForClient:(PubNub *)client;

/**
 @brief  Copy specified client's state information.
 
 @param state Reference on client state manager whose information should be copied into receiver's state
              objects.
 
 @since 4.0
 */
- (void)inheritStateFromState:(PNClientState *)state;


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief      Retrieve state information stored in cache.
 @discussion State cache updated every time when client successfully subscribe on remote data object feeds 
             with pre-defined state or modify state using corresponding API group.
 
 @return Cached dictionary which store reference between remote data object names and values bound for client.
         \c nil will be returned in case if state cache is empty.
 
 @since 4.0
 */
- (nullable NSDictionary *)state;

/**
 @brief  Provide merged client state using new \c state information which should be bound to remote data 
         \c object.
 
 @param state   State which should be merged into client state stored in cache.
 @param objects List of object names for which merged data is composed. In case if merged state will
                have names of objects not presented in \c objects their data will be removed.
 
 @return Merged client state information
 
 @since 4.0
 */
- (nullable NSDictionary *)stateMergedWith:(nullable NSDictionary<NSString *, id> *)state 
                                forObjects:(NSArray<NSString *> *)objects;

/**
 @brief  Merge cached client state information with the one which has been passed.
 
 @param state Reference on client state information which should be merged into cached version.
 
 @since 4.0
 */
- (void)mergeWithState:(nullable NSDictionary<NSString *, id> *)state;

/**
 @brief  Overwrite client state information bound to specified \c object.

 @param state  State which should replace cached information.
 @param objects List of object names for which new data should be applied.

 @since 4.8.3
 */
- (void)setState:(nullable NSDictionary<NSString *, id> *)state
      forObjects:(NSArray<NSString *> *)objects;

/**
 @brief  Clear client state cache from specified objects data.
 
 @param objects Reference on list of objects for which state should be removed.
 
 @since 4.0
 */
- (void)removeStateForObjects:(NSArray<NSString *> *)objects;

#pragma mark - 


@end

NS_ASSUME_NONNULL_END
