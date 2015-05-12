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

- (void)timeWithCompletion:(PNHandlingBlock)block {
    
    PNRequest *request = [PNRequest requestWith:@"/time/0" parameters:nil for:PNTimeOperation
                                 withCompletion:block];
    request.parseBlock = ^id(id rawData){
        
        return ([rawData isKindOfClass:[NSArray class]] ? (NSArray *)rawData[0] : nil);
    };
    [self processRequest:request];
}

#pragma mark -


@end
