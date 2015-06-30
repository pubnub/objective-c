/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNErrorParser.h"
#import "PNDictionary.h"


#pragma mark Interface implementation

@implementation PNErrorParser


#pragma mark - Identification

+ (NSArray *)operations {
    
    return @[@(-1)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary *)parsedServiceResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for operation error.
    if ([response isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *errorData = [NSMutableDictionary new];
        if (response[@"message"]) {
            
            errorData[@"information"] = response[@"message"];
        }
        else if (response[@"error"]) {
            
            errorData[@"information"] = response[@"error"];
        }
        if (response[@"payload"]) {
            
            if (response[@"payload"][@"channels"]) {
                
                errorData[@"channels"] = response[@"payload"][@"channels"];
            }
            if (response[@"payload"][@"channel-groups"]) {
                
                errorData[@"channelGroups"] = response[@"payload"][@"channel-groups"];
            }
            if (!errorData[@"channels"] && !errorData[@"channel-groups"]) {
                
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
