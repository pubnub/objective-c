/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNDictionary.h"
#import "PNString.h"


#pragma mark - Interface implementation

@implementation PNDictionary


#pragma mark - Validation

+ (BOOL)isDictionary:(NSDictionary *)dictionary containValueOfClasses:(NSArray<Class> *)classes {
    BOOL isOnlyExpectedClasses = YES;
    
    for (id value in dictionary.allValues) {
        BOOL isKindOfAny = NO;
        
        for (Class cls in classes) {
            if (!isKindOfAny) {
                isKindOfAny = [value isKindOfClass:cls];
            }
            
            if (isKindOfAny) {
                break;
            }
        }
        
        if (!isKindOfAny) {
            isOnlyExpectedClasses = NO;
            break;
        }
    }
    
    return isOnlyExpectedClasses;
}


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
