/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNRequest+Private.h"
#import "PNResult.h"
#import "PNStatus.h"


#pragma mark Interface implementation

@implementation PNRequest


#pragma mark - Initialization and configuration

+ (instancetype)requestWithPath:(NSString *)resourcePath parameters:(NSDictionary *)queryParameters
                   forOperation:(PNOperationType)type withCompletion:(PNCompletionBlock)block {
    
    return [[self alloc] initWithPath:resourcePath parameters:queryParameters forOperation:type
                       withCompletion:block];
}

- (instancetype)initWithPath:(NSString *)resourcePath parameters:(NSDictionary *)queryParameters
                forOperation:(PNOperationType)type withCompletion:(PNCompletionBlock)block {
 
    // Check whether initialization has been successful or not.
    if ((self = [super init])) {
        
        _operation = type;
        _resourcePath = [resourcePath copy];
        _parameters = [(queryParameters?: @{}) copy];
        _completionBlock = [block copy];
    }
    
    
    return self;
}

#pragma mark -


@end
