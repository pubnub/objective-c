/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNUpdateMembersStatus.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"
#import "PNMember+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNUpdateMembersStatus ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNUpdateMembersData *data;

#pragma mark -


@end


@interface PNUpdateMembersData ()


#pragma mark - Information

@property (nonatomic, strong) NSArray<PNMember *> *members;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNUpdateMembersData


#pragma mark - Information

- (NSArray<PNMember *> *)members {
    if (!_members) {
        NSMutableArray *members = [NSMutableArray new];
        
        for (NSDictionary *member in self.serviceData[@"members"]) {
            [members addObject:[PNMember memberFromDictionary:member]];
        }
        
        _members = [members copy];
    }
    
    return _members;
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


@implementation PNUpdateMembersStatus


#pragma mark - Information

- (PNUpdateMembersData *)data {
    if (!_data) {
        _data = [PNUpdateMembersData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end
