/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNTimeParser.h"
#import "PNDictionary.h"


#pragma mark Interface implementation

@implementation PNTimeParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    
    return @[@(PNTimeOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent through 
    // 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Array is valid response type for time request.
    if ([response isKindOfClass:[NSArray class]] && ((NSArray *)response).count == 1) {
        
        processedResponse = @{@"timetoken": (NSArray *)response[0]};
    }
    
    return processedResponse;
}

#pragma mark -


@end
