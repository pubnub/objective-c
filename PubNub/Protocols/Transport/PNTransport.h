#import <Foundation/Foundation.h>
#import <PubNub/PNTransportConfiguration.h>
#import <PubNub/PNTransportResponse.h>
#import <PubNub/PNTransportRequest.h>
#import <PubNub/PNError.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Structures

/// Regular request completion block.
///
/// > Note: Use error domains and codes suggested in `PNError` header. Using designated error codes helps the PubNub SDK
/// client pick the right error handling path.
///
/// - Parameters:
///   - request: Actual request which has been used to access remote origin resource.
///   - response: Remote origin response with results of access to the resource.
///   - error: Transport-related request processing error (network issues, cancelled or timeout request, and etc.).
typedef void(^PNRequestCompletionBlock)(PNTransportRequest *request,
                                        id<PNTransportResponse> _Nullable response,
                                        PNError * _Nullable error);

/// Download request completion block.
///
/// Download requests are different from regular ones because fetched data stored in temporarily folder.
///
/// > Note: Use error domains and codes suggested in `PNError` header. Using designated error codes helps the PubNub SDK
/// client pick the right error handling path. 
///
/// - Parameters:
///   - request: Actual request which has been used to download remote resource.
///   - response: Remote origin response with results of access to the resource.
///   - path: Path to the temporarily downloaded file location.
///   - error: Transport-related request processing error (network issues, cancelled or timeout request, and etc.).
typedef void(^PNDownloadRequestCompletionBlock)(PNTransportRequest *request,
                                                id<PNTransportResponse> _Nullable response,
                                                NSURL * _Nullable path,
                                                PNError * _Nullable error);

#pragma mark - Interface declaration

@protocol PNTransport <NSObject>


#pragma mark - Initialization and Configuration

/// Complete transport module configuration.
///
/// - Parameter configuration: Base transport module configuration object.
- (void)setupWithConfiguration:(PNTransportConfiguration *)configuration;


#pragma mark - Information

/// Thread-safe active requests list access.
///
/// - Parameter block: The transport module returns a list of currently active requests in a thread-safe way to avoid
/// any potential race of conditions if in `block` some of them are cancelled.
- (void)requestsWithBlock:(void(^)(NSArray<PNTransportRequest *> *))block;


#pragma mark - Request processing

/// Process provided request.
///
/// - Parameters:
///   - request: The transport request to be processed.
///   - block: Request prociessing completion handler block.
- (void)sendRequest:(PNTransportRequest *)request withCompletionBlock:(PNRequestCompletionBlock)block;

/// Download remote resource using provided request.
///
/// - Parameters:
///   - request: The transport download request to be processed.
///   - block: Request prociessing completion handler block.
- (void)sendDownloadRequest:(PNTransportRequest *)request withCompletionBlock:(PNDownloadRequestCompletionBlock)block;

/// Pre-processed transport request.
///
/// > Note: Transport implementations can use this method to adjust general request information for the needs of the
/// implementation.
///
/// - Parameter request: Source transport request object with general information.
/// - Returns: Transport request object with adjusted information (if needed).
- (PNTransportRequest *)transportRequestFromTransportRequest:(PNTransportRequest *)request;


#pragma mark - State

/// Temporarily suspension of transport operation.
///
/// This method will be used by SDK client in cases when further requests processing is impossible (like transition to
/// inactive state).
- (void)suspend;

/// Resume of transport operation
///
/// This method will be used by SDK client in cases when it becomes possible to continue requests processing (like
/// transition to the active state).
- (void)resume;

/// Stop transport operation.
///
/// This method will be used by the SDK during client instance destruction or transport module re-configuration.
///
/// > Important: Transport implementation should use this as opportunity to clean up resources used after instantiation.
- (void)invalidate;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
