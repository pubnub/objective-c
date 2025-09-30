#import "PNPresenceStateFetchRequest.h"
#import "PNTransportRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Fetch presence state` request private extension.
@interface PNPresenceStateFetchRequest ()


#pragma mark - Properties

/// Unique identifier of the user for which associated state should be retrieved.
@property(copy, nonatomic) NSString *userId;


#pragma mark - Initialization and Configuration

/// Initialize `Fetch presence state` request.
///
/// - Parameter userId: Unique identifier of the user for which associated state should be retrieved.
/// - Returns: Initialized `Fetch presence state` request.
- (instancetype)initWithUserId:(NSString *)userId;

#pragma mark -


@end

NS_ASSUME_NONNULL_END



#pragma mark - Interface implementation

@implementation PNPresenceStateFetchRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNGetStateOperation;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [([super query] ?: @{}) mutableCopy];
    
    if (self.channelGroups.count) query[@"channel-group"] = [self.channelGroups componentsJoinedByString:@","];
    if (self.arbitraryQueryParameters) [query addEntriesFromDictionary:self.arbitraryQueryParameters];
    
    return query;
}

- (NSString *)path {
    return PNStringFormat(@"/v2/presence/sub-key/%@/channel/%@/uuid/%@",
                          self.subscribeKey,
                          [PNChannel namesForRequest:self.channels defaultString:@","],
                          [PNString percentEscapedString:self.userId]);
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithUserId:(NSString *)userId {
    return [[self alloc] initWithUserId:userId];
}

- (instancetype)initWithUserId:(NSString *)userId {
    if ((self = [super init])) _userId = [userId copy];
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    return nil;
}


#pragma mark - Prepare

- (PNError *)validate {
    if (self.userId.length == 0) return [self missingParameterError:@"userId" forObjectRequest:@"Set presence state"];
    if (self.channels.count == 0 && self.channelGroups.count == 0) {
        return [self missingParameterError:@"channels" forObjectRequest:@"Set presence state"];
    }
    
    return nil;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"channels": self.channels.count ? self.channels : @",",
        @"userId": self.userId ?: @"missing",
    }];
    
    if (self.arbitraryQueryParameters) dictionary[@"arbitraryQueryParameters"] = self.arbitraryQueryParameters;
    if (self.channelGroups) dictionary[@"channelGroups"] = self.channelGroups;
    
    return dictionary;
}

#pragma mark -


@end
