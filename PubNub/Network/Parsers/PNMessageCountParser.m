/**
 * @since 4.8.4
 *
 * @author Sergey Mamontov
 * @version 4.8.3
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNMessageCountParser.h"


#pragma mark Interface implementation

@implementation PNMessageCountParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    
    return @[@(PNMessageCountOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return YES;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response
                                               withData:(id)__unused data {

    NSDictionary *processedResponse = nil;
    
    if ([response isKindOfClass:[NSDictionary class]] && response[@"channels"] &&
        response[@"status"]) {
        
        processedResponse = @{ @"channels": response[@"channels"] };
    }
    
    return processedResponse;
}

#pragma mark -


@end
