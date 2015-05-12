/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNResult


#pragma mark - Initialization and configuration

+ (instancetype)resultFor:(PNRequest *)operation withResponse:(NSURLResponse *)response
                  andData:(id <NSObject, NSCopying>)data {
    
    return [[self alloc] initFor:operation withResponse:response andData:data];
}

- (instancetype)initFor:(PNRequest *)operation withResponse:(NSHTTPURLResponse *)response
                andData:(id <NSObject, NSCopying>)data {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {
        
        self.operation = operation;
        self.statusCode = response.statusCode;
        self.data = data;
    }
    
    
    return self;
}

#pragma mark -


@end
