/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNListFilesParser.h"


#pragma mark Interface implementation

@implementation PNListFilesParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    return @[@(PNListFilesOperation)];
}

+ (BOOL)requireAdditionalData {
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    if (((NSNumber *)response[@"status"]).integerValue != 200 ||
        ![response isKindOfClass:[NSDictionary class]] || !response[@"data"]) {
        
        return nil;
    }
    
    NSMutableDictionary *uploadedFiles = [@{ @"files": response[@"data"] } mutableCopy];
    uploadedFiles[@"count"] = response[@"count"] ?: @(0);
    uploadedFiles[@"next"] = response[@"next"];
    
    return [uploadedFiles copy];
}

#pragma mark -


@end
