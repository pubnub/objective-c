#import "PNOperationResult.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Service response representation object private extension.
@interface PNOperationResult (Private) <NSCopying>


#pragma mark - Information

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, assign) PNOperationType operation;
@property (nonatomic, assign, getter = isTLSEnabled) BOOL TLSEnabled;

/// Whether unexpected service data has been passed from parsers.
@property (nonatomic, assign, getter = isUnexpectedServiceData) BOOL unexpectedServiceData;
@property (nonatomic, copy) NSString *uuid
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with next major update. Please use `userID` "
                             "instead.");
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, nullable, copy) NSString *authKey;
@property (nonatomic, copy) NSString *origin;
@property (nonatomic, nullable, copy) NSURLRequest *clientRequest;

/// Processed `response` which is ready to use by user.
///
/// Content and format for this property different for API. Each method has description about expected fields and data
/// stored inside.
@property (nonatomic, nullable, copy) NSDictionary<NSString *, id> *serviceData;


#pragma mark - Initialization and configuration

/// Create result instance in response to successful task completion.
///
/// - Parameters:
///   - operation: One of the `PNOperationType` enum fields to describe what kind of operation has been processed.
///   - task: Reference on data task which has been used to communicate with **PubNub** network.
///   - processedData: Reference on data which has been loaded and pre-processed by corresponding parser.
///   - error: Reference on request processing error.
/// - Returns: Initialized service response instance.
+ (instancetype)objectForOperation:(PNOperationType)operation
                 completedWithTask:(nullable NSURLSessionDataTask *)task
                     processedData:(nullable NSDictionary<NSString *, id> *)processedData
                   processingError:(nullable NSError *)error;

/// Initialize result instance in response to successful task completion.
///
/// - Parameters:
///   - operation: One of the `PNOperationType` enum fields to describe what kind of operation has been processed.
///   - task: Reference on data task which has been used to communicate with **PubNub** network.
///   - processedData: Reference on data which has been loaded and pre-processed by corresponding parser.
///   - error: Reference on request processing error.
/// - Returns: Initialized service response instance.
- (instancetype)initForOperation:(PNOperationType)operation
               completedWithTask:(nullable NSURLSessionDataTask *)task
                   processedData:(nullable NSDictionary<NSString *, id> *)processedData
                 processingError:(nullable NSError *)error;

/// Make copy of current result object with mutated data which should be stored in it.
///
/// > Note: Method can be used to create sub-events (for example one for each message or presence event).
///
/// - Parameter data: Reference on data which should be stored within new instance.
/// - Returns: Copy of receiver with modified data.
- (instancetype)copyWithMutatedData:(nullable id)data;

/// Update data stored for result object.
///
/// - Parameter data: New data which should be placed into result object.
- (void)updateData:(nullable id)data;


#pragma mark - Helpers

/// Convert result object to dictionary which can be used to print out structured data.
///
/// - Returns: Object in dictionary representation.
- (NSDictionary *)dictionaryRepresentation;

/// Convert result object to string which can be used to print out data
///
/// - Returns: Stringified object representation.
- (NSString *)stringifiedRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
