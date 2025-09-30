#import "PNChannelMember.h"
#import "PNBaseAppContextObject+Private.h"
#import "PNCodable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Channel member` object private extension.
@interface PNChannelMember () <PNCodable>


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNChannelMember


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{ @"metadata": @"uuid" };
}

+ (NSArray<NSString *> *)ignoredKeys {
    return @[@"uuid"];
}

- (NSString *)uuid {
    return self.metadata.uuid;
}


#pragma mark - Misc

- (NSMutableDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [super dictionaryRepresentation];
    dictionary[@"uuid"] = [self.metadata dictionaryRepresentation];

    return dictionary;
}

- (NSString *)debugDescription {
    return [self dictionaryRepresentation].description;
}

#pragma mark -


@end
