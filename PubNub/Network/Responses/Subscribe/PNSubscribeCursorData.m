#import "PNSubscribeCursorData.h"
#import "PNCodable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Subscribe request time cursor response private extension.
@interface PNSubscribeCursorData () <PNCodable>


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSubscribeCursorData


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{
        @"timetoken": @"t",
        @"region": @"r"
    };
}

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"region"];
}

#pragma mark -


@end
