/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNClientStateParser.h"
#import "PNDictionary.h"


#pragma mark Interface implementation

@implementation PNClientStateParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    
    return @[@(PNSetStateOperation), @(PNStateForChannelOperation),
             @(PNStateForChannelGroupOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent through 
    // 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for state update / audit.
    if ([response isKindOfClass:[NSDictionary class]] && ((NSNumber *)response[@"status"]).integerValue == 200){
        
        processedResponse = @{@"channels": (response[@"payload"][@"channels"]?: @[]),
                              @"state": (response[@"payload"]?: @{})};
    }
    
    return processedResponse;
}

#pragma mark -


@end
