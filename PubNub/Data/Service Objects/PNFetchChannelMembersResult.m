/**
 * @author Serhii Mamontov
 * @version 4.14.1
 * @since 4.14.1
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNServiceData+Private.h"
#import "PNFetchChannelMembersResult.h"
#import "PNResult+Private.h"
#import "PNChannelMember+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNFetchChannelMembersResult ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNFetchChannelMembersData *data;

#pragma mark -


@end


@interface PNFetchChannelMembersData ()


#pragma mark - Information

@property (nonatomic, strong) NSArray<PNChannelMember *> *members;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNFetchChannelMembersData


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


@implementation PNFetchChannelMembersResult


#pragma mark - Information

- (PNFetchChannelMembersData *)data {
    if (!_data) {
        _data = [PNFetchChannelMembersData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end
