/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNManageMembershipsStatus.h"
#import "PNServiceData+Private.h"
#import "PNMembership+Private.h"
#import "PNResult+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNManageMembershipsStatus ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNManageMembershipsData *data;

#pragma mark -


@end


@interface PNManageMembershipsData ()


#pragma mark - Information

@property (nonatomic, strong) NSArray<PNMembership *> *memberships;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNManageMembershipsData


#pragma mark - Information

- (NSArray<PNMembership *> *)memberships {
    if (!_memberships) {
        NSMutableArray *memberships = [NSMutableArray new];
        
        for (NSDictionary *membership in self.serviceData[@"memberships"]) {
            [memberships addObject:[PNMembership membershipFromDictionary:membership]];
        }
        
        _memberships = [memberships copy];
    }
    
    return _memberships;
}

- (NSUInteger)totalCount {
    return ((NSNumber *)self.serviceData[@"totalCount"]).unsignedIntegerValue;
}

- (NSString *)next {
    return self.serviceData[@"next"];
}

- (NSString *)prev {
    return self.serviceData[@"prev"];
}

#pragma mark -


@end


@implementation PNManageMembershipsStatus


#pragma mark - Information

- (PNManageMembershipsData *)data {
    if (!_data) {
        _data = [PNManageMembershipsData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end
