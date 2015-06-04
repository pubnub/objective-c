/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+Time.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus.h"


#pragma mark - Interface implementation

@implementation PubNub (Time)


#pragma mark - Time token request

- (void)timeWithCompletion:(PNTimeCompletionBlock)block {
    
    DDLogAPICall(@"<PubNub> Time token request.");
    PNTimeCompletionBlock blockCopy = [block copy];
    __weak __typeof(self) weakSelf = self;
    [self processOperation:PNTimeOperation withParameters:[PNRequestParameters new]
           completionBlock:^(PNResult *result, PNStatus *status) {
               
               // Silence static analyzer warnings.
               // Code is aware about this case and at the end will simply call on 'nil' object method.
               // This instance is one of client properties and if client already deallocated there is
               // no need to this object which will be deallocated as well.
               #pragma clang diagnostic push
               #pragma clang diagnostic ignored "-Wreceiver-is-weak"
               #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
               [weakSelf callBlock:blockCopy status:NO withResult:result andStatus:status];
               #pragma clang diagnostic pop
           }];
}

#pragma mark -


@end
