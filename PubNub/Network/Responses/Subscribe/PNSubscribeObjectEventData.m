#import "PNSubscribeObjectEventData.h"
#import "PNCodable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `App Context event` data private extension.
@interface PNSubscribeObjectEventData () <PNCodable>


#pragma mark - Properties

/// Actual `App Context` object information.
@property(strong, nonatomic, readonly) PNBaseAppContextObject *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END



#pragma mark - Interface implementation

@implementation PNSubscribeObjectEventData


#pragma mark - Properties

+ (Class)decodingClassForProperty:(NSString *)propertyName inDecodedDictionary:(NSDictionary *)decodedDictionary {
    if (![propertyName isEqualToString:@"data"]) return nil;

    if ([decodedDictionary[@"type"] isEqual:@"uuid"]) return [PNUUIDMetadata class];
    else if ([decodedDictionary[@"type"] isEqual:@"channel"]) return [PNChannelMetadata class];

    return [PNMembership class];
}

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{
        @"event": @"event",
        @"type": @"type",
        @"data": @"data"
    };
}

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"channelMetadata", @"uuidMetadata", @"membership"];
}

+ (NSArray<NSString *> *)dynamicTypeKeys {
    return @[@"data"];
}

- (PNChannelMetadata *)channelMetadata {
    return [self.type isEqualToString:@"channel"] ? (PNChannelMetadata *)self.data : nil;
}

- (PNUUIDMetadata *)uuidMetadata {
    return [self.type isEqualToString:@"uuid"] ? (PNUUIDMetadata *)self.data : nil;
}

- (PNMembership *)membership {
    return [self.type isEqualToString:@"membership"] ? (PNMembership *)self.data : nil;
}

- (NSNumber *)timestamp {
    return self.timetoken;
}

#pragma mark -


@end
