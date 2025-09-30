#import "PNSubscribeMessageActionEventData.h"
#import "PNCodable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Message action event` data private extension.
@interface PNSubscribeMessageActionEventData () <PNCodable>


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSubscribeMessageActionEventData


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{
        @"event": @"event",
        @"action": @"data"
    };
}

#pragma mark -


@end
