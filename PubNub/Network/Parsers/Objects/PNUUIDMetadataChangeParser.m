/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNUUIDMetadataChangeParser.h"


#pragma mark Interface implementation

@implementation PNUUIDMetadataChangeParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    return @[@(PNSetUUIDMetadataOperation)];
}

+ (BOOL)requireAdditionalData {
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    NSDictionary<NSString *, id> *processedResponse = nil;
    
    if ([response isKindOfClass:[NSDictionary class]] && response[@"data"] &&
        ((NSNumber *)response[@"status"]).integerValue == 200) {
        
        processedResponse = @{ @"uuid": response[@"data"] };
    }
    
    return processedResponse;
}

#pragma mark -


@end
