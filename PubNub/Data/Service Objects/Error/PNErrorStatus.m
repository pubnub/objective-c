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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (status.isError && status.category == PNBadRequestCategory) status.statusCode = 400;
    else if (status.isError && status.category == PNAccessDeniedCategory) status.statusCode = 403;
    else if (status.isError && status.category == PNResourceNotFoundCategory) status.statusCode = 404;
    else if (status.isError && status.category == PNMalformedResponseCategory) status.statusCode = 500;
    else if (status.category == PNAcknowledgmentCategory || status.category == PNCancelledCategory) {
        status.statusCode = 200;
    }
#pragma clang diagnostic pop

    return status;
}

- (id)copyWithZone:(NSZone *)zone {
    PNErrorStatus *status = [super copyWithZone:zone];
    status.associatedObject = self.associatedObject;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    status.statusCode = self.statusCode;
#pragma clang diagnostic pop

    return status;
}


#pragma mark - Properties

- (PNErrorData *)errorData {
    return self.responseData;
}

#pragma mark -


@end
