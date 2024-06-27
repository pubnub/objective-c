#import "PNFetchMessageActionsRequest.h"
#import "PNBaseRequest+Private.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Fetch message actions` request private extension.
@interface PNFetchMessageActionsRequest ()


#pragma mark - Properties

/// Name of channel from which list of `message actions` should be retrieved.
@property(copy, nonatomic) NSString *channel;


#pragma mark - Initialization and Configuration

/// Initialize `Fetch message actions` request.
///
/// - Parameter channel: Name of channel from which list of `message actions` should be retrieved.
/// - Returns: Initialized `fetch messages actions` request.
- (instancetype)initWithChannel:(NSString *)channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNFetchMessageActionsRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNFetchMessagesActionsOperation;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [NSMutableDictionary new];
    
    if (self.limit > 0) query[@"limit"] = @(self.limit);
    if (self.start) query[@"start"] = self.start;
    if (self.end) query[@"end"] = self.end;
    
    return query.count ? query : nil;
}

- (NSString *)path {
    return PNStringFormat(@"/v1/message-actions/%@/channel/%@",
                          self.subscribeKey, [PNString percentEscapedString:self.channel]);
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithChannel:(NSString *)channel {
    return [[self alloc] initWithChannel:channel];
}

- (instancetype)initWithChannel:(NSString *)channel {
    if ((self = [super init])) {
        _channel = [channel copy];
        _limit = 100;
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    return nil;
}


#pragma mark - Prepare

- (PNError *)validate {
    if (self.channel.length == 0) {
        return [self missingParameterError:@"channel" forObjectRequest:@"PNFetchMessageActionsRequest"];
    }

    return nil;
}

#pragma mark -


@end
