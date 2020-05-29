/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNRequest+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNBaseObjectsRequest ()


#pragma mark - Information

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Available values depends from object type for which request created. So far following
 *   helper \a types available: \b PNMembershipFields, \b PNMemberFields,
 *   \b PNChannelFields, \b PNUUIDFields.
 * @note Default value can be reset by setting 0.
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

- (BOOL)isIdentifierRequired {
    return YES;
}

- (PNRequestParameters *)requestParameters {
    PNRequestParameters *parameters = [super requestParameters];

    if (self.parametersError) {
        return parameters;
    }

    if (self.includeFields > 0) {
        [self addIncludedFields:[self includeFieldNames] toRequest:parameters];
    }
    
    if (self.identifier) {
        if (self.identifier.length > 92) {
            self.parametersError = [self valueTooLongErrorForParameter:self.objectType
                                                       ofObjectRequest:self.objectType
                                                            withLength:self.identifier.length
                                                         maximumLength:92];
        } else {
            NSString *placeholder = [@[@"{", self.objectType, @"}"] componentsJoinedByString:@""];
            [parameters addPathComponent:self.identifier forPlaceholder:placeholder];
        }
    } else if (self.isIdentifierRequired) {
        self.parametersError = [self missingParameterError:@"identifier"
                                          forObjectRequest:self.objectType];
    }

    return parameters;
}


#pragma mark - Initialization & Configuration

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
        (self.includeFields & PNChannelCustomField) == PNChannelCustomField) {
        [fields addObject:@"custom"];
    }

    if ((self.includeFields & PNMembershipCustomField) == PNMembershipCustomField) {
        [fields addObject:@"custom"];
    }

    if ((self.includeFields & PNMembershipChannelField) == PNMembershipChannelField) {
        [fields addObject:@"channel"];
    }

    if ((self.includeFields & PNMembershipChannelCustomField) == PNMembershipChannelCustomField) {
        [fields addObject:@"channel.custom"];
    }

    if ((self.includeFields & PNMemberCustomField) == PNMemberCustomField) {
        [fields addObject:@"custom"];
    }

    if ((self.includeFields & PNMemberUUIDField) == PNMemberUUIDField) {
        [fields addObject:@"uuid"];
    }

    if ((self.includeFields & PNMemberUUIDCustomField) == PNMemberUUIDCustomField) {
        [fields addObject:@"uuid.custom"];
    }

    return fields;
}


#pragma mark - Misc

- (void)addIncludedFields:(NSArray<NSString *> *)fields
                toRequest:(PNRequestParameters *)requestParameters {
    
    NSString *include = [requestParameters query][@"include"];
    NSArray *existingFields = [include componentsSeparatedByString:@","] ?: @[];
    NSMutableSet *includeFields = [NSMutableSet setWithArray:existingFields];
    [includeFields addObjectsFromArray:fields];

    [requestParameters removeQueryParameterWithFieldName:@"include"];
    [requestParameters addQueryParameter:[includeFields.allObjects componentsJoinedByString:@","]
                            forFieldName:@"include"];
}

#pragma mark -


@end
