#import "PNChannelGroupManageRequest.h"
#import "PNTransportRequest+Private.h"
#import "PNBaseRequest+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Channel group manage` request private extension.
@interface PNChannelGroupManageRequest ()


#pragma mark - Properties

/// Whether list of `channels` should be removed during manage or not.
@property(assign, nonatomic, getter = shouldRemoveChannels) BOOL removeChannels;

/// List of channels which can be used to manage channel group channels list.
@property(strong, nullable, nonatomic) NSArray<NSString *> *channels;

/// Name of channel group for which manage will be done.
@property(strong, nullable, nonatomic) NSString *channelGroup;


#pragma mark - Initialization and Configuration

/// Channel group channels addition request.
///
/// - Parameters:
///   - channelGroup: Name of the channel group into which channels should be added.
///   - add: `YES` if list of passed `channels` should be added into `channelGroup` or not.
///   - channels: List of channels which should be used during manage request call.
/// - Returns: Ready to use `manage channel group` request.
- (instancetype)initForChannelGroup:(NSString *)channelGroup
                              toAdd:(BOOL)add
                           channels:(nullable NSArray<NSString *> *)channels;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNChannelGroupManageRequest


#pragma mark - Properties

- (PNOperationType)operation {
    if (self.channels.count) {
        if (!self.removeChannels) return PNAddChannelsToGroupOperation;
        else return PNRemoveChannelsFromGroupOperation;
    }
    
    return PNRemoveGroupOperation;
}

- (NSString *)path {
    if (self.operation == PNRemoveGroupOperation) {
        return PNStringFormat(@"/v1/channel-registration/sub-key/%@/channel-group/%@/remove",
                              self.subscribeKey, self.channelGroup);
    }
    
    return PNStringFormat(@"/v1/channel-registration/sub-key/%@/channel-group/%@", 
                          self.subscribeKey, self.channelGroup);
}

- (NSDictionary *)query {
    if (self.operation == PNRemoveGroupOperation) return self.arbitraryQueryParameters;
    
    NSMutableDictionary *query = [([super query] ?: @{}) mutableCopy];
    [query addEntriesFromDictionary:@{
        (!self.removeChannels ? @"add": @"remove"): [self.channels componentsJoinedByString:@","]
    }];
    
    if (self.arbitraryQueryParameters) [query addEntriesFromDictionary:self.arbitraryQueryParameters];
    
    return query;
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestToAddChannels:(NSArray<NSString *> *)channels toChannelGroup:(NSString *)channelGroup {
    return [[self alloc] initForChannelGroup:channelGroup toAdd:YES channels:channels];
}

+ (instancetype)requestToRemoveChannels:(NSArray<NSString *> *)channels fromChannelGroup:(NSString *)channelGroup {
    return [[self alloc] initForChannelGroup:channelGroup toAdd:NO channels:channels];
}

+ (instancetype)requestToRemoveChannelGroup:(NSString *)channelGroup {
    return [[self alloc] initForChannelGroup:channelGroup toAdd:NO channels:nil];
}

- (instancetype)initForChannelGroup:(NSString *)channelGroup toAdd:(BOOL)add channels:(NSArray<NSString *> *)channels {
    if ((self = [super init])) {
        _channelGroup = [channelGroup copy];
        _channels = [channels copy];
        _removeChannels = !add;
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    return nil;
}


#pragma mark - Prepare

- (PNError *)validate {
    if (self.channelGroup.length == 0) {
        return [self missingParameterError:@"channelGroup" forObjectRequest:@"PNChannelGroupManageRequest"];
    }
    
    return nil;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"channelGroup": self.channelGroup ?: @"missing",
        @"removeChannels": @(self.removeChannels)
    }];
    
    if (self.arbitraryQueryParameters) dictionary[@"arbitraryQueryParameters"] = self.arbitraryQueryParameters;
    if (self.channels) {
        dictionary[@"removeChannels"] = @(self.removeChannels);
        dictionary[@"channels"] = self.channels;
    } else dictionary[@"removeChannelGroup"] = @(self.removeChannels);
    
    return dictionary;
}

#pragma mark -


@end
