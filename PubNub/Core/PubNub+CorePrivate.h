#import "PubNub+Core.h"
#import <PubNub/PNJSONSerialization.h>
#import <PubNub/PNTransportResponse.h>
#import <PubNub/PNTransportRequest.h>
#import <PubNub/PNTransport.h>
#import <PubNub/PNJSONCoder.h>
#import <PubNub/PNLock.h>
#import "PNOperationDataParser.h"
#import "PNBaseRequest+Private.h"
#import "PNPrivateStructures.h"
#import "PubNub+Deprecated.h"
#import "PNPublishSequence.h"
#import "PNStateListener.h"
#import "PNFilesManager.h"
#import "PNClientState.h"
#import "PNSubscriber.h"
#import "PNHeartbeat.h"
#ifndef PUBNUB_DISABLE_LOGGER
#import "PNLogMacro.h"
#endif // PUBNUB_DISABLE_LOGGER


#pragma mark Class forward

@class PNRequestParameters, PNConfiguration, PNOperationResult, PNStatus;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Types

/// Request perform and parse completion block.
///
/// - Parameters:
///   - request: Actual request which has been used to access remote origin resource.
///   - response: Remote origin response with results of access to the resource.
///   - path: Path to the temporarily downloaded file location.
///   - result: Processed ``request`` response.
typedef void(^PNParsedRequestCompletionBlock)(PNTransportRequest *,
                                              id<PNTransportResponse>,
                                              NSURL * _Nullable,
                                              PNOperationDataParseResult * _Nullable);


#pragma mark - Private interface declaration

/// **PubNub** client core class private extension.
@interface PubNub (Private)


#pragma mark - Properties

/// Recent client state (whether it was connected or not).
@property (nonatomic, readonly, assign) PNStatusCategory recentClientStatus;

/// Publish sequence manager.
@property (nonatomic, readonly, strong) PNPublishSequence *sequenceManager;

/// Client's state manager to store user's state for chats and group.
@property (nonatomic, readonly, strong) PNClientState *clientStateManager;

/// Subscribe event listeners manager.
@property (nonatomic, readonly, strong) PNStateListener *listenersManager;

/// Subscription loop manager.
@property (nonatomic, readonly, strong) PNSubscriber *subscriberManager;

/// JSON serializer.
@property(strong, nonatomic, readonly) PNJSONSerialization *serializer;

/// Queue on which completion / processing blocks will be called.
@property (nonatomic, readonly, strong) dispatch_queue_t callbackQueue;

/// Client's presence heartbeat manager.
@property (nonatomic, readonly, strong) PNHeartbeat *heartbeatManager;

/// Current **PubNub** client configuration.
@property (nonatomic, readonly, copy) PNConfiguration *configuration;

/// Files upload / download manager.
@property (nonatomic, readonly, strong) PNFilesManager *filesManager;

/// Transport for subscription loop.
@property (nonatomic, strong) id<PNTransport> subscriptionNetwork;

/// Transport for service requests (non-subscribe).
@property (nonatomic, strong) id<PNTransport> serviceNetwork;

/// Unique instance identifier.
@property (nonatomic, readonly, copy) NSString *instanceID;

/// Data objects coder / decoder.
@property(strong, nonatomic, readonly) PNJSONCoder *coder;

/// Resources access lock.
@property(strong, nonatomic) PNLock *lock;


#pragma mark - Requests processing

/// Perform network request.
///
/// - Parameters:
///   - userRequest: Object which contain all required information to perform request.
///   - parser: Pre-configured ``userRequest`` response parser.
///   - block: Request processing completion block. 
- (void)performRequest:(PNBaseRequest *)userRequest
            withParser:(PNOperationDataParser *)parser
            completion:(PNParsedRequestCompletionBlock)block;

/// Perform network request.
///
/// - Parameters:
///   - userRequest: Object which contain all required information to perform request.
///   - block: Request processing completion block. Completion block can be one of: ``PNRequestCompletionBlock`` or
///    `PNDownloadRequestCompletionBlock` types.
- (void)performRequest:(PNBaseRequest *)userRequest withCompletion:(id)block;

/// Create operation data parser.
///
/// - Parameters:
///   - resultClass: Class of object which represents API result (for data fetching requests).
///   - statusClass: Class of object which represents API request processing status (for non-data fetching requests) or
///   error status data.
/// - Returns: Ready to use operation data parser.
- (PNOperationDataParser *)parserWithResult:(Class)resultClass status:(Class)statusClass;

/// Create operation data parser.
///
/// - Parameter statusClass: Class of object which represents API request processing status (for non-data fetching 
/// requests) or error status data.
/// - Returns: Ready to use operation data parser.
- (PNOperationDataParser *)parserWithStatus:(Class)statusClass;


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
                               data:(NSData *)data
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with the next major update.");

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
