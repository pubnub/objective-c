/**

 @author Sergey Mamontov
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNCache.h"
#import "NSObject+PNAdditions.h"
#import "PNHelper.h"
#import "PNChannel.h"


#pragma mark Private interface declaration

@interface PNCache ()

#pragma mark - Properties

/**
 Unified storage for cached data across all channels which is in use by client and developer.
 */
@property (nonatomic, strong) NSMutableDictionary *stateCache;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNCache


#pragma mark - Instance methods

- (id)init {

    // Check whether initialization has been successful or not
    if ((self = [super init])) {

        self.stateCache = [NSMutableDictionary dictionary];
        [self pn_setupPrivateSerialQueueWithIdentifier:@"state-cache" andPriority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
    }

    return self;
}

#pragma mark - State management method

- (void)clientState:(void (^)(NSDictionary *clientState))fetchCompletionBlock {

    [self pn_dispatchBlock:^{

        fetchCompletionBlock([self.stateCache count] ? [self.stateCache copy] : nil);
    }];
}

- (void)stateMergedWithState:(NSDictionary *)state withBlock:(void (^)(NSDictionary *mergedState))mergeCompletionBlock {

    [self pn_dispatchBlock:^{

        NSMutableDictionary *cleanedState = (self.stateCache ? [self.stateCache mutableCopy] : [NSMutableDictionary dictionary]);

        [state enumerateKeysAndObjectsUsingBlock:^(NSString *channelName, NSDictionary *channelState,
                BOOL *channelStateEnumeratorStop) {

            if ([cleanedState valueForKey:channelName] != nil) {

                // Ensure that there is not empty dictionary (if dictionary for channel is empty, it mean that
                // user want to remove state from specific channel).
                if ([channelState count]) {

                    NSMutableDictionary *oldChannelState = [[cleanedState valueForKey:channelName] mutableCopy];
                    [channelState enumerateKeysAndObjectsUsingBlock:^(NSString *stateName, id stateData,
                            BOOL *stateDataEnumeratorStop) {

                        // In case if provided data is 'nil' it should be removed from previous state dictionary.
                        if ([stateData isKindOfClass:[NSNull class]]) {

                            [oldChannelState removeObjectForKey:stateName];
                        }
                        else {

                            [oldChannelState setValue:stateData forKey:stateName];
                        }
                    }];

                    if ([oldChannelState count]) {

                        [cleanedState setValue:oldChannelState forKey:channelName];
                    }
                }
            }
                // Ensure that there is not empty dictionary (if dictionary for channel is empty, it mean that
                // user want to remove state from specific channel).
            else if ([channelState count]) {

                [cleanedState setValue:channelState forKey:channelName];
            }
        }];

        mergeCompletionBlock(cleanedState);
    }];
}

- (void)storeClientState:(NSDictionary *)clientState forChannel:(PNChannel *)channel {

    [self pn_dispatchBlock:^{

        if (clientState) {

            if (channel) {

                [self.stateCache setValue:clientState forKey:channel.name];
            }
            else {

                [clientState enumerateKeysAndObjectsUsingBlock:^(NSString *channelName, NSDictionary *channelState,
                        BOOL *channelsStateEnumeratorStop) {

                    [self.stateCache setValue:channelState forKey:channelName];
                }];
            }
        }
        else {

            [self purgeStateForChannel:channel];
        }
    }];
}

- (void)storeClientState:(NSDictionary *)clientState forChannels:(NSArray *)channels {

    [self pn_dispatchBlock:^{

        if (clientState) {

            NSArray *channelNames = [channels valueForKey:@"name"];
            NSArray *channelsWithState = [clientState allKeys];

            [channelsWithState enumerateObjectsUsingBlock:^(NSString *channelName, NSUInteger idx, BOOL *stop) {

                if ([channelNames containsObject:channelName] || [self.stateCache valueForKey:channelName] != nil) {

                    [self.stateCache setValue:[clientState valueForKey:channelName] forKey:channelName];
                }
            }];
        }
        else {

            [self purgeStateForChannels:channels];
        }
    }];
}

- (void)stateForChannels:(NSArray *)channels withBlock:(void (^)(NSDictionary *stateOnChannel))fetchCompletionBlock {

    [self pn_dispatchBlock:^{
        
        NSMutableSet *channelsSet = [NSMutableSet setWithArray:[channels valueForKey:@"name"]];
        [channelsSet intersectSet:[NSSet setWithArray:[self.stateCache allKeys]]];

        fetchCompletionBlock([channelsSet count] ? [self.stateCache dictionaryWithValuesForKeys:[channelsSet allObjects]] : nil);
    }];
}

- (void)purgeStateForChannel:(PNChannel *)channel {

    if (channel) {

        [self pn_dispatchBlock:^{

            [self.stateCache removeObjectForKey:channel.name];
        }];
    }
}

- (void)purgeStateForChannels:(NSArray *)channels {

    if (channels) {

        [self pn_dispatchBlock:^{

            [self.stateCache removeObjectsForKeys:[channels valueForKey:@"name"]];
        }];
    }
}

- (void)purgeAllState {

    [self pn_dispatchBlock:^{

        [self.stateCache removeAllObjects];
    }];
}

- (void)dealloc {

    [self pn_destroyPrivateDispatchQueue];
}

#pragma mark -


@end
