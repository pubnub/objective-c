#import "PNChannelGroupsResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNChannelGroupsData


#pragma mark - Information

- (NSArray *)groups {
    
    return self.serviceData[@"groups"];
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNChannelGroupsResult


#pragma mark - Information 

- (PNChannelGroupsData *)data {
    
    return [PNChannelGroupsData dataWithServiceResponse:self.serviceData];
}

#pragma mark -


@end
