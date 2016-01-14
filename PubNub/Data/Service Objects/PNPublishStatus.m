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



#pragma mark - Private interface declaration

@interface PNPublishStatus ()


#pragma mark - Properties

@property (nonatomic, strong) PNPublishData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNPublishStatus


#pragma mark - Information

- (PNPublishData *)data {
    
    if (!_data) { _data = [PNPublishData dataWithServiceResponse:self.serviceData]; }
    return _data;
}

#pragma mark -


@end
