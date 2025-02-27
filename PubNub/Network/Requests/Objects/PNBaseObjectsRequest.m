#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNFunctions.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General request for all `App Contentx` API endpoints private extension.
@interface PNBaseObjectsRequest ()


#pragma mark - Properties

/// Bitfield set to fields which should be returned with response.
///
/// > Note: Available values depends from object type for which request created. So far following helper `types`
/// available: **PNMembershipFields**, **PNChannelMemberFields**, **PNChannelFields**, and **PNUUIDFields**.
@property(assign, nonatomic) NSUInteger includeFields;

/// Unique `object` identifier.
@property(copy, nonatomic) NSString *identifier;

/// Type of `object`.
@property(copy, nonatomic) NSString *objectType;


#pragma mark - Misc

/// Translate value of `includeFields` bitfield to actual `include` field names.
///
/// - Returns: List of names for `include` query parameter.
- (NSArray<NSString *> *)includeFieldNames;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNBaseObjectsRequest


#pragma mark - Properties

- (NSDictionary *)query {
    NSMutableDictionary *query = [NSMutableDictionary new];
    
    if (self.includeFields > 0) [self addIncludedFields:[self includeFieldNames] toQuery:query];
    if (self.arbitraryQueryParameters.count) [query addEntriesFromDictionary:self.arbitraryQueryParameters];
    
    return query.count ? query : nil;
}

- (NSString *)path {
    NSMutableString *path = [PNStringFormat(@"/v2/objects/%@/%@s", self.subscribeKey, self.objectType) mutableCopy];
    PNOperationType operation = self.operation;
    
    if (self.isIdentifierRequired) [path appendFormat:@"/%@", self.identifier];
    if (operation == PNFetchAllUUIDMetadataOperation || operation == PNFetchAllChannelsMetadataOperation) return path;
    if (operation == PNSetMembershipsOperation || operation == PNRemoveMembershipsOperation ||
        operation == PNManageMembershipsOperation || operation == PNFetchMembershipsOperation) {
        [path appendString:@"/channels"];
    }
    if (operation == PNSetChannelMembersOperation || operation == PNRemoveChannelMembersOperation ||
        operation == PNManageChannelMembersOperation || operation == PNFetchChannelMembersOperation) {
        [path appendString:@"/uuids"];
    }
    
    return path;
}

- (BOOL)isIdentifierRequired {
    return YES;
}


#pragma mark - Initialization and Configuration

- (instancetype)initWithObject:(NSString *)objectType identifier:(NSString *)identifier {
    if ((self = [super init])) {
        _identifier = [identifier copy];
        _objectType = [objectType.lowercaseString copy];
    }
    
    return self;
}


#pragma mark - Misc

- (NSArray<NSString *> *)includeFieldNames {
    NSMutableArray *fields = [NSMutableArray new];

    if ((self.includeFields & PNUUIDCustomField) == PNUUIDCustomField ||
        (self.includeFields & PNChannelCustomField) == PNChannelCustomField ||
        (self.includeFields & PNChannelMemberCustomField) == PNChannelMemberCustomField ||
        (self.includeFields & PNMembershipCustomField) == PNMembershipCustomField) {
        [fields addObject:@"custom"];
    }

    if ((self.includeFields & PNUUIDStatusField) == PNUUIDStatusField ||
        (self.includeFields & PNChannelStatusField) == PNChannelStatusField ||
        (self.includeFields & PNChannelMemberStatusField) == PNChannelMemberStatusField ||
        (self.includeFields & PNMembershipStatusField) == PNMembershipStatusField) {
        [fields addObject:@"status"];
    }

    if ((self.includeFields & PNUUIDTypeField) == PNUUIDTypeField ||
        (self.includeFields & PNChannelTypeField) == PNChannelTypeField ||
        (self.includeFields & PNChannelMemberTypeField) == PNChannelMemberTypeField ||
        (self.includeFields & PNMembershipTypeField) == PNMembershipTypeField) {
        [fields addObject:@"type"];
    }

    if ((self.includeFields & PNMembershipChannelField) == PNMembershipChannelField) {
        [fields addObject:@"channel"];
    }

    if ((self.includeFields & PNMembershipChannelCustomField) == PNMembershipChannelCustomField) {
        [fields addObject:@"channel.custom"];
    }

    if ((self.includeFields & PNMembershipChannelStatusField) == PNMembershipChannelStatusField) {
        [fields addObject:@"channel.status"];
    }

    if ((self.includeFields & PNMembershipChannelTypeField) == PNMembershipChannelTypeField) {
        [fields addObject:@"channel.type"];
    }

    if ((self.includeFields & PNChannelMemberUUIDField) == PNChannelMemberUUIDField) {
        [fields addObject:@"uuid"];
    }

    if ((self.includeFields & PNChannelMemberUUIDCustomField) == PNChannelMemberUUIDCustomField) {
        [fields addObject:@"uuid.custom"];
    }

    if ((self.includeFields & PNChannelMemberUUIDStatusField) == PNChannelMemberUUIDStatusField) {
        [fields addObject:@"uuid.status"];
    }

    if ((self.includeFields & PNChannelMemberUUIDTypeField) == PNChannelMemberUUIDTypeField) {
        [fields addObject:@"uuid.type"];
    }

    return fields;
}


#pragma mark - Prepare

- (PNError *)validate {
    if (self.identifier) {
        if (self.identifier.length > 92) {
            return [self valueTooLongErrorForParameter:self.objectType
                                       ofObjectRequest:self.objectType
                                            withLength:self.identifier.length
                                         maximumLength:92];
        }
    } else if (self.isIdentifierRequired) {
        return [self missingParameterError:@"identifier" forObjectRequest:self.objectType];
    }
    
    return nil;
}


#pragma mark - Misc

- (void)addIncludedFields:(NSArray<NSString *> *)fields toQuery:(NSMutableDictionary *)query {
    NSArray *existingFields = [query[@"include"] componentsSeparatedByString:@","] ?: @[];
    NSMutableSet *includeFields = [NSMutableSet setWithArray:existingFields];
    [includeFields addObjectsFromArray:fields];

    if (includeFields.count)
        query[@"include"] = [includeFields.allObjects componentsJoinedByString:@","];
}

#pragma mark -


@end
