#import "PNChannelGroupsResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark - Interface implementation

@implementation PNChannelGroupsData


#pragma mark - Information

- (NSArray<NSString *> *)groups {
    
    return (self.serviceData[@"groups"]?: @[]);
}

#pragma mark -


@end


#pragma mark - Private interface declaration

@interface PNChannelGroupsResult ()


#pragma mark - Properties

@property (nonatomic, nonnull, strong) PNChannelGroupsData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNChannelGroupsResult


#pragma mark - Information 

- (PNChannelGroupsData *)data {
    
    if (!_data) { _data = [PNChannelGroupsData dataWithServiceResponse:self.serviceData]; }
    return _data;
}

#pragma mark -


@end
