/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "NSDateFormatter+PNCacheable.h"
#import "PNMembership+Private.h"
#import "PNSpace+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNMembership ()


#pragma mark - Information

/**
 * @brief Additional information associated with \c user in context of his membership in \c space.
 */
@property (nonatomic, nullable, strong) NSDictionary *custom;

/**
 * @brief \c Space with which \c user linked through membership.
 *
 * @note This property will be set only if \b PNMembershipsIncludeFields.space has been added to
 * \c includeFields list during request.
 */
@property (nonatomic, nullable, strong) PNSpace *space;

/**
 * @brief Identifier of \c space with which \c user linked through membership.
 */
@property (nonatomic, strong) NSString *spaceId;

/**
 * @brief \c Membership creation date.
 */
@property (nonatomic, copy) NSDate *created;

/**
 * @brief \c Membership data modification date.
 */
@property (nonatomic, copy) NSDate *updated;

/**
 * @brief \c Membership object version identifier.
 */
@property (nonatomic, copy) NSString *eTag;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c membership data model.
 *
 * @param identifier Identifier of \c space with which \c user has membership.
 * @param space \c Space with which \c user has membership.
 *
 * @return Initialized and ready to use \c membership representation model.
 */
- (instancetype)initWithSpaceId:(NSString *)identifier space:(nullable PNSpace *)space;

#pragma mark -

@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNMembership


#pragma mark - Initialization & Configuration

+ (instancetype)membershipFromDictionary:(NSDictionary *)data {
    NSDateFormatter *formatter = [NSDateFormatter pn_objectsDateFormatter];
    PNSpace *space = nil;
    
    if (data[@"space"]) {
        space = [PNSpace spaceFromDictionary:data[@"space"]];
    }
    
    PNMembership *membership = [PNMembership membershipWithSpaceId:data[@"id"] space:space];
    membership.custom = data[@"custom"];
    membership.eTag = data[@"eTag"];
    
    if (data[@"created"]) {
        membership.created = [formatter dateFromString:data[@"created"]];
    }
    
    if (data[@"updated"]) {
        membership.updated = [formatter dateFromString:data[@"updated"]];
    }
    
    return membership;
}

+ (instancetype)membershipWithSpaceId:(NSString *)identifier space:(PNSpace *)space {
    
    return [[self alloc] initWithSpaceId:identifier space:space];
}

- (instancetype)initWithSpaceId:(NSString *)identifier space:(PNSpace *)space {
    if ((self = [super init])) {
        _spaceId = [identifier copy];
        _space = space;
    }
    
    return self;
}

#pragma mark -


@end
