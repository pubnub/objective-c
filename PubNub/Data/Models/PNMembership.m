/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "NSDateFormatter+PNCacheable.h"
#import "PNChannelMetadata+Private.h"
#import "PNMembership+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNMembership ()


#pragma mark - Information

/**
 * @brief \c Metadata associated with \c channel which is listed in \c UUID's memberships list.
 */
@property (nonatomic, nullable, strong) PNChannelMetadata *metadata;

/**
 * @brief Additional information from \c metadata which has been associated with \c UUID during
 * \c UUID \c membership \c add requests.
 */
@property (nonatomic, nullable, strong) NSDictionary *custom;

/**
 * @brief \c UUID's for which membership has been created / removed.
 *
 * @note This value is set only when object received as one of subscription events.
 */
@property (nonatomic, nullable, copy) NSString *uuid;

/**
 * @brief Name of channel which is listed in \c UUID's memberships list.
 */
@property (nonatomic, copy) NSString *channel;

/**
 * @brief \c Membership data modification date.
 */
@property (nonatomic, strong) NSDate *updated;

/**
 * @brief \c Membership object version identifier.
 */
@property (nonatomic, copy) NSString *eTag;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c membership data model.
 *
 * @param metadata \c Metadata which associated with \c UUID in context of \c channel.
 *
 * @return Initialized and ready to use \c membership representation model.
 */
- (instancetype)initWithChannelMetadata:(PNChannelMetadata *)metadata;


#pragma mark - Misc

/**
 * @brief Translate \c channel \c metadata data model to dictionary.
 */
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -

@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNMembership


#pragma mark - Initialization & Configuration

+ (instancetype)membershipFromDictionary:(NSDictionary *)data {
    NSDateFormatter *formatter = [NSDateFormatter pn_objectsDateFormatter];
    PNChannelMetadata *channelMetadata = [PNChannelMetadata channelMetadataFromDictionary:data[@"channel"]];
    PNMembership *membership = [PNMembership membershipWithChannelMetadata:channelMetadata];
    membership.custom = data[@"custom"];
    membership.eTag = data[@"eTag"];
    
    if (data[@"updated"]) {
        membership.updated = [formatter dateFromString:data[@"updated"]];
    }
    
    if (data[@"uuid"]) {
        membership.uuid = data[@"uuid"][@"id"];
    }
    
    return membership;
}

+ (instancetype)membershipWithChannelMetadata:(PNChannelMetadata *)metadata {
    return [[self alloc] initWithChannelMetadata:metadata];
}

- (instancetype)initWithChannelMetadata:(PNChannelMetadata *)metadata {
    if ((self = [super init])) {
        _channel = [metadata.channel copy];
        _metadata = metadata;
    }

    return self;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [@{ @"type": @"membership" } mutableCopy];

    dictionary[@"metadata"] = self.metadata.debugDescription;
    dictionary[@"channel"] = self.channel;
    dictionary[@"custom"] = self.custom;
    dictionary[@"uuid"] = self.uuid;
    dictionary[@"eTag"] = self.eTag;

    return dictionary;
}

- (NSString *)debugDescription {
    return [self dictionaryRepresentation].description;
}

#pragma mark -


@end
