/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNServiceData+Private.h"
#import "PNFetchUsersResult.h"
#import "PNResult+Private.h"
#import "PNUser+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNFetchUserResult ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNFetchUserData *data;

#pragma mark -


@end


@interface PNFetchUsersResult ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNFetchUsersData *data;

#pragma mark -


@end


@interface PNFetchUserData ()


#pragma mark - Information

@property (nonatomic, nullable, strong) PNUser *user;

#pragma mark -


@end


@interface PNFetchUsersData ()


#pragma mark - Information

@property (nonatomic, strong) NSArray<PNUser *> *users;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNFetchUserData


#pragma mark - Information

- (PNUser *)user {
    if (!_user) {
        _user = [PNUser userFromDictionary:self.serviceData[@"user"]];
    }
    
    return _user;
}

#pragma mark -


@end


@implementation PNFetchUsersData


#pragma mark - Information

- (NSArray<PNUser *> *)users {
    if (!_users) {
        NSMutableArray *users = [NSMutableArray new];
        
        for (NSDictionary *user in self.serviceData[@"users"]) {
            [users addObject:[PNUser userFromDictionary:user]];
        }
        
        _users = [users copy];
    }
    
    return _users;
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


@implementation PNFetchUserResult


#pragma mark - Information

- (PNFetchUserData *)data {
    if (!_data) {
        _data = [PNFetchUserData dataWithServiceResponse:self.serviceData];
    }

    return _data;
}

#pragma mark -


@end


@implementation PNFetchUsersResult


#pragma mark - Information

- (PNFetchUsersData *)data {
    if (!_data) {
        _data = [PNFetchUsersData dataWithServiceResponse:self.serviceData];
    }

    return _data;
}

#pragma mark -


@end
