/**
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNAddMessageActionParser.h"


#pragma mark Interface implementation

@implementation PNAddMessageActionParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    return @[@(PNAddMessageActionOperation)];
}

+ (BOOL)requireAdditionalData {
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    NSDictionary<NSString *, id> *processedResponse = nil;
    
    if ([response isKindOfClass:[NSDictionary class]] && response[@"data"] &&
        ((NSNumber *)response[@"status"]).integerValue < 400) {
        NSMutableDictionary *action = response[@"data"];
        NSMutableDictionary *actionInformation = [@{ @"action": action } mutableCopy];
        
        action[@"messageTimetoken"] = @(((NSString *)action[@"messageTimetoken"]).longLongValue);
        action[@"actionTimetoken"] = @(((NSString *)action[@"actionTimetoken"]).longLongValue);

        if ([response[@"error"] isKindOfClass:[NSDictionary class]]) {
            actionInformation[@"information"] = response[@"error"][@"message"];
            actionInformation[@"isError"] = @YES;
        }
        
        processedResponse = actionInformation;
    }
    
    return processedResponse;
}

#pragma mark -


@end
