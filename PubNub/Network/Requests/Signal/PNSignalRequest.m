#import "PNSignalRequest.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Signal data` request private extension.
@interface PNSignalRequest ()


#pragma mark - Properties

/// Data which has been prepared for signal.
@property(strong, nullable, nonatomic) NSString *preparedMessage;

/// Message which will be published.
///
/// Provided object will be serialized into JSON (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) string before
/// pushing to the **PubNub** network. If client has been configured with cipher key message will be encrypted as well.
@property(strong, nullable, nonatomic) id message;

/// Name of channel to which message should be published.
@property(copy, nonatomic) NSString *channel;


#pragma mark - Initialization and Configuration

/// Initialize `Signal data` request.
///
/// - Parameters:
///   - channel: Name of channel to which signal should be sent.
///   - signalData: Signal payload data.
/// - Returns: Initializded `signal data` request.
- (instancetype)initWithChannel:(NSString *)channel signal:(id)signalData;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSignalRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNSignalOperation;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [NSMutableDictionary new];

    if (self.arbitraryQueryParameters.count) [query addEntriesFromDictionary:self.arbitraryQueryParameters];

    return query.count ? query : nil;
}

- (NSString *)path {
    return PNStringFormat(@"/signal/%@/%@/0/%@/0/%@",
                          self.publishKey,
                          self.subscribeKey,
                          [PNString percentEscapedString:self.channel],
                          [PNString percentEscapedString:self.preparedMessage]);
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithChannel:(NSString *)channel signal:(id)signalData {
    return [[self alloc] initWithChannel:channel signal:signalData];
}

- (instancetype)initWithChannel:(NSString *)channel signal:(id)signalData {
    if ((self = [super init])) {
        _channel = [channel copy];
        _message = signalData;
    }

    return self;
}


#pragma mark - Prepare

- (PNError *)validate {
    PNError *error = nil;
    NSString *messageForPublish = [PNJSON JSONStringFrom:self.message withError:&error];

    if (!error && messageForPublish.length == 0) {
        return [self missingParameterError:@"message" forObjectRequest:@"Request"];
    } else if (error) {
        NSDictionary *userInfo = PNErrorUserInfo(
            @"Request parameters error",
            @"Message serialization did fail",
            @"Ensure that only JSON-compatible values used in 'message'.",
            error
        );
        
        return [PNError errorWithDomain:PNAPIErrorDomain code:PNAPIErrorUnacceptableParameters userInfo:userInfo];
    }

    self.preparedMessage = messageForPublish;

    return nil;
}

#pragma mark -

@end
