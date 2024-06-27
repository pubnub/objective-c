#import "PNPresenceStateSetRequest.h"
#import "PNTransportRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Set presence state` request private extension.
@interface PNPresenceStateSetRequest ()


#pragma mark - Properties

/// Unique identifier of the user with which `state` should be associated.
@property(copy, nonatomic) NSString *userId;


#pragma mark - Initialization and Configuration

/// Initialize `Set presence state` request.
///
/// - Parameter userId: Unique identifier of the user with which `state` should be associated.
/// - Returns: Initialized `Set presence state` request.
- (instancetype)initWithUserId:(NSString *)userId;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNPresenceStateSetRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNSetStateOperation;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [([super query] ?: @{}) mutableCopy];
    
    query[@"state"] = [PNJSON JSONStringFrom:self.state withError:NULL] ?: @"{}";
    
    if (self.channelGroups.count) query[@"channel-group"] = [self.channelGroups componentsJoinedByString:@","];
    if (self.arbitraryQueryParameters) [query addEntriesFromDictionary:self.arbitraryQueryParameters];
    
    return query;
}


- (NSString *)path {
    return PNStringFormat(@"/v2/presence/sub-key/%@/channel/%@/uuid/%@/data",
                          self.subscribeKey,
                          [PNChannel namesForRequest:self.channels defaultString:@","],
                          [PNString percentEscapedString:self.userId]);
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithUserId:(NSString *)userId{
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

#pragma mark -


@end
