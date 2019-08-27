/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "NSDateFormatter+PNCacheable.h"
#import "PNMember+Private.h"
#import "PNUser+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNMember ()


#pragma mark - Information

/**
 * @brief Additional information associated with \c user in context of his membership in \c space.
 */
@property (nonatomic, nullable, strong) NSDictionary *custom;

/**
 * @brief \c User which is listed in \c space's members list.
 */
@property (nonatomic, nullable, strong) PNUser *user;

/**
 * @brief \c Space creation date.
 */
@property (nonatomic, copy) NSDate *created;

/**
 * @brief \c Space data modification date.
 */
@property (nonatomic, copy) NSDate *updated;

/**
 * @brief \c Member object version identifier.
 */
@property (nonatomic, copy) NSString *eTag;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c member data model.
 *
 * @param identifier Identifier of \c user which is listed in \c space's members list.
 * @param user \c User listed in \c space's members list.
 *
 * @return Initialized and ready to use \c member representation model.
 */
- (instancetype)initWithUserId:(NSString *)identifier user:(nullable PNUser *)user;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNMember


#pragma mark - Initialization & Configuration

+ (instancetype)memberFromDictionary:(NSDictionary *)data {
    NSDateFormatter *formatter = [NSDateFormatter pn_objectsDateFormatter];
    PNUser *user = nil;
    
    if (data[@"user"]) {
        user = [PNUser userFromDictionary:data[@"user"]];
    }
    
    PNMember *member = [PNMember memberWithUserId:data[@"id"] user:user];
    member.custom = data[@"custom"];
    member.eTag = data[@"eTag"];
    
    if (data[@"created"]) {
        member.created = [formatter dateFromString:data[@"created"]];
    }
    
    if (data[@"updated"]) {
        member.updated = [formatter dateFromString:data[@"updated"]];
    }
    
    return member;
}

+ (instancetype)memberWithUserId:(NSString *)identifier user:(PNUser *)user {
    return [[self alloc] initWithUserId:identifier user:user];
}

- (instancetype)initWithUserId:(NSString *)identifier user:(nullable PNUser *)user {
    if ((self = [super init])) {
        _userId = [identifier copy];
        _user = user;
    }
    
    return self;
}

#pragma mark -


@end
