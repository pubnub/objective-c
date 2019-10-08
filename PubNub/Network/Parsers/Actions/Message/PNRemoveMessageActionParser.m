/**
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNRemoveMessageActionParser.h"


#pragma mark Interface implementation

@implementation PNRemoveMessageActionParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    return @[@(PNRemoveMessageActionOperation)];
}

+ (BOOL)requireAdditionalData {
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    NSDictionary<NSString *, id> *processedResponse = nil;
    
    if ([response isKindOfClass:[NSDictionary class]] && response[@"data"] &&
        ((NSNumber *)response[@"status"]).integerValue == 200) {

        processedResponse = @{ };
    }
    
    return processedResponse;
}

#pragma mark -


@end
