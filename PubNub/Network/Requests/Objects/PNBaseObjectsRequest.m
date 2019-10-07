/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNRequest+Private.h"
#import "PNErrorCodes.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNBaseObjectsRequest ()


#pragma mark - Information

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Available values depends from object type for which request created. So far following
 *   helper \a types available: \b PNMembershipFields, \b PNMemberFields,
 *   \b PNSpaceFields, \b PNUserFields.
 * @note Omit this property if you don't want to retrieve additional attributes.
 */
@property (nonatomic, assign) NSUInteger includeFields;

/**
 * @brief Unique \c object identifier.
 */
@property (nonatomic, copy) NSString *identifier;

/**
 * @brief Type of \c object.
 */
@property (nonatomic, copy) NSString *objectType;


#pragma mark - Misc

/**
 * @brief Translate value of \c includeFields bitfield to actual \c include field names.
 *
 * @return List of names for \c include query parameter.
 */
- (NSArray<NSString *> *)includeFieldNames;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNBaseObjectsRequest


#pragma mark - Information

- (PNRequestParameters *)requestParameters {
    PNRequestParameters *parameters = [super requestParameters];

    if (self.includeFields > 0) {
        [self addIncludedFields:[self includeFieldNames] toRequest:parameters];
    }
    
    if (self.identifier) {
        NSString *idKeyName = [@[self.objectType, @"id"] componentsJoinedByString:@"-"];
        NSString *placeholder = [@[@"{", idKeyName, @"}"] componentsJoinedByString:@""];
        
        [parameters addPathComponent:self.identifier forPlaceholder:placeholder];
    }

    return parameters;
}


#pragma mark - Initialization & Configuration

- (instancetype)initWithObject:(NSString *)objectType identifier:(NSString *)identifier {
    if ((self = [super init])) {
        _identifier = [identifier copy];
        _objectType = [objectType.lowercaseString copy];
        NSString *idKey = [@[self.objectType, @"id"] componentsJoinedByString:@"-"];
        
        if (!_identifier.length) {
            self.parametersError = [self missingParameterError:idKey forObjectRequest:objectType];
        } else if (_identifier.length > 92) {
            self.parametersError = [self valueTooLongErrorForParameter:idKey
                                                       ofObjectRequest:objectType
                                                            withLength:_identifier.length
                                                         maximumLength:36];
        }
    }
    
    return self;
}


#pragma mark - Misc

- (NSArray<NSString *> *)includeFieldNames {
    NSMutableArray *fields = [NSMutableArray new];
    
    if ((self.includeFields & PNUserCustomField) == PNUserCustomField ||
        (self.includeFields & PNSpaceCustomField) == PNSpaceCustomField) {
        [fields addObject:@"custom"];
    }
    
    if ((self.includeFields & PNMembershipCustomField) == PNMembershipCustomField ||
        (self.includeFields & PNMembershipSpaceField) == PNMembershipSpaceField ||
        (self.includeFields & PNMembershipSpaceCustomField) == PNMembershipSpaceCustomField) {
        
        if ((self.includeFields & PNMembershipCustomField) == PNMembershipCustomField) {
            [fields addObject:@"custom"];
        }
        
        if ((self.includeFields & PNMembershipSpaceField) == PNMembershipSpaceField) {
            [fields addObject:@"space"];
        }
        
        if ((self.includeFields & PNMembershipSpaceCustomField) == PNMembershipSpaceCustomField) {
            [fields addObject:@"space.custom"];
        }
    }
    
    if ((self.includeFields & PNMemberCustomField) == PNMemberCustomField ||
        (self.includeFields & PNMemberUserField) == PNMemberUserField ||
        (self.includeFields & PNMemberUserCustomField) == PNMemberUserCustomField) {
        
        if ((self.includeFields & PNMemberCustomField) == PNMemberCustomField) {
            [fields addObject:@"custom"];
        }
        
        if ((self.includeFields & PNMemberUserField) == PNMemberUserField) {
            [fields addObject:@"user"];
        }
        
        if ((self.includeFields & PNMemberUserCustomField) == PNMemberUserCustomField) {
            [fields addObject:@"user.custom"];
        }
    }
    
    
    return fields;
}

#pragma mark -


@end
