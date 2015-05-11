/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNHelper.h"


#pragma mark Interface implementation

@implementation PNHelper


#pragma mark - JSON serializer

+ (NSString *)JSONStringFrom:(id)object withError:(NSError **)error {
    
    NSString *JSONString = nil;
    if ([object respondsToSelector:@selector(count)]) {
        
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:object
                                                           options:(NSJSONWritingOptions)0
                                                             error:error];
        if (JSONData) {
            
            JSONString = [[NSString alloc] initWithUTF8String:[JSONData bytes]];
        }
    }
    else if ([self isJSONString:object]){
        
        JSONString = object;
    }
    else {
        
        JSONString = [[NSString alloc] initWithFormat:@"\"%@\"", object];
    }
    
    
    return JSONString;
}

+ (id)JSONObjectFrom:(NSString *)object withError:(NSError **)error {
    
    id JSONObject = nil;
    NSError *parsingError = nil;
    
    // Check whether object represent string (composed from NSString as root object or not).
    // This route required because NSJSONSerialization unable to parse JSON strings where root
    // object is NSString.
    if ([object characterAtIndex:0] == '"' &&
        [object characterAtIndex:0] == [object characterAtIndex:([object length] -1 )]) {
        
        NSCharacterSet *trimCharSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
        JSONObject = [object stringByTrimmingCharactersInSet:trimCharSet];
    }
    else {
        
        JSONObject = [NSJSONSerialization JSONObjectWithData:[object dataUsingEncoding:NSUTF8StringEncoding]
                                                     options:NSJSONReadingAllowFragments
                                                       error:&parsingError];
    }
    
    if (parsingError && error) {
        
        *error = parsingError;
    }
    
    
    return JSONObject;
}

+ (BOOL)isJSONString:(id)object {
    
    BOOL isJSONString = [object isKindOfClass:[NSNumber class]];
    if ([object isKindOfClass:[NSString class]] && [(NSString *)object length] > 0) {
        
        unichar expectedCloseingChar;
        unichar nodeStartChar = [(NSString *)object characterAtIndex:0];
        unichar nodeClosingChar = [(NSString *)object characterAtIndex:([(NSString *)object length] - 1)];
        isJSONString = (nodeStartChar == '"' || nodeStartChar == '[' || nodeStartChar == '{');
        if (isJSONString) {
            
            expectedCloseingChar = (nodeStartChar == '"' ? '"' : (nodeStartChar == '[' ? ']' : '}'));
            isJSONString = (nodeClosingChar == expectedCloseingChar);
        }
    }
    
    return isJSONString;
}


#pragma mark - 


@end
