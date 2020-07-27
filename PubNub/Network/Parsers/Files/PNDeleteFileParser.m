/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNDeleteFileParser.h"


#pragma mark Interface implementation

@implementation PNDeleteFileParser

+ (NSArray<NSNumber *> *)operations {
    return @[@(PNDeleteFileOperation)];
}

+ (BOOL)requireAdditionalData {
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    NSDictionary<NSString *, id> *processedResponse = nil;
    
    if (((NSNumber *)response[@"status"]).integerValue != 200 ||
        ![response isKindOfClass:[NSDictionary class]]) {
        
        return processedResponse;
    }
    
    
    return processedResponse;
}

#pragma mark -


@end
