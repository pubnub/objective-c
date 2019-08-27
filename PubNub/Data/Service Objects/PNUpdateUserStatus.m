/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNServiceData+Private.h"
#import "PNUpdateUserStatus.h"
#import "PNResult+Private.h"
#import "PNUser+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNUpdateUserStatus ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNUpdateUserData *data;

#pragma mark -


@end


@interface PNUpdateUserData ()


#pragma mark - Information

@property (nonatomic, nullable, strong) PNUser *user;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNUpdateUserData


#pragma mark - Information

- (PNUser *)user {
    if (!_user) {
        _user = [PNUser userFromDictionary:self.serviceData[@"user"]];
    }
    
    return _user;
}

#pragma mark -


@end


@implementation PNUpdateUserStatus


#pragma mark - Information

- (PNUpdateUserData *)data {
    if (!_data) {
        _data = [PNUpdateUserData dataWithServiceResponse:self.serviceData];
    }

    return _data;
}

#pragma mark -


@end
