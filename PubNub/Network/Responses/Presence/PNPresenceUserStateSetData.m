#import "PNPresenceUserStateSetData.h"
#import <PubNub/PNCodable.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `User presence state update` request response private extension.
@interface PNPresenceUserStateSetData () <PNCodable>


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNPresenceUserStateSetData


#pragma mark - Properties

+ (NSDictionary<NSString *, NSString *> *)codingKeys {
    return @{ @"state": @"payload" };
}

#pragma mark -


@end
