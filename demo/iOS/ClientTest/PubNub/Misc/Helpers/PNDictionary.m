/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import <CocoaLumberjack/CocoaLumberjack.h>

#import "PNDictionary.h"
#import "PNString.h"


#pragma mark Interface implementation

@implementation PNDictionary


#pragma mark - URL helper

+ (NSString *)queryStringFrom:(NSDictionary *)dictionary {
    
    NSMutableString *query = [NSMutableString new];
    for (NSString *queryKey in dictionary) {
        if ([dictionary[queryKey] isKindOfClass:[NSString class]]) {
            [query appendFormat:@"%@%@=%@", ([query length] ? @"&" : @""), queryKey,
             [PNString percentEscapedString:dictionary[queryKey]]];
        } else if ([dictionary[queryKey] isKindOfClass:[NSNumber class]]){
            [query appendFormat:@"%@%@=%@", ([query length] ? @"&" : @""), queryKey,
             [PNString percentEscapedString:[dictionary[queryKey] stringValue]]];
        } else {
            DDLogError(@"trying to append parameter with unknown format, queryKey: %@; value: %@", queryKey, dictionary[queryKey]);
        }
    }
    
    return ([query length] > 0 ? [query copy] : nil);
}

#pragma mark -


@end
