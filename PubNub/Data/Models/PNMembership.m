#import "PNMembership.h"
#import "PNBaseAppContextObject+Private.h"
#import "PNUUIDMetadata.h"
#import "PNCodable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `UUID membership` object private extension.
@interface PNMembership () <PNCodable>


#pragma mark - Properties

/// UUID's for which membership has been created / removed.
@property(strong, nonatomic, nullable) PNUUIDMetadata *uuidMetadataObject;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNMembership


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{
        @"metadata": @"channel",
        @"uuidMetadataObject": @"_uuid"
    };
}

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"uuidMetadataObject"];
}

+ (NSArray<NSString *> *)ignoredKeys {
    return @[@"channel"];
}

- (NSString *)channel {
    return self.metadata.channel;
}

- (NSString *)uuid {
    return self.uuidMetadataObject.uuid;
}


#pragma mark - Misc

- (NSMutableDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [super dictionaryRepresentation];
    dictionary[@"channel"] = [self.metadata dictionaryRepresentation];

    return dictionary;
}

- (NSString *)debugDescription {
    return [self dictionaryRepresentation].description;
}

#pragma mark -


@end
