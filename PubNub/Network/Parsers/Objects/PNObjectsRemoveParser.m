/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNObjectsRemoveParser.h"


#pragma mark Interface implementation

@implementation PNObjectsRemoveParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    return @[@(PNRemoveUUIDMetadataOperation), @(PNRemoveChannelMetadataOperation)];
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
