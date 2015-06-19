#import "PNPublishStatus.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNPublishData

#pragma mark - Information

- (NSNumber *)timetoken {
    
    return self.serviceData[@"timetoken"];
}

- (NSString *)information {
    
    return self.serviceData[@"information"];
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNPublishStatus


#pragma mark - Information

- (PNPublishData *)data {
    
    return [PNPublishData dataWithServiceResponse:self.serviceData];
}

#pragma mark -


@end
