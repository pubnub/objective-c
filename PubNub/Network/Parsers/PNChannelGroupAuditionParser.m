/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNChannelGroupAuditionParser.h"
#import "PNDictionary.h"


#pragma mark Interface implementation

@implementation PNChannelGroupAuditionParser


#pragma mark - Identification

+ (NSArray *)operations {
    
    return @[@(PNChannelGroupsOperation), @(PNChannelsForGroupOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary *)parsedServiceResponse:(id)response {

    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for channel group audition response.
    if ([response isKindOfClass:[NSDictionary class]] && response[@"payload"]) {
        
        if (response[@"payload"][@"channels"]) {
            
            processedResponse = @{@"channels": response[@"payload"][@"channels"]};
        }
        else if (response[@"payload"][@"groups"]) {
            
            processedResponse = @{@"groups": response[@"payload"][@"groups"]};
        }
    }
    
    return processedResponse;
}

#pragma mark -


@end
