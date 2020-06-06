/**
 * @author Serhii Mamontov
 * @version 4.14.1
 * @since 4.14.1
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "NSDateFormatter+PNCacheable.h"
#import "PNUUIDMetadata+Private.h"
#import "PNChannelMember+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNChannelMember ()


#pragma mark - Information

/**
 * @brief \c Metadata associated with \c UUID which is listed in \c channel's members list.
 */
@property (nonatomic, nullable, strong) PNUUIDMetadata *metadata;

/**
 * @brief Additional information from \c metadata which has been associated with \c UUID during
 * \c channel \c member \c add requests.
 */
@property (nonatomic, nullable, strong) NSDictionary *custom;

/**
 * @brief \c Member data modification date.
 */
@property (nonatomic, strong) NSDate *updated;

/**
 * @brief \c Member object version identifier.
 */
@property (nonatomic, copy) NSString *eTag;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c member data model.
 *
 * @param metadata \c Metadata which associated with specified \c UUID in context of \c channel.
 *
 * @return Initialized and ready to use \c member representation model.
 */
- (instancetype)initWithUUIDMetadata:(PNUUIDMetadata *)metadata;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNChannelMember


#pragma mark - Initialization & Configuration

+ (instancetype)memberFromDictionary:(NSDictionary *)data {
    NSDateFormatter *formatter = [NSDateFormatter pn_objectsDateFormatter];
    PNUUIDMetadata *uuidMetadata = [PNUUIDMetadata uuidMetadataFromDictionary:data[@"uuid"]];
    PNChannelMember *member = [PNChannelMember memberWithUUIDMetadata:uuidMetadata];
    member.custom = data[@"custom"];
    member.eTag = data[@"eTag"];
    
    if (data[@"updated"]) {
        member.updated = [formatter dateFromString:data[@"updated"]];
    }
    
    return member;
}

+ (instancetype)memberWithUUIDMetadata:(PNUUIDMetadata *)metadata {
    return [[self alloc] initWithUUIDMetadata:metadata];
}

- (instancetype)initWithUUIDMetadata:(PNUUIDMetadata *)metadata {
    if ((self = [super init])) {
        _uuid = [metadata.uuid copy];
        _metadata = metadata;
    }

    return self;
}

#pragma mark -


@end
