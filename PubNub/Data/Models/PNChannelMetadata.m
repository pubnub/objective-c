/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "NSDateFormatter+PNCacheable.h"
#import "PNChannelMetadata+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNChannelMetadata ()


#pragma mark - Information

/**
 * @brief Additional / complex attributes which should be stored in \c metadata associated with
 * specified \c channel.
 */
@property (nonatomic, nullable, strong) NSDictionary *custom;

/**
 * @brief Description which should be stored in \c metadata associated with specified \c channel.
 */
@property (nonatomic, nullable, copy) NSString *information;

/**
 * @brief Last \c metadata update date.
 */
@property (nonatomic, nullable, strong) NSDate *updated;

/**
 * @brief \c Channel \c metadata object version identifier.
 */
@property (nonatomic, nullable, copy) NSString *eTag;

/**
 * @brief Name which should be stored in \c metadata associated with specified \c channel.
 */
@property (nonatomic, nullable, copy) NSString *name;

/**
 * @brief \c Channel name with which \c metadata has been associated.
 */
@property (nonatomic, copy) NSString *channel;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c channel \c metadata data model.
 *
 * @param channel Name of channel with which \c metadata associated.
 *
 * @return Initialized and ready to use \c channel \c metadata representation model.
 */
- (instancetype)initWithChannel:(NSString *)channel;


#pragma mark - Misc

/**
 * @brief Translate \c channel \c metadata data model to dictionary.
 */
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNChannelMetadata


#pragma mark - Initialization & Configuration

+ (instancetype)channelMetadataFromDictionary:(NSDictionary *)data {
    PNChannelMetadata *metadata = [PNChannelMetadata metadataForChannel:data[@"id"]];
    metadata.information = data[@"description"];
    metadata.custom = data[@"custom"];
    metadata.eTag = data[@"eTag"];
    metadata.name = data[@"name"];

    NSDateFormatter *formatter = [NSDateFormatter pn_objectsDateFormatter];
    
    if (data[@"updated"]) {
        metadata.updated = [formatter dateFromString:data[@"updated"]];
    }
    
    return metadata;
}

+ (instancetype)metadataForChannel:(NSString *)channel {
    return [[self alloc] initWithChannel:channel];
}

- (instancetype)initWithChannel:(NSString *)channel {
    if ((self = [super init])) {
        _channel = [channel copy];
    }

    return self;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [@{ @"type": @"channel-metadata" } mutableCopy];

    dictionary[@"information"] = self.information;
    dictionary[@"updated"] = self.updated;
    dictionary[@"channel"] = self.channel;
    dictionary[@"custom"] = self.custom;
    dictionary[@"name"] = self.name;
    dictionary[@"eTag"] = self.eTag;

    return dictionary;
}

- (NSString *)debugDescription {
    return [self dictionaryRepresentation].description;
}

#pragma mark -


@end
