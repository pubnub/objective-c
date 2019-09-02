/**
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNFetchMessagesActionsParser.h"


#pragma mark Interface implementation

@implementation PNFetchMessagesActionsParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    return @[@(PNFetchMessagesActionsOperation)];
}

+ (BOOL)requireAdditionalData {
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    NSDictionary<NSString *, id> *processedResponse = nil;
    
    if ([response isKindOfClass:[NSDictionary class]] && response[@"data"] &&
        ((NSNumber *)response[@"status"]).integerValue == 200) {
        
        NSMutableArray<NSMutableDictionary *> *actions = response[@"data"];
        
        for (NSMutableDictionary *action in actions) {
            action[@"messageTimetoken"] = @(((NSString *)action[@"messageTimetoken"]).longLongValue);
            action[@"actionTimetoken"] = @(((NSString *)action[@"actionTimetoken"]).longLongValue);
        }
        
        processedResponse = @{
            @"actions": actions,
            @"start": actions.count ? actions.firstObject[@"actionTimetoken"] : @(0),
            @"end": actions.count ? actions.lastObject[@"actionTimetoken"] : @(0)
        };
    }
    
    return processedResponse;
}

#pragma mark -


@end
