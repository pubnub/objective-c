#import "PubNub+Core.h"
#import "PNPublishSequence.h"
#import "PNStateListener.h"
#import "PNClientState.h"
#import "PNSubscriber.h"
#import "PNTelemetry.h"
#import "PNHeartbeat.h"
#import "PNLogMacro.h"


#pragma mark Class forward

@class PNRequestParameters, PNConfiguration, PNNetwork, PNResult, PNStatus;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b PubNub client core extension which expose private fields and methods to support other
 * extensions.
 *
 * @discussion Core class manage client configuration as well as access to networking layer through
 * which passed request will be sent to \b PubNub service.
 *
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PubNub (Private)


#pragma mark - Properties

/**
 * @brief Current \b PubNub client configuration.
 *
 * @since 4.0
 */
@property (nonatomic, readonly, copy) PNConfiguration *configuration;

/**
 * @brief Unique instance identifier.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, copy) NSString *instanceID;

/**
 * @brief Subscription loop manager.
 *
 * @since 4.0
 */
@property (nonatomic, readonly, strong) PNSubscriber *subscriberManager;

/**
 * @brief Publish sequence manager.
 *
 * @since 4.5.2
 */
@property (nonatomic, readonly, strong) PNPublishSequence *sequenceManager;

/**
 * @brief Client's state manager to store user's state for chats and group.
 *
 * @since 4.0
 */
@property (nonatomic, readonly, strong) PNClientState *clientStateManager;

/**
 * @brief Subscribe event listeners manager.
 *
 * @since 4.0
 */
@property (nonatomic, readonly, strong) PNStateListener *listenersManager;

/**
 * @brief Client's presence heartbeat manager.
 *
 * @since 4.0
 */
@property (nonatomic, readonly, strong) PNHeartbeat *heartbeatManager;

/**
 * @brief Network manager configured to be used for 'subscription' API group with long-polling.
 *
 * @since 4.0
 */
@property (nonatomic, strong, nullable) PNNetwork *subscriptionNetwork;

/**
 * @brief Network manager configured to be used for 'non-subscription' API group.
 *
 * @since 4.0
 */
@property (nonatomic, strong, nullable) PNNetwork *serviceNetwork;

/**
 * @brief Client telemetry gather and publish manager.
 *
 * @since 4.6.2
 */
@property (nonatomic, readonly, strong) PNTelemetry *telemetryManager;

/**
 * @brief Recent client state (whether it was connected or not).
 *
 * @since 4.0
 */
@property (nonatomic, readonly, assign) PNStatusCategory recentClientStatus;

/**
 * @brief Queue on which completion / processing blocks will be called.
 *
 * @since 4.0
 */
@property (nonatomic, readonly, strong) dispatch_queue_t callbackQueue;


#pragma mark - Operation processing

/**
 * @brief Compose request to \b PubNub network basing on operation type and passed \c parameters.
 *
 * @param operationType One of \b PNOperationType enum fields which represent type of operation
 *     which should be issued to \b PubNub network.
 * @param parameters Resource and query path fields wrapped into object.
 * @param block Operation processing completion block.
 *
 * @since 4.0
 */
- (void)processOperation:(PNOperationType)operationType
          withParameters:(PNRequestParameters *)parameters
         completionBlock:(nullable id)block;

/**
 * @brief Compose request to \b PubNub network basing on operation type and passed \c parameters.
 *
 * @param operationType One of \b PNOperationType enum fields which represent type of operation
 *     which be issued to \b PubNub network.
 * @param parameters Resource and query path fields wrapped into object.
 * @param data Data which should be pushed to \b PubNub network.
 * @param block Operation processing completion block.
 *
 * @since 4.0
 */
- (void)processOperation:(PNOperationType)operationType
          withParameters:(PNRequestParameters *)parameters
                    data:(nullable NSData *)data
         completionBlock:(nullable id)block;


#pragma mark - Operation information

/**
 * @brief Calculate actual size of packet for passed \c operationType which will be sent to
 * \b PubNub network.
 *
 * @param operationType One of \b PNOperationType enum fields which specify for what kind of
 *     operation packet size should be calculated.
 * @param parameters List of passed parameters which should be passed to URL builder.
 * @param data Data which can be pushed along with request to \b PubNub network if required.
 *
 * @return Size of the packet which include request string, host, headers and HTTP post body.
 *
 * @since 4.0
 */
- (NSInteger)packetSizeForOperation:(PNOperationType)operationType
                     withParameters:(PNRequestParameters *)parameters
                               data:(NSData *)data;

/**
 * @brief Add available client information to object instance subclassed from \b PNResult
 * (\b PNStatus)
 *
 * @param result Reference on object which should be updated with client information.
 *
 * @since 4.0
 */
- (void)appendClientInformation:(PNResult *)result;


#pragma mark - Events notification

/**
 * @brief Notify user about processing results by calling completion block with specified result and
 * status on callback queue.
 *
 * @param block Completion block which has been passed by user during API call.
 * @param result API request processing results.
 * @param status API request processing status (mostly reports about errors).
 *
 * @since 4.0
 */
- (void)callBlock:(nullable id)block
           status:(BOOL)callingStatusBlock
       withResult:(nullable PNResult *)result
        andStatus:(nullable PNStatus *)status;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
