/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNJSON.h"


#pragma mark Interface implementation

@implementation PNJSON


#pragma mark - Serialization

+ (NSString *)JSONStringFrom:(id)object withError:(NSError *__autoreleasing *)error {

    NSString *JSONString = nil;
    if (object) {

        if ([object respondsToSelector:@selector(count)]) {

            NSData *JSONData = [NSJSONSerialization dataWithJSONObject:object options:(NSJSONWritingOptions)0
                                                                 error:error];
            if (JSONData) {

                JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
            }
        }
        else if ([self isJSONString:object]){

            JSONString = [[NSString alloc] initWithFormat:@"%@", object];
        }
        else { JSONString = [[NSString alloc] initWithFormat:@"\"%@\"", object]; }
    }
    
    return JSONString;
}


#pragma mark - De-serialization

+ (id)JSONObjectFrom:(NSString *)object withError:(NSError *__autoreleasing *)error {
    
    id JSONObject = nil;
    NSError *parsingError = nil;
    if (object) {

        // Check whether object represent string (composed from NSString as root object or not).
        // This route required because NSJSONSerialization unable to parse JSON strings where root
        // object is NSString.
        if ([object characterAtIndex:0] == '"' &&
            [object characterAtIndex:0] == [object characterAtIndex:(object.length -1 )]) {

            NSCharacterSet *trimCharSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
            JSONObject = [object stringByTrimmingCharactersInSet:trimCharSet];
        }
        else {

            NSData *JSONData = [object dataUsingEncoding:NSUTF8StringEncoding];
            JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData
                                                         options:NSJSONReadingAllowFragments
                                                           error:&parsingError];
        }

        if (parsingError && error) { *error = parsingError; }
    }
    
    return JSONObject;
}


#pragma mark - Validation

+ (BOOL)isJSONString:(id)object {
    
    BOOL isJSONString = [object isKindOfClass:[NSNumber class]];
    if ([object isKindOfClass:[NSString class]] && ((NSString *)object).length > 0) {
        
        unichar expectedClosingChar;
        unichar nodeStartChar = [(NSString *)object characterAtIndex:0];
        unichar nodeClosingChar = [(NSString *)object characterAtIndex:(((NSString *)object).length - 1)];
        isJSONString = (nodeStartChar == '"' || nodeStartChar == '[' || nodeStartChar == '{');
        if (isJSONString) {

            expectedClosingChar = (unichar)(nodeStartChar == '"' ? '"' : (nodeStartChar == '[' ? ']' : '}'));
            isJSONString = (nodeClosingChar == expectedClosingChar);
        }
    }
    
    return isJSONString;
}

#pragma mark -


@end
