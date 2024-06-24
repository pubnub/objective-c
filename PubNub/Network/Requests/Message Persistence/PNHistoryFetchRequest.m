#import "PNHistoryFetchRequest.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportResponse.h"
#import "PNFunctions.h"
#import "PNHelpers.h"
#import "PNError.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Fetch history` request private extension.
@interface PNHistoryFetchRequest ()

#pragma mark - Properties

///  List of channel names for which events should be pulled out from storage.
///
///  > Notes: Maximum 500 channels.
@property(copy, nonatomic) NSArray<NSString *> *channels;


#pragma mark - Initialization and Constructor

/// Initialize `Fetch history` request.
///
/// - Parameter channels: List of channel names for which events should be pulled out from storage. Maximum 500 channels.
/// - Returns: Initialized `Fetch history` request.
- (instancetype)initWithChannels:(NSArray<NSString *> *)channels;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNHistoryFetchRequest


#pragma mark - Properies

- (PNOperationType)operation {
    return self.includeMessageActions ? PNHistoryWithActionsOperation : PNHistoryForChannelsOperation;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [([super query] ?: @{}) mutableCopy];

    NSNumber *startDate = self.start;
    NSUInteger limit = self.max;
    NSNumber *endDate = self.end;
    
    if (startDate && endDate && [startDate compare:endDate] == NSOrderedDescending) {
        NSNumber *_startDate = startDate;
        startDate = endDate;
        endDate = _startDate;
    }
    
    NSUInteger defaultLimit = !self.includeMessageActions && self.channels.count == 1 ? 100 : 25;
    NSUInteger limitValue = defaultLimit;
    
    query[@"include_message_type"] = self.includeMessageType ? @"true" : @"false";
    query[@"include_uuid"] = self.includeUUID ? @"true" : @"false";
    
    if (limit > 0) limitValue = MIN(limit, defaultLimit);
    if (self.includeMessageActions && limit > 0) limitValue = limit;
    if (startDate) query[@"start"] = [PNNumber timeTokenFromNumber:startDate].stringValue;
    if (endDate) query[@"end"] = [PNNumber timeTokenFromNumber:endDate].stringValue;
    if (self.reverse) query[@"reverse"] = @"true";
    if (self.includeMetadata) query[@"include_meta"] = @"true";
    if (limit > 0) query[@"max"] = [NSString stringWithFormat:@"%lu", limitValue];
    if (self.arbitraryQueryParameters) [query addEntriesFromDictionary:self.arbitraryQueryParameters];
    
    return query;
}

- (NSString *)path {
    return PNStringFormat(@"/v3/history%@/sub-key/%@/channel/%@",
                          self.includeMessageActions ? @"-with-actions" : @"",
                          self.subscribeKey,
                          [PNChannel namesForRequest:self.channels]);
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithChannels:(NSArray<NSString *> *)channels {
    return [[self alloc] initWithChannels:channels];
}

- (instancetype)initWithChannels:(NSArray<NSString *> *)channels {
    if ((self = [super init])){
        _channels = [channels copy];
        _includeMessageType = YES;
        _includeUUID = YES;
    }
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    
    return nil;
}


#pragma mark - Prepare

- (PNError *)validate {
    if (self.channels.count == 0) return [self missingParameterError:@"channels" forObjectRequest:@"Fetch history"];
    if (self.channels.count > 1 && self.includeMessageActions) {
        NSDictionary *userInfo = PNErrorUserInfo(@"Validation error",
                                                 @"Message actions can't be fetched for multiple channels",
                                                 @"Set only on channel in 'channels' or don't use 'includeMessageActions'.",
                                                 nil);
        return [PNError errorWithDomain:PNAPIErrorDomain code:PNAPIErrorUnacceptableParameters userInfo:userInfo];
    }
    
    return nil;
}



#pragma mark -


@end
