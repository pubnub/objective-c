/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
*/
#import "PNBaseObjectsMembershipRequest+Private.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNRequest+Private.h"
#import "PNErrorCodes.h"
#import "PNDictionary.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNBaseObjectsMembershipRequest ()


#pragma mark - Information

/**
 * @brief Dictionary which is used to manage memberships / members.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableSet *> *membershipBodyPayload;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark Interface implementation

@implementation PNBaseObjectsMembershipRequest


#pragma mark - Information

- (NSString *)httpMethod {
    return @"PATCH";
}

- (NSData *)bodyData {
    if (self.parametersError) {
        return nil;
    }
    
    NSMutableDictionary *update = [NSMutableDictionary new];
    NSError *error = nil;
    NSData *data = nil;
    
    if (self.membershipBodyPayload[@"set"].count) {
        update[@"set"] = self.membershipBodyPayload[@"set"].allObjects;
    }
    
    if (self.membershipBodyPayload[@"delete"].count) {
        update[@"delete"] = self.membershipBodyPayload[@"delete"].allObjects;
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
            NSLocalizedDescriptionKey: @"Update information serialization did fail",
            NSUnderlyingErrorKey: error
        };
        
        self.parametersError = [NSError errorWithDomain:kPNAPIErrorDomain
                                                   code:kPNAPIUnacceptableParameters
                                               userInfo:errorInformation];
    }
    
    return data;
}


#pragma mark - Initialization & Configuration

- (instancetype)initWithObject:(NSString *)objectType identifier:(NSString *)identifier {
    if ((self = [super initWithObject:objectType identifier:identifier])) {
        _membershipBodyPayload = [NSMutableDictionary new];
    }
    
    return self;;
}


#pragma mark - Membership / members management

- (void)setRelationToObjects:(NSArray<NSDictionary *> *)objects ofType:(NSString *)objectType {
    NSArray *serializedObjects = [self serializedObjectType:objectType fromArray:objects];
    
    if (!self.membershipBodyPayload[@"set"]) {
        self.membershipBodyPayload[@"set"] = [NSMutableSet new];
    }
    
    [self.membershipBodyPayload[@"set"] addObjectsFromArray:serializedObjects];
}

- (void)removeRelationToObjects:(NSArray<NSString *> *)objects ofType:(NSString *)objectType {
    NSMutableArray *removeObjects = [NSMutableArray new];
    
    if (!self.membershipBodyPayload[@"delete"]) {
        self.membershipBodyPayload[@"delete"] = [NSMutableSet new];
    }
    
    for (NSString *object in objects) {
        [removeObjects addObject:@{ objectType: @{ @"id": object } }];
    }
    
    [self.membershipBodyPayload[@"delete"] addObjectsFromArray:removeObjects];
}


#pragma mark - Serialization

- (NSArray *)serializedObjectType:(NSString *)type fromArray:(NSArray<NSDictionary *> *)objects {
    NSArray<Class> *clss = @[[NSString class], [NSNumber class]];
    NSMutableArray *serializedObjects = [NSMutableArray new];
    
    for (NSDictionary *object in objects) {
        if (!((NSString *)object[type]).length) {
            continue;
        }

        NSMutableDictionary *objectData = [NSMutableDictionary new];
        NSString *identifier = object[type];
        objectData[type] = @{ @"id": identifier };

        if (((NSDictionary *)object[@"custom"]).count) {
            if ([PNDictionary isDictionary:object[@"custom"] containValueOfClasses:clss]) {
                objectData[@"custom"] = object[@"custom"];
            } else {
                NSString *reason = [NSString stringWithFormat:@"'custom' object for '%@' %@ "
                                    "membership contain not allowed data types (only NSString "
                                    "and NSNumber allowed).", identifier, type];
                NSDictionary *errorInformation = @{
                    NSLocalizedDescriptionKey: @"Object additional membership information "
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

        [serializedObjects addObject:objectData];
    }
    
    return serializedObjects;
}

#pragma mark -


@end
