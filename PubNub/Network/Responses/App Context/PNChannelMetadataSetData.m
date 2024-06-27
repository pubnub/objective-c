#import "PNChannelMetadataSetData.h"
#import <PubNub/PNCodable.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Set Channel metadata` request response private extension.
@interface PNChannelMetadataSetData () <PNCodable>


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNChannelMetadataSetData


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{ @"metadata": @"data" };
}

#pragma mark -


@end
