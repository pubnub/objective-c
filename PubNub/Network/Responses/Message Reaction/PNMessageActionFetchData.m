#import "PNMessageActionFetchData.h"
#import <PubNub/PNCodable.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Add message action request response data private extension.
@interface PNMessageActionFetchData () <PNCodable>


#pragma mark -


@end

NS_ASSUME_NONNULL_END



#pragma mark - Interface implementation

@implementation PNMessageActionFetchData


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{ @"action": @"data" };
}

#pragma mark -

@end
