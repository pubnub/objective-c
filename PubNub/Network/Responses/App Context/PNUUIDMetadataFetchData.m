#import "PNUUIDMetadataFetchData.h"
#import "PNCodable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Fetch UUID metadata` request response private extension.
@interface PNUUIDMetadataFetchData () <PNCodable>


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNUUIDMetadataFetchData


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{ @"metadata": @"data" };
}

#pragma mark -


@end
