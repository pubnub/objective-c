/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNRequest+Private.h"


#pragma mark Interface implementation

@implementation PNRequest


#pragma mark - Initialization and configuration

+ (instancetype)requestWith:(NSString *)resourcePath parameters:(NSDictionary *)parameters
                        for:(PNOperationType)operation withCompletion:(PNHandlingBlock)block {
    
    return [[self alloc] initWith:resourcePath parameters:parameters for:operation
                   withCompletion:block];
}

- (instancetype)initWith:(NSString *)resourcePath parameters:(NSDictionary *)parameters
                     for:(PNOperationType)operation withCompletion:(PNHandlingBlock)block {
 
    // Check whether initialization has been successful or not.
    if ((self = [super init])) {
        
        _operation = operation;
        _resourcePath = [resourcePath copy];
        _parameters = [(parameters?: @{}) copy];
        _completionBlock = [block copy];
    }
    
    
    return self;
}

#pragma mark -


@end
