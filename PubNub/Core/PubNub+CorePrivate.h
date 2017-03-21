#import "PubNub+Core.h"
#import "PNPublishSequence.h"
#import "PNStateListener.h"
#import "PNClientState.h"
#import "PNSubscriber.h"
#import "PNHeartbeat.h"
#import "PNLogMacro.h"


#pragma mark Class forward

@class PNRequestParameters, PNConfiguration, PNResult, PNStatus;


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      \b PubNub client core extension which expose private fields and methods to support other 
             extensions.
 @discussion Core class manage client configuration as well as access to networking layer through which passed
             request will be sent to \b PubNub service.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PubNub (Private)


///------------------------------------------------
/// @name Properties
///------------------------------------------------

/**
@brief  Stores reference on active \b PubNub client configuration.

@since 4.0
*/
@property (nonatomic, readonly, copy) PNConfiguration *configuration;

/**
 @brief      Stores reference on unique instance identifier.
 @discussion Identifier used by presence service to track multiple clients which is configured for same 
             \c uuid and trigger events like \c leave only if all client instances not subscribed for
             particular channel. \c timeout event can be triggered only if all clients went \c offline 
             (w/o unsubscription)

 @since 4.5.4
 */
@property (nonatomic, readonly, copy) NSString *instanceID;

/**
 @brief  Stores reference on instance which manage all subscribe loop logic and help to deliver updates from 
         remote data objects live feed to the client.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNSubscriber *subscriberManager;

/**
 @brief  Stores reference on instance which manage currently published message sequence number.
 
 @since 4.5.2
 */
@property (nonatomic, readonly, strong) PNPublishSequence *sequenceManager;

/**
 @brief  Stores reference on instance which is responsible for cached client state management.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNClientState *clientStateManager;

/**
 @brief  Stores reference on instance which is responsible for subscriber listeners management.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNStateListener *listenersManager;

/**
 @brief  Stores reference on instance which is responsible for presence heartbeat management.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNHeartbeat *heartbeatManager;

/**
 @brief  Stores reference about recent client state (whether it was connected or not).
 
 @since 4.0
 */
@property (nonatomic, readonly, assign) PNStatusCategory recentClientStatus;

/**
 @brief      Reference on queue on which completion/processing blocks will be called.
 @discussion At the end of each operation completion blocks will be called asynchronously on provided queue.
 
 @default    By default all callback blocks will be called on main queue (\c dispatch_get_main_queue()).
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) dispatch_queue_t callbackQueue;


///------------------------------------------------
/// @name Operation processing
///------------------------------------------------

/**
 @brief  Compose request to \b PubNub network basing on operation type and passed \c parameters.

 @param operationType One of \b PNOperationType enum fields which represent type of operation which should be 
                      issued to \b PubNub network.
 @param parameters    Resource and query path fields wrapped into object.
 @param block         Reference on operation processing completion block.

 @since 4.0
 */
- (void)processOperation:(PNOperationType)operationType withParameters:(PNRequestParameters *)parameters
         completionBlock:(nullable id)block;

/**
 @brief  Compose request to \b PubNub network basing on operation type and passed \c parameters.

 @param operationType One of \b PNOperationType enum fields which represent type of operation which be issued 
                      to \b PubNub network.
 @param parameters    Resource and query path fields wrapped into object.
 @param data          Reference on data which should be pushed to \b PubNub network.
 @param block         Reference on operation processing completion block.

 @since 4.0
 */
- (void)processOperation:(PNOperationType)operationType withParameters:(PNRequestParameters *)parameters 
                    data:(nullable NSData *)data completionBlock:(nullable id)block;

/**
 @brief  Cancel any active long-polling operations scheduled for processing.
 
 @since 4.0
 */
- (void)cancelAllLongPollingOperations;


///------------------------------------------------
/// @name Operation information
///------------------------------------------------

/**
 @brief  Calculate actual size of packet for passed \c operationType which will be sent to \b PubNub network.
 
 @param operationType One of \b PNOperationType enum fields which specify for what kind of operation packet 
                      size should be calculated.
 @param parameters    List of passed parameters which should be passed to URL builder.
 @param data          Data which can be pushed along with request to \b PubNub network if required.
 
 @return Size of the packet which include request string, host, headers and HTTP post body.
 
 @since 4.0
 */
- (NSInteger)packetSizeForOperation:(PNOperationType)operationType
                     withParameters:(PNRequestParameters *)parameters data:(NSData *)data;

/**
 @brief  Add available client information to object instance subclassed from \b PNResult (\b PNStatus)
 
 @param result Reference on object which should be updated with client information.
 
 @since 4.0
 */
- (void)appendClientInformation:(PNResult *)result;


///------------------------------------------------
/// @name Events notification
///------------------------------------------------

/**
 @brief  Notify user about processing results by calling completion block with specified result and status on 
         callback queue.

 @param block  Reference on completion block which has been passed by user during API call.
 @param result Reference on API request processing results.
 @param status Reference on API request processing status (mostly reports about errors).

 @since 4.0
 */
- (void)callBlock:(nullable id)block status:(BOOL)callingStatusBlock withResult:(nullable PNResult *)result
        andStatus:(nullable PNStatus *)status;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
