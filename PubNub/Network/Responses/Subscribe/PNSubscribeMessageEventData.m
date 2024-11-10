#import "PNSubscribeMessageEventData+Private.h"
#import <PubNub/PNCodable.h>
#import "PNSubscribeEventData+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Message event` data private extension.
@interface PNSubscribeMessageEventData () <PNCodable>


#pragma mark - Properties

/// Whether decryption error happened during data processing or not.
@property(assign, nonatomic) BOOL decryptionError;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSubscribeMessageEventData


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{
        @"customMessageType": @"cmt",
        @"message": @"message"
    };
}

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"customMessageType"];
}

+ (NSArray<NSString *> *)ignoredKeys {
    return @[@"publisher", @"decryptionError"];
}

- (NSString *)publisher {
    return self.senderIdentifier;
}

#pragma mark -


@end
