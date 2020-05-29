/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNFetchUUIDMetadataParser.h"


#pragma mark Interface implementation

@implementation PNFetchUUIDMetadataParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    return @[@(PNFetchUUIDMetadataOperation), @(PNFetchAllUUIDMetadataOperation)];
}

+ (BOOL)requireAdditionalData {
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    NSDictionary<NSString *, id> *processedResponse = nil;
    
    if ([response isKindOfClass:[NSDictionary class]] && response[@"data"] &&
        ((NSNumber *)response[@"status"]).integerValue == 200) {
        
        if ([response[@"data"] isKindOfClass:[NSDictionary class]]) {
            processedResponse = @{ @"uuid": response[@"data"] };
        } else if ([response[@"data"] isKindOfClass:[NSArray class]]) {
            NSMutableDictionary *paginatedResponse = [@{ @"uuids": response[@"data"] } mutableCopy];
            
            if (response[@"totalCount"]) {
                paginatedResponse[@"totalCount"] = response[@"totalCount"];
            }
            
            if (response[@"next"]) {
                paginatedResponse[@"next"] = response[@"next"];
            }
            
            if (response[@"prev"]) {
                paginatedResponse[@"prev"] = response[@"prev"];
            }
            
            processedResponse = [paginatedResponse copy];
        }
    }
    
    return processedResponse;
}

#pragma mark -


@end
