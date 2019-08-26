/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNManageMembershipsRequest.h"
#import "PNRequest+Private.h"
#import "PNErrorCodes.h"
#import "PNDictionary.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNManageMembershipsRequest ()


#pragma mark - Serialization

/**
 * @brief Serialize input array of \c space dictionaries into structure required by API.
 *
 * @note This method check provided \c custom field value and create \b parametersError if it
 * contain not allowed data types. If \b parametersError is set, method won't process passed
 * \c spaces.
 *
 * @param spaces List of \c space dictionaries which should be serialized.
 *
 * @return Objects which describe \c spaces in required by Objects API structure.
 */
- (NSArray *)serializedSpacesFromArray:(NSArray<NSDictionary *> *)spaces;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNManageMembershipsRequest


#pragma mark - Information

@dynamic includeFields;


- (PNOperationType)operation {
    return PNManageMembershipsOperation;
}

- (NSString *)httpMethod {
    return @"PATCH";
}

- (NSData *)bodyData {
    NSArray *updatedSpaces = [self serializedSpacesFromArray:self.updateSpaces];
    NSArray *addSpaces = [self serializedSpacesFromArray:self.joinSpaces];
    NSMutableArray *removedSpaces = [NSMutableArray new];
    
    for (NSString *spaceId in self.leaveSpaces) {
        [removedSpaces addObject:@{ @"id": spaceId }];
    }
    
    if (self.parametersError) {
        return nil;
    }
    
    NSMutableDictionary *update = [NSMutableDictionary new];
    NSError *error = nil;
    NSData *data = nil;
    
    if (addSpaces.count) {
        update[@"add"] = addSpaces;
    }
    
    if (updatedSpaces.count) {
        update[@"update"] = updatedSpaces;
    }
    
    if (removedSpaces.count) {
        update[@"remove"] = removedSpaces;
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
            NSLocalizedDescriptionKey: @"Memberships update information serialization did fail",
            NSUnderlyingErrorKey: error
        };
        
        self.parametersError = [NSError errorWithDomain:kPNAPIErrorDomain
                                                   code:kPNAPIUnacceptableParameters
                                               userInfo:errorInformation];
    }
    
    return data;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithUserID:(NSString *)identifier {
    return [[self alloc] initWithObject:@"User" identifier:identifier];
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    
    return nil;
}


#pragma mark - Serialization

- (NSArray *)serializedSpacesFromArray:(NSArray<NSDictionary *> *)spaces {
    NSArray<Class> *clss = @[[NSString class], [NSNumber class]];
    NSMutableArray *serializedSpaces = [NSMutableArray new];
    
    for (NSDictionary *space in spaces) {
        if (((NSString *)space[@"spaceId"]).length) {
            NSMutableDictionary *spaceData = [@{ @"id": space[@"spaceId"] } mutableCopy];
            BOOL isValidCustom = [PNDictionary isDictionary:space[@"custom"]
                                      containValueOfClasses:clss];
            
            if (((NSDictionary *)space[@"custom"]).count) {
                if (isValidCustom) {
                    spaceData[@"custom"] = space[@"custom"];
                } else {
                    NSString *reason = [NSString stringWithFormat:@"'custom' object for '%@' space "
                                        "membership contain not allowed data types (only NSString "
                                        "and NSNumber allowed).", space[@"spaceId"]];
                    NSDictionary *errorInformation = @{
                        NSLocalizedDescriptionKey: @"User additional membership information "
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
            
            [serializedSpaces addObject:spaceData];
        }
    }
    
    return serializedSpaces;
}

#pragma mark -


@end
