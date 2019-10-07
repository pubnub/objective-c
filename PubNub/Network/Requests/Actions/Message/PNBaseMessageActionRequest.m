/**
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNBaseMessageActionRequest+Private.h"
#import "PNRequest+Private.h"
#import "PNErrorCodes.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNBaseMessageActionRequest ()


#pragma mark - Information

/**
 * @brief Name of channel in which target \c message is stored.
 */
@property (nonatomic, copy) NSString *channel;

/**
 * @brief Timetoken (\b PubNub's high precision timestamp) of \c message for which \c action should
 * be managed.
 */
@property (nonatomic, strong) NSNumber *messageTimetoken;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNBaseMessageActionRequest


#pragma mark - Information

- (PNRequestParameters *)requestParameters {
    PNRequestParameters *parameters = [super requestParameters];
    
    if (self.parametersError) {
        return parameters;
    }
    
    [parameters addPathComponent:self.channel forPlaceholder:@"{channel}"];
    [parameters addPathComponent:self.messageTimetoken.stringValue
                  forPlaceholder:@"{message-timetoken}"];
    
    return parameters;
}


#pragma mark - Initialization & Configuration

- (instancetype)initWithChannel:(NSString *)channel messageTimetoken:(NSNumber *)messageTimetoken {
    if ((self = [super init])) {
        _messageTimetoken = messageTimetoken;
        _channel = [channel copy];
        
        if (!channel.length) {
            self.parametersError = [self missingParameterError:@"channel"
                                              forObjectRequest:@"Message action"];
        } else if (messageTimetoken.unsignedIntegerValue == 0) {
            self.parametersError = [self missingParameterError:@"messageTimetoken"
                                              forObjectRequest:@"Message action"];
        }
    }
    
    return self;
}

#pragma mark -


@end
