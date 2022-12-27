/**
 * @author Serhii Mamontov
 * @version 5.2.0
 * @since 5.2.0
 * @copyright © 2010-2022 PubNub Inc. All Rights Reserved.
 */
#import "PNSpaceId.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNSpaceId () <NSCopying>

/**
 * @brief Space into which message should be / has been published
 */
@property(nonatomic, copy) NSString *value;


#pragma mark - Initialization and configuration

/**
 * @brief Initialize space id instance.
 *
 * @param identifier Space id identifier.
 *
 * @return Initialized and ready to use space id instance.
 */
- (instancetype)initFromString:(NSString *)identifier NS_DESIGNATED_INITIALIZER;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSpaceId


#pragma mark - Initialization and configuration

+ (instancetype)spaceIdFromString:(NSString *)identifier {
    return [[self alloc] initFromString:identifier];
}

- (instancetype)initFromString:(NSString *)identifier {
    if ((self = [super init])) {
        _value = [identifier copy];
    }
    
    return self;
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[PNSpaceId alloc] initFromString:self.value];
}


#pragma mark - Helper

- (BOOL)isEqual:(id)other {
    return other && [other isKindOfClass:[self class]] ? [self isEqualToSpaceId:other] : NO;
}

- (BOOL)isEqualToSpaceId:(PNSpaceId *)otherSpaceId {
    return [self.value isEqualToString:otherSpaceId.value];
}

#pragma mark -


@end
