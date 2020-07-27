/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNListFilesRequest.h"
#import "PNRequest+Private.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNListFilesRequest ()


#pragma mark - Information

/**
 * @brief Name of channel for which list of files should be fetched.
 */
@property (nonatomic, copy) NSString *channel;


#pragma mark - Initialization & Configuration

/**
 * @brief Configure \c list \c files request.
 *
 * @param channel Name of channel for which files list should be retrieved.
 *
 * @return Configured and ready to use \c list \c files request.
 */
- (instancetype)initWithChannel:(NSString *)channel;


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNListFilesRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNListFilesOperation;
}

- (PNRequestParameters *)requestParameters {
    PNRequestParameters *parameters = [super requestParameters];

    if (self.parametersError) {
        return parameters;
    }
    
    if (self.channel.length) {
        [parameters addPathComponent:[PNString percentEscapedString:self.channel]
                      forPlaceholder:@"{channel}"];
    } else {
        self.parametersError = [self missingParameterError:@"channel" forObjectRequest:@"Request"];
    }

    if (self.limit > 0) {
        [parameters addQueryParameter:@(MIN(self.limit, 100)).stringValue forFieldName:@"limit"];
    }

    if (self.next.length) {
        [parameters addQueryParameter:[PNString percentEscapedString:self.next]
                         forFieldName:@"next"];
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
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}

#pragma mark -


@end
