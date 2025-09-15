#import "PNBaseRequest.h"
#import "PNTransportRequest+Private.h"
#import <PubNub/PNCryptoProvider.h>
#import <PubNub/PNConfiguration.h>
#import <PubNub/PNBaseRequest.h>
#import <PubNub/PNRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General request private extension.
@interface PNBaseRequest (Protected) <PNRequest>


#pragma mark - Properties

/// Whether non-stream body should be compressed or not.
@property(assign, nonatomic, readonly, getter=shouldCompressBody) BOOL compressBody;

/// Crypto module for data encryption / decryption.
@property(strong, nullable, nonatomic, readonly) id<PNCryptoProvider> cryptoModule;

/// Number of seconds which is used by client during non-subscription operations to check whether response potentially
/// failed with `timeout` or not.
@property (assign, nonatomic, readonly) NSTimeInterval nonSubscribeRequestTimeout;

/// Maximum number of seconds which client should wait for events from live feed.
@property (assign, nonatomic, readonly) NSTimeInterval subscribeMaximumIdleTime;

/// Service response body as stream.
@property(strong, nullable, nonatomic, readonly) NSInputStream *bodyStream;

/// Number of seconds which is used by server to track whether client still subscribed on remote data objects live feed
/// or not.
@property(assign, nonatomic, readonly) NSInteger presenceHeartbeatValue;

/// Key which is used to push data / state to the **PubNub** network.
@property(strong, nullable, nonatomic, readonly) NSString *publishKey;

/// Headers to be sent with the request.
@property(copy, nullable, nonatomic, readonly) NSDictionary *headers;

/// Query parameters to be sent with the request.
@property(copy, nullable, nonatomic, readonly) NSDictionary *query;

/// Remote host name.
@property(strong, nullable, nonatomic, readonly) NSString *origin;

/// HTTP method which should be used to send request.
@property(assign, nonatomic, readonly) TransportMethod httpMethod;

/// Whether request `body` available as bytes stream or not.
@property(assign, nonatomic, readonly) BOOL bodyStreamAvailable;

/// Key which is used to fetch data / state from the **PubNub** network.
@property(strong, nonatomic, readonly) NSString *subscribeKey;

/// Body to be sent with the request.
@property(strong, nullable, nonatomic, readonly) NSData *body;

/// Whether the response should be available as a file.
///
/// > Note: By default set to `NO`.
@property(assign, nonatomic, readonly) BOOL responseAsFile;

/// Remote resource path.
@property(strong, nonatomic, readonly) NSString *path;


#pragma mark - Initialization and Configuration

/// Complete request configuration.
///
/// - Parameter configuration: Current PubNub client configuration with keysey and active client user information.
- (void)setupWithClientConfiguration:(PNConfiguration *)configuration;


#pragma mark - Helpers

/// Create error which will provide information about missing required request parameter.
///
/// - Parameters:
///   - parameter: Name of missed of empty parameter.
///   - type: Name of object type.
/// - Returns: Error with information about missing parameter.
- (PNError *)missingParameterError:(NSString *)parameter forObjectRequest:(NSString *)type;

/// Create error which will provide information about that one of request parameter values is too short.
///
/// - Parameters:
///   - parameter: Name of parameter who's length smaller than minimum value.
///   - type: Name of object type.
///   - actualLength: Actual value length.
///   - minimumLength: Minimum allowed value length.
/// - Returns: Error with information about short parameter.
- (PNError *)valueTooShortErrorForParameter:(NSString *)parameter
                            ofObjectRequest:(NSString *)type
                                 withLength:(NSUInteger)actualLength
                              minimumLength:(NSUInteger)minimumLength;

/// Create error which will provide information about that one of request parameter values is
///
/// - Parameters:
///   - parameter: Name of parameter who's length exceed maximum value.
///   - type: Name of object type.
///   - actualLength: Actual value length.
///   - maximumLength: Maximum allowed value length.
/// - Returns: Error with information about long parameter.
- (PNError *)valueTooLongErrorForParameter:(NSString *)parameter
                           ofObjectRequest:(NSString *)type
                                withLength:(NSUInteger)actualLength
                             maximumLength:(NSUInteger)maximumLength;

/// Helper method to throw exception in case if request instance require constructor usage but has been called with `-init` or `+new`.
///
/// - Throws: `PNInterfaceNotAvailable` exception.
- (void)throwUnavailableInitInterface;


#pragma mark - Misc

/// Serialize request object.
///
/// - Returns: Request object data represented as `NSDictionary`.
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
