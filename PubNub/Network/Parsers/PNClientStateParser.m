/**
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNClientStateParser.h"


#pragma mark Interface implementation

@implementation PNClientStateParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    
    return @[@(PNSetStateOperation), @(PNGetStateOperation), @(PNStateForChannelOperation),
             @(PNStateForChannelGroupOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {

    NSMutableDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for state update / audit.
    if ([response isKindOfClass:[NSDictionary class]] &&
        ((NSNumber *)response[@"status"]).integerValue == 200){

        processedResponse = [@{ @"state": (response[@"payload"] ?: @{}) } mutableCopy];
        NSDictionary *channelsState = response[@"payload"][@"channels"] ?: @{};

        if (response[@"channel"]) {
            channelsState = @{ response[@"channel"]: processedResponse[@"state"] };
        }

        processedResponse[@"channels"] = channelsState;
    }
    
    return processedResponse;
}

#pragma mark -


@end
