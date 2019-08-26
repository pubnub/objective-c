/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNManageMembersRequest.h"
#import "PNRequest+Private.h"
#import "PNErrorCodes.h"
#import "PNDictionary.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNManageMembersRequest ()


#pragma mark - Serialization

/**
 * @brief Serialize input array of \c user dictionaries into structure required by API.
 *
 * @note This method check provided \c custom field value and create \b parametersError if it
 * contain not allowed data types. If \b parametersError is set, method won't process passed
 * \c spaces.
 *
 * @param users List of \c user dictionaries which should be serialized.
 *
 * @return Objects which describe \c users in required by Objects API structure.
 */
- (NSArray *)serializedUsersFromArray:(NSArray<NSDictionary *> *)users;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNManageMembersRequest


#pragma mark - Information

@dynamic includeFields;


- (PNOperationType)operation {
    return PNManageMembersOperation;
}

- (NSString *)httpMethod {
    return @"PATCH";
}

- (NSData *)bodyData {
    NSArray *updatedMembers = [self serializedUsersFromArray:self.updateMembers];
    NSArray *addMembers = [self serializedUsersFromArray:self.addMembers];
    NSMutableArray *removedMembers = [NSMutableArray new];
    
    for (NSString *memberId in self.removeMembers) {
        [removedMembers addObject:@{ @"id": memberId }];
    }
    
    if (self.parametersError) {
        return nil;
    }
    
    NSMutableDictionary *update = [NSMutableDictionary new];
    NSError *error = nil;
    NSData *data = nil;
    
    if (addMembers.count) {
        update[@"add"] = addMembers;
    }
    
    if (updatedMembers.count) {
        update[@"update"] = updatedMembers;
    }
    
    if (removedMembers.count) {
        update[@"remove"] = removedMembers;
    }
    
    if ([NSJSONSerialization isValidJSONObject:update]) {
        data = [NSJSONSerialization dataWithJSONObject:update
                                               options:(NSJSONWritingOptions)0
                                                 error:&error];
    } else {
        NSDictionary *errorInformation = @{
            NSLocalizedDescriptionKey: @"Unable to serialize to JSON string",
            NSLocalizedFailureReasonErrorKey: @"Provided object contains unsupported data type "
                                               "instances."
        };
        
        error = [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:NSPropertyListWriteInvalidError
                                userInfo:errorInformation];
    }
    
    if (error) {
        NSDictionary *errorInformation = @{
            NSLocalizedDescriptionKey: @"Members update information serialization did fail",
            NSUnderlyingErrorKey: error
        };
        
        self.parametersError = [NSError errorWithDomain:kPNAPIErrorDomain
                                                   code:kPNAPIUnacceptableParameters
                                               userInfo:errorInformation];
    }
    
    return data;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithSpaceID:(NSString *)identifier {
    return [[self alloc] initWithObject:@"Space" identifier:identifier];
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    
    return nil;
}


#pragma mark - Serialization

- (NSArray *)serializedUsersFromArray:(NSArray<NSDictionary *> *)users {
    NSArray<Class> *clss = @[[NSString class], [NSNumber class]];
    NSMutableArray *serializedMembers = [NSMutableArray new];
    
    for (NSDictionary *user in users) {
        if (((NSString *)user[@"userId"]).length) {
            NSMutableDictionary *userData = [@{ @"id": user[@"userId"] } mutableCopy];
            BOOL isValidCustom = [PNDictionary isDictionary:user[@"custom"]
                                      containValueOfClasses:clss];
            
            if (((NSDictionary *)user[@"custom"]).count) {
                if (isValidCustom) {
                    userData[@"custom"] = user[@"custom"];
                } else {
                    NSString *reason = [NSString stringWithFormat:@"'custom' object for '%@' "
                                        "medmber contain not allowed data types (only NSString "
                                        "and NSNumber allowed).", user[@"userId"]];
                    NSDictionary *errorInformation = @{
                        NSLocalizedDescriptionKey: @"User additional member information "
                                                    "serialization did fail",
                        NSLocalizedFailureReasonErrorKey: reason,
                    };
                    
                    self.parametersError = [NSError errorWithDomain:kPNAPIErrorDomain
                                                               code:kPNAPIUnacceptableParameters
                                                           userInfo:errorInformation];
                }
            }
            
            if (self.parametersError) {
                break;
            }
            
            [serializedMembers addObject:userData];
        }
    }
    
    return serializedMembers;
}

#pragma mark -


@end
