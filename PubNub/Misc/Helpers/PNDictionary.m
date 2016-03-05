/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNDictionary.h"
#import "PNString.h"


#pragma mark - Interface implementation

@implementation PNDictionary


#pragma mark - URL helper

+ (NSString *)queryStringFrom:(NSDictionary *)dictionary {
    
    NSMutableString *query = [NSMutableString new];
    for (NSString *queryKey in dictionary) {
        
        [query appendFormat:@"%@%@=%@", ([query length] ? @"&" : @""), queryKey, dictionary[queryKey]];
    }
    
    return ([query length] > 0 ? [query copy] : nil);
}

#pragma mark -


@end
