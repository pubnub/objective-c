/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNAPICallBuilder+Private.h"
#import "PubNub+CorePrivate.h"
#import "PNResult+Private.h"
#import "PNStatus+Private.h"
#import "PubNub+Objects.h"


#pragma mark Interface implementation

@implementation PubNub (Objects)


#pragma mark - User Objects API builder support

- (PNCreateUserAPICallBuilder * (^)(void))createUser {
    PNCreateUserAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNCreateUserAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                      NSDictionary *parameters) {
        
        NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
        NSString *identifier = parameters[NSStringFromSelector(@selector(userId))];
        NSString *name = parameters[NSStringFromSelector(@selector(name))];
        
        PNCreateUserRequest *request = [PNCreateUserRequest requestWithUserID:identifier
                                                                         name:name];
        request.externalId = parameters[NSStringFromSelector(@selector(externalId))];
        request.profileUrl = parameters[NSStringFromSelector(@selector(profileUrl))];
        request.custom = parameters[NSStringFromSelector(@selector(custom))];
        request.email = parameters[NSStringFromSelector(@selector(email))];
        request.includeFields = includeFields.unsignedIntegerValue;
        
        [weakSelf createUserWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNCreateUserAPICallBuilder * {
        return builder;
    };
}

- (PNUpdateUserAPICallBuilder * (^)(void))updateUser {
    PNUpdateUserAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNUpdateUserAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                      NSDictionary *parameters) {

        NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
        NSString *identifier = parameters[NSStringFromSelector(@selector(userId))];
        
        PNUpdateUserRequest *request = [PNUpdateUserRequest requestWithUserID:identifier];
        request.externalId = parameters[NSStringFromSelector(@selector(externalId))];
        request.profileUrl = parameters[NSStringFromSelector(@selector(profileUrl))];
        request.custom = parameters[NSStringFromSelector(@selector(custom))];
        request.email = parameters[NSStringFromSelector(@selector(email))];
        request.name = parameters[NSStringFromSelector(@selector(name))];
        request.includeFields = includeFields.unsignedIntegerValue;
        
        [weakSelf updateUserWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNUpdateUserAPICallBuilder * {
        return builder;
    };
}

- (PNDeleteUserAPICallBuilder * (^)(void))deleteUser {
    PNDeleteUserAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNDeleteUserAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                      NSDictionary *parameters) {
        
        NSString *identifier = parameters[NSStringFromSelector(@selector(userId))];
        PNDeleteUserRequest *request = [PNDeleteUserRequest requestWithUserID:identifier];
        
        [weakSelf deleteUserWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNDeleteUserAPICallBuilder * {
        return builder;
    };
}

- (PNFetchUserAPICallBuilder * (^)(void))fetchUser {
    PNFetchUserAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNFetchUserAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                     NSDictionary *parameters) {
        
        NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
        NSString *identifier = parameters[NSStringFromSelector(@selector(userId))];
        
        PNFetchUserRequest *request = [PNFetchUserRequest requestWithUserID:identifier];
        request.includeFields = includeFields.unsignedIntegerValue;
        
        [weakSelf fetchUserWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNFetchUserAPICallBuilder * {
        return builder;
    };
}

- (PNFetchUsersAPICallBuilder * (^)(void))fetchUsers {
    PNFetchUsersAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNFetchUsersAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                      NSDictionary *parameters) {
        
        NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
        NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
        NSNumber *limit = parameters[NSStringFromSelector(@selector(limit))] ?: @(100);
        
        PNFetchUsersRequest *request = [PNFetchUsersRequest new];
        request.start = parameters[NSStringFromSelector(@selector(start))];
        request.end = parameters[NSStringFromSelector(@selector(end))];
        request.includeFields = includeFields.unsignedIntegerValue;
        request.includeCount = includeCount.boolValue;
        request.limit = limit.unsignedIntegerValue;
        
        [weakSelf fetchUsersWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNFetchUsersAPICallBuilder * {
        return builder;
    };
}


#pragma mark - Space Objects API builder support

- (PNCreateSpaceAPICallBuilder * (^)(void))createSpace {
    PNCreateSpaceAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNCreateSpaceAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                       NSDictionary *parameters) {
        
        NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
        NSString *identifier =parameters[NSStringFromSelector(@selector(spaceId))];
        NSString *name = parameters[NSStringFromSelector(@selector(name))];
        
        PNCreateSpaceRequest *request = [PNCreateSpaceRequest requestWithSpaceID:identifier
                                                                            name:name];
        request.information = parameters[NSStringFromSelector(@selector(information))];
        request.custom = parameters[NSStringFromSelector(@selector(custom))];
        request.includeFields = includeFields.unsignedIntegerValue;
        
        [weakSelf createSpaceWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNCreateSpaceAPICallBuilder * {
        return builder;
    };
}

- (PNUpdateSpaceAPICallBuilder * (^)(void))updateSpace {
    PNUpdateSpaceAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNUpdateSpaceAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                       NSDictionary *parameters) {
        
        NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
        NSString *identifier = parameters[NSStringFromSelector(@selector(spaceId))];
        
        PNUpdateSpaceRequest *request = [PNUpdateSpaceRequest requestWithSpaceID:identifier];
        request.information = parameters[NSStringFromSelector(@selector(information))];
        request.custom = parameters[NSStringFromSelector(@selector(custom))];
        request.name = parameters[NSStringFromSelector(@selector(name))];
        request.includeFields = includeFields.unsignedIntegerValue;
        
        [weakSelf updateSpaceWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNUpdateSpaceAPICallBuilder * {
        return builder;
    };
}

- (PNDeleteSpaceAPICallBuilder * (^)(void))deleteSpace {
    PNDeleteSpaceAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNDeleteSpaceAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                       NSDictionary *parameters) {
        
        NSString *identifier = parameters[NSStringFromSelector(@selector(spaceId))];
        PNDeleteSpaceRequest *request = [PNDeleteSpaceRequest requestWithSpaceID:identifier];
        
        [weakSelf deleteSpaceWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNDeleteSpaceAPICallBuilder * {
        return builder;
    };
}

- (PNFetchSpaceAPICallBuilder * (^)(void))fetchSpace {
    PNFetchSpaceAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNFetchSpaceAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                      NSDictionary *parameters) {
        
        NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
        NSString *identifier = parameters[NSStringFromSelector(@selector(spaceId))];
        
        PNFetchSpaceRequest *request = [PNFetchSpaceRequest requestWithSpaceID:identifier];
        request.includeFields = includeFields.unsignedIntegerValue;
        
        [weakSelf fetchSpaceWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNFetchSpaceAPICallBuilder * {
        return builder;
    };
}

- (PNFetchSpacesAPICallBuilder * (^)(void))fetchSpaces {
    PNFetchSpacesAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNFetchSpacesAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                       NSDictionary *parameters) {
        
        NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
        NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
        NSNumber *limit = parameters[NSStringFromSelector(@selector(limit))] ?: @(100);
        
        PNFetchSpacesRequest *request = [PNFetchSpacesRequest new];
        request.start = parameters[NSStringFromSelector(@selector(start))];
        request.end = parameters[NSStringFromSelector(@selector(end))];
        request.includeFields = includeFields.unsignedIntegerValue;
        request.includeCount = includeCount.boolValue;
        request.limit = limit.unsignedIntegerValue;
        
        [weakSelf fetchSpacesWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNFetchSpacesAPICallBuilder * {
        return builder;
    };
}


#pragma mark - Membership objects

- (PNManageMembershipsAPICallBuilder * (^)(void))manageMemberships {
    PNManageMembershipsAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNManageMembershipsAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                             NSDictionary *parameters) {

        NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
        NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
        NSNumber *limit = parameters[NSStringFromSelector(@selector(limit))] ?: @(100);
        NSString *userId = parameters[NSStringFromSelector(@selector(userId))];
        
        PNManageMembershipsRequest *request = [PNManageMembershipsRequest requestWithUserID:userId];
        request.updateSpaces = parameters[NSStringFromSelector(@selector(update))];
        request.leaveSpaces = parameters[NSStringFromSelector(@selector(remove))];
        request.joinSpaces = parameters[NSStringFromSelector(@selector(add))];
        request.start = parameters[NSStringFromSelector(@selector(start))];
        request.end = parameters[NSStringFromSelector(@selector(end))];
        request.includeFields = includeFields.unsignedIntegerValue;
        request.includeCount = includeCount.boolValue;
        request.limit = limit.unsignedIntegerValue;
        
        [weakSelf manageMembershipsWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNManageMembershipsAPICallBuilder * {
        return builder;
    };
}

- (PNFetchMembershipsAPICallBuilder * (^)(void))fetchMemberships {
    PNFetchMembershipsAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNFetchMembershipsAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                            NSDictionary *parameters) {
        
        NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
        NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
        NSNumber *limit = parameters[NSStringFromSelector(@selector(limit))] ?: @(100);
        NSString *userId = parameters[NSStringFromSelector(@selector(userId))];
        
        PNFetchMembershipsRequest *request = [PNFetchMembershipsRequest requestWithUserID:userId];
        request.start = parameters[NSStringFromSelector(@selector(start))];
        request.end = parameters[NSStringFromSelector(@selector(end))];
        request.includeFields = includeFields.unsignedIntegerValue;
        request.includeCount = includeCount.boolValue;
        request.limit = limit.unsignedIntegerValue;
        
        [weakSelf fetchMembershipsWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNFetchMembershipsAPICallBuilder * {
        return builder;
    };
}

- (PNManageMembersAPICallBuilder * (^)(void))manageMembers {
    PNManageMembersAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNManageMembersAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                         NSDictionary *parameters) {

        NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
        NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
        NSNumber *limit = parameters[NSStringFromSelector(@selector(limit))] ?: @(100);
        NSString *spaceId = parameters[NSStringFromSelector(@selector(spaceId))];
        
        PNManageMembersRequest *request = [PNManageMembersRequest requestWithSpaceID:spaceId];
        request.updateMembers = parameters[NSStringFromSelector(@selector(update))];
        request.removeMembers = parameters[NSStringFromSelector(@selector(remove))];
        request.addMembers = parameters[NSStringFromSelector(@selector(add))];
        request.start = parameters[NSStringFromSelector(@selector(start))];
        request.end = parameters[NSStringFromSelector(@selector(end))];
        request.includeFields = includeFields.unsignedIntegerValue;
        request.includeCount = includeCount.boolValue;
        request.limit = limit.unsignedIntegerValue;
        
        [weakSelf manageMembersWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNManageMembersAPICallBuilder * {
        return builder;
    };
}

- (PNFetchMembersAPICallBuilder * (^)(void))fetchMembers {
    PNFetchMembersAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNFetchMembersAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                        NSDictionary *parameters) {
        
        NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
        NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
        NSNumber *limit = parameters[NSStringFromSelector(@selector(limit))] ?: @(100);
        NSString *spaceId = parameters[NSStringFromSelector(@selector(spaceId))];
        
        PNFetchMembersRequest *request = [PNFetchMembersRequest requestWithSpaceID:spaceId];
        request.start = parameters[NSStringFromSelector(@selector(start))];
        request.end = parameters[NSStringFromSelector(@selector(end))];
        request.includeFields = includeFields.unsignedIntegerValue;
        request.includeCount = includeCount.boolValue;
        request.limit = limit.unsignedIntegerValue;
        
        [weakSelf fetchMembersWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNFetchMembersAPICallBuilder * {
        return builder;
    };
}


#pragma mark - User object

- (void)createUserWithRequest:(PNCreateUserRequest *)request
                   completion:(PNCreateUserCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNCreateUserStatus *status) {
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf createUserWithRequest:request completion:block];
            };
        }
        
        block(status);
    }];
}

- (void)updateUserWithRequest:(PNUpdateUserRequest *)request
                   completion:(PNUpdateUserCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNUpdateUserStatus *status) {
        if (block && status.isError) {
            status.retryBlock = ^{
                [weakSelf updateUserWithRequest:request completion:block];
            };
        }
        
        if (block) {
            block(status);
        }
    }];
}

- (void)deleteUserWithRequest:(PNDeleteUserRequest *)request
                   completion:(PNDeleteUserCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNAcknowledgmentStatus *status) {
        if (block && status.isError) {
            status.retryBlock = ^{
                [weakSelf deleteUserWithRequest:request completion:block];
            };
        }
        
        if (block) {
            block(status);
        }
    }];
}

- (void)fetchUserWithRequest:(PNFetchUserRequest *)request
                  completion:(PNFetchUserCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request
          withCompletion:^(PNFetchUserResult *result, PNErrorStatus *status) {
              
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf fetchUserWithRequest:request completion:block];
            };
        }

        block(result, status);
    }];
}

- (void)fetchUsersWithRequest:(PNFetchUsersRequest *)request
                   completion:(PNFetchUsersCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request
          withCompletion:^(PNFetchUsersResult *result, PNErrorStatus *status) {
        
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf fetchUsersWithRequest:request completion:block];
            };
        }
        
        block(result, status);
    }];
}

#pragma mark - Space object

- (void)createSpaceWithRequest:(PNCreateSpaceRequest *)request
                    completion:(PNCreateSpaceCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNCreateSpaceStatus *status) {
        if (block && status.isError) {
            status.retryBlock = ^{
                [weakSelf createSpaceWithRequest:request completion:block];
            };
        }
        
        if (block) {
            block(status);
        }
    }];
}

- (void)updateSpaceWithRequest:(PNUpdateSpaceRequest *)request
                    completion:(PNUpdateSpaceCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNUpdateSpaceStatus *status) {
        if (block && status.isError) {
            status.retryBlock = ^{
                [weakSelf updateSpaceWithRequest:request completion:block];
            };
        }
        
        if (block) {
            block(status);
        }
    }];
}

- (void)deleteSpaceWithRequest:(PNDeleteSpaceRequest *)request
                    completion:(PNDeleteSpaceCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNAcknowledgmentStatus *status) {
        if (block && status.isError) {
            status.retryBlock = ^{
                [weakSelf deleteSpaceWithRequest:request completion:block];
            };
        }
        
        if (block) {
            block(status);
        }
    }];
}

- (void)fetchSpaceWithRequest:(PNFetchSpaceRequest *)request
                   completion:(PNFetchSpaceCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request
          withCompletion:^(PNFetchSpaceResult *result, PNErrorStatus *status) {
        
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf fetchSpaceWithRequest:request completion:block];
            };
        }
        
        block(result, status);
    }];
}

- (void)fetchSpacesWithRequest:(PNFetchSpacesRequest *)request
                    completion:(PNFetchSpacesCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request
          withCompletion:^(PNFetchSpacesResult *result, PNErrorStatus *status) {
        
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf fetchSpacesWithRequest:request completion:block];
            };
        }
        
        block(result, status);
    }];
}


#pragma mark - Membership objects

- (void)manageMembershipsWithRequest:(PNManageMembershipsRequest *)request
                          completion:(PNManageMembershipsCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNManageMembershipsStatus *status) {
        if (block && status.isError) {
            status.retryBlock = ^{
                [weakSelf manageMembershipsWithRequest:request completion:block];
            };
        }
        
        if (block) {
            block(status);
        }
    }];
}

- (void)fetchMembershipsWithRequest:(PNFetchMembershipsRequest *)request
                         completion:(PNFetchMembershipsCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request
          withCompletion:^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
        
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf fetchMembershipsWithRequest:request completion:block];
            };
        }
        
        block(result, status);
    }];
}

- (void)manageMembersWithRequest:(PNManageMembersRequest *)request
                      completion:(PNManageMembersCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNManageMembersStatus *status) {
        if (block && status.isError) {
            status.retryBlock = ^{
                [weakSelf manageMembersWithRequest:request completion:block];
            };
        }
        
        if (block) {
            block(status);
        }
    }];
}

- (void)fetchMembersWithRequest:(PNFetchMembersRequest *)request
                     completion:(PNFetchMembersCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request
          withCompletion:^(PNFetchMembersResult *result, PNErrorStatus *status) {
        
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf fetchMembersWithRequest:request completion:block];
            };
        }
        
        block(result, status);
    }];
}

#pragma mark -


@end
