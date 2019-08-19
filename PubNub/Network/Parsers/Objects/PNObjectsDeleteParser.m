/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNObjectsDeleteParser.h"


#pragma mark Interface implementation

@implementation PNObjectsDeleteParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    return @[@(PNDeleteUserOperation), @(PNDeleteSpaceOperation)];
}

+ (BOOL)requireAdditionalData {
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    NSDictionary<NSString *, id> *processedResponse = nil;
    
    if ([response isKindOfClass:[NSDictionary class]] && 
        ((NSNumber *)response[@"status"]).integerValue == 200) {
        
        processedResponse = @{};
    }
    
    return processedResponse;
}

#pragma mark -


@end
