#import "PNUUIDMetadataSetData.h"
#import <PubNub/PNCodable.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Set UUID metadata` request response privatre extension.
@interface PNUUIDMetadataSetData () <PNCodable>


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNUUIDMetadataSetData


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{ @"metadata": @"data" };
}

#pragma mark -


@end
