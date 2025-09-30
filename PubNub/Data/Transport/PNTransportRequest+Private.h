#import "PNTransportRequest.h"

NS_ASSUME_NONNULL_BEGIN

/// Private extension of the general remote endpoint request.
@interface PNTransportRequest ()


#pragma mark - Properties

/// Multipart form data fields.
///
/// > Important: `Content-Type` header should be sent the `body` data type when `multipart/form-data` should request
/// should be sent.
@property(copy, nullable, nonatomic) NSDictionary<NSString *, NSString *> *formData;

/// Whether non-stream body should be compressed or not.
///
/// > Note: By default set to `NO`.
@property(assign, nonatomic, getter=shouldCompressBody) BOOL compressBody;

/// Service response body as stream.
@property(strong, nullable, nonatomic) NSInputStream *bodyStream;

/// Headers to be sent with the request.
@property(copy, nullable, nonatomic) NSDictionary *headers;

/// Unique request identifier.
@property(copy, nullable, nonatomic) NSString *identifier;

/// Query parameters to be sent with the request.
@property(copy, nullable, nonatomic) NSDictionary *query;

/// Whether request `body` available as bytes stream or not.
///
/// > Note: By default set to `NO`.
@property(assign, nonatomic) BOOL bodyStreamAvailable;

/// Current request retry attempt.
@property(assign, nonatomic) NSUInteger retryAttempt;

/// For how long request should wait response from the server.
@property(assign, nonatomic) NSTimeInterval timeout;

/// Transport HTTP request method.
@property(assign, nonatomic) TransportMethod method;

/// Body to be sent with the request.
@property(strong, nullable, nonatomic) NSData *body;

/// Whether the response should be available as a file.
///
/// > Note: By default set to `NO`.
@property(assign, nonatomic) BOOL responseAsFile;

/// Whether request can be cancelled or not.
///
/// > Note: By default set to `NO`.
@property(assign, nonatomic) BOOL cancellable;

/// Whether request can be retried automatically (if transport implementation support it) or not.
///
/// > Note: By default set to `YES`.
@property(assign, nonatomic) BOOL retriable;

/// Whether request has been cancelled or not.
///
/// > Note: By default set to `NO`.
@property(assign, nonatomic) BOOL cancelled;

/// Remote host name.
@property(copy, nonatomic) NSString *origin;

/// Remote resource path.
@property (copy, nonatomic) NSString *path;

/// Whether secured connection should be used or not.
///
/// > Note: By default set to `YES`.
@property(assign, nonatomic) BOOL secure;

/// Whether request failed or not.
///
/// > Note: By default set to `NO`.
@property(assign, nonatomic) BOOL failed;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
