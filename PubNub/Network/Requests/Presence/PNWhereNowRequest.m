#import "PNWhereNowRequest.h"
#import "PNTransportRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `User presence` request private extension.
@interface PNWhereNowRequest ()


#pragma mark - Properties

/// Unique identifier of the user for which presence information should be retrieved.
@property(copy, nonatomic) NSString *userId;


#pragma mark - Initialization and Configuration

/// Initialize `User presence` request.
///
/// - Parameter userId: Unique identifier of the user for which presence information should be retrieved.
/// - Returns: Initialized `User presence` request.
- (instancetype)initForUserId:(NSString *)userId;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNWhereNowRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNWhereNowOperation;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [([super query] ?: @{}) mutableCopy];
    
    if (self.arbitraryQueryParameters) [query addEntriesFromDictionary:self.arbitraryQueryParameters];
    
    return query;
}

- (NSString *)path {
    return PNStringFormat(@"/v2/presence/sub-key/%@/uuid/%@",
                          self.subscribeKey, [PNString percentEscapedString:self.userId]);
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestForUserId:(NSString *)userId {
    return [[self alloc] initForUserId:userId];
}

- (instancetype)initForUserId:(NSString *)userId {
    if ((self = [super init])) _userId = [userId copy];
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    return nil;
}


#pragma mark - Prepare

- (PNError *)validate {
    if (self.userId.length == 0) return [self missingParameterError:@"userId" forObjectRequest:@"User presence"];
    return nil;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"userId": self.userId ?: @"missing"
    }];
    
    if (self.arbitraryQueryParameters) dictionary[@"arbitraryQueryParameters"] = self.arbitraryQueryParameters;
    
    return dictionary;
}

#pragma mark -


@end
