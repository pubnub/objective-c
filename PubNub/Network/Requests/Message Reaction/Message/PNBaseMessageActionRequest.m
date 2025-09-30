#import "PNBaseMessageActionRequest+Private.h"
#import "PNTransportRequest+Private.h"
#import "PNBaseRequest+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General request for all `Message Action` API endpoints private extension.
@interface PNBaseMessageActionRequest ()


#pragma mark - Properties

/// Timetoken (**PubNub**'s high precision timestamp) of `message` for which `action` should be managed.
@property (nonatomic, strong) NSNumber *messageTimetoken;

/// Name of channel in which target `message` is stored.
@property (copy, nonatomic) NSString *channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNBaseMessageActionRequest


#pragma mark - Properties

- (PNOperationType)operation {
    @throw [NSException exceptionWithName:@"PNNotImplemented"
                                   reason:@"'operation' not implemented by subclass."
                                 userInfo:nil];
}


#pragma mark - Initialization & Configuration

- (instancetype)initWithChannel:(NSString *)channel messageTimetoken:(NSNumber *)messageTimetoken {
    if ((self = [super init])) {
        _messageTimetoken = messageTimetoken;
        _channel = [channel copy];
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
        return [self missingParameterError:@"channel" forObjectRequest:NSStringFromClass([self class])];
    } else if (self.messageTimetoken.unsignedIntegerValue == 0) {
        return [self missingParameterError:@"messageTimetoken" forObjectRequest:NSStringFromClass([self class])];
    }
    
    return nil;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    return @{ @"channel": self.channel ?: @"missing", @"messageTimetoken": self.messageTimetoken ?: @"missing" };
}

#pragma mark -


@end
