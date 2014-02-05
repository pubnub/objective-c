/**

 @author Sergey Mamontov
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNCache.h"


#pragma mark Private interface declaration

@interface PNCache ()

#pragma mark - Properties

/**
 Unified storage for cached data across all channels which is in use by client and developer.
 */
@property (nonatomic, strong) NSMutableDictionary *metadataCache;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNCache


#pragma mark - Instance methods

- (id)init {

    // Check whether initialization has been successful or not
    if ((self = [super init])) {

        self.metadataCache = [NSMutableDictionary dictionary];
    }

    return self;
}

#pragma mark - Metadata management method

- (NSDictionary *)metadata {

    return ([self.metadataCache count] ? [self.metadataCache copy] : nil);
}

- (void)storeMetadata:(NSDictionary *)metadata forChannel:(PNChannel *)channel {

    if (metadata) {

        if (channel) {

            [self.metadataCache setValue:metadata forKey:channel.name];
        }
    }
    else {

        [self purgeMetadataForChannel:channel];
    }
}

- (void)storeMetadata:(NSDictionary *)metadata forChannels:(NSArray * __unused)channels {

    [self.metadataCache addEntriesFromDictionary:metadata];
}

- (NSDictionary *)metadataForChannel:(PNChannel *)channel {

    return (channel ? [self.metadataCache valueForKey:channel.name] : nil);
}

- (NSDictionary *)metadataForChannels:(NSArray *)channels {

    NSMutableSet *channelsSet = [NSMutableSet setWithArray:[channels valueForKey:@"name"]];
    [channelsSet intersectSet:[NSSet setWithArray:[self.metadataCache allKeys]]];


    return ([channelsSet count] ? [self.metadataCache dictionaryWithValuesForKeys:[channelsSet allObjects]] : nil);
}

- (void)purgeMetadataForChannel:(PNChannel *)channel {

    if (channel) {

        [self.metadataCache removeObjectForKey:channel.name];
    }
}

- (void)purgeMetadataForChannels:(NSArray *)channels {

    if (channels) {

        [self.metadataCache removeObjectsForKeys:[channels valueForKey:@"name"]];
    }
}

- (void)purgeAllMetadata {

    [self.metadataCache removeAllObjects];
}

#pragma mark -


@end
