#import "PNClientStateGetResult+Private.h"
#import "PNPresenceUserStateFetchData+Private.h"
#import "PNOperationResult+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Fetch user presence for channels / channel groups` response private extension.
@interface PNClientStateData ()


#pragma mark - Properties

/// User presence state information.
@property(strong, nonnull, nonatomic) PNPresenceUserStateFetchData *stateData;


#pragma mark - Initialization and Configuration

/// Initialize user presence state response object.
///
/// - Parameter stateData: User presence state information.
/// - Returns: Initialized user presence state response object.
- (instancetype)initWithPresenceData:(PNPresenceUserStateFetchData *)stateData;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNClientStateData


#pragma mark - Properties

- (NSDictionary<NSString *,NSDictionary *> *)channels {
    if (self.stateData.channel) return @{ self.stateData.channel: self.stateData.state };
    return self.stateData.channels;
}


#pragma mark - Initialization and Configuration

- (instancetype)initWithPresenceData:(PNPresenceUserStateFetchData *)stateData {
    if ((self = [super init])) _stateData = stateData;
    return self;
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNClientStateGetResult


#pragma mark - Initialization and Configuration

+ (instancetype)legacyPresenceStateFromPresenceState:(PNPresenceStateFetchResult *)state {
    return [self objectWithOperation:state.operation
                            response:[[PNClientStateData alloc] initWithPresenceData:state.responseData]];
}


#pragma mark - Properties

- (PNClientStateData *)data {
    return self.responseData;
}

#pragma mark -

@end
