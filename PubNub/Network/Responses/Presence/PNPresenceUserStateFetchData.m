#import "PNPresenceUserStateFetchData+Private.h"
#import <PubNub/PNCodable.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Fetch user presence state` request response private extension.
@interface PNPresenceUserStateFetchData () <PNCodable>


#pragma mark - Properties

/// Per-channel or single channel presence state information.
@property(strong, nullable, nonatomic) NSDictionary<NSString *, id> *presenceState;

/// Name of the channel for which user's state has been requested.
///
/// > Note: This value will be `nil` if state requested for multiple channels / channel group.
@property(strong, nullable, nonatomic) NSString *channel;


#pragma mark - Initialization and Configuration

/// Initialize user's presence information object.
///
/// - Parameters:
///   - state: Per-channel or single channel user's presence state.
///   - channel: Name of the channel for which user's state has been requested.
/// - Returns: Initialized user's presence information object.
- (instancetype)initWithPresenceState:(NSDictionary *)state forChannel:(nullable NSString *)channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNPresenceUserStateFetchData


#pragma mark - Properties

- (NSDictionary<NSString *,id> *)state {
    return self.channel ? self.presenceState : nil;
}

- (NSDictionary<NSString *,id> *)channels {
    return !self.channel ? self.presenceState : nil;
}


#pragma mark - Initialization and Configuration

- (instancetype)initWithPresenceState:(NSDictionary *)state forChannel:(nullable NSString *)channel {
    if ((self = [super init])) {
        _presenceState = state;
        _channel = channel;
    }

    return self;
}

- (instancetype)initObjectWithCoder:(id<PNDecoder>)coder {
    NSDictionary *payload = [coder decodeObjectOfClass:[NSDictionary class]];
    if (![payload isKindOfClass:[NSDictionary class]] || !payload[@"payload"]) return nil;

    return [self initWithPresenceState:!payload[@"channel"] ? payload[@"payload"][@"channels"] : payload[@"payload"]
                            forChannel:payload[@"channel"]];
}

#pragma mark -

@end
