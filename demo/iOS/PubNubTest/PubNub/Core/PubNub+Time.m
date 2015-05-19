/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+CorePrivate.h"
#import "PNRequest+Private.h"
#import "PNStatus+Private.h"
#import "PNResult+Private.h"
#import "PubNub+Time.h"
#import "PNResponse.h"


#pragma mark Protected interface

@interface PubNub (TimeProtected)


#pragma mark - Processing

/**
 @brief  Try to pre-process provided data and translate it's content to expected from 'Time' API.
 
 @param response Reference on Foundation object which should be pre-processed.
 
 @return Pre-processed dictionary or \c nil in case if passed \c response doesn't meet format 
         requirements to be handled by 'Time' API.
 
 @since 4.0
 */
- (NSDictionary *)processedTimeResponse:(id)response;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PubNub (Time)


#pragma mark - Time token request

- (void)timeWithCompletion:(PNCompletionBlock)block {

    __weak __typeof(self) weakSelf = self;
    PNRequest *request = [PNRequest requestWithPath:@"/time/0" parameters:nil
                                       forOperation:PNTimeOperation
                                     withCompletion:nil];
    request.parseBlock = ^id(id rawData){
        
        __strong __typeof(self) strongSelf = weakSelf;
        return [strongSelf processedTimeResponse:rawData];
    };
    request.reportBlock = block;
    
    DDLogAPICall(@"<PubNub> Time token.");
    
    [self processRequest:request];
}


#pragma mark - Processing

- (NSDictionary *)processedTimeResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Array is valid response type for time request.
    if ([response isKindOfClass:[NSArray class]] && [(NSArray *)response count] == 1) {
        
        processedResponse = @{@"tt": (NSArray *)response[0]};
    }
    
    return [processedResponse copy];
}

#pragma mark -


@end
