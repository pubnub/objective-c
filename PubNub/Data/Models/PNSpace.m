/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "NSDateFormatter+PNCacheable.h"
#import "PNSpace+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNSpace ()


#pragma mark - Information

/**
 * @brief Additional information about \c space.
 */
@property (nonatomic, nullable, copy) NSString *information;

/**
 * @brief Additional / complex attributes which has been associated with \c space.
 */
@property (nonatomic, nullable, copy) NSDictionary *custom;

/**
 * @brief \c Space creation date.
 */
@property (nonatomic, nullable, copy) NSDate *created;

/**
 * @brief \c Space data modification date.
 */
@property (nonatomic, nullable, copy) NSDate *updated;

/**
 * @brief \c Space object version identifier.
 */
@property (nonatomic, nullable, copy) NSString *eTag;

/**
 * @brief \c Space identifier.
 */
@property (nonatomic, copy) NSString *identifier;

/**
 * @brief Name which has been associated with \c space.
 */
@property (nonatomic, copy) NSString *name;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c space data model.
 *
 * @param identifier Unique \c space identifier.
 * @param name Name which has been associated with \c space.
 *
 * @return Initialized and ready to use \c space representation model.
 */
- (instancetype)initWithID:(NSString *)identifier name:(NSString *)name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSpace


#pragma mark - Initialization & Configuration

+ (instancetype)spaceFromDictionary:(NSDictionary *)data {
    PNSpace *space = [PNSpace spaceWithID:data[@"id"] name:data[@"name"]];
    space.information = data[@"description"];
    space.custom = data[@"custom"];
    space.eTag = data[@"eTag"];
    
    NSDateFormatter *formatter = [NSDateFormatter pn_objectsDateFormatter];
    
    if (data[@"created"]) {
        space.created = [formatter dateFromString:data[@"created"]];
    }
    
    if (data[@"updated"]) {
        space.updated = [formatter dateFromString:data[@"updated"]];
    }
    
    return space;
}

+ (instancetype)spaceWithID:(NSString *)identifier name:(NSString *)name {
    return [[self alloc] initWithID:identifier name:name];
}

- (instancetype)initWithID:(NSString *)identifier name:(NSString *)name {
    if ((self = [super init])) {
        _identifier = [identifier copy];
        _name = [name copy];
    }

    return self;
}

#pragma mark -


@end
