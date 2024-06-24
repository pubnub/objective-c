#import "PNErrorStatus+Private.h"
#import "PNOperationResult+Private.h"
#import "PNStatus+Private.h"


#pragma mark Interface implementation

@implementation PNErrorStatus


#pragma mark - Properties

+ (Class)statusDataClass {
    return [PNErrorData class];
}


#pragma mark - Initialization and Configuration

- (id)copyWithZone:(NSZone *)zone {
    PNErrorStatus *status = [super copyWithZone:zone];
    status.associatedObject = self.associatedObject;

    return status;
}


#pragma mark - Properties

- (PNErrorData *)errorData {
    return self.responseData;
}

#pragma mark -


@end
