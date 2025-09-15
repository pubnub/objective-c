#import "PNHereNowRequest.h"
#import "PNTransportRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Presence` request private extension.
@interface PNHereNowRequest ()


#pragma mark - Properties


/// List of channel groups for which here now information should be received.
@property(copy, nonatomic) NSArray<NSString *> *channelGroups;

/// List of channels for which here now information should be received.
@property(copy, nonatomic) NSArray<NSString *> *channels;

/// Type of request operation.
///
/// One of PubNub REST API endpoints or third-party endpoint.
@property (assign, nonatomic) PNOperationType operation;


#pragma mark - Initialization and Configuration

/// Initialize `Presence` request of specific operation type.
///
/// - Parameter operation: Type of presence request which should be performed.
/// - Returns: Initialized `Presence` request.
- (instancetype)initWithOperation:(PNOperationType)operation;

#pragma -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNHereNowRequest


#pragma mark - Properties

- (NSDictionary *)query {
    NSMutableDictionary *query = [([super query] ?: @{}) mutableCopy];
    query[@"disable_uuids"] = @"1";
    query[@"state"] = @"0";
    
    if (self.verbosityLevel == PNHereNowUUID || self.verbosityLevel == PNHereNowState) {
        if (self.verbosityLevel == PNHereNowState) query[@"state"] = @"1";
        query[@"disable_uuids"] = @"0";
    }
    
    if (self.operation == PNHereNowForChannelGroupOperation) {
        query[@"channel-group"] = [self.channelGroups componentsJoinedByString:@","];
    }
    
    if (self.arbitraryQueryParameters) [query addEntriesFromDictionary:self.arbitraryQueryParameters];
    
    return query;
}

- (NSString *)path {
    if (self.operation == PNHereNowGlobalOperation) return PNStringFormat(@"/v2/presence/sub-key/%@", self.subscribeKey);
    
    return PNStringFormat(@"/v2/presence/sub-key/%@/channel/%@",
                          self.subscribeKey,
                          [PNChannel namesForRequest:self.channels defaultString:@","]);
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestForChannelGroups:(NSArray<NSString *> *)channelGroups {
    PNHereNowRequest *request = [[self alloc] initWithOperation:PNHereNowForChannelGroupOperation];
    request.verbosityLevel = PNHereNowState;
    request.channelGroups = [channelGroups copy];
    
    return request;
}

+ (instancetype)requestForChannels:(NSArray<NSString *> *)channels {
    PNHereNowRequest *request = [[self alloc] initWithOperation:PNHereNowForChannelOperation];
    request.verbosityLevel = PNHereNowState;
    request.channels = [channels copy];
    
    return request;
}

+ (instancetype)requestGlobal {
    PNHereNowRequest *request = [[self alloc] initWithOperation:PNHereNowGlobalOperation];
    request.verbosityLevel = PNHereNowState;

    return request;
}

- (instancetype)initWithOperation:(PNOperationType)operation {
    if ((self = [super init])) _operation = operation;
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    return nil;
}


#pragma mark - Prepare

- (PNError *)validate {
    if (self.operation == PNHereNowGlobalOperation) return nil;
    else if (self.operation == PNHereNowForChannelOperation && self.channels.count == 0) {
        return [self missingParameterError:@"channels" forObjectRequest:@"Channel presence"];
    } else if (self.operation == PNHereNowForChannelGroupOperation && self.channelGroups.count == 0) {
        return [self missingParameterError:@"channelGroup" forObjectRequest:@"Channel group presence"];
    }
    
    return nil;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"channels": self.channels.count ? self.channels : @",",
        @"verbosityLevel": @(self.verbosityLevel)
    }];
    
    if (self.arbitraryQueryParameters) dictionary[@"arbitraryQueryParameters"] = self.arbitraryQueryParameters;
    if (self.channelGroups) dictionary[@"channelGroups"] = self.channelGroups;
    
    return dictionary;
}

#pragma mark -


@end
