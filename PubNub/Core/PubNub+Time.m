/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PubNub+Time.h"
#import "PNAPICallBuilder+Private.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNLogMacro.h"
#import "PNStatus.h"


#pragma mark Interface implementation

@implementation PubNub (Time)


#pragma mark - API Builder support

- (PNTimeAPICallBuilder *(^)(void))time {
    
    PNTimeAPICallBuilder *builder = nil;
    builder = [PNTimeAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags, 
                                                                NSDictionary *parameters) {
                                         
        [self timeWithCompletion:parameters[@"block"]];
    }];
    
    return ^PNTimeAPICallBuilder *{ return builder; };
}


#pragma mark - Time token request

- (void)timeWithCompletion:(PNTimeCompletionBlock)block {
    
    PNLogAPICall(self.logger, @"<PubNub::API> Time token request.");
    __weak __typeof(self) weakSelf = self;
    [self processOperation:PNTimeOperation withParameters:[PNRequestParameters new]
           completionBlock:^(PNResult *result, PNStatus *status) {
        if (status.isError) { status.retryBlock = ^{ [weakSelf timeWithCompletion:block]; }; }
        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
    }];
}

#pragma mark -


@end
