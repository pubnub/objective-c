#import "PNSubscribeFileEventData+Private.h"
#import <PubNub/PNCodable.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private nterface declaration

/// `File event` data private extension.
@interface PNSubscribeFileEventData () <PNCodable>


#pragma mark - Properties

/// Whether decryption error happened during data processing or not.
@property(assign, nonatomic) BOOL decryptionError;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSubscribeFileEventData


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{
        @"customMessageType": @"cmt",
        @"message": @"message",
        @"file": @"file"
    };
}

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"customMessageType", @"message"];
}

+ (NSArray<NSString *> *)ignoredKeys {
    return @[@"decryptionError"];
}

#pragma mark -


@end
