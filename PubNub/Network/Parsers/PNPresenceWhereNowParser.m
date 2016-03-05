/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNPresenceWhereNowParser.h"
#import "PNDictionary.h"


#pragma mark Interface implementation

@implementation PNPresenceWhereNowParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    
    return @[@(PNWhereNowOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (nullable NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent through
    // 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for where now response.
    if ([response isKindOfClass:[NSDictionary class]] && response[@"payload"][@"channels"]) {
        
        processedResponse = @{@"channels": response[@"payload"][@"channels"]};
    }
    
    return processedResponse;
}

#pragma mark -


@end
