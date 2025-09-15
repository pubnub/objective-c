#import "PubNub+Time.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"

// Deprecated
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

/// **PubNub** `Time` API private extension.
@implementation PubNub (Time)


#pragma mark - Time token API builder interface (deprecated)

- (PNTimeAPICallBuilder * (^)(void))time {
    [self.logger warnWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNStringLogEntry entryWithMessage:@"Builder-based interface deprecated. Please use corresponding "
                "request-based interfaces."];
    }];
    
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

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNTimeResult *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Fetch service time success. Current "
                                                                         "timetoken: %@", result.result.data.timetoken)];
            }];
        }

        [self callBlock:block status:NO withResult:result.result andStatus:result.status];
    };
    
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNStringLogEntry entryWithMessage:@"Fetch service time."];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)timeWithCompletion:(PNTimeCompletionBlock)block {
    [self.logger warnWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNStringLogEntry entryWithMessage:@"This method deprecated. Please use "
                "'-timeWithRequest:completion:' method instead."];
    }];
    
    [self timeWithRequest:[PNTimeRequest new] completion:block];
}

#pragma mark -


@end
