#import "PubNub+Core.h"
#import "PNPublishSequence.h"
#import "PNRequest+Private.h"
#import "PNStateListener.h"
#import "PNFilesManager.h"
#import "PNClientState.h"
#import "PNSubscriber.h"
#import "PNTelemetry.h"
#import "PNHeartbeat.h"
#import "PNLogMacro.h"


#pragma mark Class forward

@class PNRequestParameters, PNConfiguration, PNNetwork, PNOperationResult, PNStatus;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

/// **PubNub** client core class private extension.
@interface PubNub (Private)


#pragma mark - Properties

/**
 * @brief Shared \a PubNub resources access serialization queue.
 *
 * @version 4.17.0
 * @since 4.17.0
 */
/// Shared **PubNub** resources access serialization queue.
///
/// - Since: 4.17.0
@property (nonatomic, nullable, readonly, strong) dispatch_queue_t resourceAccessQueue;

/// Current **PubNub** client configuration.
@property (nonatomic, readonly, copy) PNConfiguration *configuration;

/// Unique instance identifier.
///
/// - Since: 4.5.4
@property (nonatomic, readonly, copy) NSString *instanceID;

/// Subscription loop manager.
@property (nonatomic, readonly, strong) PNSubscriber *subscriberManager;

/// Files upload / download manager.
///
/// - Since: 4.15.0
@property (nonatomic, readonly, strong) PNFilesManager *filesManager;

/// Publish sequence manager.
///
/// - Since: 4.5.2
@property (nonatomic, readonly, strong) PNPublishSequence *sequenceManager;

/// Client's state manager to store user's state for chats and group.
@property (nonatomic, readonly, strong) PNClientState *clientStateManager;

/// Subscribe event listeners manager.
@property (nonatomic, readonly, strong) PNStateListener *listenersManager;

/// Client's presence heartbeat manager.
@property (nonatomic, readonly, strong) PNHeartbeat *heartbeatManager;

/// Network manager configured to be used for 'subscription' API group with long-polling.
@property (nonatomic, strong, nullable) PNNetwork *subscriptionNetwork;

/// Network manager configured to be used for 'non-subscription' API group.
@property (nonatomic, strong, nullable) PNNetwork *serviceNetwork;

/// Client telemetry gather and publish manager.
///
/// - Since: 4.6.2
@property (nonatomic, readonly, strong) PNTelemetry *telemetryManager;

/// Recent client state (whether it was connected or not).
@property (nonatomic, readonly, assign) PNStatusCategory recentClientStatus;

/// Queue on which completion / processing blocks will be called.
@property (nonatomic, readonly, strong) dispatch_queue_t callbackQueue;

/// Set of key/value pairs which is used in API endpoint path and common for all endpoints.
///
/// - Since: 4.15.2
@property (nonatomic, readonly, strong) NSDictionary *defaultPathComponents;

/// Set of key/value pairs which is used in API endpoint query and common for all endpoints.
///
/// - Since: 4.15.2
@property (nonatomic, readonly, strong) NSDictionary *defaultQueryComponents;


#pragma mark - Requests helper

/// Perform network request.
///
/// - Parameters:
///   - request: Object which contain all required information to perform request.
///   - block: Request processing completion block.
- (void)performRequest:(PNRequest *)request withCompletion:(id)block;


#pragma mark - Operation processing

/// Compose request to the **PubNub** network basing on operation type and passed `parameters`.
///
/// - Parameters:
///   - operationType: One of the `PNOperationType` enum fields which represent type of operation which should be issued
///   to **PubNub** network.
///   - parameters: Resource and query path fields wrapped into object.
///   - block: Operation processing completion block.
- (void)processOperation:(PNOperationType)operationType
          withParameters:(PNRequestParameters *)parameters
         completionBlock:(nullable id)block;

/// Compose request to **PubNub** network basing on operation type and passed `parameters`.
///
/// - Parameters:
///   - operationType: One of the `PNOperationType` enum fields which represent type of operation which be issued to
///   **PubNub** network.
///   - parameters: Resource and query path fields wrapped into object.
///   - data: Data which should be pushed to the **PubNub** network.
///   - block: Operation processing completion block.
- (void)processOperation:(PNOperationType)operationType
          withParameters:(PNRequestParameters *)parameters
                    data:(nullable NSData *)data
         completionBlock:(nullable id)block;

/// Compose objects which is used to provide default values for requests.
///
/// - Since: 4.15.2
- (void)prepareRequiredParameters;


#pragma mark - Operation information

/// Calculate actual size of packet for passed `operationType` which will be sent to the **PubNub** network.
///
/// - Parameters:
///   - operationType: One of the `PNOperationType` enum fields which specify for what kind of operation packet size
///   should be calculated.
///   - parameters: List of passed parameters which should be passed to URL builder.
///   - data: Data which can be pushed along with request to the **PubNub** network if required.
/// - Returns: Size of the packet which include request string, host, headers and HTTP post body.
- (NSInteger)packetSizeForOperation:(PNOperationType)operationType
                     withParameters:(PNRequestParameters *)parameters
                               data:(NSData *)data;

/// Add available client information to object instance subclassed from `PNOperationResult` (`PNStatus`).
///
/// - Parameter result: Reference on object which should be updated with client information.
- (void)appendClientInformation:(PNOperationResult *)result;


#pragma mark - Events notification

/// Notify user about processing results by calling completion block with specified result and status on callback queue.
///
/// - Parameters:
///   - block: Completion block which has been passed by user during API call.
///   - callingStatusBlock: Whether calling block with status object only or not.
///   - result: API request processing results.
///   - status: API request processing status (mostly reports about errors).
- (void)callBlock:(nullable id)block
           status:(BOOL)callingStatusBlock
       withResult:(nullable PNOperationResult *)result
        andStatus:(nullable PNStatus *)status;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
