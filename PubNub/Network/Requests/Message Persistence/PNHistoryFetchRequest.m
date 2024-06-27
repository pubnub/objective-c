#import "PNHistoryFetchRequest+Private.h"
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

/// Whether request has been created to fetch history for multiple channels or not.
///
/// > Important: If set to `YES` requst will use `v3` `Message Persistence` REST API.
@property(assign, nonatomic) BOOL multipleChannels;


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
    if (self.multipleChannels) return PNHistoryForChannelsOperation;
    return self.includeMessageActions ? PNHistoryWithActionsOperation : PNHistoryOperation;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [([super query] ?: @{}) mutableCopy];
    PNOperationType operation = self.operation;

    NSNumber *startDate = self.start;
    NSNumber *endDate = self.end;
    
    if (startDate && endDate && [startDate compare:endDate] == NSOrderedDescending) {
        NSNumber *_startDate = startDate;
        startDate = endDate;
        endDate = _startDate;
    }

    NSString *limitQueryKeyName = self.multipleChannels ? @"max" : @"count";
    NSUInteger defaultLimit = self.multipleChannels ? 25 : 100;

    if (operation == PNHistoryForChannelsOperation && self.channels.count == 1) defaultLimit = 100;
    NSUInteger limitValue = defaultLimit;

    if (self.limit > 0) limitValue = MIN(self.limit, defaultLimit);

    if (operation == PNHistoryWithActionsOperation) {
        limitValue = self.limit;
        limitQueryKeyName = @"max";
    }

    if (self.multipleChannels) {
        if (self.limit > 0 || (operation != PNHistoryWithActionsOperation && self.channels.count == 1)) {
            query[limitQueryKeyName] = @(limitValue).stringValue;
        }
    } else if (self.limit > 0) query[limitQueryKeyName] = @(limitValue).stringValue;


    if (startDate) query[@"start"] = [PNNumber timeTokenFromNumber:startDate].stringValue;
    if (endDate) query[@"end"] = [PNNumber timeTokenFromNumber:endDate].stringValue;
    if (operation == PNHistoryOperation && self.reverse) query[@"reverse"] = @"true";
    if (self.includeMetadata) query[@"include_meta"] = @"true";

    if (self.multipleChannels || operation == PNHistoryWithActionsOperation) {
        query[@"include_message_type"] = self.includeMessageType ? @"true" : @"false";
        query[@"include_uuid"] = self.includeUUID ? @"true" : @"false";
    }

    if (!self.multipleChannels && self.includeTimeToken) query[@"include_token"] = @"true";
    if (self.arbitraryQueryParameters) [query addEntriesFromDictionary:self.arbitraryQueryParameters];
    
    return query;
}

- (NSString *)path {
    return PNStringFormat(@"/%@/history%@/sub-key/%@/channel/%@",
                          self.operation == PNHistoryOperation ? @"v2" : @"v3",
                          self.includeMessageActions ? @"-with-actions" : @"",
                          self.subscribeKey,
                          [PNChannel namesForRequest:self.channels]);
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithChannel:(NSString *)channel {
    PNHistoryFetchRequest *request = [self requestWithChannels:(channel ? @[channel] : @[])];
    request.multipleChannels = NO;

    return request;
}

+ (instancetype)requestWithChannels:(NSArray<NSString *> *)channels {
    return [[self alloc] initWithChannels:channels];
}

- (instancetype)initWithChannels:(NSArray<NSString *> *)channels {
    if ((self = [super init])){
        _channels = [channels copy];
        _includeMessageType = YES;
        _multipleChannels = YES;
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
    if (self.multipleChannels && self.includeMessageActions) {
        NSDictionary *userInfo = PNErrorUserInfo(
            @"Request parameters error",
            @"PNHistoryFetchRequest's 'includeMessageActions' can't be used with multiple channels.",
            @"Use +requestWithChannel: or disable 'includeMessageActions'.",
            nil
        );

        return [PNError errorWithDomain:PNAPIErrorDomain code:PNAPIErrorUnacceptableParameters userInfo:userInfo];
    } else if (!self.multipleChannels && self.channels.count == 0) {
        return [self missingParameterError:@"channel" forObjectRequest:@"PNHistoryFetchRequest"];
    } else if (self.multipleChannels && self.channels.count == 0) {
        return [self missingParameterError:@"channels" forObjectRequest:@"PNHistoryFetchRequest"];
    }
    
    return nil;
}



#pragma mark -


@end
