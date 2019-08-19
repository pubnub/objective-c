/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNAPICallBuilder+Private.h"
#import "PNPrivateStructures.h"
#import "PubNub+CorePrivate.h"
#import "PNRequest+Private.h"
#import "PNResult+Private.h"
#import "PNStatus+Private.h"
#import "PNConfiguration.h"
#import "PubNub+Objects.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PubNub (ObjectsProtected)


#pragma mark - Requests helper

/**
 * @brief Perform network request.
 *
 * @param request Object which contain all required information to perform request.
 * @param block Request processing completion block.
 */
- (void)performRequest:(PNRequest *)request withCompletion:(id)block;

- (Class)errorStatusClassForRequest:(PNRequest *)request;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

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

- (PNUpdateMembershipsAPICallBuilder * (^)(void))memberships {
    PNUpdateMembershipsAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNUpdateMembershipsAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                             NSDictionary *parameters) {

        NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
        NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
        NSNumber *limit = parameters[NSStringFromSelector(@selector(limit))] ?: @(100);
        NSString *userId = parameters[NSStringFromSelector(@selector(userId))];
        
        PNUpdateMembershipsRequest *request = [PNUpdateMembershipsRequest requestWithUserID:userId];
        request.updateSpaces = parameters[NSStringFromSelector(@selector(update))];
        request.leaveSpaces = parameters[NSStringFromSelector(@selector(remove))];
        request.joinSpaces = parameters[NSStringFromSelector(@selector(add))];
        request.start = parameters[NSStringFromSelector(@selector(start))];
        request.end = parameters[NSStringFromSelector(@selector(end))];
        request.includeFields = includeFields.unsignedIntegerValue;
        request.includeCount = includeCount.boolValue;
        request.limit = limit.unsignedIntegerValue;
        
        [weakSelf updateMembershipsWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNUpdateMembershipsAPICallBuilder * {
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

- (PNUpdateMembersAPICallBuilder * (^)(void))members {
    PNUpdateMembersAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNUpdateMembersAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                         NSDictionary *parameters) {

        NSNumber *includeFields = parameters[NSStringFromSelector(@selector(includeFields))];
        NSNumber *includeCount = parameters[NSStringFromSelector(@selector(includeCount))];
        NSNumber *limit = parameters[NSStringFromSelector(@selector(limit))] ?: @(100);
        NSString *spaceId = parameters[NSStringFromSelector(@selector(spaceId))];
        
        PNUpdateMembersRequest *request = [PNUpdateMembersRequest requestWithSpaceID:spaceId];
        request.updateMembers = parameters[NSStringFromSelector(@selector(update))];
        request.removeMembers = parameters[NSStringFromSelector(@selector(remove))];
        request.addMembers = parameters[NSStringFromSelector(@selector(add))];
        request.start = parameters[NSStringFromSelector(@selector(start))];
        request.end = parameters[NSStringFromSelector(@selector(end))];
        request.includeFields = includeFields.unsignedIntegerValue;
        request.includeCount = includeCount.boolValue;
        request.limit = limit.unsignedIntegerValue;
        
        [weakSelf updateMembersWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNUpdateMembersAPICallBuilder * {
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
    
    [self performRequest:request withCompletion:block];
}

- (void)updateUserWithRequest:(PNUpdateUserRequest *)request
                   completion:(PNUpdateUserCompletionBlock)block {
    
    [self performRequest:request withCompletion:block];
}

- (void)deleteUserWithRequest:(PNDeleteUserRequest *)request
                   completion:(PNDeleteUserCompletionBlock)block {
    
    [self performRequest:request withCompletion:block];
}

- (void)fetchUserWithRequest:(PNFetchUserRequest *)request
                  completion:(PNFetchUserCompletionBlock)block {
    
    [self performRequest:request withCompletion:block];
}

- (void)fetchUsersWithRequest:(PNFetchUsersRequest *)request
                   completion:(PNFetchUsersCompletionBlock)block {
    
    [self performRequest:request withCompletion:block];
}

#pragma mark - Space object

- (void)createSpaceWithRequest:(PNCreateSpaceRequest *)request
                    completion:(PNCreateSpaceCompletionBlock)block {
    
    [self performRequest:request withCompletion:block];
}

- (void)updateSpaceWithRequest:(PNUpdateSpaceRequest *)request
                    completion:(PNUpdateSpaceCompletionBlock)block {
    
    [self performRequest:request withCompletion:block];
}

- (void)deleteSpaceWithRequest:(PNDeleteSpaceRequest *)request
                    completion:(PNDeleteSpaceCompletionBlock)block {
    
    [self performRequest:request withCompletion:block];
}

- (void)fetchSpaceWithRequest:(PNFetchSpaceRequest *)request
                   completion:(PNFetchSpaceCompletionBlock)block {
    
    [self performRequest:request withCompletion:block];
}

- (void)fetchSpacesWithRequest:(PNFetchSpacesRequest *)request
                    completion:(PNFetchSpacesCompletionBlock)block {
    
    [self performRequest:request withCompletion:block];
}


#pragma mark - Membership objects

- (void)updateMembershipsWithRequest:(PNUpdateMembershipsRequest *)request
                          completion:(PNUpdateMembershipsCompletionBlock)block {
    
    [self performRequest:request withCompletion:block];
}

- (void)fetchMembershipsWithRequest:(PNFetchMembershipsRequest *)request
                         completion:(PNFetchMembershipsCompletionBlock)block {
    
    [self performRequest:request withCompletion:block];
}

- (void)updateMembersWithRequest:(PNUpdateMembersRequest *)request
                      completion:(PNUpdateMembersCompletionBlock)block {
    
    [self performRequest:request withCompletion:block];
}

- (void)fetchMembersWithRequest:(PNFetchMembersRequest *)request
                     completion:(PNFetchMembersCompletionBlock)block {
    
    [self performRequest:request withCompletion:block];
}


#pragma mark - Misc

- (void)performRequest:(PNRequest *)request withCompletion:(id)block {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __weak __typeof(self) weakSelf = self;
    
    if (@available(macOS 10.10, iOS 8.0, *)) {
        if (self.configuration.applicationExtensionSharedGroupIdentifier) {
            queue = dispatch_get_main_queue();
        }
    }
    
    dispatch_async(queue, ^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        NSString *httpMethod = request.httpMethod.lowercaseString;
        BOOL hasBody = [@[@"post", @"patch"] indexOfObject:httpMethod] != NSNotFound;
        PNRequestParameters *parameters = request.requestParameters;
        parameters.HTTPMethod = request.httpMethod;
        NSData *data = hasBody ? request.bodyData : nil;
        
        NSError *error = request.parametersError;
        id requestCompletionBlock = nil;
        id errorStatus = nil;
        
        if (error) {
            Class errorStatusClass = [self errorStatusClassForRequest:request];
            errorStatus = [errorStatusClass objectForOperation:request.operation
                                             completedWithTask:nil
                                                 processedData:nil
                                               processingError:error];
            [(PNStatus *)errorStatus updateCategory:PNBadRequestCategory];
        }
        
        if ([request.httpMethod isEqualToString:@"GET"]) {
            requestCompletionBlock = ^(PNResult *result, PNStatus *status) {
                [strongSelf callBlock:block status:NO withResult:result andStatus:status];
            };
        } else {
            requestCompletionBlock = ^(PNStatus *status) {
                [strongSelf callBlock:block status:YES withResult:nil andStatus:status];
            };
        }
        
        if (errorStatus) {
            if ([request.httpMethod isEqualToString:@"GET"]) {
                [strongSelf callBlock:block status:NO withResult:nil andStatus:errorStatus];
            } else {
                [strongSelf callBlock:block status:YES withResult:nil andStatus:errorStatus];
            }
            
            return;
        }
        
        [self processOperation:request.operation
                withParameters:parameters
                          data:data
               completionBlock:requestCompletionBlock];
    });
}

- (Class)errorStatusClassForRequest:(PNRequest *)request {
    Class class = [PNErrorStatus class];
    
    if (PNOperationStatusClasses[request.operation]) {
        class = NSClassFromString(PNOperationStatusClasses[request.operation]);
    }
    
    return class;
}

#pragma mark -


@end
