//
//  PNJSONSerialization.m
//  pubnub
//
//  This class encapsulate logic with JSON
//  serialization fallback (pre-iOS 5) and
//  handles JSONP by returning prefix falue.
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//

#import "PNJSONSerialization.h"
#import "PNLogger+Protected.h"
#import "PNLoggerSymbols.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub JSON serializer must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNJSONSerialization ()


#pragma mark - Class methods

/**
 * Try to retrieve callback method name from provided
 * JSON string. If method will be fetched, than this is 
 * JSONP string.
 */
+ (void)getCallbackMethodName:(NSString **)callbackMethodName fromJSONString:(NSString *)jsonString;
+ (NSString *)JSONStringFromJSONPString:(NSString *)jsonpString callbackMethodName:(NSString *)callbackMethodName;


#pragma mark - Misc methods

/**
 Perform quck check on whether provided object is JSON encoded string (begins and ends with ").
 
 @param object
 Any object against which check should be performed
 
 @return \c YES if specified \a 'object' is JSON encoded string and \c NO in another case.
 */
+ (BOOL)isJSONStringObject:(id)object;
+ (BOOL)isNSJSONAvailable;
+ (BOOL)isJSONKitAvailable;

#pragma mark -


@end


#pragma mark - Public interface methods

@implementation PNJSONSerialization


#pragma mark - Class methods

+ (void)JSONObjectWithData:(NSData *)jsonData
           completionBlock:(void(^)(id result, BOOL isJSONPStyle, NSString *callbackMethodName))completionBlock
                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self JSONObjectWithString:jsonString completionBlock:completionBlock errorBlock:errorBlock];
}

+ (void)JSONObjectWithString:(NSString *)jsonString
             completionBlock:(void(^)(id result, BOOL isJSONPStyle, NSString *callbackMethodName))completionBlock
                  errorBlock:(void(^)(NSError *error))errorBlock {
    
    id result = nil;
    __autoreleasing NSError *parsingError = nil;
    NSString *jsonCallbackMethodName = nil;
    [self getCallbackMethodName:&jsonCallbackMethodName fromJSONString:jsonString];
    
    // Check whether callback name was found in JSON string or not
    if(jsonCallbackMethodName != nil) {
        
        jsonString = [self JSONStringFromJSONPString:jsonString callbackMethodName:jsonCallbackMethodName];
    }
    
    // Check whether passed string is non-object
    if ([self isJSONStringObject:jsonString]) {
        
        result = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
    }
    else {
        
        // Checking whether native JSONSerializer is available or not
        if ([self isNSJSONAvailable]) {
            
            result = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                     options:NSJSONReadingAllowFragments
                                                       error:&parsingError];
        }
        // Fallback to JSONKit usage
        else if ([self isJSONKitAvailable]) {
            
            NSData *dataForDeserialization = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            SEL jsonKitSelector = NSSelectorFromString(@"objectFromJSONDataWithParseOptions:error:");
            NSMethodSignature *jsonKitMethod = [NSData instanceMethodSignatureForSelector:jsonKitSelector];
            NSInvocation *deserializationInvocation = [NSInvocation invocationWithMethodSignature:jsonKitMethod];
            [deserializationInvocation setSelector:jsonKitSelector];
            [deserializationInvocation setTarget:dataForDeserialization];
            
            NSUInteger parseOption = 0;
            __autoreleasing NSError **parsingErrorForInvocation = &parsingError;
            __unsafe_unretained id invocationResult;
            [deserializationInvocation setArgument:&parseOption atIndex:2];
            [deserializationInvocation setArgument:&parsingErrorForInvocation atIndex:3];
            [deserializationInvocation invoke];
            [deserializationInvocation getReturnValue:&invocationResult];
            
            result = invocationResult;
        }
        else {
            
            [NSException raise:@"JSON serialization library"
                        format:@"There is no JSON serialization library available. If you are targeting 4.3+ versions, "
             "please make sure to read 'How-to' on JSONKit addition"];
        }
    }


    // Checking whether parsing was successful or not
    if (result && parsingError == nil) {
        
        if(completionBlock) {
            
            completionBlock(result, jsonCallbackMethodName!=nil, jsonCallbackMethodName);
        }
    }
    else if(parsingError != nil){
        
        if (errorBlock) {
            
            errorBlock(parsingError);
        }
    }
}

+ (NSString *)stringFromJSONObject:(id)object {

    NSString *JSONString = nil;
    if (![self isJSONString:object]) {

        if ([self isNSJSONAvailable]) {

            if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {

                NSError *serializationError = nil;
                NSData *JSONSerializedObject = [NSJSONSerialization dataWithJSONObject:object
                                                                               options:(NSJSONWritingOptions)0
                                                                                 error:&serializationError];
                JSONString = [[NSString alloc] initWithData:JSONSerializedObject encoding:NSUTF8StringEncoding];
            }
            else if ([object isKindOfClass:[NSNumber class]]) {

                JSONString = [(NSNumber *)object stringValue];
            }
            else {

                JSONString = [NSString stringWithFormat:@"\"%@\"", object];
            }
        }
        else if ([self isJSONKitAvailable]) {
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            JSONString = [object performSelector:NSSelectorFromString(@"JSONString")];
#pragma clang diagnostic pop
        }
        else {

            [NSException raise:@"JSON serialization library"
                        format:@"There is no JSON serialization library available. If you are targeting 4.3+ versions, "
                                "please make sure to read 'How-to' on JSONKit addition"];
        }
    }
    else {

        JSONString = object;
    }

    // Replace null value has been passed or not (serialized [NSNull null] value)
	if ([JSONString respondsToSelector:@selector(stringByReplacingOccurrencesOfString:withString:)]) {

		JSONString = [JSONString stringByReplacingOccurrencesOfString:@":null" withString:@":\"null\""];
	}

    return JSONString;
}

+ (void)getCallbackMethodName:(NSString **)callbackMethodName fromJSONString:(NSString *)jsonString {

    if (jsonString) {

        // Checking whether there are parenthesis in JSON
        NSRange parenthesisRange = [jsonString rangeOfString:@"("];
        if (parenthesisRange.location != NSNotFound &&
                ([jsonString characterAtIndex:(parenthesisRange.location+parenthesisRange.length)] == '[' ||
                        [jsonString characterAtIndex:(parenthesisRange.location+parenthesisRange.length)] == '{')) {

            NSScanner *scanner = [NSScanner scannerWithString:jsonString];
            [scanner scanUpToString:@"(" intoString:callbackMethodName];
        }
    }
    else {

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.JSONserializer.emptyJSONString];
        }];
    }
}

+ (NSString *)JSONStringFromJSONPString:(NSString *)jsonpString callbackMethodName:(NSString *)callbackMethodName {
    
    NSScanner *scanner = [NSScanner scannerWithString:jsonpString];
    [scanner scanUpToString:@"(" intoString:NULL];
    
    NSString *JSONWrappedInParens = [[scanner string] substringFromIndex:[scanner scanLocation]];
    NSCharacterSet *parens = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%@();",
                                                                                 callbackMethodName?callbackMethodName:@""]];
    
    
    return [JSONWrappedInParens stringByTrimmingCharactersInSet:parens];
}


#pragma mark - Misc methods

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

+ (BOOL)isJSONStringObject:(id)object {
    
    BOOL isJSONStringObject = [object isKindOfClass:[NSString class]];
    if (isJSONStringObject && [(NSString *)object length] > 0) {
        
        unichar nodeStartChar = [(NSString *)object characterAtIndex:0];
        unichar nodeClosingChar = [(NSString *)object characterAtIndex:([(NSString *)object length] - 1)];
        
        isJSONStringObject = nodeStartChar == '"' && nodeClosingChar == '"';
    }
    
    
    return isJSONStringObject;
}

+ (BOOL)isNSJSONAvailable {

    static BOOL isNSJSONAvailable;
    static dispatch_once_t isNSJSONAvailableToken;
    dispatch_once(&isNSJSONAvailableToken, ^{

        isNSJSONAvailable = NSClassFromString(@"NSJSONSerialization") != nil;
    });


    return isNSJSONAvailable;
}

+ (BOOL)isJSONKitAvailable {
    
    static BOOL isJSONKitAvailable;
    static dispatch_once_t isJSONKitAvailableToken;
    dispatch_once(&isJSONKitAvailableToken, ^{
        
        isJSONKitAvailable = [@"" respondsToSelector:NSSelectorFromString(@"JSONString")];
    });
    

    return isJSONKitAvailable;
}

#pragma mark -


@end
