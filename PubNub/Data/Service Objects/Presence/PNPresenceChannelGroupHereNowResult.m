#import "PNPresenceChannelGroupHereNowResult+Private.h"
#import "PNPresenceHereNowFetchData+Private.h"
#import "PNOperationResult+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Channel group presence response private extension.
@interface PNPresenceChannelGroupHereNowData ()


#pragma mark - Properties

/// Channels presence information.
@property(strong, nonatomic, readonly) PNPresenceHereNowFetchData *presenceData;


#pragma mark - Initialization and Configuration

/// Initialize channel group presence response object.
///
/// - Parameter presenceData: Channels presence information.
/// - Returns: Initialized channel group presence response object.
- (instancetype)initWithPresenceData:(PNPresenceHereNowFetchData *)presenceData;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark Interface implementation

@implementation PNPresenceChannelGroupHereNowData


#pragma mark - Properties

+ (NSArray<NSString *> *)ignoredKeys {
    return @[@"presenceData"];
}


#pragma mark - Initialization and Condiguration

- (instancetype)initWithPresenceData:(PNPresenceHereNowFetchData *)presenceData {
    if ((self = [super init])) _presenceData = presenceData;
    return self;
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNPresenceChannelGroupHereNowResult


#pragma mark - Initialization and Configuration

+ (instancetype)legacyPresenceFromPresence:(PNPresenceHereNowResult *)presence {
    id response = [[PNPresenceChannelGroupHereNowData alloc] initWithPresenceData:presence.responseData];
    return [self objectWithOperation:presence.operation response:response];
}


#pragma mark - Properties

- (PNPresenceChannelGroupHereNowData *)data {
    return self.responseData;
}

#pragma mark -


@end
