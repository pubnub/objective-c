#import "PubNub+Time.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"

// Deprecated
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

/// **PubNub** `Time` API private extension.
@implementation PubNub (Time)


#pragma mark - Time token API builder interdace (deprecated)

- (PNTimeAPICallBuilder * (^)(void))time {
    PNTimeAPICallBuilder *builder = nil;
    builder = [PNTimeAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags, NSDictionary *parameters) {
        PNTimeRequest *request = [PNTimeRequest new];
        request.arbitraryQueryParameters = parameters[@"queryParam"];

        [self timeWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNTimeAPICallBuilder * {
        return builder;
    };
}


#pragma mark - Time token request

- (void)timeWithRequest:(PNTimeRequest *)userRequest completion:(PNTimeCompletionBlock)handlerBlock {
    PNOperationDataParser *responseParser = [self parserWithResult:[PNTimeResult class] status:[PNErrorStatus class]];
    PNTimeCompletionBlock block = [handlerBlock copy];
    PNParsedRequestCompletionBlock handler;

    PNLogAPICall(self.logger, @"<PubNub::API> Time token request.");

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNTimeResult *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self timeWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self callBlock:block status:NO withResult:result.result andStatus:result.status];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)timeWithCompletion:(PNTimeCompletionBlock)block {
    [self timeWithRequest:[PNTimeRequest new] completion:block];
}

#pragma mark -


@end
