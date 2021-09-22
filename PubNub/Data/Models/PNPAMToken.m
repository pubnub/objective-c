/**
 * @author Serhii Mamontov
 * @version 4.17.0
 * @since 4.17.0
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PNPAMToken+Private.h"
#import "PNCBORDecoder.h"
#import "PNErrorCodes.h"
#import "PNString.h"


#pragma mark Types & Structures

typedef NSDictionary<NSString *, NSNumber *> PAMResourcesDictionary;


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNPAMResourcePermission ()


#pragma mark - Information

@property (nonatomic, assign) PNPAMPermission value;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure resource permission representation instance.
 *
 * @param permission Bit fields which specify permissions granted to resource.
 *
 * @return Initialized and ready to use permission object.
 */
+ (instancetype)permissionWithValue:(PNPAMPermission)permission;

/**
 * @brief Initialize resource permission representation instance.
 *
 * @param permission Bit fields which specify permissions granted to resource.
 *
 * @return Initalized and ready to use permission object.
 */
- (instancetype)initWithValue:(PNPAMPermission)permission;

#pragma mark -


@end

@interface PNPAMTokenResource ()


#pragma mark - Information

@property (nonatomic, strong) NSDictionary<NSString *, PNPAMResourcePermission *> *channels;
@property (nonatomic, strong) NSDictionary<NSString *, PNPAMResourcePermission *> *groups;
@property (nonatomic, strong) NSDictionary<NSString *, PNPAMResourcePermission *> *uuids;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize resource permission representation instance.
 *
 * @param permission Bit fields which specify permissions granted to resource.
 *
 * @return Initialized and ready to use permission object.
 */
- (instancetype)initWithResources:(NSDictionary<NSString *, PAMResourcesDictionary *> *)permission;

/**
 * @brief Process PAM token content for easier consumption.
 *
 * @param permissions Dictionary with resource identifiers and their permissions as values.
 *
 * @return Processed resources permissions.
 */
- (NSDictionary<NSString *, PNPAMResourcePermission *> *)resourcePermissionsFrom:(PAMResourcesDictionary *)permissions;

#pragma mark -


@end


@interface PNPAMToken ()


#pragma mark - Information

/**
 * @brief Dictionary which has been encoded as CBOR data item and hold permissions information.
 */
@property (nonatomic, nullable, strong) NSDictionary *parsedToken;

@property (nonatomic, strong) PNPAMTokenResource *resources;
@property (nonatomic, strong) PNPAMTokenResource *patterns;

/**
 * @brief Binary token representation.
 */
@property (nonatomic, strong) NSData *tokenData;

@property (nonatomic, nullable, strong) NSError *error;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize PubNub access token description object.
 *
 * @param string PAM token encoded as Base64 string.
 * @param uuid \c uuid which used by target \b PubNub instance.
 *
 * @return Initialized and ready to use \c token representation model.
 */
- (instancetype)initFromBase64String:(NSString *)string forUUID:(NSString *)uuid;


#pragma mark - Processing

/**
 * @brief Process CBOR data items encoded in token data.
 */
- (void)processTokenData;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNPAMResourcePermission


#pragma mark - Initialization & Configuration

+ (instancetype)permissionWithValue:(PNPAMPermission)permission {
    return [[self alloc] initWithValue:permission];
}

- (instancetype)initWithValue:(PNPAMPermission)permission {
    if ((self = [super init])) {
        _value = permission;
    }
    
    return self;
}

- (NSString *)description {
    NSMutableArray<NSString *> *permissions = [NSMutableArray new];
    
    if (self.value == PNPAMPermissionNone) {
        return @"[none]";
    }
    
    if (self.value == PNPAMPermissionAll) {
        return @"[all]";
    }
    
    if (self.value & PNPAMPermissionRead) {
        [permissions addObject:@"read"];
    }
    
    if (self.value & PNPAMPermissionWrite) {
        [permissions addObject:@"write"];
    }
    
    if (self.value & PNPAMPermissionManage) {
        [permissions addObject:@"manage"];
    }
    
    if (self.value & PNPAMPermissionDelete) {
        [permissions addObject:@"delete"];
    }
    
    if (self.value & PNPAMPermissionGet) {
        [permissions addObject:@"get"];
    }
    
    if (self.value & PNPAMPermissionUpdate) {
        [permissions addObject:@"update"];
    }
    
    if (self.value & PNPAMPermissionJoin) {
        [permissions addObject:@"join"];
    }
    
    return [permissions componentsJoinedByString:@", "];
}

#pragma mark -


@end


@implementation PNPAMTokenResource


#pragma mark - Initialization & Configuration

- (instancetype)initWithResources:(NSDictionary<NSString *, PAMResourcesDictionary *> *)resourcesPermission {
    if ((self = [super init])) {
        _channels = [self resourcePermissionsFrom:resourcesPermission[@"chan"]];
        _groups = [self resourcePermissionsFrom:resourcesPermission[@"grp"]];
        _uuids = [self resourcePermissionsFrom:resourcesPermission[@"uuid"]];
    }
    
    return self;
}

- (NSDictionary<NSString *, PNPAMResourcePermission *> *)resourcePermissionsFrom:(PAMResourcesDictionary *)permissions {
    NSMutableDictionary *resourcePermissions = [NSMutableDictionary new];
    
    [permissions enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, NSNumber *accessBits, BOOL *stop) {
        resourcePermissions[identifier] = [PNPAMResourcePermission permissionWithValue:accessBits.unsignedIntegerValue];
    }];
    
    return resourcePermissions;
}


#pragma mark - Misc

- (NSString *)description {
    NSMutableString *channels = [NSMutableString new];
    NSMutableString *groups = [NSMutableString new];
    NSMutableString *uuids = [NSMutableString new];
    
    [self.channels enumerateKeysAndObjectsUsingBlock:^(NSString *channel, PNPAMResourcePermission *permission, BOOL *stop) {
        [channels appendFormat:@"\n\t\t\t- %@: %@", channel, permission.description];
    }];
    
    [self.groups enumerateKeysAndObjectsUsingBlock:^(NSString *group, PNPAMResourcePermission *permission, BOOL *stop) {
        [groups appendFormat:@"\n\t\t\t- %@: %@", group, permission.description];
    }];
    
    [self.uuids enumerateKeysAndObjectsUsingBlock:^(NSString *uuid, PNPAMResourcePermission *permission, BOOL *stop) {
        [uuids appendFormat:@"\n\t\t\t- %@: %@", uuid, permission.description];
    }];
    
    return [NSString stringWithFormat:@"\n\t\t- channels: %@"
            "\n\t\t- channel groups: %@"
            "\n\t\t- uuids: %@",
            channels, groups, uuids];
}


#pragma mark -


@end


@implementation PNPAMToken


#pragma mark - Information

- (NSUInteger)version {
    return ((NSNumber *)self.parsedToken[@"v"]).unsignedIntegerValue;
}

- (NSUInteger)timestamp {
    return ((NSNumber *)self.parsedToken[@"t"]).unsignedIntegerValue;
}

- (NSUInteger)ttl {
    return ((NSNumber *)self.parsedToken[@"ttl"]).unsignedIntegerValue;
}

- (NSString *)authorizedUUID {
    return self.parsedToken[@"uuid"];
}


- (NSDictionary *)meta {
    return self.parsedToken[@"meta"];
}

- (NSData *)signature {
    return self.parsedToken[@"sig"];
}


#pragma mark - Initialization & Configuration

+ (instancetype)tokenFromBase64String:(NSString *)string forUUID:(NSString *)uuid {
    return [[self alloc] initFromBase64String:string forUUID:uuid];
}

- (instancetype)initFromBase64String:(NSString *)string forUUID:(NSString *)uuid {
    if ((self = [super init])) {
        NSString *token = [PNString base64StringFromURLFriendlyBase64String:string];
        
        if (token) {
            _tokenData = [[NSData alloc] initWithBase64EncodedString:token options:(NSDataBase64DecodingOptions)0];
        }
        
        [self processTokenData];
        
        if (uuid.length && self.authorizedUUID.length && ![self.authorizedUUID isEqualToString:uuid]) {
            NSDictionary *userInfo = @{
                NSLocalizedFailureReasonErrorKey: @"PAM token invalid.",
                NSLocalizedDescriptionKey: [NSString stringWithFormat:@"PAM token provided for %@ but %@ is used by "
                                            "current PubNub instance.",
                                            self.authorizedUUID, uuid]
            };
            self.error = [NSError errorWithDomain:kPNAPIErrorDomain
                                             code:kPNAuthPAMTokenWrongUUIDError
                                         userInfo:userInfo];
        }
    }
    
    return self;
}


#pragma mark - Processing

- (void)processTokenData {
    PNCBORDecoder *decoder = [PNCBORDecoder decoderWithCBORData:self.tokenData];
    NSError *error;
    id value = [decoder decodeWithError:&error];
    
    if (!error && [value isKindOfClass:[NSDictionary class]]) {
        self.parsedToken = value;
    } else if (!error) {
        NSDictionary *userInfo = @{
            NSLocalizedFailureReasonErrorKey: @"The given data top-level value has unexpected type.",
            NSLocalizedDescriptionKey: [NSString stringWithFormat:@"PAM token should be parsed as NSDictionary, but got %@",
                                        NSStringFromClass([value class])]
        };
        error = [NSError errorWithDomain:kPNCBORErrorDomain
                                    code:kPNCBORUnexpectedDataTypeError
                                userInfo:userInfo];
    }
    
    if (self.parsedToken && error == nil) {
        self.resources = [[PNPAMTokenResource alloc] initWithResources:self.parsedToken[@"res"]];
        self.patterns = [[PNPAMTokenResource alloc] initWithResources:self.parsedToken[@"pat"]];
    }
    
    NSTimeInterval tokenExpiration = self.timestamp + self.ttl * 60.f;
    NSTimeInterval currentDate = [NSDate date].timeIntervalSince1970;

    if (self.timestamp > 0 && currentDate > tokenExpiration) {
        NSDictionary *userInfo = @{
            NSLocalizedFailureReasonErrorKey: @"PAM token invalid.",
            NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Provided PAM token expired %@ seconds ago.",
                                        @(currentDate - tokenExpiration)]
        };
        error = [NSError errorWithDomain:kPNAuthErrorDomain
                                    code:kPNAuthPAMTokenExpiredError
                                userInfo:userInfo];
    }
    
    self.error = error;
}


#pragma mark - Misc

- (NSString *)description {
    if (self.error) {
        return [NSString stringWithFormat:@"Access token not parsed because of error: %@", self.error];
    }
    
    NSData *metaJSONData = [NSJSONSerialization dataWithJSONObject:self.meta options:(NSJSONWritingOptions)0 error:nil];
    
    return [NSString stringWithFormat:@"PubNub Access Token content:"
            "\n\t- Issue date: %@ (%@)"
            "\n\t- Expiration date: %@ (%@)"
            "\n\t- Authorized UUID: %@"
            "\n\t- Resources: %@"
            "\n\t- Patterns: %@"
            "\n\t- Metadata: %@"
            "\n\t- Token version: %@"
            "\n\t- Signature: %@",
            [NSDate dateWithTimeIntervalSince1970:self.timestamp], @(self.timestamp),
            [NSDate dateWithTimeIntervalSince1970:(self.timestamp+self.ttl*60)], @(self.timestamp+self.ttl*60),
            self.authorizedUUID,
            self.resources.description,
            self.patterns.description,
            [[NSString alloc] initWithData:metaJSONData encoding:NSUTF8StringEncoding],
            @(self.version),
            self.signature];
}

#pragma mark -


@end
