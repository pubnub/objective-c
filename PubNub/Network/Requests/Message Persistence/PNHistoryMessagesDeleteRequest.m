#import "PNHistoryMessagesDeleteRequest.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Delete messages` request private extension.
@interface PNHistoryMessagesDeleteRequest ()

#pragma mark - Properties

/// Name of the channel from which events should be removed.
@property(copy, nonatomic) NSString *channel;


#pragma mark - Initialization and Constructor

/// Initialize `Delete messages` request.
///
/// - Parameter channel: Name of the channel from which events should be removed.
/// - Returns: Initialized `Delete messages` request.
- (instancetype)initWithChannel:(NSString *)channel;


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNHistoryMessagesDeleteRequest


#pragma mark - Parameters

- (TransportMethod)httpMethod {
    return TransportDELETEMethod;
}

- (PNOperationType)operation {
    return PNDeleteMessageOperation;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [([super query] ?: @{}) mutableCopy];
    NSNumber *startDate = self.start;
    NSNumber *endDate = self.end;
    
    if (startDate && endDate && [startDate compare:endDate] == NSOrderedDescending) {
        NSNumber *_startDate = startDate;
        startDate = endDate;
        endDate = _startDate;
    }
    
    if (startDate) query[@"start"] = [PNNumber timeTokenFromNumber:startDate].stringValue;
    if (endDate) query[@"end"] = [PNNumber timeTokenFromNumber:endDate].stringValue;
    
    return query;
}

- (NSString *)path {
    return PNStringFormat(@"/v3/history/sub-key/%@/channel/%@",
                          self.subscribeKey, [PNString percentEscapedString:self.channel]);
}


#pragma mark - Initialization and Constructor

+ (instancetype)requestWithChannel:(NSString *)channels {
    return [[self alloc] initWithChannel:channels];
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
    if (self.channel.length == 0) return [self missingParameterError:@"channel" forObjectRequest:@"Delete messages"];
    return nil;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"channel": self.channel ?: @"missing"
    }];
    
    if (self.arbitraryQueryParameters) dictionary[@"arbitraryQueryParameters"] = self.arbitraryQueryParameters;
    if (self.start) dictionary[@"start"] = self.start;
    if (self.end) dictionary[@"end"] = self.end;
    
    return dictionary;
}

#pragma mark -


@end
