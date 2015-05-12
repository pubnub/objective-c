/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+CorePrivate.h"
#import "PubNub+Time.h"
#import "PNRequest+Private.h"


#pragma mark Interface implementation

@implementation PubNub (Time)


#pragma mark - Time token request

- (void)timeWithCompletion:(PNCompletionBlock)block {

    __weak __typeof(self) weakSelf = self;
    PNRequest *request = [PNRequest requestWithPath:@"/time/0" parameters:nil
                                       forOperation:PNTimeOperation
                                     withCompletion:^(PNResult *result, PNStatus *status){

        __strong __typeof(self) strongSelfForResponse = weakSelf;
        [strongSelfForResponse callBlock:[block copy] withResult:result andStatus:status];
    }];
    request.parseBlock = ^id(id rawData){
        
        return ([rawData isKindOfClass:[NSArray class]] ? (NSArray *)rawData[0] : nil);
    };
    
    [self processRequest:request];
}

#pragma mark -


@end
