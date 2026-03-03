#import <Foundation/Foundation.h>
#import <PubNub/PNTransport.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Types

/// Describes the simulated network state of the mock transport.
typedef NS_ENUM(NSUInteger, PNMockTransportNetworkState) {
    /// Transport is connected and will deliver responses normally.
    PNMockTransportConnected,

    /// Transport is disconnected and will return network errors for all requests.
    PNMockTransportDisconnected,

    /// Transport will simulate request timeouts.
    PNMockTransportTimingOut
};


#pragma mark - Structures

/// A recorded request entry captured by the mock transport.
@interface PNMockTransportRequestRecord : NSObject

/// The transport request that was sent.
@property(strong, nonatomic, readonly) PNTransportRequest *request;

/// Timestamp when the request was recorded.
@property(strong, nonatomic, readonly) NSDate *timestamp;

/// Initialise a request record.
///
/// - Parameter request: The transport request to record.
/// - Returns: Initialised request record instance.
- (instancetype)initWithRequest:(PNTransportRequest *)request;

@end


/// A pre-configured response that the mock transport should return.
@interface PNMockTransportResponse : NSObject

/// HTTP status code to return.
@property(assign, nonatomic) NSUInteger statusCode;

/// Response body data.
@property(strong, nullable, nonatomic) NSData *body;

/// Response headers (keys will be lowercased by the mock response object).
@property(strong, nullable, nonatomic) NSDictionary<NSString *, NSString *> *headers;

/// Simulated delay before delivering the response (in seconds).
@property(assign, nonatomic) NSTimeInterval delay;

/// Transport error to return instead of a response (simulates connection failure).
///
/// When set, `statusCode`, `body`, and `headers` are ignored and this error is delivered.
@property(strong, nullable, nonatomic) NSError *error;

/// Create a successful response with the given status code and optional body.
///
/// - Parameters:
///   - statusCode: HTTP status code.
///   - body: Optional response body data.
/// - Returns: Configured mock response.
+ (instancetype)responseWithStatusCode:(NSUInteger)statusCode body:(nullable NSData *)body;

/// Create a successful JSON response with the given status code and dictionary payload.
///
/// - Parameters:
///   - statusCode: HTTP status code.
///   - json: Dictionary to serialise as JSON for the response body.
/// - Returns: Configured mock response with `application/json` content type.
+ (instancetype)responseWithStatusCode:(NSUInteger)statusCode json:(nullable NSDictionary *)json;

/// Create an error response that simulates a transport-level failure.
///
/// - Parameter error: The `NSError` to deliver.
/// - Returns: Configured mock response that delivers an error.
+ (instancetype)responseWithError:(NSError *)error;

@end


#pragma mark - Interface declaration

/// Mock transport for testing SDK behaviour under network failure conditions.
///
/// This transport implements the `PNTransport` protocol and can be configured to simulate various network conditions
/// including connectivity loss, timeouts, HTTP errors, and delayed responses. All requests are recorded for
/// verification in tests.
///
/// - Since: Test support (not shipped in SDK)
@interface PNMockTransport : NSObject <PNTransport>


#pragma mark - Properties

/// Current simulated network state.
@property(assign, nonatomic) PNMockTransportNetworkState networkState;

/// List of all requests that have been sent through this transport.
///
/// Includes requests from retry attempts. Access is thread-safe via copy.
@property(copy, nonatomic, readonly) NSArray<PNMockTransportRequestRecord *> *recordedRequests;

/// Number of requests recorded (convenience accessor).
@property(assign, nonatomic, readonly) NSUInteger recordedRequestCount;


#pragma mark - Configuration

/// Enqueue a response to be returned for the next matching request.
///
/// Responses are consumed in FIFO order. When the queue is empty, the transport falls back to the default response
/// (200 OK with empty body) or returns a network error if `networkState` is not `PNMockTransportConnected`.
///
/// - Parameter response: The mock response to enqueue.
- (void)enqueueResponse:(PNMockTransportResponse *)response;

/// Enqueue multiple responses to be returned in order.
///
/// - Parameter responses: Array of mock responses to enqueue.
- (void)enqueueResponses:(NSArray<PNMockTransportResponse *> *)responses;

/// Set a default response that is returned when the response queue is empty and the transport is connected.
///
/// - Parameter response: The default mock response (nil resets to built-in 200 OK).
- (void)setDefaultResponse:(nullable PNMockTransportResponse *)response;

/// Remove all enqueued responses and reset to default state.
- (void)resetResponses;

/// Remove all recorded requests.
- (void)resetRecordedRequests;

/// Fully reset the transport: clear responses, recorded requests, and set state to connected.
- (void)reset;


#pragma mark -


@end

NS_ASSUME_NONNULL_END
