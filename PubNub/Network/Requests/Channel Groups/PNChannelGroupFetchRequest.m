#import "PNChannelGroupFetchRequest.h"
#import "PNTransportRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `List channel group channels` request private extension.
@interface PNChannelGroupFetchRequest ()


#pragma mark - Properties

/// Name of the channel group for which list of registered channels should be retrieved.
@property(copy, nullable, nonatomic) NSString *channelGroup;

/// Type of channel group audit operation.
@property(assign, nonatomic) PNOperationType operation;


#pragma mark - Initialization and Configuration

/// Initialize `list channel group channels` request.
///
/// - Parameters:
///   - channelGroup: Name of the channel group for which list of registered channels should be retrieved.
///   - operation: Type of channel group audit operation.
/// - Returns: Initialized `list channel group channels` request.
- (instancetype)initWithChannelGroup:(nullable NSString *)channelGroup operation:(PNOperationType)operation;

#pragma mark -

@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNChannelGroupFetchRequest


#pragma mark - Properties

- (NSDictionary *)query {
    NSMutableDictionary *query = [([super query] ?: @{}) mutableCopy];
    
    if (self.arbitraryQueryParameters) [query addEntriesFromDictionary:self.arbitraryQueryParameters];
    
    return query.count ? query : nil;
}

- (NSString *)path {
    return PNStringFormat(@"/v1/channel-registration/sub-key/%@/channel-group%@",
                          self.subscribeKey, self.channelGroup.length ? PNStringFormat(@"/%@", self.channelGroup) : @"");
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestChannelGroups {
    return [[self alloc] initWithChannelGroup:nil operation:PNChannelGroupsOperation];
}

+ (instancetype)requestWithChannelGroup:(NSString *)channelGroup {
    return [[self alloc] initWithChannelGroup:channelGroup operation:PNChannelsForGroupOperation];
}

- (instancetype)initWithChannelGroup:(NSString *)channelGroup operation:(PNOperationType)operation {
    if ((self = [super init])) {
        _channelGroup = [channelGroup copy];
        _operation = operation;
    }
    
    return self;
}


#pragma mark - Prepare

- (PNError *)validate {
    if (self.channelGroup.length == 0 && self.operation != PNChannelGroupsOperation) {
        return [self missingParameterError:@"channelGroup" forObjectRequest:@"PNChannelGroupListRequest"];
    }
    
    return nil;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    if (self.arbitraryQueryParameters) dictionary[@"arbitraryQueryParameters"] = self.arbitraryQueryParameters;
    if (self.channelGroup) dictionary[@"channelGroup"] = self.channelGroup;
    
    return dictionary;
}

#pragma mark -

@end
