/**
 @author Sergey Mamontov
 @since 4.7.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNMessageDeleteParser.h"


#pragma mark Interface implementation

@implementation PNMessageDeleteParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    
    return @[@(PNDeleteMessageOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for message delete request.
    if ([response isKindOfClass:[NSDictionary class]]) { processedResponse = @{}; }
    
    return processedResponse;
}

#pragma mark -


@end
