/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "NSDateFormatter+PNCacheable.h"
#import "PNUser+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNUser ()


#pragma mark - Information

/**
 * @brief \c User identifier from external service (database, auth service).
 */
@property (nonatomic, nullable, copy) NSString *externalId;

/**
 * @brief URL at which \c user's profile available.
 */
@property (nonatomic, nullable, copy) NSString *profileUrl;

/**
 * @brief Additional / complex attributes which has been associated with \c user.
 */
@property (nonatomic, nullable, copy) NSDictionary *custom;

/**
 * @brief Email address which should be associated with \c user.
 */
@property (nonatomic, nullable, copy) NSString *email;

/**
 * @brief \c User creation date.
 */
@property (nonatomic, nullable, copy) NSDate *created;

/**
 * @brief \c User data modification date.
 */
@property (nonatomic, nullable, copy) NSDate *updated;

/**
 * @brief \c User object version identifier.
 */
@property (nonatomic, nullable, copy) NSString *eTag;

/**
 * @brief \c User identifier.
 */
@property (nonatomic, copy) NSString *identifier;

/**
 * @brief Name which has been associated with \c user.
 */
@property (nonatomic, copy) NSString *name;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c user data model.
 *
 * @param identifier Unique \c user identifier.
 * @param name Name which has been associated with \c user.
 *
 * @return Initialized and ready to use \c user representation model.
 */
- (instancetype)initWithID:(NSString *)identifier name:(NSString *)name;


#pragma mark - Misc

/**
 * @brief Translate \c user data model to dictionary.
 */
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNUser


#pragma mark - Initialization & Configuration

+ (instancetype)userFromDictionary:(NSDictionary *)data {
    PNUser *user = [PNUser userWithID:data[@"id"] name:data[@"name"]];
    user.externalId = data[@"externalId"];
    user.profileUrl = data[@"profileUrl"];
    user.custom = data[@"custom"];
    user.email = data[@"email"];
    user.eTag = data[@"eTag"];
    
    NSDateFormatter *formatter = [NSDateFormatter pn_objectsDateFormatter];
    
    if (data[@"created"]) {
        user.created = [formatter dateFromString:data[@"created"]];
    }
    
    if (data[@"updated"]) {
        user.updated = [formatter dateFromString:data[@"updated"]];
    }
    
    return user;
}

+ (instancetype)userWithID:(NSString *)identifier name:(NSString *)name {
    return [[self alloc] initWithID:identifier name:name];
}

- (instancetype)initWithID:(NSString *)identifier name:(NSString *)name {
    if ((self = [super init])) {
        _identifier = [identifier copy];
        _name = [name copy];
    }

    return self;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [@{ @"type": @"user" } mutableCopy];
    
    dictionary[@"externalId"] = self.externalId;
    dictionary[@"profileUrl"] = self.profileUrl;
    dictionary[@"created"] = self.created;
    dictionary[@"updated"] = self.updated;
    dictionary[@"custom"] = self.custom;
    dictionary[@"id"] = self.identifier;
    dictionary[@"email"] = self.email;
    dictionary[@"name"] = self.name;
    
    return dictionary;
}

- (NSString *)debugDescription {
    return [[self dictionaryRepresentation] description];
}

#pragma mark -


@end
