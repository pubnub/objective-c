/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNClientStateParser.h"
#import "PNDictionary.h"


#pragma mark Interface implementation

@implementation PNClientStateParser


#pragma mark - Identification

+ (NSArray *)operations {
    
    return @[@(PNSetStateOperation), @(PNStateForChannelOperation),
             @(PNStateForChannelGroupOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary *)parsedServiceResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for state update / audit.
    if ([response isKindOfClass:[NSDictionary class]] && [response[@"status"] integerValue] == 200){
        
        if (response[@"payload"][@"channels"]) {
            
            processedResponse = @{@"channels": response[@"payload"][@"channels"]};
        }
        else {
            
            processedResponse = @{@"state": response[@"payload"]};
        }
    }
    
    return processedResponse;
}

#pragma mark -


@end
