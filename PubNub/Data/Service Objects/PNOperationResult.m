#import "PNOperationResult+Private.h"
#import "PNPrivateStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General operation (request or client generated) result object private extension.
@interface PNOperationResult ()


#pragma mark - Properties

/// Processed operation outcome data object.
@property(strong, nullable, nonatomic) id responseData;

/// Type of operation for which result object has been created.
@property(assign, nonatomic) PNOperationType operation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNOperationResult


#pragma mark - Properties

- (NSString *)stringifiedOperation {
    return self.operation >= PNSubscribeOperation ? PNOperationTypeStrings[self.operation] : @"Unknown";
}


#pragma mark - Initialization and Configuration

+ (instancetype)objectWithOperation:(PNOperationType)operation response:(id)response {
    return [[self alloc] initWithOperation:operation response:response];
}

- (instancetype)initWithOperation:(PNOperationType)operation response:(id)response {
    if ((self = [super init])) {
        _responseData = response;
        _operation = operation;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithOperation:self.operation response:self.responseData];

}

#pragma mark -


@end
