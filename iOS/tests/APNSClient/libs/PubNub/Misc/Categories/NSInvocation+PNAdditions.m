//
//  NSInvocation+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 05/14/13.
//
//

#import "NSInvocation+PNAdditions.h"
#import "NSArray+PNAdditions.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub invocation category must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Public interface implementation

@implementation NSInvocation (PNAdditions)


#pragma mark - Class methods

+ (NSInvocation *)pn_invocationForObject:(id)targetObject selector:(SEL)selector
                     retainsArguments:(BOOL)shouldRetainArguments, ... NS_REQUIRES_NIL_TERMINATION {

    // Compose list of parameters
    va_list parametersList;
    va_start(parametersList, shouldRetainArguments);
    NSArray *parameters = [NSArray pn_arrayWithVarietyList:parametersList];
    va_end(parametersList);


    return [self pn_invocationForObject:targetObject selector:selector retainsArguments:shouldRetainArguments
                             parameters:parameters];
}

+ (NSInvocation *)pn_invocationForObject:(id)targetObject selector:(SEL)selector retainsArguments:(BOOL)shouldRetainArguments
                              parameters:(NSArray *)parameters {

    // Initialze variables required to perform postponed method call
    int signatureParameterOffset = 2;
    NSMethodSignature *methodSignature = [targetObject methodSignatureForSelector:selector];
    NSInvocation *methodInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];


    // Configure invocation instance
    methodInvocation.selector = selector;
    [parameters enumerateObjectsUsingBlock:^(id parameter, NSUInteger parameterIdx, BOOL *parametersEnumeratorStop) {

        NSUInteger parameterIndex = (parameterIdx + signatureParameterOffset);
        parameter = [parameter isKindOfClass:[NSNull class]] ? nil : parameter;
        const char *parameterType = [methodSignature getArgumentTypeAtIndex:parameterIndex];
        if ([parameter isKindOfClass:[NSNumber class]]) {

            if (strcmp(parameterType, @encode(BOOL)) == 0) {

                BOOL flagValue = [(NSNumber *) parameter boolValue];
                [methodInvocation setArgument:&flagValue atIndex:parameterIndex];
            }
            else if (strcmp(parameterType, @encode(NSUInteger)) == 0) {

                NSUInteger unsignedInteger = [(NSNumber *) parameter unsignedIntegerValue];
                [methodInvocation setArgument:&unsignedInteger atIndex:parameterIndex];
            }
        }
        else {

            if (parameter != nil) {

                [methodInvocation setArgument:&parameter atIndex:parameterIndex];
            }
        }
    }];
    methodInvocation.target = targetObject;

    if (shouldRetainArguments) {

        [methodInvocation retainArguments];
    }


    return methodInvocation;
}

#pragma mark -


@end
