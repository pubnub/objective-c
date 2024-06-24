#import "PNMembership.h"
#import <PubNub/PNCodable.h>
#import "PNBaseAppContextObject+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `UUID membership` object private extension.
@interface PNMembership () <PNCodable>


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNMembership


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{ @"metadata": @"channel" };
}

+ (NSArray<NSString *> *)ignoredKeys {
    return @[@"channel"];
}

- (NSString *)channel {
    return self.metadata.channel;
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
