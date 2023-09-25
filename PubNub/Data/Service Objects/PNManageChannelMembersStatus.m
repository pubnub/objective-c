/**
 * @author Serhii Mamontov
 * @version 4.14.1
 * @since 4.14.1
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNManageChannelMembersStatus.h"
#import "PNOperationResult+Private.h"
#import "PNChannelMember+Private.h"
#import "PNServiceData+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNManageChannelMembersStatus ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNManageChannelMembersData *data;

#pragma mark -


@end


@interface PNManageChannelMembersData ()


#pragma mark - Information

@property (nonatomic, strong) NSArray<PNChannelMember *> *members;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNManageChannelMembersData


#pragma mark - Information

- (NSArray<PNChannelMember *> *)members {
    if (!_members) {
        NSMutableArray *members = [NSMutableArray new];
        
        for (NSDictionary *member in self.serviceData[@"members"]) {
            [members addObject:[PNChannelMember memberFromDictionary:member]];
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


@implementation PNManageChannelMembersStatus


#pragma mark - Information

- (PNManageChannelMembersData *)data {
    if (!_data) {
        _data = [PNManageChannelMembersData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end
