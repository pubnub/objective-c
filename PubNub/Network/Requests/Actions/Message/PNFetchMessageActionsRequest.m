/**
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNFetchMessageActionsRequest.h"
#import "PNRequest+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNFetchMessageActionsRequest ()


#pragma mark - Information

/**
 * @brief Name of channel from which list of \c message \c actions should be retrieved.
 */
@property (nonatomic, copy) NSString *channel;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c fetch \c message \c actions request.
 *
 * @param channel Name of channel from which list of \c message \c actions should be retrieved.
 *
 * @return Initialized and ready to use \c fetch \c message \c actions request.
 */
- (instancetype)initWithChannel:(NSString *)channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNFetchMessageActionsRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNFetchMessagesActionsOperation;
}

- (NSString *)httpMethod {
    return @"GET";
}

- (PNRequestParameters *)requestParameters {
    PNRequestParameters *parameters = [super requestParameters];
    
    if (self.parametersError) {
        return parameters;
    }
    
    [parameters addPathComponent:self.channel forPlaceholder:@"{channel}"];
    
    if (self.limit > 0) {
        [parameters addQueryParameter:@(self.limit).stringValue forFieldName:@"limit"];
    }
    
    if (self.start) {
        [parameters addQueryParameter:self.start.stringValue forFieldName:@"start"];
    }
    
    if (self.end) {
        [parameters addQueryParameter:self.end.stringValue forFieldName:@"end"];
    }
    
    return parameters;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithChannel:(NSString *)channel {
    return [[self alloc] initWithChannel:channel];
}

- (instancetype)initWithChannel:(NSString *)channel {
    if ((self = [super init])) {
        _channel = [channel copy];
        
        if (!channel.length) {
            self.parametersError = [self missingParameterError:@"channel"
                                              forObjectRequest:@"Message action"];
        }
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    
    return nil;
}

#pragma mark -


@end
