/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNHeartbeatParser.h"


#pragma mark Interface implementation

@implementation PNHeartbeatParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    
    return @[@(PNHeartbeatOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent through 
    // 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for heartbeat request.
    if ([response isKindOfClass:[NSDictionary class]] && response[@"status"] && response[@"service"] && 
        [response[@"status"] isEqual: @200] && [response[@"service"] isEqualToString:@"Presence"]) {
        
        processedResponse = @{};
    }
    
    return processedResponse;
}

#pragma mark -

@end
