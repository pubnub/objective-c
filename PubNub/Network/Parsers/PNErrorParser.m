/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNErrorParser.h"
#import "PNDictionary.h"


#pragma mark Interface implementation

@implementation PNErrorParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    
    return @[@(-1)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent through 
    // 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for operation error.
    if ([response isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *errorData = [NSMutableDictionary new];
        if (response[@"message"] || response[@"error"]) {
            
            errorData[@"information"] = (response[@"message"]?: response[@"error"]);
        }
        
        if (response[@"payload"]) {
            
            errorData[@"channels"] = (response[@"payload"][@"channels"]?: @[]);
            errorData[@"channelGroups"] = (response[@"payload"][@"channel-groups"]?: @[]);
            if (!response[@"payload"][@"channels"] && !response[@"payload"][@"channel-groups"]) {
                
                errorData[@"data"] = response[@"payload"];
            }
        }
        
        if ([response[@"status"] isKindOfClass:[NSNumber class]]) {
            
            errorData[@"status"] = response[@"status"];
        }
        processedResponse = errorData;
    }
    
    return processedResponse;
}

#pragma mark -


@end
