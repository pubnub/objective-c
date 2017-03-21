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
    
    DDLogAPICall(self.logger, @"<PubNub::API> Time token request.");
    __weak __typeof(self) weakSelf = self;
    [self processOperation:PNTimeOperation withParameters:[PNRequestParameters new]
           completionBlock:^(PNResult *result, PNStatus *status) {
               
        // Silence static analyzer warnings.
        // Code is aware about this case and at the end will simply call on 'nil' object method.
        // In most cases if referenced object become 'nil' it mean what there is no more need in
        // it and probably whole client instance has been deallocated.
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wreceiver-is-weak"
        if (status.isError) { status.retryBlock = ^{ [weakSelf timeWithCompletion:block]; }; }
        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
        #pragma clang diagnostic pop
    }];
}

#pragma mark -


@end
