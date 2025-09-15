#import <Foundation/Foundation.h>


#pragma mark Types

/// Possible transport methods for HTTP requests.
typedef NS_ENUM(NSUInteger, TransportMethod) {
    /// Request will be sent using `GET` method.
    TransportGETMethod,
    
    /// Request will be sent using `POST` method.
    TransportPOSTMethod,
    
    /// Request will be sent using `PATCH` method.
    TransportPATCHMethod,
    
    /// Request will be sent using `DELETE` method.
    TransportDELETEMethod,
    
    /// Local request.
    ///
    /// Request won't be sent to the service and probably used to compute URL.
    TransportLOCALMethod,
};


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface declaration

/// General remote endpoint request.
///
/// Transport-independent request representation object.
/// All fields are representing certain parts of the request that can be used to prepare one.
@interface PNTransportRequest : NSObject


#pragma mark - Properties

/// Multipart form data fields.
///
/// > Important: `Content-Type` header should be sent the `body` data type when `multipart/form-data` should request
/// should be sent.
@property(copy, nullable, nonatomic, readonly) NSDictionary<NSString *, NSString *> *formData;

/// Whether non-stream body should be compressed or not.
///
/// > Important: Request body compression is handled by the transport implementation when the request is passed to it.
/// > Note: By default set to `NO`.
@property(assign, nonatomic, readonly, getter=shouldCompressBody) BOOL compressBody;

/// Stringified transport HTTP request method.
///
/// > Important: Returns `nil` if unknown `method` value has been set.
@property(strong, nullable, nonatomic, readonly) NSString *stringifiedMethod;

/// Service response body as stream.
@property(strong, nullable, nonatomic, readonly) NSInputStream *bodyStream;

/// Headers to be sent with the request.
@property(copy, nullable, nonatomic, readonly) NSDictionary *headers;

/// Unique request identifier.
@property(copy, nullable, nonatomic, readonly) NSString *identifier;

/// Query parameters to be sent with the request.
@property(copy, nullable, nonatomic, readonly) NSDictionary *query;

/// Whether request `body` available as bytes stream or not.
///
/// > Note: By default set to `NO`.
@property(assign, nonatomic, readonly) BOOL bodyStreamAvailable;

/// Transport HTTP request method.
///
/// > Note: By default set to `TransportGETMethod`.
@property(assign, nonatomic, readonly) TransportMethod method;

/// For how long request should wait response from the server.
@property(assign, nonatomic, readonly) NSTimeInterval timeout;

/// Body to be sent with the request.
@property(strong, nullable, nonatomic, readonly) NSData *body;

/// Request cancellation block.
///
/// > Important: Transport layer is responsible for setting cancellation block if ``cancellable`` is set to `true` to 
/// make it possible for the SDK client stop request.
@property(copy, nullable, nonatomic) dispatch_block_t cancel;

/// Whether the response should be available as a file.
///
/// > Note: By default set to `NO`.
@property(assign, nonatomic, readonly) BOOL responseAsFile;

/// Whether request can be cancelled or not.
///
/// > Note: By default set to `NO`.
@property(assign, nonatomic, readonly) BOOL cancellable;

/// Whether request can be retried automatically (if trabsport implementation support it) or not.
///
/// > Note: By default set to `YES`.
@property(assign, nonatomic, readonly) BOOL retriable;

/// Whether request has been cancelled or not.
///
/// > Note: By default set to `NO`.
@property(assign, nonatomic, readonly) BOOL cancelled;

/// Remote host name.
@property(copy, nonatomic, readonly) NSString *origin;

/// Remote resource path.
@property(copy, nonatomic, readonly) NSString *path;

/// Whether secured connection should be used or not.
///
/// > Note: By default set to `YES`.
@property(assign, nonatomic, readonly) BOOL secure;

/// Whether request failed or not.
///
/// > Note: By default set to `NO`.
@property(assign, nonatomic, readonly) BOOL failed;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
