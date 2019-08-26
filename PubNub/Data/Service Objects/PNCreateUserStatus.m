/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNServiceData+Private.h"
#import "PNCreateUserStatus.h"
#import "PNResult+Private.h"
#import "PNUser+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNCreateUserStatus ()


#pragma mark - Information

@property (nonatomic, strong) PNCreateUserData *data;

#pragma mark -


@end


@interface PNCreateUserData ()


#pragma mark - Information

@property (nonatomic, strong) PNUser *user;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark Interfaces implementation

@implementation PNCreateUserData


#pragma mark - Information

- (PNUser *)user {
    if (!_user) {
        _user = [PNUser userFromDictionary:self.serviceData[@"user"]];
    }
    
    return _user;
}

#pragma mark -


@end


@implementation PNCreateUserStatus


#pragma mark - Information

- (PNCreateUserData *)data {
    if (!_data) {
        _data = [PNCreateUserData dataWithServiceResponse:self.serviceData];
    }

    return _data;
}

#pragma mark -


@end
