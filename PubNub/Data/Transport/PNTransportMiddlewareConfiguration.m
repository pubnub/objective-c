#import "PNTransportMiddlewareConfiguration.h"
#import "PNTransportConfiguration+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Transport middleware module configuration private extension.
@interface PNTransportMiddlewareConfiguration ()


#pragma mark - Properties
/// Current `PubNub` instance configuration object.
@property(strong, nonatomic) PNConfiguration *configuration;

/// Maximum simultaneously connections which can be opened.
@property(assign, nonatomic) NSUInteger maximumConnections;


/// Initialized and ready to use transport implementation.
@property(strong, nonatomic) id<PNTransport> transport;

/// Unique `PubNub` instance identifier.
@property(copy, nonatomic) NSString *clientInstanceId;

#ifndef PUBNUB_DISABLE_LOGGER
/// `PubNub` client instance logger.
///
/// Logger can be used to add additional logs into console and file (if enabled).
@property(strong, nonatomic) PNLLogger *logger;
#endif // PUBNUB_DISABLE_LOGGER


#pragma mark - Initialization and Configuration

#ifdef PUBNUB_DISABLE_LOGGER
/// Initialize middleware configuration.
///
/// - Parameters:
///   - configuration: `PubNub` client configuration object.
///   - clientInstanceId: Unique `PubNub` instance identifier.
///   - transport: Instantiated transport object.
///   - maximumConnections: Maximum simultaneously connections which can be opened.
/// - Returns: Initialized middleware configuration object.
- (instancetype)initWithClientConfiguration:(PNConfiguration *)configuration 
                           clientInstanceId:(NSString *)clientInstanceId
                                  transport:(id<PNTransport>)transport
                         maximumConnections:(NSUInteger)maximumConnections;
#else
/// Initialize middleware configuration.
///
/// - Parameters:
///   - configuration: `PubNub` client configuration object.
///   - clientInstanceId: Unique `PubNub` instance identifier.   
///   - transport: Instantiated transport object.
///   - maximumConnections: Maximum simultaneously connections which can be opened.
///   - logger: `PubNub` client instance logger.
/// - Returns: Initialized middleware configuration object.
- (instancetype)initWithClientConfiguration:(PNConfiguration *)configuration
                           clientInstanceId:(NSString *)clientInstanceId
                                  transport:(id<PNTransport>)transport
                         maximumConnections:(NSUInteger)maximumConnections
                                     logger:(PNLLogger *)logger;
#endif // PUBNUB_DISABLE_LOGGER

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNTransportMiddlewareConfiguration

#pragma mark - Properties

- (PNTransportConfiguration *)transportConfiguration {
    PNTransportConfiguration *configurartion = [PNTransportConfiguration new];
    configurartion.retryConfiguration = self.configuration.requestRetry;
    configurartion.maximumConnections = self.maximumConnections;
#ifndef PUBNUB_DISABLE_LOGGER
    configurartion.logger = self.logger;
#endif // PUBNUB_DISABLE_LOGGER
    
    return configurartion;
}


#pragma mark - Initialization and Configuration

#ifdef PUBNUB_DISABLE_LOGGER
+ (instancetype)configurationWithClientConfiguration:(PNConfiguration *)configuration
                                    clientInstanceId:(NSString *)clientInstanceId
                                           transport:(id<PNTransport>)transport
                                  maximumConnections:(NSUInteger)maximumConnections {
    return [[self alloc] initWithClientConfiguration:configuration 
                                    clientInstanceId:clientInstanceId
                                           transport:transport
                                  maximumConnections:maximumConnections];
}


- (instancetype)initWithClientConfiguration:(PNConfiguration *)configuration 
                           clientInstanceId:(NSString *)clientInstanceId
                                  transport:(id<PNTransport>)transport
                         maximumConnections:(NSUInteger)maximumConnections {
    if ((self = [super init])) {
        _clientInstanceId = [clientInstanceId copy];
        _maximumConnections = maximumConnections;
        _configuration = configuration;
        _transport = transport;
    }
    
    return self;
}
#else
+ (instancetype)configurationWithClientConfiguration:(PNConfiguration *)configuration
                                    clientInstanceId:(NSString *)clientInstanceId
                                           transport:(id<PNTransport>)transport
                                  maximumConnections:(NSUInteger)maximumConnections
                                              logger:(PNLLogger *)logger {
    return [[self alloc] initWithClientConfiguration:configuration 
                                    clientInstanceId:(NSString *)clientInstanceId
                                           transport:transport
                                  maximumConnections:maximumConnections
                                              logger:logger];
}

- (instancetype)initWithClientConfiguration:(PNConfiguration *)configuration
                           clientInstanceId:(NSString *)clientInstanceId
                                  transport:(id<PNTransport>)transport
                         maximumConnections:(NSUInteger)maximumConnections
                                     logger:(PNLLogger *)logger {
    if ((self = [super init])) {
        _clientInstanceId = [clientInstanceId copy];
        _maximumConnections = maximumConnections;
        _configuration = configuration;
        _transport = transport;
        _logger = logger;
    }
    
    return self;
}
#endif // PUBNUB_DISABLE_LOGGER

#pragma mark -


@end
