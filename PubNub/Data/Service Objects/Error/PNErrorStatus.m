#import "PNErrorStatus+Private.h"
#import "PNBaseOperationData+Private.h"
#import "PNOperationResult+Private.h"
#import "PNStatus+Private.h"


#pragma mark Interface implementation

@implementation PNErrorStatus


#pragma mark - Properties

+ (Class)statusDataClass {
    return [PNErrorData class];
}


#pragma mark - Initialization and Configuration

+ (instancetype)objectWithOperation:(PNOperationType)operation category:(PNStatusCategory)category response:(id)response {
    PNErrorStatus *status = [super objectWithOperation:operation category:category response:response];
    
    if ([response isKindOfClass:[PNBaseOperationData class]]) {
        PNStatusCategory category = ((PNBaseOperationData *)response).category;
        if (category != PNUnknownCategory) status.category = category;
    }
    
    if (!status.isError && status.category == PNUnknownCategory) status.category = PNAcknowledgmentCategory;

    return status;
}

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
