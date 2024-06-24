#import "PNOperationResult.h"
#import <PubNub/PNObjectSerializer.h>
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General operation (request or client generated) result object private extension.
@interface PNOperationResult (Private) <NSCopying>


#pragma mark - Properties

/// Class which should be used to deserialize ``responseData``.
@property(class, strong, nonatomic, readonly) Class responseDataClass;

/// Processed service response data object.
@property(strong, nullable, nonatomic) id responseData;

/// Type of operation for which result object has been created.
@property(assign, nonatomic) PNOperationType operation;


#pragma mark - Properties (deprecated)

/// Whether secured connection has been used to send request or not.
@property(assign, nonatomic, getter = isTLSEnabled) BOOL TLSEnabled
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. The actual value"
                             " can be retrieved from the client configuration object (`PNConfiguration`).");

/// Copy of the original request which has been used to fetch or push data to **PubNub** network.
///
/// > Important: This information not available anymore because property has been deprecated.
@property (copy, nonatomic, nullable) NSURLRequest *clientRequest
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update.");

/// Authorisation key / token which is used to get access to protected remote resources.
///
/// Some resources can be protected by **PAM** functionality and access done using this authorisation key.
@property (copy, nonatomic, nullable) NSString *authKey
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. The actual value"
                             " can be retrieved from the client configuration object (`PNConfiguration`).");

/// **PubNub** network host name or IP address against which `request` has been called.
@property (copy, nullable, nonatomic) NSString *origin
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. The actual value"
                             " can be retrieved from the client configuration object (`PNConfiguration`).");

/// UUID which is currently used by client to identify user in **PubNub** network.
@property(copy, nullable, nonatomic) NSString *userID
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. The actual value"
                             " can be retrieved from the client configuration object (`PNConfiguration`).");

/// HTTP status code with which `request` completed processing with **PubNub** service.
@property(assign, nonatomic) NSInteger statusCode
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update.");


#pragma mark - Initialization and Configuration

/// Create operation result object.
///
/// - Parameters:
///   - operation: Type of operation for which result object has been created.
///   - response: Processed operation outcome data object.
/// - Returns: Ready to use operation result object.
+ (instancetype)objectWithOperation:(PNOperationType)operation response:(nullable id)response;

/// Initialized operation result object.
///
/// - Parameters:
///   - operation: Type of operation for which result object has been created.
///   - response: Processed operation outcome data object.
/// - Returns: Initialized operation result object.
- (instancetype)initWithOperation:(PNOperationType)operation response:(nullable id)response;


#pragma mark - Misc

/// Convert result object to dictionary which can be used to print out structured data
///
/// - Parameter serializer: Data object serializer.
/// - Returns: Dictionary object representation.
- (NSDictionary *)dictionaryRepresentationWithSerializer:(nullable id<PNObjectSerializer>)serializer;

/// Convert result object into string which can be used to print out data.
///
/// - Parameter serializer: Data object serializer.
/// - Returns: Stringified representation.
- (NSString *)stringifiedRepresentationWithSerializer:(nullable id<PNObjectSerializer>)serializer;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
