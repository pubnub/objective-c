/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNLeaveParser.h"


#pragma mark Interface implementation

@implementation PNLeaveParser


#pragma mark - Identification

+ (NSArray *)operations {
    
    return @[@(PNUnsubscribeOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary *)parsedServiceResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for presence leave request.
    if ([response isKindOfClass:[NSDictionary class]]) {
        
        processedResponse = @{};
    }
    
    return processedResponse;
}

#pragma mark -


@end
