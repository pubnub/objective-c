/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNDictionary.h"
#import "PNString.h"


#pragma mark - Interface implementation

@implementation PNDictionary


#pragma mark - API helper

+ (BOOL)hasFlattenedContent:(NSDictionary *)dictionary {
    
    BOOL flattened = YES;
    for (NSString *key in dictionary) {
        
        flattened = ![dictionary[key] respondsToSelector:@selector(count)];
        if (!flattened) {
            
            break;
        }
    }
    
    return flattened;
}


#pragma mark - URL helper

+ (NSString *)queryStringFrom:(NSDictionary *)dictionary {
    
    NSMutableString *query = [NSMutableString new];
    for (NSString *queryKey in dictionary) {
        
        [query appendFormat:@"%@%@=%@", ([query length] ? @"&" : @""), queryKey,
         dictionary[queryKey]];
    }
    
    return ([query length] > 0 ? [query copy] : nil);
}

#pragma mark -


@end
