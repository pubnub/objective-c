#import "PNResult.h"


#pragma mark Private interface declaration

@interface PNResult ()

#pragma mark - Initialization and configuration

/// Initialize operation processing result object.
///
/// An object is used to unify the two possible outcomes of operation execution: _success_ and _error_.
///
/// - Parameters:
///   - data: The outcome of a successful operation.
///   - error: An error occurred with information about what exactly went wrong during operation execution.
/// - Returns: Initialized result instance contains information about the operation's outcome.
- (instancetype)initWithData:(nullable id)data error:(nullable NSError*)error;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNResult


#pragma mark - Information

- (BOOL)isError {
    return self.error != nil;
}


#pragma mark - Initialization and configuration

+ (instancetype)resultWithData:(id)data error:(NSError *)error {
    return [[self alloc] initWithData:data error:error];
}

- (instancetype)initWithData:(id)data error:(NSError *)error {
    if ((self = [super init])) {
        _error = error;
        _data = data;
    }
    
    return self;
}

#pragma mark -


@end
