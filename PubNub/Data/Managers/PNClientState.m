/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNClientState.h"
#import "PubNub+CorePrivate.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface  PNClientState ()


#pragma mark - Information

/**
 @brief  Weak reference on client for which state cache manager created.
 
 @since 4.0
 */
@property (nonatomic, weak) PubNub *client;

/**
 @brief  Stores reference on current client state information cached from previous \b state API
         usage and presence events.
 
 @since 4.0
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *stateCache;

/**
 @brief  Stores reference on queue which is used to serialize access to shared client state
         information.
 
 @since 4.0
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;


#pragma mark - Initialization and Configuration

/**
 @brief  Construct state cache manager.
 
 @param client Reference on client for which state manager should be created.
 
 @return Constructed and ready to use client state cache manager.
 
 @since 4.0
 */
- (instancetype)initForClient:(PubNub *)client;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNClientState


#pragma mark - Initialization and Configuration

+ (instancetype)stateForClient:(PubNub *)client {
    
    return [[self alloc] initForClient:client];
}

- (instancetype)initForClient:(PubNub *)client {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _client = client;
        _stateCache = [NSMutableDictionary new];
        _resourceAccessQueue = dispatch_queue_create("com.pubnub.client-state",
                                                     DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

- (void)inheritStateFromState:(PNClientState *)state {
    
    _stateCache = [state.stateCache mutableCopy];
}


#pragma mark - Information

- (NSDictionary *)state {
    
    __block NSDictionary *state = nil;
    dispatch_sync(self.resourceAccessQueue, ^{
        
        state = [(self->_stateCache.count ? self->_stateCache : nil) copy];
    });
    
    return state;
}

- (NSDictionary *)stateMergedWith:(nullable NSDictionary<NSString *, id> *)state 
                       forObjects:(NSArray<NSString *> *)objects {
    
    NSMutableDictionary *mutableState = [([self state]?: @{}) mutableCopy];
    [state enumerateKeysAndObjectsUsingBlock:^(NSString *objectName, NSDictionary *stateForObject,
                                               __unused BOOL *stateEnumeratorStop) {
        
        mutableState[objectName] = stateForObject;
    }];
    
    [[mutableState allKeys] enumerateObjectsUsingBlock:^(NSString *objectName,
                                                         __unused NSUInteger objectNameIdx,
                                                         __unused BOOL *objectNamesEnumeratorStop) {
        
        if (![objects containsObject:objectName]) { [mutableState removeObjectForKey:objectName]; }
    }];
    
    return [(mutableState.count ? mutableState : nil) copy];
}

- (void)mergeWithState:(nullable NSDictionary<NSString *, id> *)state {

    if (state.count) {

        dispatch_barrier_async(self.resourceAccessQueue, ^{
            
            [state enumerateKeysAndObjectsUsingBlock:^(NSString *objectName, NSDictionary *stateForObject,
                                                       __unused BOOL *stateEnumeratorStop) {
                
                self.stateCache[objectName] = stateForObject;
            }];
            
            // Clean up state cache from objects on which client not subscribed at this moment.
            NSMutableArray *objects = [NSMutableArray arrayWithArray:[self.stateCache allKeys]];
            // Silence static analyzer warnings.
            // Code is aware about this case and at the end will simply call on 'nil' object method.
            // In most cases if referenced object become 'nil' it mean what there is no more need in
            // it and probably whole client instance has been deallocated.
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wreceiver-is-weak"
            [objects removeObjectsInArray:[self.client.subscriberManager allObjects]];
            #pragma clang diagnostic pop
            [self removeStateForObjects:objects];
        });
    }
}

- (void)setState:(nullable NSDictionary<NSString *, id> *)state forObject:(NSString *)object {

    dispatch_barrier_async(self.resourceAccessQueue, ^{
        
        if (state.count) { self.stateCache[object] = state; }
        else { [self.stateCache removeObjectForKey:object]; }
    });
}

- (void)removeStateForObjects:(NSArray<NSString *> *)objects {
    
    dispatch_barrier_async(self.resourceAccessQueue, ^{
        
        if (objects.count) { [self.stateCache removeObjectsForKeys:objects]; }
    });
}

#pragma mark -


@end
