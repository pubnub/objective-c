#import "PNSubscribeObjectEventData.h"
#import <PubNub/PNCodable.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `App Context event` data private extension.
@interface PNSubscribeObjectEventData () <PNCodable>


#pragma mark - Properties

/// Actual `App Context` object information.
@property(strong, nonatomic, readonly) id data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END



#pragma mark - Interface implementation

@implementation PNSubscribeObjectEventData


#pragma mark - Properties

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"channelMetadata", @"uuidMetadata", @"membership"];
}

+ (NSArray<NSString *> *)dynamicTypeKeys {
    return @[@"data"];
}

+ (Class)decodingClassForProperty:(NSString *)propertyName inDecodedDictionary:(NSDictionary *)decodedDictionary {
    if (![propertyName isEqualToString:@"data"]) return nil;

    if ([decodedDictionary[@"type"] isEqual:@"uuid"]) return [PNUUIDMetadata class];
    else if ([decodedDictionary[@"type"] isEqual:@"channel"]) return [PNChannelMetadata class];

    return [PNMembership class];
}

- (PNChannelMetadata *)channelMetadata {
    return [self.type isEqualToString:@"channel"] ? self.data : nil;
}

- (PNUUIDMetadata *)uuidMetadata {
    return [self.type isEqualToString:@"uuid"] ? self.data : nil;
}

- (PNMembership *)membership {
    return [self.type isEqualToString:@"membership"] ? self.data : nil;
}

- (NSNumber *)timestamp {
    return self.timetoken;
}

#pragma mark -


@end
