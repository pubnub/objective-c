/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
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
            id errorDescription = response[@"error"];
            
            if (!errorDescription ||
                ([errorDescription isKindOfClass:[NSNumber class]] && response[@"error_message"])) {
                
                errorDescription = response[@"error_message"];
            }
            
            if ([errorDescription isKindOfClass:[NSDictionary class]] &&
                errorDescription[@"message"]) {
                NSMutableArray<NSDictionary *> *errorDetails = errorDescription[@"details"];
                errorDescription = errorDescription[@"message"];
                
                if (errorDetails.count) {
                    NSMutableArray<NSString *> *detailStrings = [NSMutableArray new];
                    
                    for (NSDictionary *details in errorDetails) {
                        NSString *detailString = @"";
                        
                        if (details[@"message"]) {
                            detailString = [@"- " stringByAppendingString:details[@"message"]];
                        }
                        
                        if (details[@"location"]) {
                            detailString = [detailString stringByAppendingFormat:@"%@ Location: %@",
                                            detailString.length ? @"" : @"-", details[@"location"]];
                        }
                        
                        [detailStrings addObject:detailString];
                    }
                    
                    if (detailStrings.count) {
                        errorDescription = [errorDescription stringByAppendingFormat:@" Details:\n%@",
                                            [detailStrings componentsJoinedByString:@"\n"]];
                    }
                }
            }
            
            errorData[@"information"] = response[@"message"] ?: errorDescription;
        }
        
        if (response[@"payload"]) {
            errorData[@"channels"] = response[@"payload"][@"channels"] ?: @[];
            errorData[@"channelGroups"] = response[@"payload"][@"channel-groups"] ?: @[];
            
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
