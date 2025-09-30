#import "PNOperationResult.h"
#import "PNObjectSerializer.h"
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

#pragma mark -


@end

NS_ASSUME_NONNULL_END
