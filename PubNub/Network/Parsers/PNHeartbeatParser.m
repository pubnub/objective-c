/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNHeartbeatParser.h"


#pragma mark Interface implementation

@implementation PNHeartbeatParser


#pragma mark - Identification

+ (NSArray *)operations {
    
    return @[@(PNHeartbeatOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary *)parsedServiceResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for heartbeat request.
    if ([response isKindOfClass:[NSDictionary class]] && [response objectForKey:@"status"] &&
        [response objectForKey:@"service"] && [[response objectForKey:@"status"] isEqual: @200] &&
        [[response objectForKey:@"service"] isEqualToString:@"Presence"]) {
        
        processedResponse = @{};
    }
    
    return processedResponse;
}

#pragma mark -

@end
