/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
*/
#import "PNBaseObjectsMembershipRequest+Private.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"
#import "PNDictionary.h"
#import "PNFunctions.h"
#import "PNError.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General request for all `App Context Membership / Members` API endpoints.
@interface PNBaseObjectsMembershipRequest ()


#pragma mark - Properties

/// Dictionary which is used to manage memberships / members.
@property(strong, nonatomic) NSMutableDictionary<NSString *, NSMutableSet *> *membershipBodyPayload;

/// Error which has been identified during request configuration.
@property(strong, nullable, nonatomic) PNError *parametersError;

/// Request post body.
@property(strong, nullable, nonatomic) NSData *body;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark Interface implementation

@implementation PNBaseObjectsMembershipRequest


#pragma mark - Properties

- (TransportMethod)httpMethod {
    return TransportPATCHMethod;
}

- (NSDictionary *)headers {
    NSMutableDictionary *headers =[([super headers] ?: @{}) mutableCopy];
    headers[@"Content-Type"] = @"application/json";

    return headers;
}


#pragma mark - Initialization and Configuration

- (instancetype)initWithObject:(NSString *)objectType identifier:(NSString *)identifier {
    if ((self = [super initWithObject:objectType identifier:identifier])) {
        _membershipBodyPayload = [NSMutableDictionary new];
    }
    
    return self;
}


#pragma mark - Membership / members management

- (void)setRelationToObjects:(NSArray<NSDictionary *> *)objects ofType:(NSString *)objectType {
    NSArray *serializedObjects = [self serializedObjectType:objectType fromArray:objects];
    
    if (!self.membershipBodyPayload[@"set"]) self.membershipBodyPayload[@"set"] = [NSMutableSet new];
    [self.membershipBodyPayload[@"set"] addObjectsFromArray:serializedObjects];
}

- (void)removeRelationToObjects:(NSArray<NSString *> *)objects ofType:(NSString *)objectType {
    NSMutableArray *removeObjects = [NSMutableArray new];
    
    if (!self.membershipBodyPayload[@"delete"]) self.membershipBodyPayload[@"delete"] = [NSMutableSet new];
    for (NSString *object in objects)  [removeObjects addObject:@{ objectType: @{ @"id": object } }];
    
    [self.membershipBodyPayload[@"delete"] addObjectsFromArray:removeObjects];
}


#pragma mark - Prepare

- (PNError *)validate {
    PNError *error = [super validate] ?: self.parametersError;
    if (error) return error;
    
    NSMutableDictionary *update = [NSMutableDictionary new];
    
    if (self.membershipBodyPayload[@"set"].count) update[@"set"] = self.membershipBodyPayload[@"set"].allObjects;
    if (self.membershipBodyPayload[@"delete"].count) {
        update[@"delete"] = self.membershipBodyPayload[@"delete"].allObjects;
    }
    
    if ([NSJSONSerialization isValidJSONObject:update]) {
        self.body = [NSJSONSerialization dataWithJSONObject:update options:(NSJSONWritingOptions)0 error:&error];
    } else {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Unable to serialize to JSON string",
            NSLocalizedFailureReasonErrorKey: @"Provided object contains unsupported data type instances."
        };
        
        error = [PNError errorWithDomain:NSCocoaErrorDomain code:NSPropertyListWriteInvalidError userInfo:userInfo];
    }
    
    if (error) {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Update information serialization did fail",
            NSUnderlyingErrorKey: error
        };
        
        return [PNError errorWithDomain:PNAPIErrorDomain code:PNAPIErrorUnacceptableParameters userInfo:userInfo];
    }
    
    return nil;
}


#pragma mark - Serialization

- (NSArray *)serializedObjectType:(NSString *)type fromArray:(NSArray<NSDictionary *> *)objects {
    NSArray<Class> *clss = @[[NSString class], [NSNumber class]];
    NSMutableArray *serializedObjects = [NSMutableArray new];
    
    for (NSDictionary *object in objects) {
        if (!((NSString *)object[type]).length || self.parametersError) continue;

        NSMutableDictionary *objectData = [NSMutableDictionary new];
        NSString *identifier = object[type];
        objectData[type] = @{ @"id": identifier };

        if (((NSDictionary *)object[@"custom"]).count) {
            if ([PNDictionary isDictionary:object[@"custom"] containValueOfClasses:clss]) {
                objectData[@"custom"] = object[@"custom"];
            } else {
                NSString *reason = PNStringFormat(@"'custom' object for '%@' %@ membership contain not allowed data "
                                                  "types (only NSString and NSNumber allowed).", identifier, type);
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: @"Object additional membership information "
                                                "serialization did fail",
                    NSLocalizedFailureReasonErrorKey: reason,
                };

                self.parametersError = [PNError errorWithDomain:PNAPIErrorDomain
                                                           code:PNAPIErrorUnacceptableParameters
                                                       userInfo:userInfo];
            }
        }

        if (object[@"status"]) objectData[@"status"] = object[@"status"];
        if (object[@"type"]) objectData[@"type"] = object[@"type"];

        [serializedObjects addObject:objectData];
    }
    
    return serializedObjects;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];
    
    if (self.membershipBodyPayload[@"set"].count) dictionary[@"set"] = self.membershipBodyPayload[@"set"].allObjects;
    if (self.membershipBodyPayload[@"delete"].count)
        dictionary[@"delete"] = self.membershipBodyPayload[@"delete"].allObjects;
    
    return dictionary;
}

#pragma mark -


@end
