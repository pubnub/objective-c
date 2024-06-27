#import "PNPushNotificationFetchData.h"
#import "PNCodable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Fetch time request response data private extension.
@interface PNPushNotificationFetchData () <PNCodable>


#pragma mark - Properties

/// Channels with active push notifications.
@property(strong, nonatomic) NSArray<NSString *> *channels;


#pragma mark - Initialization and Configuration

/// Initialize APNS enabled channels request response object.
///
/// - Parameter channels: List of APNS enabled channels
/// - Returns: Initialized APNS enabled channels data object.
- (instancetype)initWithChannels:(NSArray<NSString *> *)channels;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNPushNotificationFetchData


#pragma mark - Properties

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"channels"];
}


#pragma mark - Initialization and Configuration

- (instancetype)initWithChannels:(NSArray<NSString *> *)channels {
    if ((self = [super init])) {
        _channels = channels;
    }

    return self;
}

- (instancetype)initObjectWithCoder:(id<PNDecoder>)coder {
    id payload = [coder decodeObjectOfClass:[NSArray class]];

    if (![payload isKindOfClass:[NSArray class]]) return nil;
    return [self initWithChannels:payload];
}

#pragma mark -


@end
