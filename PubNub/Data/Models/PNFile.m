#import "PNFile+Private.h"
#import "PNCodable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Shared file` data object private extension.
@interface PNFile () <PNCodable>


#pragma mark - Properties

/// URL which can be used to download file.
@property (nonatomic, strong) NSURL *downloadURL;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNFile


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{
        @"name": @"name",
        @"identifier": @"id",
        @"size": @"size",
        @"created": @"created"
    };
}

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"created", @"downloadURL", @"size"];
}

#pragma mark -


@end
