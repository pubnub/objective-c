#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNChannel;


/**
 Cache class will store all crucial information which maybe used by \b PubNub client during lifetime of session.

 @since 3.6.0

 @author Sergey Mamontov
 @copyright © 2009-13 PubNub Inc.
 */
@interface PNCache : NSObject


#pragma mark - Instance methods

#pragma mark - State management method

/**
 Method allow to fetch all state which has been cached while \b PubNub client has been used. State will be
 returned in \b NSDictionary and each key will be the name of \b PNChannel and value which has been set by user in
 subscribe or state set methods.

 @return NSDictionary instance or \c nil (if there is no state in cache) with cached state which is stored
 individually for each channel who's name used as key.
 */
- (void)clientState:(void (^)(NSDictionary *clientState))fetchCompletionBlock;

/**
 Method allow to fetch all state which hasb been cached and merge it with provided. It will clean up resulting dictionary from 
 properties which user want to remove (by setting [NSNull null] as value for them) or state for whole channel in case if user will
 pass empty dictionary (@{} will remove state for channel from resulting object).
 
 @param state
 Is \b NSDictionary instance first level values of which represent state for channels which is used as keys for this dictionary.
 
 @return Cleaned up state dictionary.
 */
- (void)stateMergedWithState:(NSDictionary *)state withBlock:(void (^)(NSDictionary *mergedState))mergeCompletionBlock;

/**
 Method allow to update cached state for concrete channel.

 @param state
 \b NSDictionary instance with list of parameters which should be bound to the client. If \c nil provided,
 then state for specified channel will be removed from cache.

 @param channel
 \b PNChannel instance for which provided state should bound.

 @warning Client state shouldn't contain any nesting and values should be one of: int, float or string.

 @since 3.6.0
 */
- (void)storeClientState:(NSDictionary *)clientState forChannel:(PNChannel *)channel;

/**
 Method allow to update cached state for set of channels.

 @param state
 \b NSDictionary instance with list of parameters which should be bound to the channels. Existing data for cached
 channels will be overridden (but not deleted).

 @param channels
 List of \b PNChannel instances for which provided state should bound.

 @since 3.6.0
 */
- (void)storeClientState:(NSDictionary *)clientState forChannels:(NSArray *)channels;

/**
 Method allow to fetch state for set of channels.

 @param channels
 List of \b PNChannel instances for which state should be retrieved from cache.

 @return \b NSDictionary with state for all requested channels (for those which doesn't have cached state
 there will be no values).
 */
- (void)stateForChannels:(NSArray *)channels withBlock:(void (^)(NSDictionary *stateOnChannel))fetchCompletionBlock;

/**
 Method allow to remove state from cache for concrete channels.

 @param channel
 \b PNChannel for which state should be removed from cache.
 */
- (void)purgeStateForChannel:(PNChannel *)channel;

/**
 Method allow to remove state from cache for set of channel.

 @param channels
 List of \b PNChannel instances for which state should be removed from cache.
 */
- (void)purgeStateForChannels:(NSArray *)channels;

/**
 Method allow to purge all state which is stored in cache.
 */
- (void)purgeAllState;

#pragma mark -


@end
