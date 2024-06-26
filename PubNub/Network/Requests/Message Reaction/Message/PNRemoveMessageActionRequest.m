#import "PNRemoveMessageActionRequest+Private.h"
#import "PNBaseMessageActionRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Remove message action` request private extension.
@interface PNRemoveMessageActionRequest ()


#pragma mark - Properties

/// `Message action` addition timetoken (**PubNub**'s high precision timestamp).
@property(strong, nonatomic) NSNumber *messageActionTimetoken;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNRemoveMessageActionRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNRemoveMessageActionOperation;
}

- (TransportMethod)httpMethod {
    return TransportDELETEMethod;
}

- (NSString *)path {
    return PNStringFormat(@"/v1/message-actions/%@/channel/%@/message/%@/action/%@",
                          self.subscribeKey,
                          [PNString percentEscapedString:self.channel],
                          self.messageTimetoken,
                          self.messageActionTimetoken);
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithChannel:(NSString *)channel messageTimetoken:(NSNumber *)messageTimetoken {
    return [[self alloc] initWithChannel:channel messageTimetoken:messageTimetoken];
}

+ (instancetype)requestWithChannel:(NSString *)channel 
                  messageTimetoken:(NSNumber *)messageTimetoken
                   actionTimetoken:(NSNumber *)actionTimetoken {
    PNRemoveMessageActionRequest *request = [[self alloc] initWithChannel:channel messageTimetoken:messageTimetoken];
    request.messageActionTimetoken = actionTimetoken;

    return request;
}


#pragma mark - Prepare

- (PNError *)validate {
    PNError *error = [super validate];
    if (error) return error;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (self.actionTimetoken.unsignedIntegerValue == 0 && self.messageActionTimetoken.unsignedIntegerValue == 0) {
        return [self missingParameterError:@"actionTimetoken" forObjectRequest:@"PNRemoveMessageActionRequest"];
    }
#pragma clang diagnostic pop
    
    return nil;
}

#pragma mark -


@end
