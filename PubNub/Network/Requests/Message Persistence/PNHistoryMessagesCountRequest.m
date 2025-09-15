#import "PNHistoryMessagesCountRequest.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"
#import "PNFunctions.h"
#import "PNHelpers.h"
#import "PNError.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNHistoryMessagesCountRequest ()


#pragma mark - Properties


#pragma mark - Initialization and Configuration

/// Initialize `Fetch messages count` request.
///
/// - Parameters:
///   - channels: List of channel names for which persist messages count should be fetched.
///   - timetokens: List with single or multiple timetokens, where each timetoken position in correspond to target
///   `channel` location in channel names list.
/// - Returns: Initialized `Fetch messages count` request.
- (instancetype)initWithChannels:(NSArray<NSString *> *)channels timetokens:(NSArray<NSNumber *> *)timetokens;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNHistoryMessagesCountRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNMessageCountOperation;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [([super query] ?: @{}) mutableCopy];
    
    if (self.timetokens.count == 1) {
        query[@"timetoken"] = [PNNumber timeTokenFromNumber:self.timetokens.firstObject].stringValue;
    } else if (self.timetokens.count > 1) {
        NSMutableArray *pubNubTimetokens = [NSMutableArray arrayWithCapacity:self.timetokens.count];
        
        for (NSNumber *timetoken in self.timetokens) {
            [pubNubTimetokens addObject:[PNNumber timeTokenFromNumber:timetoken].stringValue];
        }
        
        query[@"channelsTimetoken"] = [pubNubTimetokens componentsJoinedByString:@","];
    }
    
    return query;
}

- (NSString *)path {
    return PNStringFormat(@"/v3/history/sub-key/%@/message-counts/%@",
                          self.subscribeKey, [PNChannel namesForRequest:self.channels]);
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithChannels:(NSArray<NSString *> *)channels timetokens:(NSArray<NSNumber *> *)timetokens {
    return [[self alloc] initWithChannels:channels timetokens:timetokens];
}

- (instancetype)initWithChannels:(NSArray<NSString *> *)channels timetokens:(NSArray<NSNumber *> *)timetokens {
    if ((self = [super init])) {
        _timetokens = [timetokens copy];
        _channels = [channels copy];
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    
    return nil;
}


#pragma mark - Prepare

- (PNError *)validate {
    if (self.channels.count == 0) return [self missingParameterError:@"channels" forObjectRequest:@"Messages count"];
    if (self.timetokens.count == 0) return [self missingParameterError:@"timetokens" forObjectRequest:@"Messages count"];
    if ((self.channels.count == 1 && self.timetokens.count > 1) ||
        (self.channels.count > 1 && self.timetokens.count > 1 && self.channels.count != self.timetokens.count)) {
        NSDictionary *userInfo = PNErrorUserInfo(@"Parameters validation error", 
                                                 PNStringFormat(@"Number of channels (%@) doesn't match number of "
                                                                "timetokens (%@)", @(self.channels.count), @(self.timetokens.count)),
                                                 @"Make sure to pass proper number of elements into each array.",
                                                 nil);
        
        return [PNError errorWithDomain:PNAPIErrorDomain code:PNAPIErrorUnacceptableParameters userInfo:userInfo];
    }
    
    return nil;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"timetokens": self.timetokens ?: @"missing",
        @"channels": self.channels ?: @"missing"
    }];
    
    if (self.arbitraryQueryParameters) dictionary[@"arbitraryQueryParameters"] = self.arbitraryQueryParameters;
    
    return dictionary;
}

#pragma mark -


@end
