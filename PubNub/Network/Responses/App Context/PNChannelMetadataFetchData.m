#import "PNChannelMetadataFetchData.h"
#import "PNCodable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Fetch channel metadata` request response private extension.
@interface PNChannelMetadataFetchData () <PNCodable>


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNChannelMetadataFetchData


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{ @"metadata": @"data" };
}

#pragma mark -


@end
