#import "PNListFilesRequest.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `List files` request private extension.
@interface PNListFilesRequest ()


#pragma mark - Properties

/// Name of channel for which list of files should be fetched.
@property(copy, nonatomic) NSString *channel;


#pragma mark - Initialization and Configuration

/// Initialize `List files` request.
///
/// - Parameter channel: Name of channel for which files list should be retrieved.
/// - Returns: Initialized `list files` request.
- (instancetype)initWithChannel:(NSString *)channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNListFilesRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNListFilesOperation;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [NSMutableDictionary new];
    
    if (self.next.length) query[@"next"] = [PNString percentEscapedString:self.next];
    if (self.limit > 0) query[@"limit"] = @(MIN(self.limit, 100)).stringValue;
    
    if (self.arbitraryQueryParameters.count) [query addEntriesFromDictionary:self.arbitraryQueryParameters];
    
    return query.count ? query : nil;
}

- (NSString *)path {
    return PNStringFormat(@"/v1/files/%@/channels/%@/files",
                          self.subscribeKey,
                          [PNString percentEscapedString:self.channel]);
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithChannel:(NSString *)channel {
    return [[self alloc] initWithChannel:channel];
}

- (instancetype)initWithChannel:(NSString *)channel {
    if ((self = [super init])) _channel = [channel copy];
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}


#pragma mark - Prepare

- (PNError *)validate {
    if (self.channel.length == 0) return [self missingParameterError:@"channel" forObjectRequest:@"Request"];
    return nil;
}

#pragma mark -


@end
