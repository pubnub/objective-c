#import "PNPresenceWhereNowFetchData.h"
#import "PNCodable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Response `payload` object.
@interface PNPresenceWhereNowPayload: NSObject <PNCodable>


#pragma mark - Properties

/// List of channels where requested user is present.
@property(strong, nonatomic, readonly) NSArray<NSString *> *channels;

#pragma mark -


@end


/// Here now presence request response private extension.
@interface PNPresenceWhereNowFetchData () <PNCodable>


#pragma mark - Properties

/// Payload with service-provided in response on request.
@property(strong, nonatomic, readonly) PNPresenceWhereNowPayload *payload;


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNPresenceWhereNowPayload


#pragma mark -


@end


@implementation PNPresenceWhereNowFetchData


#pragma mark - Properties

+ (NSArray<NSString *> *)ignoredKeys {
    return @[@"channels"];
}

- (NSArray<NSString *> *)channels {
    return self.payload.channels;
}

#pragma mark -


@end
