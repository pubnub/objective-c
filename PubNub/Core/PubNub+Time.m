/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PubNub+Time.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNLogMacro.h"
#import "PNStatus.h"


#pragma mark Interface implementation

@implementation PubNub (Time)


#pragma mark - Time token request

- (void)timeWithCompletion:(PNTimeCompletionBlock)block {
    
    DDLogAPICall([[self class] ddLogLevel], @"<PubNub::API> Time token request.");
    __weak __typeof(self) weakSelf = self;
    [self processOperation:PNTimeOperation withParameters:[PNRequestParameters new]
           completionBlock:^(PNResult * _Nullable result, PNStatus * _Nullable status) {
               
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
