#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNResult<SuccessType> : NSObject


#pragma mark - Properties

/// Result of performed operation.
@property(nonatomic, readonly, nullable, strong) SuccessType data;

/// Operation processing error.
@property(nonatomic, readonly, nullable, strong) NSError *error;

/// Whether result represent error or nor.
@property(nonatomic, readonly, assign) BOOL isError;


#pragma mark - Initialization and configuration

/// Create operation processing result object.
///
/// An object is used to unify the two possible outcomes of operation execution: _success_ and _error_.
///
/// - Parameters:
///   - data: The outcome of a successful operation.
///   - error: An error occurred with information about what exactly went wrong during operation execution.
/// - Returns: The result instance contains information about the operation's outcome.
+ (instancetype)resultWithData:(nullable SuccessType)data error:(nullable NSError*)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
