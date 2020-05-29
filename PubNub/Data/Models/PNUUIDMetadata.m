/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "NSDateFormatter+PNCacheable.h"
#import "PNUUIDMetadata+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNUUIDMetadata ()


#pragma mark - Information

/**
 * @brief Identifier from external service (database, auth service).
 */
@property (nonatomic, nullable, copy) NSString *externalId;

/**
 * @brief URL at which profile available.
 */
@property (nonatomic, nullable, copy) NSString *profileUrl;

/**
 * @brief Additional / complex attributes which should be associated with \c metadata.
 */
@property (nonatomic, nullable, strong) NSDictionary *custom;

/**
 * @brief Last \c metadata update date.
 */
@property (nonatomic, nullable, strong) NSDate *updated;

/**
 * @brief Email address.
 */
@property (nonatomic, nullable, copy) NSString *email;

/**
 * @brief \c UUID \c metadata object version identifier.
 */
@property (nonatomic, nullable, copy) NSString *eTag;

/**
 * @brief \c UUID with which \c metadata has been associated.
 */
@property (nonatomic, copy) NSString *uuid;

/**
 * @brief Name which should be stored in \c metadata associated with specified \c uuid.
 */
@property (nonatomic, copy) NSString *name;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c UUID \c metadata data model.
 *
 * @param uuid Identifier with which \c metadata associated.
 *
 * @return Initialized and ready to use \c UUID \c metadata representation model.
 */
- (instancetype)initWithUUID:(NSString *)uuid;


#pragma mark - Misc

/**
 * @brief Translate \c UUID \c metadata data model to dictionary.
 */
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNUUIDMetadata


#pragma mark - Initialization & Configuration

+ (instancetype)uuidMetadataFromDictionary:(NSDictionary *)data {
    PNUUIDMetadata *metadata = [PNUUIDMetadata metadataForUUID:data[@"id"]];
    metadata.externalId = data[@"externalId"];
    metadata.profileUrl = data[@"profileUrl"];
    metadata.custom = data[@"custom"];
    metadata.email = data[@"email"];
    metadata.eTag = data[@"eTag"];
    metadata.name = data[@"name"];

    NSDateFormatter *formatter = [NSDateFormatter pn_objectsDateFormatter];

    if (data[@"updated"]) {
        metadata.updated = [formatter dateFromString:data[@"updated"]];
    }

    return metadata;
}

+ (instancetype)metadataForUUID:(NSString *)uuid {
    return [[self alloc] initWithUUID:uuid];
}

- (instancetype)initWithUUID:(NSString *)uuid {
    if ((self = [super init])) {
        _uuid = [uuid copy];
    }

    return self;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [@{ @"type": @"uuid-metadata" } mutableCopy];
    
    dictionary[@"externalId"] = self.externalId;
    dictionary[@"profileUrl"] = self.profileUrl;
    dictionary[@"updated"] = self.updated;
    dictionary[@"custom"] = self.custom;
    dictionary[@"email"] = self.email;
    dictionary[@"name"] = self.name;
    dictionary[@"uuid"] = self.uuid;
    dictionary[@"eTag"] = self.eTag;

    return dictionary;
}

- (NSString *)debugDescription {
    return [self dictionaryRepresentation].description;
}

#pragma mark -


@end
