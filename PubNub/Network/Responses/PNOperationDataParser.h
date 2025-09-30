#import <Foundation/Foundation.h>
#import "PNTransportResponse.h"
#import "PNTransportRequest.h"
#import "PNObjectSerializer.h"
#import "PNStructures.h"
#import "PNError.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Parsed remote service response.
@interface PNOperationDataParseResult<ResultType, StatusType> : NSObject


#pragma mark - Properties

/// API request processing result with de-serialized response data object.
///
/// If there is no error and it is expected to have result data which object will be parsed from the service response.
@property(strong, nullable, nonatomic, readonly) ResultType result;

/// API request processing status with de-serialized request status data.
///
/// In case of error or non-fetching requests which object may contain request processing status data.
@property(strong, nullable, nonatomic, readonly) StatusType status;

#pragma mark -


@end


/// Remote service response parser.
///
/// Object used to process and represent result or status data.
@interface PNOperationDataParser : NSObject


#pragma mark - Properties

/// Whether only error response should be processed or not.
@property(assign, nonatomic) BOOL errorOnly;


#pragma mark - Initialization and Configuration

/// Create operation data parser.
///
/// - Parameters:
///   - serializer: Service response data serializer to map response to the data model.
///   - resultClass: Class of object which represents API result (for data fetching requests).
///   - statusClass: Class of object which represents API request processing status (for non-data fetching requests) or
///   error status data.
///   - additionalData: Additional information which can be used by `aClass` custom initializer.
/// - Returns: Ready to use operation data parser.
+ (instancetype)parserWithSerializer:(id<PNObjectSerializer>)serializer
                              result:(nullable Class)resultClass
                              status:(nullable Class)statusClass
                  withAdditionalData:(nullable NSDictionary *)additionalData;

#pragma mark - Processing

/// Parse service response.
///
/// - Parameters:
///   - operation: Type of request operation.
///   - request: Actual request which has been used to access remote origin resource.
///   - response: Remote origin response with results of access to the resource.
///   - data: Response data provided by service.
///   - error: Transport-related request processing error (network issues, cancelled or timeout request, and etc.).
/// - Returns: Data object with service response parse results.
- (PNOperationDataParseResult *)parseOperation:(PNOperationType)operation
                                   withRequest:(PNTransportRequest *)request
                                      response:(nullable id<PNTransportResponse>)response
                                          data:(nullable NSData *)data
                                         error:(nullable PNError *)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
