#import "PubNub+Core.h"
#import "PNJSONSerialization.h"
#import "PNTransportResponse.h"
#import "PNTransportRequest.h"
#import "PNTransport.h"
#import "PNJSONCoder.h"
#import "PNLock.h"
#import "PNNetworkResponseLogEntry+Private.h"
#import "PNNetworkRequestLogEntry+Private.h"
#import "PNOperationDataParser.h"
#import "PNBaseRequest+Private.h"
#import "PNPrivateStructures.h"
#import "PNPublishSequence.h"
#import "PNStateListener.h"
#import "PNLoggerManager.h"
#import "PNFilesManager.h"
#import "PNClientState.h"
#import "PNSubscriber.h"
#import "PNHeartbeat.h"


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

/// **PubNub** client logger instance which can be used to add additional logs.
@property(strong, nonatomic, readonly) PNLoggerManager *logger;

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

/// Create operation data parser.
///
/// - Parameters:
///   - resultClass: Class of object which represents API result (for data fetching requests).
///   - statusClass: Class of object which represents API request processing status (for non-data fetching requests) or
///   error status data.
///   - cryptoModule: Crypto module which should be used for data processing.
/// - Returns: Ready to use operation data parser.
- (PNOperationDataParser *)parserWithResult:(Class)resultClass
                                     status:(Class)statusClass
                               cryptoModule:(nullable id<PNCryptoProvider>)cryptoModule;

/// Create operation data parser.
///
/// - Parameter statusClass: Class of object which represents API request processing status (for non-data fetching
/// requests) or error status data.
///   - cryptoModule: Crypto module which should be used for data processing.
/// - Returns: Ready to use operation data parser.
- (PNOperationDataParser *)parserWithStatus:(Class)statusClass
                               cryptoModule:(nullable id<PNCryptoProvider>)cryptoModule;


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
