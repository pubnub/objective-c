/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNChannelGroupModificationParser.h"


#pragma mark Interface implementation

@implementation PNChannelGroupModificationParser


#pragma mark - Identification

+ (NSArray *)operations {
    
    return @[@(PNAddChannelsToGroupOperation), @(PNRemoveChannelsFromGroupOperation),
             @(PNRemoveGroupOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary *)parsedServiceResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for channel group modification response.
    if ([response isKindOfClass:[NSDictionary class]] &&
        response[@"message"] && response[@"error"]) {
        
        processedResponse = @{};
    }
    
    return processedResponse;
}

#pragma mark - 


@end
