#import "PNPresenceLeaveRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Leave` request private extension.
@interface PNPresenceLeaveRequest ()


#pragma mark - Properties

/// List of channel group names from which client should try to unsubscribe.
@property(copy, nullable, nonatomic) NSArray<NSString *> *channelGroups;

/// List of channel names from which client should try to unsubscribe.
@property(copy, nullable, nonatomic) NSArray<NSString *> *channels;

/// Whether presence change should be done only for presence channels or not.
///
/// > Note: Actual `leave` won't be triggered, and only the list of active channels will be modified if set to `NO`.
@property(assign, nonatomic) BOOL presenceOnly;


#pragma mark - Initialization and Configuration

/// Initialize `Leave` request.
///
/// - Parameters:
///   - channels: List of channel names from which client should try to unsubscribe.
///   - channelGroups: List of channel group names from which client should try to unsubscribe.
///   - presenceOnly: Whether request change should be done only for presence channels or not.
/// - Returns: Initialized `Leave` request.
- (instancetype)initWithChannels:(nullable NSArray<NSString *> *)channels
                   channelGroups:(nullable NSArray<NSString *> *)channelGroups
                    presenceOnly:(BOOL)presenceOnly;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNPresenceLeaveRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNUnsubscribeOperation;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [([super query] ?: @{}) mutableCopy];
    
    if (self.channelGroups.count) query[@"channel-group"] = [self.channelGroups componentsJoinedByString:@","];
    if (self.arbitraryQueryParameters) [query addEntriesFromDictionary:self.arbitraryQueryParameters];
    
    return query;
}

- (NSString *)path {
    return PNStringFormat(@"/v2/presence/sub_key/%@/channel/%@/leave",
                          self.subscribeKey,
                          [PNChannel namesForRequest:self.channels defaultString:@","]);
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithChannels:(NSArray<NSString *> *)channels channelGroups:(NSArray<NSString *> *)channelGroups {
    return [[self alloc] initWithChannels:channels channelGroups:channelGroups presenceOnly:NO];
}

+ (instancetype)requestWithPresenceChannels:(NSArray<NSString *> *)channels
                              channelGroups:(NSArray<NSString *> *)channelGroups {
    NSMutableArray *presenceChannelGroups = nil;
    NSMutableArray *presenceChannels = nil;
    
    if (channels.count) {
        presenceChannels = [NSMutableArray arrayWithCapacity:channels.count];
        for(NSString *name in channels) {
            if ([name hasSuffix:@"-pnpres"]) [presenceChannels addObject:name];
            [presenceChannels addObject:[name stringByAppendingString:@"-pnpres"]];
        }
    }
    
    if (channelGroups.count) {
        presenceChannelGroups = [NSMutableArray arrayWithCapacity:channelGroups.count];
        for(NSString *name in channelGroups) {
            if ([name hasSuffix:@"-pnpres"]) [presenceChannelGroups addObject:name];
            [presenceChannelGroups addObject:[name stringByAppendingString:@"-pnpres"]];
        }
    }
    
    return [[self alloc] initWithChannels:presenceChannels channelGroups:presenceChannelGroups presenceOnly:YES];
}

- (instancetype)initWithChannels:(NSArray<NSString *> *)channels
                   channelGroups:(NSArray<NSString *> *)channelGroups
                    presenceOnly:(BOOL)presenceOnly {
    if ((self = [super init])) {
        _channelGroups = [channelGroups copy];
        _observePresence = presenceOnly;
        _presenceOnly = presenceOnly;
        _channels = [channels copy];
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    
    return nil;
}


#pragma mark - Prepare

- (PNError *)validate {
    if (self.channels.count == 0 && self.channelGroups.count == 0) {
        return [self missingParameterError:@"channels" forObjectRequest:@"Presence leave request"];
    }
    
    return nil;
}

#pragma mark -


@end
