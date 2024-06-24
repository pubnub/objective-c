#import "PNBaseAppContextObject+Private.h"
#import <PubNub/PNCodable.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General `App Context` data object private extension.
@interface PNBaseAppContextObject () <PNCodable>


#pragma mark - Properties

/// Additional data associated with App Context object.
///
/// > Important: Values must be scalars; only arrays or objects are supported. App Context filtering language doesn’t
/// support filtering by custom properties.
@property(strong, nullable, nonatomic) NSDictionary *custom;


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNBaseAppContextObject


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{
        @"custom": @"custom",
        @"updated": @"updated",
        @"eTag": @"eTag",
    };
}

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"custom"];
}


#pragma mark - Misc

- (NSMutableDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [@{ @"updated": self.updated, @"eTag": self.eTag } mutableCopy];

    if (self.custom) dictionary[@"custom"] = self.custom;

    return dictionary;
}

#pragma mark -


@end
