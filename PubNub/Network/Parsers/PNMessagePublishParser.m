/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNMessagePublishParser.h"
#import "PNDictionary.h"


@implementation PNMessagePublishParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    
    return @[@(PNPublishOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent through 
    // 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Response in form of array arrive in two cases: publish successful and failed.
    // In case if no valid Foundation object has been passed it is possible what service returned
    // HTML and it should be treated as data publish error.
    if ([response isKindOfClass:[NSArray class]] || !response) {
        
        NSString *information = @"Message Not Published";
        NSNumber *timeToken = nil;
        if (((NSArray *)response).count == 3) {
            
            information = response[1];
            if ([response[2] isKindOfClass:[NSString class]]) {
                
                const char *token = [(NSString *)response[2] cStringUsingEncoding:NSUTF8StringEncoding];
                timeToken = @(strtoull(token, NULL, 0));
            }
            else { timeToken = response[2]; }
        }
        else { timeToken = @((unsigned long long)([[NSDate date] timeIntervalSince1970] * 10000000)); }
        
        processedResponse = @{@"information": information, @"timetoken": timeToken};
    }
    
    return processedResponse;
}

#pragma mark -


@end
