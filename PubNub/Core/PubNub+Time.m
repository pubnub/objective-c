/**
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PubNub+Time.h"
#import "PNAPICallBuilder+Private.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNLogMacro.h"
#import "PNStatus.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PubNub (SubscribeProtected)


#pragma mark - Time token request

/**
 * @brief Request current time from \b PubNub service servers.
 *
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 * @param block Time request process results handling block.
 *
 * @since 4.8.2
 */
- (void)timeWithQueryParameters:(nullable NSDictionary *)queryParameters
                     completion:(PNTimeCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (Time)


#pragma mark - API Builder support

- (PNTimeAPICallBuilder * (^)(void))time {
    
    PNTimeAPICallBuilder *builder = nil;
    builder = [PNTimeAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags, 
                                                                NSDictionary *parameters) {
        
        [self timeWithQueryParameters:parameters[@"queryParam"] completion:parameters[@"block"]];
    }];
    
    return ^PNTimeAPICallBuilder * {
        return builder;
    };
}


#pragma mark - Time token request

- (void)timeWithCompletion:(PNTimeCompletionBlock)block {
    
    [self timeWithQueryParameters:nil completion:block];
}

- (void)timeWithQueryParameters:(NSDictionary *)queryParameters
                     completion:(PNTimeCompletionBlock)block {

    PNLogAPICall(self.logger, @"<PubNub::API> Time token request.");

    PNRequestParameters *parameters = [PNRequestParameters new];

    [parameters addQueryParameters:queryParameters];

    __weak __typeof(self) weakSelf = self;
    [self processOperation:PNTimeOperation
            withParameters:[PNRequestParameters new]
           completionBlock:^(PNResult *result, PNStatus *status) {
               
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf timeWithQueryParameters:queryParameters completion:block];
            };
        }

        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
    }];
}

#pragma mark -


@end
