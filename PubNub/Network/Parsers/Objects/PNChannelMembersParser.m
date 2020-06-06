/**
 * @author Serhii Mamontov
 * @version 4.14.1
 * @since 4.14.1
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNChannelMembersParser.h"


#pragma mark Interface implementation

@implementation PNChannelMembersParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    return @[
        @(PNSetChannelMembersOperation),
        @(PNRemoveChannelMembersOperation),
        @(PNManageChannelMembersOperation),
        @(PNFetchChannelMembersOperation)
    ];
}

+ (BOOL)requireAdditionalData {
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    NSDictionary<NSString *, id> *processedResponse = nil;
    
    if ([response isKindOfClass:[NSDictionary class]] && response[@"data"] &&
        ((NSNumber *)response[@"status"]).integerValue == 200) {
        NSMutableDictionary *paginatedResponse = [@{ @"members": response[@"data"] } mutableCopy];
        
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
    
    return processedResponse;
}

#pragma mark -


@end
